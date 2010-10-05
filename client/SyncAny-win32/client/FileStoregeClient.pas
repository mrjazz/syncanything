unit FileStoregeClient;

interface

uses Classes, SysUtils, StrUtils, Windows,
  CRCunit,
  Hashes,
  Dialogs,
  Dates,
  Entity,
  MonitoringThread;


type
  TFileEntity = TEntity;
  TBD = File Of TFileEntity;

  TFileStorege = class
  private
    Folder:String;
    isOpen:Boolean;
    DataFile:TBD;
    SavedHashStorege: THash;
    CurentHashStorege: THash;
    SavedFileStorege: array of TFileEntity;
    CurentFileStorege: array of TFileEntity;
    curentFileId: LongInt;
    FHook:TOnHook;
    procedure OpenFile;
    procedure LoadSavedHashStorege;
    procedure ListFileDir(Path: string);
    destructor Destroy; override;
  public
    FFileMonitor: TMonDirThread;
    DiffEnitiesSize : integer;
    DiffEnities: TArrayEntity;
    constructor Create(Source:String);
    procedure init;
    procedure CompareHashStorege();
    procedure saveFileStorege();
    procedure AddHook(f: TOnHook);
    procedure OnFolderChange(Entity: TEntity);
  protected
    function FileRecordNext():TFileEntity;
  end;



var
  NameFile:String;

implementation

uses logger, Configs;

destructor TFileStorege.Destroy;
begin
  if Assigned(FFileMonitor) then
  begin
    FFileMonitor.Terminate;
  end;
  saveFileStorege;
  inherited;
end;

procedure TFileStorege.saveFileStorege;
var
  i: integer;
  CurRec: TEntity;
begin
  if Not IsOpen then
    OpenFile;
  for i := Low(SavedFileStorege) to High(SavedFileStorege) do
  begin
    CurRec:= SavedFileStorege[i];
    Write(DataFile,CurRec);
  end;
  CloseFile(DataFile);
end;

procedure TFileStorege.AddHook(f: TOnHook);
begin
  FHook := f;
end;
procedure TFileStorege.OpenFile;
begin
  AssignFile( DataFile,NameFile);
  If not FileExists (NameFile) then
  begin
    Rewrite(DataFile);
  end
  else
  begin
    ReSet(DataFile);
    Seek(DataFile,FileSize(DataFile));
  end;
  IsOpen:=True;
End;

constructor TFileStorege.Create(Source:String);
begin
  Folder := Source;
  NameFile := config.Additional.ApplicationPath + 'Storege.db';
end;


procedure TFileStorege.init;
var
  hook : TOnFolderChange;
begin
  Log.info('TFileStorege.Execute');
  curentFileId := 0;
  SavedHashStorege := THash.Create;
  CurentHashStorege := THash.Create;
  LoadSavedHashStorege();
  ListFileDir(Folder);
  DiffEnitiesSize := 0;
  CompareHashStorege();
  FHook(DiffEnities);
  hook:= OnFolderChange;

  FFileMonitor := TMonDirThread.Create(config.Additional.folder,hook);
  FFileMonitor.Resume;
end;

procedure TFileStorege.OnFolderChange(Entity: TEntity);
var
  a: TArrayEntity;
  tmp:TEntity;
  key:string;
  p:^TEntity;
begin
  SetLength(a, 1);
  if(Entity.removed) then
  begin
    key := RightStr(Entity.path,(Length(Entity.path)- 6));
    if(CurentHashStorege.KeyExists(key)) then
    begin
      p := CurentHashStorege.GetObject(key);
      tmp := p^;
      Entity.folder := tmp.folder;
    end;
  end;
  a[0] := Entity;
  FHook(a);
end;
procedure TFileStorege.LoadSavedHashStorege();
var
  CurRec:TFileEntity;
  i: integer;
begin
  OpenFile;
  CurRec := FileRecordNext();
  i:= 0;
  while True do
  begin
    CurRec := FileRecordNext();
    if(CurRec.path = '') then
      Break;
    SetLength(SavedFileStorege, (i+1));
    SavedFileStorege[curentFileId] := CurRec;
    SavedHashStorege.SetObject(CurRec.path, @SavedFileStorege[curentFileId]);
  end;
end;

function TFileStorege.FileRecordNext():TFileEntity;
var
  CurRec:TFileEntity;
begin
  if Not isOpen Then
    OpenFile;
  If Not Eof(DataFile) Then
  Begin
    Read(DataFile,CurRec);
  End
  Else
    CurRec.path := '';
  Result := CurRec;
End;

