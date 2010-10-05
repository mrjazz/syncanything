unit SyncSoket;

interface

uses
  IdIOHandler, IdIOHandlerSocket, IdSSLOpenSSL, IdBaseComponent,
  IdComponent, IdTCPConnection, IdTCPClient, IdIOHandlerStack,
  IdSSL, SysUtils, IdGlobal, Registry, Windows, IdException,
  Dialogs, Entity, uJSON, MotileThreading, forms, StrUtils;

type

  TSyncSoketClient = object
    IdTCPClient: TIdTCPClient;
    IdSSLIOHandlerSocketOpenSSL: TIdSSLIOHandlerSocketOpenSSL;
    host: String;
    port: Integer;
    ReceiveHook :TOnReceive;
  private

    { Private declarations }
  public
    procedure connect();
    procedure reconnect();
    procedure SyncEntities(AEntity: TArrayEntity);
    procedure OnConnectedTCPClient(Sender: TObject);
    procedure OnDisconnectedTCPClient(Sender: TObject);
    procedure ProcessResponseData();
    procedure Auth();

    procedure send(line: Utf8String);
    function receive(): Utf8String;
    { Public declarations }
  end;

var
  SyncSoketClient: TSyncSoketClient;
  SerialNumber:longbool;
  VendorId:ShortString;

implementation

uses logger, Configs;

function GetWindowsVersion: string;
var
  VerInfo: TOsversionInfo;
  PlatformId, VersionNumber: string;
  Reg: TRegistry;
begin
  VerInfo.dwOSVersionInfoSize := SizeOf(VerInfo);
  GetVersionEx(VerInfo);
  // Detect platform
  Reg := TRegistry.Create;
  Reg.RootKey := HKEY_LOCAL_MACHINE;
  case VerInfo.dwPlatformId of
    VER_PLATFORM_WIN32s:
      begin
        PlatformId := 'Windows 3.1';
      end;
    VER_PLATFORM_WIN32_WINDOWS:
      begin
        Reg.OpenKey('\SOFTWARE\Microsoft\Windows\CurrentVersion', False);
        PlatformId := Reg.ReadString('ProductName');
        VersionNumber := Reg.ReadString('VersionNumber');
      end;
    VER_PLATFORM_WIN32_NT:
      begin
        Reg.OpenKey('\SOFTWARE\Microsoft\Windows NT\CurrentVersion', False);
        PlatformId := Reg.ReadString('ProductName');
        VersionNumber := Reg.ReadString('CurrentVersion');
      end;
  end;
  Reg.Free;
  Result := PlatformId + ' (version ' + VersionNumber + ')';
end;

procedure TSyncSoketClient.reconnect();
begin
  if ((IdTCPClient <> nil) and IdTCPClient.Connected) then
  begin
    IdTCPClient.Disconnect;
    connect();
    Auth();
  end;
end;

procedure TSyncSoketClient.OnDisconnectedTCPClient(Sender: TObject);
begin
//@todo write
ShowMessage('Disconnected');
end;

procedure TSyncSoketClient.OnConnectedTCPClient(Sender: TObject);
var
  NewData :string;
begin
  TMotileThreading.ExecuteAndCall  (
    procedure
    begin
      while SyncSoketClient.IdTCPClient.Connected and not Application.Terminated do
      begin
        if SyncSoketClient.IdTCPClient.IOHandler.CheckForDataOnSource(100) then
        begin
          SyncSoketClient.ProcessResponseData;
        end;
        sleep(100);
      end;

    end,
    procedure
    begin

    end, true
  );
end;

