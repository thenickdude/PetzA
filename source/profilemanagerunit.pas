unit profilemanagerunit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  contnrs, StdCtrls, ExtCtrls, profilelistdisplay, GR32_Image,helpunit;

type
  TfrmProfileManager = class(TForm)
    chkEnabled: TCheckBox;
    grpProfiles: TGroupBox;
    btnAddProfile: TButton;
    Panel1: TPanel;
    lstProfiles: TProfileListDisplay;
    btnOk: TButton;
    bvl1: TBevel;
    btnEdit: TButton;
    Button1: TButton;
    procedure updatebuttons;
    procedure FormCreate(Sender: TObject);
    procedure chkEnabledClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure btnAddProfileClick(Sender: TObject);
    procedure lstProfilesChange(Sender: TObject);
    procedure btnDeleteSelectedClick(Sender: TObject);
    procedure btnEditClick(Sender: TObject);
    procedure lstProfilesExecute(sender: TObject; index: Integer);
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

implementation

uses petzprofilesunit, profileeditunit;
{$R *.DFM}

procedure TfrmProfileManager.FormCreate(Sender: TObject);
begin
  clientwidth:=494;
  clientheight:=307; //Assert form size (XP)

  lstProfiles.manager := profilemanager;
  chkEnabled.Checked := profilemanager.useprofiles;
  chkEnabledClick(self);
end;

procedure TfrmProfileManager.chkEnabledClick(Sender: TObject);
begin
  profilemanager.useprofiles := chkEnabled.checked;

  lstProfiles.Enabled := chkEnabled.checked;
  Panel1.Enabled := chkEnabled.checked;
  btnAddProfile.enabled := chkEnabled.checked;
  btnEdit.enabled := chkEnabled.checked;
end;

procedure TfrmProfileManager.FormShow(Sender: TObject);
begin
  lstProfiles.Enabled := chkEnabled.Checked;
end;

procedure TfrmProfileManager.btnAddProfileClick(Sender: TObject);
var editform: TfrmProfileEdit;
  name: string;
begin
  editform := TfrmProfileEdit.Create(nil);
  try
    editform.caption := 'Add profile...';
    editform.showmodal;
    if editform.modalresult = mrok then begin
      name := editform.edtTitle.Text;
      if Trim(name) = '' then name := 'Unnamed';
      profilemanager.createprofile(name, editform.edtDesc.Text,editform.icon);
    end;
  finally
    editform.free;
  end;

  lstProfiles.Refresh;
  updatebuttons;
end;

procedure TfrmProfileManager.updatebuttons;
begin
  btnEdit.Enabled := lstProfiles.selindex > -1;
end;

procedure TfrmProfileManager.lstProfilesChange(Sender: TObject);
begin
  updatebuttons;
end;

procedure TfrmProfileManager.btnDeleteSelectedClick(Sender: TObject);
begin
  updatebuttons;
end;

procedure TfrmProfileManager.btnEditClick(Sender: TObject);
var editform: TfrmProfileEdit;
  name: string;
begin
  editform := TfrmProfileEdit.Create(nil);
  try
    editform.caption := 'Edit profile...';
    editform.edtTitle.Text:=profilemanager.profiles[lstProfiles.selindex].name;
    editform.edtDesc.Text:=profilemanager.profiles[lstProfiles.selindex].description;
    editform.icon.assign(profilemanager.profiles[lstProfiles.selindex].icon);

    editform.showmodal;
    if editform.modalresult = mrok then begin
      name := editform.edtTitle.Text;
      if Trim(name) = '' then name := 'Unnamed';
      profilemanager.profiles[lstProfiles.selindex].name := name;
      profilemanager.profiles[lstProfiles.selindex].description := editform.edtDesc.Text;
      profilemanager.profiles[lstProfiles.selindex].loadicon(editform.Icon);
      profilemanager.SaveProfile(profilemanager.profiles[lstProfiles.selindex]);
    end;
  finally
    editform.free;
  end;

  lstProfiles.Refresh;
  updatebuttons;
end;

procedure TfrmProfileManager.lstProfilesExecute(sender: TObject;
  index: Integer);
begin
btnedit.Click;
end;

procedure TfrmProfileManager.Button1Click(Sender: TObject);
begin
 application.HelpContext(HELP_Profiles);
end;

end.

