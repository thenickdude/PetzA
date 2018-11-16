unit sliderbrainunit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ComCtrls, contnrs, petzclassesunit, ExtCtrls, math;

type
  TfrmSliderBrain = class(TForm)
    tmrRefresh: TTimer;
    procedure Edit1KeyPress(Sender: TObject; var Key: Char);
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure tmrRefreshTimer(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
    fglobal: boolean;
    fpetid: smallint;
    fdontupdate: boolean;
  public
    { Public declarations }
    property global: Boolean read fglobal;
    property petid: smallint read fpetid;
    constructor create(aowner: tcomponent; ontop: Boolean; global: boolean = false; petid: smallint = 0); reintroduce;
    function findpet: tpetzpetsprite;
    procedure scrollonchange(sender: tobject);
  end;

implementation
uses bndpetz, petzaunit;
{$R *.DFM}

constructor tfrmsliderbrain.create(aowner: tcomponent; ontop: Boolean; global: boolean = false; petid: smallint = 0);
begin
  inherited create(aowner);
  fglobal := global;
  fpetid := petid;
  fdontupdate := false;
  if ontop then
    formstyle := fsStayontop else
    formstyle := fsnormal;
end;

function tfrmsliderbrain.findpet: tpetzpetsprite;
var list: tobjectlist;
  t1: integer;
begin
  result := nil;
  list := tobjectlist.create(false);
  try
    petzclassesman.findclassinstances(cnPetsprite, list);
    for t1 := 0 to list.count - 1 do
      if TPetzPetSprite(TPetzClassInstance(list[t1]).instance).id = fpetid then begin
        result := TPetzPetSprite(TPetzClassInstance(list[t1]).instance);
        break;
      end;
  finally
    list.free;
  end;
end;

procedure TfrmSliderBrain.Edit1KeyPress(Sender: TObject; var Key: Char);
begin
  if not (key in ['0'..'9', #9]) then key := #0;
end;

procedure tfrmsliderbrain.scrollonchange(sender: tobject);
var pet: TPetzPetSprite;
  t1: integer;
  list: tobjectlist;
begin
  if not Visible then exit;

  tlabel(FindComponent('lbl' + inttostr(tcomponent(sender).tag))).Caption := inttostr(TScrollBar(sender).Position);
  if fdontupdate then exit;

  if not fglobal then begin
    pet := findpet;
    if pet = nil then begin
//      release; let the timer release us
      exit;
    end;

    if (tcomponent(sender).tag = petza.brainageindex) and (not (cpetzver in verBabyz)) then begin

      if pet.getbiorhythm(tcomponent(sender).tag) <> TScrollBar(sender).Position then
        pet.setbiorhythm(tcomponent(sender).tag, max(TScrollBar(sender).Position, 6));

    end else
      if pet.getbiorhythm(tcomponent(sender).tag) <> TScrollBar(sender).Position then
        pet.setbiorhythm(tcomponent(sender).tag, TScrollBar(sender).Position);
  end else begin {Global}
    list := tobjectlist.create(false);
    try
      petzclassesman.findclassinstances(cnpetsprite, list);

      if (tcomponent(sender).tag = petza.brainageindex) and (not (cpetzver in verBabyz)) then begin
      for t1 := 0 to list.count - 1 do
        TPetzPetSprite(TPetzClassInstance(list[t1]).instance).setbiorhythm(tcomponent(sender).tag, max(tscrollbar(sender).position,6));
      end else
      for t1 := 0 to list.count - 1 do
        TPetzPetSprite(TPetzClassInstance(list[t1]).instance).setbiorhythm(tcomponent(sender).tag, tscrollbar(sender).position);
    finally
      list.free;
    end;
  end;
end;

procedure TfrmSliderBrain.FormCreate(Sender: TObject);
var t1: integer;
  lbl: tlabel;
  scroll: tscrollbar;
begin
  lbl := nil;
  for t1 := 0 to high(petza.brainbarnames) do begin
    lbl := tlabel.create(Self);
    lbl.parent := self;
    lbl.caption := petza.brainbarnames[t1] + ':';
    lbl.left := 4;
    lbl.top := t1 * 24 + 8;
    scroll := TScrollBar.Create(self);
    scroll.name := 'scr' + inttostr(t1);
    scroll.parent := self;
    scroll.left := 60;
    scroll.top := t1 * 24 + 8;
    scroll.width := 125;
    scroll.max := 100;
    scroll.tag := t1;
    scroll.LargeChange := 15;
    scroll.onchange := scrollonchange;
    lbl := tlabel.create(self);
    lbl.name := 'lbl' + inttostr(t1);
    lbl.parent := self;
    lbl.left := 192;
    lbl.top := t1 * 24 + 8;
    lbl.caption := '0';
  end;
  clientheight := lbl.top + lbl.height + 8;
end;

procedure TfrmSliderBrain.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  action := caHide;
end;

procedure TfrmSliderBrain.tmrRefreshTimer(Sender: TObject);
var pet: tpetzpetsprite;
  acc, t1, t2: integer;
  list: tobjectlist;
begin
  if not Visible then exit;

  fdontupdate := true; // so our changing of scrollbar position doesn't trigger a reapply
  try
    if not fglobal then begin
      pet := findpet;
      if pet = nil then begin
        close;
        exit;
      end;
      for t1 := 0 to high(petza.brainbarnames) do
        tscrollbar(findcomponent('scr' + inttostr(t1))).Position := pet.getbiorhythm(t1);
    end else begin
      list := tobjectlist.create(false);
      try
        petzclassesman.findclassinstances(cnpetsprite, list);


        for t1 := 0 to high(petza.brainbarnames) do begin
          tscrollbar(findcomponent('scr' + inttostr(t1))).Enabled := (list.count > 0);
          if tscrollbar(findcomponent('scr' + inttostr(t1))).Enabled then begin
            acc := 0;
            for t2 := 0 to list.count - 1 do
              acc := acc + TPetzPetSprite(tpetzclassinstance(list[t2]).instance).getbiorhythm(t1);
            tscrollbar(findcomponent('scr' + inttostr(t1))).Position := acc div list.count;
          end;
        end;
      finally
        list.free;
      end;
    end;
  finally
    fdontupdate := false;
  end;
end;

procedure TfrmSliderBrain.FormShow(Sender: TObject);
var pet: tpetzpetsprite;
begin
  if fglobal then begin
    caption := 'Global brainsliders';
  end else begin
    pet := findpet;
    if pet = nil then begin
      exit;
    end;
    caption := pet.name + '''s brain';
  end;
  tmrRefresh.ontimer(self);
end;

end.

