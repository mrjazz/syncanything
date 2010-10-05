unit MonitoringThread;

interface

uses
  Classes, Windows, SysUtils, SyncObjs, Entity, CRCunit, Dates,
  Dialogs;

type
  PFileNotifyInformation = ^TFileNotifyInformation;

  TFileNotifyInformation = record
    NextEntryOffset: DWORD;
    Action: DWORD;
    FileNameLength: DWORD;
    FileName: array [0 .. 0] of WideChar;
  end;

const
  FILE_LIST_DIRECTORY = $0001;

type
  TOnFolderChange = procedure(Entity: TEntity) of object;

  TMonDirThread = class(TThread)
  private
    FPath: String;
    FNotificationBuffer: array [0 .. 4096] of Byte;
    FCompletionPort: THandle;
    FDirectoryHandle: THandle;
    CriticalSection: TCriticalSection;
    OnFolderChange: TOnFolderChange;
    FOldFileName    : string;
  protected
    procedure HandleEvent;
    procedure Execute; override;
    procedure ThreadStart;
    procedure ThreadStop;
    procedure add(fname: String);
    procedure removed(fname: String);
    procedure modified(fname: String);
    procedure renamedNew(fname: String);
    function GetFileBaseInfo(fname: String):TEntity;
  public
    constructor Create(aPath: String; f: TOnFolderChange);
  end;

implementation

uses logger;

constructor TMonDirThread.Create(aPath: String; f: TOnFolderChange);
begin
  inherited Create(True);
  FreeOnTerminate := True;
  FPath := aPath;
  Self.Priority := tpHighest;
  CriticalSection := TCriticalSection.Create;
  OnFolderChange := f;
  FOldFileName:=EmptyStr;
end;

procedure TMonDirThread.HandleEvent;
var
  FileOpNotification: PFileNotifyInformation;
  Offset: Longint;
  str: String;
begin

  Pointer(FileOpNotification) := @FNotificationBuffer[0];
  if FileOpNotification <> nil then
  repeat
    Offset := FileOpNotification^.NextEntryOffset;

    str := Trim(WideCharToString(@(FileOpNotification^.FileName)));
    if (str <> '') then
    begin
      case FileOpNotification^.Action of
        FILE_ACTION_ADDED:
          add(str);
        FILE_ACTION_REMOVED:
          removed(str);
        FILE_ACTION_MODIFIED:
          modified(str);
        FILE_ACTION_RENAMED_OLD_NAME:
          FOldFileName := str;
        FILE_ACTION_RENAMED_NEW_NAME:
          renamedNew(str);
      end;
    end;

    PChar(FileOpNotification) := PChar(FileOpNotification) + Offset;
  until Offset = 0;
end;

procedure TMonDirThread.add(fname: String);
var
  curent: TEntity;
