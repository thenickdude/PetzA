unit mymessageunit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, math, registry;

type
  TfrmMyMessage = class(TForm)
    lblmain: TLabel;
    btnOkay: TButton;
    chkDontShowAgain: TCheckBox;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure btnOkayClick(Sender: TObject);
  private
    { Private declarations }
    fname: string;
    function gethidden: Boolean;
    procedure sethidden(value: boolean);
  public
    { Public declarations }
    class function getmessageroot: string;
    class procedure setmessageroot(const value: string);
    property hidden: Boolean read gethidden write sethidden;
    constructor create(const msg: string; const name: string = ''); reintroduce;
  end;

procedure nonmodalmessage(const msg: string; const name: string = '');

implementation

{$R *.DFM}

uses petzaunit;

var messageroot: string;


//Provide a name if you want the message to be disableable

procedure nonmodalmessage(const msg: string; const name: string = '');
var box: TfrmMyMessage;
begin
  box := tfrmmymessage.create(msg, name);
  if not box.hidden then
    box.show else
    box.free;
end;

function tfrmmymessage.gethidden: Boolean;
var reg: TRegistry;
begin
  result := false;

  if length(fname) = 0 then
    exit; //Can never be hidden if it has no name

  reg := TRegistry.Create;
  try
    reg.RootKey := HKEY_CURRENT_USER;
    if reg.OpenKey(getmessageroot, false) then begin
      result := reg.ValueExists(fname);
    end;
  finally
    reg.free;
  end;
end;

procedure tfrmmymessage.sethidden(value: boolean);
var reg: TRegistry;
begin
  if length(fname) = 0 then
    exit; //Can never be hidden if it has no name

  reg := TRegistry.Create;
  try
    reg.RootKey := HKEY_CURRENT_USER;
    if reg.OpenKey(getmessageroot, value) then begin //create on true, dont need to on false
      if value then
        reg.WriteBool(fname, true) else
        reg.DeleteKey(fname);
    end;
  finally
    reg.free;
  end;
end;

class function TfrmMyMessage.getmessageroot: string;
begin
  result := messageroot;
end;

class procedure TfrmMyMessage.setmessageroot(const value: string);
begin
  messageroot := value;
end;

constructor tfrmmymessage.create(const msg: string; const name: string = '');
begin
  inherited create(nil);
  fname := name;
  caption := 'PetzA';
  lblmain.caption := msg;
  lblmain.AutoSize := true;
  chkDontShowAgain.Visible := length(fname) > 0;
  chkDontShowAgain.Checked:=false;
  if chkDontShowAgain.Visible then begin
    chkDontShowAgain.Top := lblmain.top + lblmain.Height + 8;
    btnOkay.Top := chkDontShowAgain.top + chkDontShowAgain.Height + 8;
  end else begin
    btnOkay.top := lblmain.top + lblmain.height + 8;
  end;
  clientwidth := max(lblmain.width + lblmain.left + 8, btnokay.width + 16);
  if chkDontShowAgain.Visible then
   clientwidth:=max(clientwidth, chkdontshowagain.left + chkdontshowagain.width + 8);
  clientheight := btnokay.top + btnokay.height + 8;
  btnokay.left := (clientwidth - btnokay.width) div 2;
end;

procedure TfrmMyMessage.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  hidden:=chkDontShowAgain.Checked;
  action := cafree;
end;

procedure TfrmMyMessage.btnOkayClick(Sender: TObject);
begin
  close;
end;

end.

