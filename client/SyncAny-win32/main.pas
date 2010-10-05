unit main;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, Menus, ComCtrls, Buttons, Mask, Registry,
  ShlObj,ShellApi,AppController;

type
  TSyncAnyForm = class(TForm)
    TrayIcon: TTrayIcon;
    SynchAdrBook: TCheckBox;
    TrayMenu: TPopupMenu;
    WebSite: TMenuItem;
    exit: TMenuItem;
    Settings: TMenuItem;
    N1: TMenuItem;
    openFolder: TMenuItem;
    SaveBtn: TButton;
    lbEvents: TListBox;
    ButtonPanel: TPanel;
    SaveButtonPanel: TPanel;
    GeneralPanel: TPanel;
    GeneralImage: TImage;
    GeneralLabel: TLabel;
    NetworkPanel: TPanel;
    NetworkLabel: TLabel;
    NetworkImage: TImage;
    ProxyBox: TGroupBox;
    GeneralTab: TPanel;
    NetworkTab: TPanel;
    Account: TGroupBox;
    UserName: TEdit;
    UserNambeLb: TLabel;
    Password: TMaskEdit;
    PasswordLb: TLabel;
    GroupBox2: TGroupBox;
    autoRun: TCheckBox;
    DirListBox: TGroupBox;
    ProxyOff: TRadioButton;
    ProxyOn: TRadioButton;
    ServerLb: TLabel;
    ProxyServer: TEdit;
    PortLb: TLabel;
    ProxyPort: TEdit;
    ProxyRequiredPwd: TCheckBox;
    ProxyUserNameLb: TLabel;
    ProxyPasswordLb: TLabel;
    ProxyUserName: TEdit;
    ProxyPassword: TMaskEdit;
    CancelBtn: TButton;
    SyncFolder: TEdit;
    AddFolder: TButton;
    procedure FormCreate(Sender: TObject);
    procedure TrayIconDblClick(Sender: TObject);
    Procedure ControlWindow(var Msg:TMessage); message WM_SYSCOMMAND;
    procedure exitClick(Sender: TObject);
    procedure SettingsClick(Sender: TObject);
    procedure FormMainOnAddFile(const FileName: string);
    procedure GeneralPanelClick(Sender: TObject);
    procedure NetworkPanelClick(Sender: TObject);

    procedure UpdateButton(index: integer);
    procedure AddFolderClick(Sender: TObject);
    procedure ProxyOnClick(Sender: TObject);
    procedure ProxyOffClick(Sender: TObject);
    procedure ProxyRequiredPwdClick(Sender: TObject);
    procedure SaveBtnClick(Sender: TObject);
    procedure AutorunProgram(Flag:boolean; NameParam, Path:String);
    procedure openFolderClick(Sender: TObject);
    procedure WebSiteClick(Sender: TObject);
    procedure initControlls();
    procedure CancelBtnClick(Sender: TObject);
    procedure onClose;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  SyncAnyForm: TSyncAnyForm;
  FTerminateEvent: Cardinal;
  app:TAppController;


implementation

uses SyncSoket, logger, Configs,  MonitoringThread;

{$R *.dfm}


procedure TSyncAnyForm.AddFolderClick(Sender: TObject);
var
  InfoType: Byte;
  BI: TBrowseInfo;
  Image: Integer;
  PIDL: PItemIDList;
  Path: array[0..MAX_PATH - 1] of AnsiChar;
  ResPIDL: PItemIDList;
begin
  SHGetSpecialFolderLocation(Handle, CSIDL_DESKTOP, PIDL);
  // !!!
  ZeroMemory(@BI, SizeOf(TBrowseInfo));
  // !!!
  with BI do
  begin
    hWndOwner := Handle;
    lpszTitle := 'Select directory';
    ulFlags := BIF_StatusText;
    pidlRoot := PIDL;
    lpfn := NIL;
    iImage := Image;
  end;

  ResPIDL := SHBrowseForFolder(BI);
  SHGetPathFromIDListA(ResPIDL, @Path[0]);
  if (Path <> '') then
    SyncFolder.Text := Path;
