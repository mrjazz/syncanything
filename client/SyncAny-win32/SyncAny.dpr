program SyncAny;

uses
  Forms,
  main in 'main.pas' {SyncAnyForm},
  SyncSoket in 'client\SyncSoket.pas',
  logger in 'logger.pas',
  Configs in 'Configs.pas',
  FileStoregeClient in 'client\FileStoregeClient.pas',
  MonitoringThread in 'base\MonitoringThread.pas',
  CRCunit in 'Lib\CRCunit.pas',
  Hashes in 'Lib\hash\Hashes.pas',
  AppController in 'AppController.pas',
  Entity in 'base\Entity.pas',
  uJSON in 'Lib\uJSON.pas',
  Dates in 'Lib\Dates.pas',
  QueueComands in 'base\QueueComands.pas',
  ServiceServer in 'client\ServiceServer.pas',
  Crypt in 'Lib\Crypt.pas',
  MotileThreading in 'Lib\MotileThreading.pas',
  md5 in 'Lib\md5.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TSyncAnyForm, SyncAnyForm);
  Application.Run;
end.
