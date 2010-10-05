unit QueueComands;

interface
uses
  Classes, Entity, SyncObjs, Forms, windows, StrUtils;


type

  TQueueComands = class(TThread)
  private

  public
    QueueComandsList: TArrayComandEntity;
    LastId: LongInt;
    constructor Create();
    destructor Destroy; override;
    procedure processNext;
    procedure DeleteArrayIndex(var X: TArrayComandEntity; Index: Integer);
    procedure add(ace : TArrayComandEntity ); overload;
    procedure add(ComandEntity : TComandEntity ); overload;
  protected
    procedure Execute; override;
  end;

var
  CriticalSection: TCriticalSection;


implementation

uses logger, ServiceServer;

procedure TQueueComands.DeleteArrayIndex(var X: TArrayComandEntity; Index: Integer);
begin
  if Index > High(X) then
    Exit;
  if Index < Low(X) then
    Exit;
  if Index = High(X) then
  begin
    SetLength(X, Length(X) - 1);
    Exit;
  end;
  Finalize(X[Index]);
  System.Move(X[Index + 1], X[Index],
  (Length(X) - Index - 1) * SizeOf(string) + 1);
  SetLength(X, Length(X) - 1);
end;



constructor TQueueComands.Create();
begin
  inherited Create(true);
  FreeOnTerminate:= True;
  Priority:=tpNormal;
end;

destructor TQueueComands.Destroy;
begin
  Log.info('TQueueComands.Destroy');
  inherited;
end;

procedure TQueueComands.Execute;
begin
  Log.info('TQueueComands.Execute;');
  LastId:=0;
  CriticalSection:=TCriticalSection.Create;
  while not (Terminated or Application.Terminated) do
  begin
    if Length(QueueComandsList) > 0 then
    begin
      processNext();
    end
    else
    begin
      Sleep(500);
    end;
  end;

end;
procedure TQueueComands.processNext();
const
  cmdUpload     = 'upload';
  cmdDownload    = 'download';
  cmdDelete = 'delete';
  cmdArray : Array [ 0..2 ] of String = ( cmdUpload, cmdDownload, cmdDelete );
var
  curent: TComandEntity;
  action: string;
begin
  Log.info('processNext');
  curent := QueueComandsList[Low(QueueComandsList)];
  DeleteArrayIndex(QueueComandsList, Low(QueueComandsList));
  case AnsiIndexStr(curent.action, cmdArray ) of
    0: ServiceClient.upload(curent);
    1: ServiceClient.download(curent);
    2: ServiceClient.delete(curent);
  end;

end;

procedure TQueueComands.add(ace : TArrayComandEntity );
var
  i:integer;
begin
  Log.info('TQueueComands.add(ace : TArrayComandEntity )');
  for i:=0 to  Length(ace) do
  begin
     add(ace[i]);
  end;
end;
procedure TQueueComands.add(ComandEntity : TComandEntity );
begin
  CriticalSection.Enter;
  Log.info('TQueueComands.add');
  SetLength(QueueComandsList, (LastId+1));
  QueueComandsList[LastId] := ComandEntity;
  Inc(LastId);
  CriticalSection.Leave;
end;


end.