end;

procedure TSyncAnyForm.FormMainOnAddFile(const FileName: string);
begin
  Log.info('Add file: ' + FileName);
end;

procedure TSyncAnyForm.GeneralPanelClick(Sender: TObject);
begin
  UpdateButton(0);
end;


procedure TSyncAnyForm.NetworkPanelClick(Sender: TObject);
begin
  UpdateButton(1);
end;

procedure TSyncAnyForm.openFolderClick(Sender: TObject);
begin
  if(config.Additional.folder <> '') then
  ShellExecute(Application.Handle,
    PChar('explore'),
    PChar(config.Additional.folder ),
    nil,
    nil,
    SW_SHOWNORMAL);
end;

procedure TSyncAnyForm.ProxyOffClick(Sender: TObject);
begin
  ProxyServer.Enabled := false;
  ProxyPort.Enabled := false;
  ProxyRequiredPwd.Enabled := false;
  ProxyUserName.Enabled := false;
  ProxyPassword.Enabled := false;
end;

procedure TSyncAnyForm.ProxyOnClick(Sender: TObject);
begin
ProxyServer.Enabled := true;
ProxyPort.Enabled := true;
ProxyRequiredPwd.Enabled := true;
end;

procedure TSyncAnyForm.ProxyRequiredPwdClick(Sender: TObject);
begin
  if ProxyRequiredPwd.Checked then
  begin
    ProxyUserName.Enabled := true;
    ProxyPassword.Enabled := true;
  end
  else begin
    ProxyUserName.Enabled := false;
    ProxyPassword.Enabled := false;
  end;
end;


procedure TSyncAnyForm.UpdateButton(index: integer);
var
  button:array[0..1] of ^TPanel;
  tabs:array[0..1] of ^TPanel;
  i: integer;
begin
  tabs[0] := @GeneralTab;
  button[0] := @GeneralPanel;
  tabs[1] := @NetworkTab;
  button[1] := @NetworkPanel;
  for i := (Length(tabs)-1) downto 0 do
  begin
    (tabs[i]^).Visible := false;
    (button[i]^).Color := clWhite;
  end;
  (tabs[index]^).Visible := true;
  (button[index]^).Color := clGradientActiveCaption;

end;


procedure TSyncAnyForm.WebSiteClick(Sender: TObject);
begin
  ShellExecute(Handle, 'open', 'http://evolver.org.ua',nil,nil, SW_SHOWNORMAL) ;
end;



procedure TSyncAnyForm.initControlls();
begin
  ProxyOn.Checked := config.ConfigProxy.ProxyEnable;
  ProxyServer.Text := config.ConfigProxy.ProxyServer;
  ProxyPort.Text := intToStr(config.ConfigProxy.ProxyPort);
  ProxyRequiredPwd.Checked := config.ConfigProxy.ProxyRequiredPwd;
  ProxyUserName.Text := config.ConfigProxy.ProxyUserName;
  ProxyPassword.Text := config.ConfigProxy.ProxyPassword;
  UserName.Text := config.SyncServer.UserName;
  Password.Text := config.SyncServer.Password;

  SyncFolder.Text:= config.Additional.folder;
  SynchAdrBook.Checked := config.Additional.SynchAdrBook;
  autoRun.Checked := config.Additional.autoRun;
end;

procedure TSyncAnyForm.SaveBtnClick(Sender: TObject);
var
  reconnect:Boolean;