procedure TFileStorege.ListFileDir(Path: string);
var
  FindHandle : THandle;
  FindData : TWin32FindData;
  b: boolean;
  s: string;
  curentFile:TFileEntity;

  LTime : TFileTime;
  Systemtime : TSystemtime;
begin
  Log.info('Folder:' + Path);
  FindData.dwFileAttributes := FILE_ATTRIBUTE_NORMAL;
{
    *  FILE_ATTRIBUTE_ARCHIVE - архивный файл.
    * FILE_ATTRIBUTE_COMPRESSED - сжатый файл или папка.
    * FILE_ATTRIBUTE_HIDDEN - скрытый файл.
    * FILE_ATTRIBUTE_NORMAL - обычный файл.
    * FILE_ATTRIBUTE_OFFLINE - данные файла недоступны. Указывает, что данные файлы были физически перемещены.
    * FILE_ATTRIBUTE_READONLY - файл только для чтения.
    * FILE_ATTRIBUTE_SYSTEM - системный файл.
    * FILE_ATTRIBUTE_TEMPORARY - временный файл.
    * FILE_ATTRIBUTE_DIRECTORY - директория
 }
  FindHandle := FindFirstFile(PWideChar(WideString(Path + '\*.*')), FindData);
  if FindHandle <> INVALID_HANDLE_VALUE then
  begin
     b := true;
     while b do
     begin
        s := FindData.cFileName;
        if (s<>'..') and (s<>'.') then
        begin
          Log.info(s);
          if (FindData.dwFileAttributes and faDirectory = faDirectory)  then
          begin
           ListFileDir(Path+ '\' + s);
          end
          else
          begin
            curentFile.path := 'files:' + copy( Path+ '\' + s, (Length(Folder) + 2), Length(Path+ '\' + s) - Length(Folder) -1);
            curentFile.size := FindData.nFileSizeHigh;
            FileTimeToLocalFileTime(FindData.ftLastWriteTime, LTime);
            FileTimeToSystemTime( LTime, SystemTime );

            curentFile.modified := ISO8601_DateTimeToStr( LocalToUTC(SystemTimeToDateTime ( SystemTime)));
            curentFile.folder := false;

            Log.info(curentFile.modified);

            curentFile.Hash     := IntToHex(GetFileCRC(Path+ '\' + s), 8);
            SetLength(CurentFileStorege, (curentFileId+1));
            CurentFileStorege[curentFileId] := curentFile;
            //@todo may be need check '/'
            Log.info('file:' + Path+ '\' + s + ' key:' + curentFile.path + '  id ' + intToStr(curentFileId) );
            CurentHashStorege.SetObject(path, @CurentFileStorege[curentFileId]);
            if (Not SavedHashStorege.KeyExists(path)) then
            begin
              inc(DiffEnitiesSize);
              SetLength(DiffEnities, DiffEnitiesSize);
              curentFile.removed := false;
              DiffEnities[(DiffEnitiesSize - 1) ] := curentFile;
              //@todo write else
            end;
            inc(curentFileId)
          end;
       end;
       b := FindNextFile(FindHandle, FindData);
     end;
  end;
  FindClose(FindHandle);
end;



procedure TFileStorege.CompareHashStorege();
var
  curentFile,SavedFile:TFileEntity;
  p:  ^TFileEntity;
  i : integer;
  key: string;

begin
  if(SavedHashStorege.Keys.Count > 0) then
  for i := 0 to SavedHashStorege.Keys.Count - 1 do
  begin
    key := SavedHashStorege.Keys.Strings[i];
    p := SavedHashStorege.GetObject(key);
    SavedFile := p^;
    if( CurentHashStorege.KeyExists(key) ) then
    begin
      p := CurentHashStorege.GetObject(key);
      curentFile := p^;
      if (curentFile.Hash <> SavedFile.Hash) then
      begin
        inc(DiffEnitiesSize);
        SetLength(DiffEnities, DiffEnitiesSize);
        DiffEnities[(DiffEnitiesSize - 1) ] := curentFile;
        DiffEnities[(DiffEnitiesSize - 1) ].removed := false;
      end;
    end
    else
    begin;
      inc(DiffEnitiesSize);
      SetLength(DiffEnities, DiffEnitiesSize);
      DiffEnities[(DiffEnitiesSize - 1) ] := curentFile;
      DiffEnities[(DiffEnitiesSize - 1) ].removed := true;
      DiffEnities[(DiffEnitiesSize - 1) ].modified :=
        ISO8601_DateTimeToStr( LocalToUTC(SysUtils.Date));
    end;
  end;
end;

end.
