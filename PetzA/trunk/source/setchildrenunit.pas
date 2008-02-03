unit setchildrenunit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Spin;

type
  TfrmSetnumchildren = class(TForm)
    btnCancel: TButton;
    btrnSet: TButton;
    Memo1: TMemo;
    Label1: TLabel;
    cmbNumber: TComboBox;
    procedure btrnSetClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;


implementation

uses dllpatchunit;
{$R *.DFM}

procedure TfrmSetnumchildren.btrnSetClick(Sender: TObject);
type tsetrec = packed record
    moveedi: byte;
    value: longword;
  end;
var setrec: tsetrec;
begin
  setrec.moveedi := $BF;
  try
    setrec.value := cmbNumber.ItemIndex;
  except
    setrec.value := 2;
  end;
  patchcode(ptr($57F3B7), sizeof(setrec), 18, @setrec);
end;

procedure TfrmSetnumchildren.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  action := cafree;
end;

procedure TfrmSetnumchildren.FormCreate(Sender: TObject);
begin
  cmbNumber.itemindex := 2;
end;

end.

