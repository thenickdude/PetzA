unit profileeditunit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, GR32_Image, gr32, framediconunit;

type
  TfrmProfileEdit = class(TForm)
    lblTitle: TLabel;
    edtTitle: TEdit;
    Label1: TLabel;
    edtDesc: TEdit;
    btnCancel: TButton;
    btnOk: TButton;
    Label2: TLabel;
    imgIcon: TImage32;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure imgIconClick(Sender: TObject);
  private
    { Private declarations }
    procedure presenticon;
  public
    { Public declarations }
    icon: TBitmap32;
  end;

implementation
uses frmpickiconunit;
{$R *.DFM}

procedure TfrmProfileEdit.FormCreate(Sender: TObject);
begin
  icon := tbitmap32.create;
  borderstyle:=bsSizeable;   //hack to get XP title bars not to squash things
end;

procedure TfrmProfileEdit.FormDestroy(Sender: TObject);
begin
  icon.free;
end;

procedure TFrmProfileEdit.presenticon;
begin
  imgIcon.Bitmap.SetSize(50 + 2 * 2, 50 + 2 * 2);
  imgIcon.Bitmap.Clear(color32(clbtnface));

  if icon.Empty then begin
    imgIcon.Bitmap.Textout(4, 4, '(none)');
  end else begin
    drawframedicon(icon, imgIcon.bitmap, 0, 0, true, 50, 2);
  end;

  imgicon.refresh;
end;

procedure TfrmProfileEdit.FormShow(Sender: TObject);
begin
  presenticon;
end;

procedure TfrmProfileEdit.imgIconClick(Sender: TObject);
var frm: Tfrmpickicon;
begin
  frm := TfrmPickIcon.Create(nil);
  try
    frm.showmodal;
    if frm.ModalResult=mrOk then begin
      icon.assign(frm.selicon);
      presenticon;
    end;
    if frm.ModalResult=mrNo then begin //clear icon
      icon.SetSize(0,0);
      presenticon;
    end;
  finally
    frm.free;
  end;
end;

end.

