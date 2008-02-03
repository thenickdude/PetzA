unit gamespeedunit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ComCtrls, StdCtrls, Spin, ExtCtrls;

type
  TfrmGameSpeed = class(TForm)
    Label1: TLabel;
    btnCancel: TButton;
    btnOk: TButton;
    Button3: TButton;
    btnApply: TButton;
    spnSpeed: TSpinEdit;
    lbl1: TLabel;
    Bevel1: TBevel;
    procedure btnCancelClick(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure btnApplyClick(Sender: TObject);
    procedure btnOkClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
  public
    { Public declarations }
  end;


implementation
uses petzaunit, bndpetz, petzclassesunit;
{$R *.DFM}

procedure TfrmGameSpeed.btnCancelClick(Sender: TObject);
begin
  close;
end;

procedure TfrmGameSpeed.Button3Click(Sender: TObject);
begin
  spnspeed.value := petza.defaultgamespeed;
  btnok.click;
end;

procedure TfrmGameSpeed.btnApplyClick(Sender: TObject);
var i:integer;
begin
  try
    i:=spnSpeed.value; //I have seen strtoint in TSpinEdit fail before
  except
    i:=petza.defaultgamespeed;
  end;
  petza.gamespeed := i;
end;

procedure TfrmGameSpeed.btnOkClick(Sender: TObject);
begin
  btnapply.click;
  close;
end;

procedure TfrmGameSpeed.FormShow(Sender: TObject);
begin
  spnspeed.value := petza.gamespeed;
  lbl1.caption:=format('Use this dialog to change the speed of your Petz game.'#13#10#13#10+
   'Smaller numbers are faster. The default speed for this version of Petz is %d.',
   [petza.defaultgamespeed]);
end;

procedure TfrmGameSpeed.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  action := cafree;
end;

end.

