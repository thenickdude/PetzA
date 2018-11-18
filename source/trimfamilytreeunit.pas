unit trimfamilytreeunit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Vcl.Imaging.jpeg, ExtCtrls, contnrs, helpunit;

type
  TfrmTrimFamilyTree = class(TForm)
    Memo1: TMemo;
    Image1: TImage;
    Button1: TButton;
    Button2: TButton;
    Memo2: TMemo;
    btnHelp: TButton;
    procedure Button2Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormShow(Sender: TObject);
    procedure btnHelpClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    petid: smallint;
    petname: string;
  end;


implementation

{$R *.DFM}
uses petzaunit, mymessageunit;

procedure TfrmTrimFamilyTree.Button2Click(Sender: TObject);
begin
  close;
end;

procedure TfrmTrimFamilyTree.Button1Click(Sender: TObject);
begin
  if petza.trimtree(petid, 7) then
    nonmodalmessage('Successfully trimmed your pet''s family tree','TrimTreeSuccess') else
    nonmodalmessage('Couldn''t find your pet or another error occured, try again.');
  close;
end;

procedure TfrmTrimFamilyTree.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  action := cafree;
end;

procedure TfrmTrimFamilyTree.FormShow(Sender: TObject);
begin
  memo2.text := 'Click "Trim" to trim ''' + petname + '''''s family tree, click "Cancel" to exit.';

end;

procedure TfrmTrimFamilyTree.btnHelpClick(Sender: TObject);
begin
 application.HelpContext(HELP_Familytreetrimmer);
end;

end.

