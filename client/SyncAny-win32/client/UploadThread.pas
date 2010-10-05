unit UploadThread;

interface
uses Classes, SysUtils, IdHTTP, IdSSLOpenSSL, StrUtils,IdMultipartFormData;

type
  THTTPUploadThread = class(TThread)
  private
    FileSource:String;
    UploadUrl: String;
    IdHTTP: TIdHTTP;
    isDownload:boolean;
  public
    constructor Create(Source,Dest: String; CreateSuspended:boolean);
    destructor Destroy; override;
  protected
    procedure Execute; override;
  end;

implementation

uses logger;

constructor THTTPUploadThread.Create(Source,Dest: String; CreateSuspended:boolean);
begin
  inherited Create(CreateSuspended);
  FreeOnTerminate:= True;
  Priority:=tpNormal;
  FileSource:= Dest;
  UploadUrl:= Source;
  IdHTTP:= TIdHTTP.Create(nil);
end;

destructor THTTPUploadThread.Destroy;
begin
  inherited;
end;

procedure THTTPUploadThread.Execute;
var
  idHttp: TIdHTTP;
  IdSSL: TIdSSLIOHandlerSocketOpenSSL;
  idmultipartformdatastream: TIdMultiPartFormDataStream;
begin
//  idHttp.Get('http://data.cod.ru');
  try
  Log.info('Upload file:' + FileSource);
    idmultipartformdatastream:=TIdMultiPartFormDataStream.Create;
    idmultipartformdatastream.AddFormField('action', 'file_upload');
//    idmultipartformdatastream.AddFormField('password', '');
//    idmultipartformdatastream.AddFormField('description', 'testing');
//    idmultipartformdatastream.AddFormField('agree', '1');
    idmultipartformdatastream.AddFile('sfile', FileSource, 'application/octet-stream');
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
