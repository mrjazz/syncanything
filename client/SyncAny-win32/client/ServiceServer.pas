unit ServiceServer;


interface

uses
  Classes, SysUtils, IdHTTP, IdSSLOpenSSL, Entity, IdMultipartFormData, StrUtils ;

type
  TServiceServer = object
    host: String;
    port: String;
  private
    { Private declarations }
  public
    procedure init();
    procedure upload(Comand:TComandEntity);
    procedure download(Comand:TComandEntity);
    procedure delete(Comand:TComandEntity);
    { Public declarations }
  end;

var
  ServiceClient: TServiceServer;

implementation

uses logger, Configs;

procedure  TServiceServer.init();
begin
  Log.info('SyncSoketClient::connect()');
  Log.info('host' + config.FileServer.host + ':' + IntToStr(config.FileServer.port));
  host := 'https://' + config.FileServer.host;

  port := intToStr(config.FileServer.port);


end;

procedure TServiceServer.delete(Comand:TComandEntity);
var
  idHttp: TIdHTTP;
  Stream: TFileStream;
  IdSSL: TIdSSLIOHandlerSocketOpenSSL;
  Url: String;
  Repdest: String;
begin
  Repdest := config.Additional.folder + '/' + RightStr(Comand.path,(Length(Comand.path)- 6));
  if (DeleteFile(Repdest)) then
  begin
    Url := host + ':' + port + '/delete/' + Comand.ticket;
    try
      idHttp := TIdHTTP.Create(nil);
      IdSSL := TIdSSLIOHandlerSocketOpenSSL.Create;
      try
        IdHTTP.IOHandler := IdSSL;
        try
          idHttp.Get(Url, Stream);
        except on E:Exception do
          Log.warn('Error send ticket delete file: ' + E.ClassName + ' Message: ' + E.Message);
        end;
      finally
        idHttp.Free;
      end;
    finally
      Stream.Free;
    end;
  end;
end;

procedure TServiceServer.download(Comand:TComandEntity);
var
  idHttp: TIdHTTP;
  Stream: TFileStream;
  IdSSL: TIdSSLIOHandlerSocketOpenSSL;
  Url,Repdest: String;
begin
exit;
  Repdest := config.Additional.folder + '/' + RightStr(Comand.path,(Length(Comand.path)- 6));
  ForceDirectories(ExtractFilePath(Repdest));
  Stream := TFileStream.Create(Repdest, fmCreate or fmShareExclusive);
  Url := host + ':' + port + '/download/' + Comand.ticket;
  try
    idHttp := TIdHTTP.Create(nil);
    IdSSL := TIdSSLIOHandlerSocketOpenSSL.Create;
    try
      IdHTTP.IOHandler := IdSSL;
      try
        idHttp.Get(Url, Stream);
      except on E:Exception do
        Log.warn('Error download file: ' + E.ClassName + ' Message: ' + E.Message);
      end;
    finally
      idHttp.Free;
    end;
  finally
    Stream.Free;
  end;
end;
procedure TServiceServer.upload(Comand:TComandEntity);
var
  UploadUrl,FileSource : string;
  idHttp: TIdHTTP;
  IdSSL: TIdSSLIOHandlerSocketOpenSSL;
  idmultipartformdatastream: TIdMultiPartFormDataStream;
begin
  IdHTTP:= TIdHTTP.Create(nil);
  Log.info('Upload file:' + Comand.path);
  UploadUrl := host + ':' + '/upload/' + Comand.ticket;
  FileSource := config.Additional.folder + '/' + RightStr(Comand.path,(Length(Comand.path)- 6));
  Log.info('Upload file real:' + FileSource);
  try
    idmultipartformdatastream:=TIdMultiPartFormDataStream.Create;
//    idmultipartformdatastream.AddFormField('ticket', Comand.ticket );

    idmultipartformdatastream.AddFile('entity', FileSource, 'application/octet-stream');
    try
      idHttp := TIdHTTP.Create(nil);
      IdSSL := TIdSSLIOHandlerSocketOpenSSL.Create;
      IdHTTP.IOHandler := IdSSL;
      try
        IdHTTP.Post(UploadUrl, idmultipartformdatastream);
      except on E:Exception do
        begin
          Log.warn('Error upload file: ' + E.ClassName + ' Message: ' + E.Message);
          if IdHTTP.ResponseCode div 100<>3 then raise;
          Log.warn(UploadUrl + ' '+IdHTTP.Response.RawHeaders.Values['LOCATION']);
        end;
      end;
    finally
      idHttp.Free;
    end;
  finally
    idmultipartformdatastream.Free;
  end;
end;

end.
