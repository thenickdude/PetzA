unit pickprofileunit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, GR32_Image, gr32, profilelistdisplay, GR32_Blend, ExtCtrls;

type
  TfrmPickProfile = class(TForm)
    lbl1: TLabel;
    btnLoad: TButton;
    btnCancel: TButton;
    Panel1: TPanel;
    lstProfiles: TProfileListDisplay;
    procedure FormCreate(Sender: TObject);
    procedure lstProfilesChange(Sender: TObject);
    procedure lstProfilesExecute(sender: TObject; index: Integer);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

implementation

uses petzprofilesunit;

{$R *.DFM}

procedure TfrmPickProfile.FormCreate(Sender: TObject);
begin
  lstprofiles.manager := profilemanager;
end;

procedure TfrmPickProfile.lstProfilesChange(Sender: TObject);
begin
  btnload.enabled := (lstProfiles.selindex <> -1);
end;

procedure TfrmPickProfile.lstProfilesExecute(sender: TObject;
  index: Integer);
begin
 btnLoad.Click;
end;

end.

