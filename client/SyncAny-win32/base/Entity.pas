unit Entity;

interface

uses uJSON;

type
  TEntity = record
    path:String[255];
    oldname:String[255];
    modified:String[255];
    size:LongInt;
    removed:Boolean;
    hash:String[255];
    folder:Boolean;
    public
      function toJson():UTF8String;
      function getJsonObj():TJSONObject;
  end;
  TArrayEntity = array of TEntity;


  TComandEntity = record
    path:String[255];
    modified:String[255];
    size:LongInt;
    hash:String[255];
    action:String[255];
    ticket:String[255];
  end;
  TArrayComandEntity  = array of TComandEntity;

  TOnHook = procedure(aEntity: TArrayEntity)of object;
  TOnReceive = procedure(json: Utf8String) of object;


implementation

function TEntity.toJson():UTF8String;
var
  jobj: TJSONObject;
begin
   jobj := TJSONObject.create;
    jobj.put('path', path);
    jobj.put('modified', modified);
    jobj.put('removed', removed);
    jobj.put('hash', hash);
    jobj.put('oldname', oldname);
    jobj.put('folder', folder);
    Result := jobj.toString;
end;

function TEntity.getJsonObj():TJSONObject;
var
  jobj: TJSONObject;
begin
   jobj := TJSONObject.create;
    jobj.put('path', path);
    jobj.put('modified', modified);
    jobj.put('removed', removed);
    jobj.put('hash', hash);
    jobj.put('oldname', oldname);
    jobj.put('folder', folder);
    Result := jobj;
end;




end.