procedure TSyncSoketClient.connect();
begin

  Log.info('SyncSoketClient::connect()');
  Log.info('host' + config.SyncServer.host + ':' + IntToStr
        (config.SyncServer.port));
  IdSSLIOHandlerSocketOpenSSL := TIdSSLIOHandlerSocketOpenSSL.Create(nil);
  with (IdSSLIOHandlerSocketOpenSSL) do
  begin
    Destination := ':' + IntToStr(config.SyncServer.port);
    MaxLineAction := maException;
    port := config.SyncServer.port;
    DefaultPort := 0;
    SSLOptions.Method := sslvTLSv1;
    SSLOptions.Mode := sslmUnassigned;
    SSLOptions.VerifyMode := [];
    SSLOptions.VerifyDepth := 0;
  end;
  IdTCPClient := TIdTCPClient.Create(nil);
  with (IdTCPClient) do
  begin
    IOHandler := IdSSLIOHandlerSocketOpenSSL;
    ConnectTimeout := 0;
    ReadTimeout := 0;
    host := config.SyncServer.host;
    port := config.SyncServer.port;
    OnConnected :=  OnConnectedTCPClient;
    OnDisconnected := OnDisconnectedTCPClient;
  end;
  try
    IdTCPClient.connect;
  except
    on E: EIdException do
      Log.warn('can not conect ' + E.ClassName + ' Message: ' + E.Message);
  end;
end;


procedure TSyncSoketClient.Auth();
var
  jobj: TJSONObject;
  line: Utf8String;
  
begin
  Log.info('TSyncSoketClient.Auth');
  if (IdTCPClient.Connected = False) then
    exit;

  if (Length(config.SyncServer.UserName) < 5) then
  begin
    ShowMessage('exit');
    exit;
  end;
  jobj := TJSONObject.Create;
  jobj.put('call', 'login');
  jobj.put('email', config.SyncServer.UserName);
  jobj.put('password', config.SyncServer.Password);
  jobj.put('instance', 'WinDesctop ' + GetWindowsVersion);
  jobj.put('client_hash', config.SyncServer.guid);
  line := jobj.toString;
  try
    send(line);
  finally
    //@todo write
  end;
end;

procedure TSyncSoketClient.send(line: Utf8String);
begin
  if (IdTCPClient.Connected = False) then
    exit;
  Log.info(' ');
  Log.info('json:' + line);
  try
    IdTCPClient.IOHandler.writeln(line);
  except
    on E: Exception do
    begin
      Log.warn('can not send ' + E.ClassName + ' Message: ' + E.Message);
      Raise ;
    end;

  end;
end;
procedure TSyncSoketClient.ProcessResponseData();
var
  line:Utf8String;
begin
  Log.info('ProcessResponseData');
  if IdTCPClient.IOHandler.InputBufferIsEmpty then
    exit;

  line := receive();
  Log.info(line);
  if line = '' then
    exit;
  ReceiveHook(line);
end;
function TSyncSoketClient.receive(): Utf8String;
var
  line: Utf8String;
  WasSplit: Boolean;
begin
  if (IdTCPClient.Connected = False) then
    exit;
  try
    line := '';
    repeat
      line := line + IdTCPClient.IOHandler.ReadLnSplit(WasSplit,EOL);
    until not WasSplit;
    Log.info('json:' + line);
  except
    on E: Exception do
    begin
      Log.warn('can not receive ' + E.ClassName + ' Message: ' + E.Message);
      Raise ;
    end;
  end;
  Result := line;
end;

procedure TSyncSoketClient.SyncEntities(AEntity: TArrayEntity);
var
  line: Utf8String;
  jobj: TJSONObject;
  jarray: TJSONArray;
  i:Integer;
begin
  Log.info('SyncEntities');
  jobj := TJSONObject.Create;
  jarray := TJSONArray.Create;
  for i := 0 to Length(AEntity) - 1 do
  begin
    jarray.put(AEntity[i].getJsonObj);
  end;

  jobj.put('call', 'syncEntities');
  jobj.put('entities', jarray);

  line := jobj.toString;
  try
    send(line);
  except
    on E: Exception do
      Log.warn('SyncEntities send. Message: ' + E.Message);
  end;
end;

end.