begin
  Log.info('add ' + fname);
  curent := GetFileBaseInfo(fname);
  curent.removed := false;
  curent.hash := IntToHex(GetFileCRC(FPath + '\' + fname), 8);
  OnFolderChange(curent);
end;

procedure TMonDirThread.removed(fname: String);
var
  curent: TEntity;
begin
  Log.info('removed ' + fname);
  curent.path := 'file:' + fname;
  curent.modified := ISO8601_DateTimeToStr( LocalToUTC( SysUtils.Date ));
  curent.size := 0;
  curent.removed := false;
  curent.folder := false;
  curent.hash := '0';
  OnFolderChange(curent);
end;

procedure TMonDirThread.modified(fname: String);
var
  curent: TEntity;
begin
  Log.info('modified ' + fname);
  curent := GetFileBaseInfo(fname);
  curent.removed := false;
  curent.hash := IntToHex(GetFileCRC(FPath + '\' + fname), 8);
  OnFolderChange(curent);
end;

procedure TMonDirThread.renamedNew(fname: String);
var
  curent: TEntity;
begin
  Log.info('renamed ' + fname);
  curent := GetFileBaseInfo(fname);
  curent.oldname := FPath + '\' + FOldFileName;
  curent.removed := false;
  curent.hash := IntToHex(GetFileCRC(FPath + '\' + fname), 8);
  OnFolderChange(curent);
end;

function TMonDirThread.GetFileBaseInfo(fname: String):TEntity;
var
  f : TSearchRec;
  ret: integer;
  res :TEntity;
  LTime : TFileTime;
  Systemtime : TSystemtime;
begin
ret := FindFirst( FPath + '\' + fname, faReadOnly + faHidden+ faSysFile +
  faVolumeID + faDirectory + faArchive + faAnyFile, f );
if ret <> 0 then
  SysUtils.RaiseLastWin32Error;
  res.path := 'file:' + fname;
  FileTimeToLocalFileTime( f.FindData.ftLastWriteTime, LTime);
  FileTimeToSystemTime( LTime, SystemTime );
  res.modified :=ISO8601_DateTimeToStr( LocalToUTC(SystemTimeToDateTime ( SystemTime)));

  res.size := f.Size;
  Result := res;
end;

procedure TMonDirThread.ThreadStart;
begin ;
end;

procedure TMonDirThread.ThreadStop;
begin
  PostQueuedCompletionStatus(FCompletionPort, 0, 0, nil);
  CloseHandle(FDirectoryHandle);
  FDirectoryHandle:=0;
  CloseHandle(FCompletionPort);
  FCompletionPort:=0;
end;

procedure TMonDirThread.Execute;
var
  numBytes: DWORD;
  cbOffset: DWORD;
  CompletionKey: DWORD;
  FBytesWritten: DWORD;
  FNotifyFilter: DWORD;
  FOverlapped: TOverlapped;
  FPOverlapped: POverlapped;
begin
  FCompletionPort := 0;
  FDirectoryHandle := 0;
  FPOverlapped := @FOverlapped;
  ZeroMemory(@FOverlapped, SizeOf(FOverlapped));

  FDirectoryHandle := CreateFile(PChar(FPath), FILE_LIST_DIRECTORY,
    FILE_SHARE_READ or FILE_SHARE_WRITE or FILE_SHARE_DELETE, nil,
    OPEN_EXISTING, FILE_FLAG_BACKUP_SEMANTICS or FILE_FLAG_OVERLAPPED, 0);
  if Win32Check(FDirectoryHandle <> INVALID_HANDLE_VALUE) then
  begin
    Synchronize(ThreadStart);
  end
  else
  begin
    beep;
    FDirectoryHandle := 0;
    // del
    ShowMessage('1 ' + SysErrorMessage(GetLastError));
    exit;
  end;

  FNotifyFilter := FILE_NOTIFY_CHANGE_FILE_NAME;
  FNotifyFilter := FNotifyFilter or FILE_NOTIFY_CHANGE_DIR_NAME;
  FNotifyFilter := FNotifyFilter or FILE_NOTIFY_CHANGE_ATTRIBUTES;
  FNotifyFilter := FNotifyFilter or FILE_NOTIFY_CHANGE_SIZE;
  FNotifyFilter := FNotifyFilter or FILE_NOTIFY_CHANGE_LAST_WRITE;
  FNotifyFilter := FNotifyFilter or FILE_NOTIFY_CHANGE_LAST_ACCESS;
  FNotifyFilter := FNotifyFilter or FILE_NOTIFY_CHANGE_CREATION;
  FNotifyFilter := FNotifyFilter or FILE_NOTIFY_CHANGE_SECURITY;

  FCompletionPort := CreateIoCompletionPort(FDirectoryHandle, 0,
    Longint(Pointer(Self)), 0);
  ZeroMemory(@FNotificationBuffer, SizeOf(FNotificationBuffer));
  FBytesWritten := 0;
  if not ReadDirectoryChanges(FDirectoryHandle, @FNotificationBuffer,
    SizeOf(FNotificationBuffer), True,
    FNotifyFilter, @FBytesWritten, @FOverlapped, nil) then
  begin
    CloseHandle(FDirectoryHandle);
    FDirectoryHandle := 0;
    CloseHandle(FCompletionPort);
    FCompletionPort := 0;
    //@todo del
    ShowMessage('2 ' + SysErrorMessage(GetLastError));
    exit;
  end;
  try
    while not Terminated do
    begin
      GetQueuedCompletionStatus(FCompletionPort, numBytes, CompletionKey,
        FPOverlapped, INFINITE);
      if CompletionKey <> 0 then
      begin
        Synchronize(HandleEvent);
        FBytesWritten := 0;
        ZeroMemory(@FNotificationBuffer, SizeOf(FNotificationBuffer));
        ReadDirectoryChanges(FDirectoryHandle, @FNotificationBuffer,
          SizeOf(FNotificationBuffer), True,
          FNotifyFilter, @FBytesWritten, @FOverlapped, nil);
      end
      else
        Terminate;
    end;
  finally
    CloseHandle(FDirectoryHandle);
    FDirectoryHandle := 0;
    CloseHandle(FCompletionPort);
    FCompletionPort := 0;
  end;
  Synchronize(ThreadStop);
end;

end.