begin
  reconnect:= false;
  config.ConfigProxy.ProxyEnable := ProxyOn.Checked;
  if(ProxyOn.Checked) then
  begin
    config.ConfigProxy.ProxyServer := ProxyServer.Text;
    config.ConfigProxy.ProxyPort := StrToInt(ProxyPort.Text);
    config.ConfigProxy.ProxyRequiredPwd := ProxyRequiredPwd.Checked;
    if(ProxyRequiredPwd.Checked) then
    begin
      config.ConfigProxy.ProxyUserName := ProxyUserName.Text;
      config.ConfigProxy.ProxyPassword := ProxyPassword.Text;
    end else begin
      config.ConfigProxy.ProxyUserName := '';
      config.ConfigProxy.ProxyPassword := '';
    end;
  end else begin
    config.ConfigProxy.ProxyServer := '';
    config.ConfigProxy.ProxyPort := 0;
    config.ConfigProxy.ProxyRequiredPwd := false;
    config.ConfigProxy.ProxyUserName := '';
    config.ConfigProxy.ProxyPassword := '';
  end;
  if((config.SyncServer.UserName <> UserName.Text) or (config.SyncServer.Password <> Password.Text)) then
    reconnect:= true;

  config.SyncServer.UserName := UserName.Text;
  config.SyncServer.Password := Password.Text;

  config.Additional.folder := SyncFolder.Text;

  config.Additional.SynchAdrBook := SynchAdrBook.Checked;
  if (config.Additional.autoRun <> autoRun.Checked) then
  begin
    AutorunProgram(autoRun.Checked,'SyncAny', Application.ExeName);
  end;
  config.Additional.autoRun := autoRun.Checked;
  config.save();
  hide();
  if (reconnect) then
    SyncSoketClient.reconnect();
end;

procedure TSyncAnyForm.SettingsClick(Sender: TObject);
begin
  ShowWindow(Application.Handle,SW_SHOW);
  ShowWindow(Handle,SW_SHOW);
  SetForegroundWindow(Handle);
  show();
end;

procedure TSyncAnyForm.TrayIconDblClick(Sender: TObject);
begin
  ShowWindow(Application.Handle,SW_SHOW);
  ShowWindow(Handle,SW_SHOW);
  SetForegroundWindow(Handle);
end;

procedure TSyncAnyForm.CancelBtnClick(Sender: TObject);
begin
  initControlls();
  ShowWindow(Handle,SW_HIDE);
  ShowWindow(Application.Handle,SW_HIDE);
end;

procedure TSyncAnyForm.ControlWindow(var Msg:TMessage);
begin
  if Msg.WParam = SC_MINIMIZE then
  begin
    ShowWindow(Handle,SW_HIDE);
    ShowWindow(Application.Handle,SW_HIDE);
  end else if Msg.WParam = SC_CLOSE then
  begin
      onClose();
      inherited;
  end else inherited;
end;

procedure TSyncAnyForm.onClose;
var
  temp : TAppController;
begin
  if Assigned(app) then
  begin
    Temp := app;
    app := nil;
    Temp.Terminate;
  end;
end;
procedure TSyncAnyForm.exitClick(Sender: TObject);
begin
  onClose();
  close;
end;

procedure TSyncAnyForm.AutorunProgram(Flag:boolean; NameParam, Path:String);
var Reg:TRegistry;
begin
  if Flag then
  begin
     Reg := TRegistry.Create;
     Reg.RootKey := HKEY_CURRENT_USER;
     Reg.OpenKey('\SOFTWARE\Microsoft\Windows\CurrentVersion\Run', false);
     Reg.WriteString(NameParam, Path);
     Reg.Free;
  end
  else
  begin
     Reg := TRegistry.Create;
     Reg.RootKey := HKEY_CURRENT_USER;
     Reg.OpenKey('\SOFTWARE\Microsoft\Windows\CurrentVersion\Run',false);
     Reg.DeleteValue(NameParam);
     Reg.Free;
  end;
end;

procedure TSyncAnyForm.FormCreate(Sender: TObject);
begin
  Log.Create;
  config.init();
  initControlls();
  if( Length(config.SyncServer.UserName) > 5 ) then
  begin
    app := TAppController.Create;
    app.Resume;
  end;
end;

end.
