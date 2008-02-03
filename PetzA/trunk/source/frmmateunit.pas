unit frmmateunit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, contnrs,helpunit;

type
  TfrmMate = class(TForm)
    Label1: TLabel;
    lstFemales: TListBox;
    Label2: TLabel;
    lstMales: TListBox;
    Button1: TButton;
    btnMate: TButton;
    Label3: TLabel;
    btnHelp: TButton;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure Button1Click(Sender: TObject);
    procedure btnMateClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure btnHelpClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmMate: TfrmMate;

implementation
uses petzclassesunit, bndpetz, mymessageunit, dllpatchunit;
{$R *.DFM}

procedure TfrmMate.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  action := cafree;
end;

procedure TfrmMate.Button1Click(Sender: TObject);
begin
  close;
end;

function matebystateconceive(female, male: TPetzPetSprite): boolean;
var state: Pointer;
  old: TPetzPetSprite;
  old90: longword;
  buffer: array[0..100] of byte;
begin
  try
    old := female.interactingpet;
    female.interactingpet := male;

    old90 := female.stateflag;
    female.stateflag := 1;

    try
      state := pointer(thiscall(@buffer[0], rimports.stateconceive_stateconceive, []));
      thiscall(state, rimports.stateconceive_execute, [cardinal(female), 1, 0]);
      result := female.petinfo.pregnant;
    finally
      female.interactingpet := old;
      female.stateflag := old90;
    end;
  except
    result := false;
  end;
end;

procedure TfrmMate.btnMateClick(Sender: TObject);
var t1: integer;
  list: tobjectlist;
  male, female: pointer;
begin
  if (lstFemales.itemindex < 0) or (lstmales.itemindex < 0) then begin
    showmessage('You must select both a male and a female');
    exit;
  end;
 //okay, make sure both pets are still here, then mate
  male := nil;
  female := nil;
  list := tobjectlist.create(false);
  try
    petzclassesman.findclassinstances(cnpetsprite, list);
    for t1 := 0 to list.count - 1 do
      if TPetzPetSprite(TPetzClassInstance(list[t1]).instance).id = integer(lstfemales.items.objects[lstFemales.ItemIndex]) then
        female := TPetzClassInstance(list[t1]).instance else
        if TPetzPetSprite(TPetzClassInstance(list[t1]).instance).id = integer(lstmales.items.objects[lstmales.ItemIndex]) then
          male := TPetzClassInstance(list[t1]).instance;

    if (male = nil) or (female = nil) then begin
      nonmodalmessage('Sorry, one of the pets you have selected is no longer out. Please try again.');
      exit;
    end;

    if TPetzPetSprite(female).petinfo.pregnant then begin
      nonmodalmessage('The female pet is already pregnant.');
      exit;
    end;

    if matebystateconceive(female, male) then
      nonmodalmessage('Success!','MateSuccess') else
      nonmodalmessage('Couldn''t mate. Perhaps one pet is too young, or another problem occured');
    close;
  finally
    list.free;
  end;
end;

procedure TfrmMate.FormShow(Sender: TObject);
begin
  lstfemales.itemindex := 0;
  lstmales.itemindex := 0;
end;

procedure TfrmMate.btnHelpClick(Sender: TObject);
begin
  Application.HelpCommand(HELP_CONTEXT,HELP_BreedingIntro);
end;

end.

