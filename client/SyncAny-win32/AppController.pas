unit AppController;

interface

uses
  FileStoregeClient,Entity, uJSON,
  Classes, SysUtils, StrUtils, Windows, Dialogs;

type
  TAppController = class(TThread)
    isUser: Boolean;
    TerminatedLogin: Boolean;
  private

  public
    constructor Create();
    destructor Destroy; override;
    procedure onHooks(aEntity: TArrayEntity);
    procedure onReceive(line: Utf8String);
  protected
    procedure Execute; override;
    procedure initStorges();
    procedure ErrorLogin;
  end;

var
  FileStorege: TFileStorege;
implementation

uses logger, Configs, SyncSoket, QueueComands, ServiceServer;
var
  QueueStec :TQueueComands;

constructor TAppController.Create();
begin
  inherited Create(true);
  FreeOnTerminate:= True;
  Priority:=tpNormal;
end;

destructor TAppController.Destroy;
begin
  Log.info('TAppController.Destroy;');
  QueueStec.Terminate;
  FileStorege.Destroy;
  inherited;
end;

procedure TAppController.Execute;
begin
  Log.info('TApplication.Execute');
  QueueStec := TQueueComands.Create;
  QueueStec.Resume;
  SyncSoketClient.ReceiveHook := onReceive;
  SyncSoketClient.connect();
  TerminatedLogin := false;
  SyncSoketClient.Auth();
  while Not TerminatedLogin do
    sleep(500);
  TerminatedLogin := false;
  Log.info('initStorges');

  if( isUser ) then
  begin
    initStorges();
     while not (Terminated ) do
      sleep(1000);
  end
  else
  begin
   Synchronize( ErrorLogin );
  end;
end;

procedure TAppController.ErrorLogin;
begin
  ShowMessage('Can''t login')
end;

procedure TAppController.initStorges();
begin
  FileStorege := TFileStorege.Create(config.Additional.folder);
  FileStorege.AddHook(onHooks);
  FileStorege.init;
  ServiceClient.init();
end;

procedure TAppController.onHooks(aEntity: TArrayEntity);
var
  ace : TArrayComandEntity;
begin
   SyncSoketClient.SyncEntities(aEntity);
end;

procedure TAppController.onReceive(line: Utf8String);
const
  cmdArray : Array [ 0..1 ] of String = ( 'login', 'syncEntities' );
var
  jobj: TJSONObject;
  jarray: TJSONArray;
  curent: TComandEntity;
  i: Integer;
begin
  Log.info('onReceive:' + line);
  jobj := TJSONObject.Create(line);
  if jobj.has('command') then
  begin
    case AnsiIndexStr(jobj.getString('command'), cmdArray ) of
      0: begin
        TerminatedLogin:= true;
        Log.info('TerminatedLogin ' + BoolToStr(TerminatedLogin) );
        if jobj.getString('session') <> '' then
          isUser := true
        else
          isUser := false
      end;
      1:begin
        jarray := jobj.getJSONArray('entities');
        if jarray.length > 0 then
        for i := 0 to jarray.length - 1 do
        begin
          jobj := jarray.getJSONObject(i);
          curent.path := jobj.getString('path');
          curent.modified := jobj.getString('modified');
          curent.size := jobj.getInt('size');
          curent.hash := jobj.getString('hash');
          curent.action := jobj.getString('action');
          curent.ticket := jobj.getString('ticket');
          QueueStec.add(curent);
        end;
      end;
    end;

  end;
end;

end.
