unit aboutunit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, shellapi, ExtCtrls, rsfileversion,frmdefaultunit, ActnList;

type
  TfrmAbout = class(TForm)
    Label1: TLabel;
    Label2: TLabel;
    Button1: TButton;
    Label3: TLabel;
    Label4: TLabel;
    Memo1: TMemo;
    Label5: TLabel;
    Label6: TLabel;
    procedure Button1Click(Sender: TObject);
    procedure Label4Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure Label6Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

implementation
uses petzclassesunit, dllpatchunit, bndpetz, petzcommon1;
{$R *.DFM}

procedure TfrmAbout.Button1Click(Sender: TObject);
begin
  close;
end;

procedure TfrmAbout.Label4Click(Sender: TObject);
begin
  ShellExecute(handle, 'open', 'mailto:nick@sherlocksoftware.org', nil, nil, sw_shownormal);
end;

procedure TfrmAbout.Button2Click(Sender: TObject);
begin
  Thiscall(petzclassesman.findclassinstance(cnSpriteAdpt), rimports.spriteadpt_killpetz, []);

//thiscall(petzclassesman.findclassinstance(cnPetsprite).instance,rimports.scriptsprite_pushstoredaction,[298,cardinal(-1),cardinal(false)]);

//petzaunit.bringout;
// showmessage('$'+inttohex(integer(tpetzpetsprite(petzclassesman.findclassinstance(cnPetsprite)).instance),8));
// showmessage(inttostr(petzclassesman.countinstances(cnXDrawport)));
//  PostMessage(findpetzwindow, wm_command, 3003, 0);
//showmessage( pchar( ptr(cardinal(petzcurrentarea)+$32A)));
//thiscall(petzoberon,addr(oberonpickarea),[200,200]);
end;

procedure TfrmAbout.FormCreate(Sender: TObject);
var rs: TrsFileVersion;
  s: string;
begin
  caption := 'About ' + petzvername(cpetzver) + '...';
  rs := TrsFileVersion.Create;
  try
    setlength(s, 500);
    setlength(s, GetModuleFileName(hinstance, pchar(s), length(s)));
    rs.GetFileVersion(s);
    label1.caption := petzvername(cpetzver) + ' (V' + inttostr(rs.Major) + '.' + inttostr(rs.minor) + '.' + inttostr(rs.Release) + ') was developed by Nicholas Sherlock';

  finally
    rs.free;
  end;
end;

procedure TfrmAbout.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  action := cafree;
end;

procedure TfrmAbout.Label6Click(Sender: TObject);
begin
    ShellExecute(handle, 'open', 'http://www.sherlocksoftware.org', nil, nil, sw_shownormal);
end;

end.

