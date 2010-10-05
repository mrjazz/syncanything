unit AppController;

interface

uses Classes, SysUtils, StrUtils, Windows, Dialogs;

type

  TAppController = class(TThread)
  private

  public
    constructor Create();
    destructor Destroy; override;
  protected
    procedure Execute; override;
    procedure initStorges();
  end;

implementation

uses logger, Configs, SyncSoket;


constructor TAppController.Create();
begin
  inherited Create(true);
  FreeOnTerminate:= True;
  Priority:=tpNormal;
end;

destructor TAppController.Destroy;
begin
  inherited;
end;

procedure TAppController.Execute;
begin
  Log.info('TApplication.Execute');
  SyncSoketClient.connect();
  SyncSoketClient.Auth();
  if( SyncSoketClient.isUser ) then
  begin
    initStorges();
  end
  else
  begin
   Synchronize( ShowMessage('Can''t login') );
  end;
end;

procedure TAppController.initStorges();
begin
  FileStorege := TFileStorege.Create('F:\Temp');
  FileStorege.Resume;
end;

end.
