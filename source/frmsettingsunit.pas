unit frmsettingsunit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, registry, mymessageunit, bndpetz, helpunit, UITypes;

type
  TfrmSettings = class(TForm)
    Bevel1: TBevel;
    btnCancel: TButton;
    btnOk: TButton;
    chkBrainSliders: TCheckBox;
    Button3: TButton;
    chkNameTags: TCheckBox;
    btnHelp: TButton;
    chkHideNavigation: TCheckBox;
    GroupBox1: TGroupBox;
    chkShowHeart: TCheckBox;
    chkInstantBirth: TCheckBox;
    lblCameraFormat: TLabel;
    cmbCameraFormat: TComboBox;
    chkNoDiapers: TCheckBox;
    procedure Button3Click(Sender: TObject);
    procedure btnOkClick(Sender: TObject);
    procedure btnHelpClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmSettings: TfrmSettings;

implementation
uses petzaunit;
{$R *.DFM}

procedure TfrmSettings.Button3Click(Sender: TObject);
var reg: tregistry;
begin
  if MessageDlg('This will turn back on all the messages which have been hidden '
    + #13 + #10 + 'by "Do not show this message again". Are you sure that you '
    + #13 + #10 + 'want to do this?', mtConfirmation, [mbYes, mbNo, mbCancel], 0) = mrYes then begin
    reg := TRegistry.Create;
    try
      reg.RootKey := HKEY_CURRENT_USER;
      reg.DeleteKey(TfrmMyMessage.getmessageroot);
    finally
      reg.free;
    end;
    showmessage('All message boxes have been reset');
  end;
end;

procedure TfrmSettings.btnOkClick(Sender: TObject);
begin
  petza.showheart := chkshowheart.checked;
  petza.instantbirth := chkInstantBirth.checked;
  petza.shownametags := chkNameTags.checked;
  if (not chkNoDiapers.checked) and petza.nodiaperchanges then
   showmessage('You must restart Babyz for diaper changing to return to normal');
  petza.nodiaperchanges:=chkNoDiapers.checked;
  petza.brainslidersontop := chkBrainSliders.checked;
  petza.CameraFormat := TCameraFormat(cmbCameraFormat.itemindex);
  petza.shownavigation := not chkHideNavigation.checked;
end;

procedure TfrmSettings.btnHelpClick(Sender: TObject);
begin
  application.HelpContext(HELP_Settings);
end;

procedure TfrmSettings.FormCreate(Sender: TObject);
begin
  chkBrainSliders.checked := petza.brainslidersontop;
  chkNameTags.checked := petza.shownametags;
  chkNoDiapers.checked := petza.nodiaperchanges;
  chkInstantBirth.Checked := petza.instantbirth;
  cmbCameraFormat.itemindex := integer(petza.CameraFormat);
  chkHideNavigation.Checked := not petza.shownavigation;
  chkshowheart.checked := petza.showheart;

  chkshowheart.enabled := cpetzver in verBreeding;
  chkHideNavigation.Enabled := cpetzver = pvBabyz;
  chkNameTags.Enabled := cpetzver = pvpetz5;
  chkNoDiapers.enabled:=cpetzver = pvBabyz;
  chkInstantBirth.Enabled := assigned(rimports.petsprite_isoffspringdue);
  lblCameraFormat.enabled := cpetzver in verCamera;
  cmbCameraFormat.enabled := cpetzver in verCamera;
end;

end.

