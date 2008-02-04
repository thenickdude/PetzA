unit profilelistdisplay;

interface

uses sysutils, contnrs, windows, Forms, Controls, classes, petzprofilesunit, gr32,
  GR32_Image, GR32_Blend, graphics, math, stdctrls, messages, gr32_rangebars,
  framediconunit, GR32_Resamplers;

type
  TItemExecuteEvent = procedure(sender: TObject; index: integer) of object;

  TProfileListDisplay = class(TCustomPaintBox32)
  private
    fscrollbar: tscrollbar;
    fmanager: TProfileManager;
    fscroll: integer;
    fitemheight: integer;
    fselindex: integer;
    fonchange: TNotifyEvent;
    fonexecute: TItemExecuteEvent;
    fshowenabled: Boolean;
    procedure setselindex(value: integer);
    procedure setscroll(value: integer);
    procedure scrollchange(sender: tobject);
    procedure setmanager(value: TProfileManager);
    procedure doubleclick(sender: TObject);
    procedure wheelmoved(Sender: TObject; Shift: TShiftState; WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
    function MaxScroll: integer;
  protected
    procedure SetEnabled(Value: Boolean); override;
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
  public
    procedure Resize; override;
    property selindex: Integer read fselindex write setselindex;
    property itemHeight: integer read fitemheight write fitemheight;
    property manager: TProfileManager read fmanager write setmanager;
    property Scroll: integer read fscroll write setscroll;
    procedure DoPaintBuffer; override;
    destructor Destroy; override;
    constructor Create(aOwner: Tcomponent); override;
  published
    property onExecute: TItemExecuteEvent read fonexecute write fonexecute;
    property onChange: TNotifyEvent read fonchange write fonchange;
    property ShowEnabled: boolean read fshowenabled write fshowenabled default false;
    property Align;
    property onResize;
    property Anchors;
    property TabStop;
    property TabOrder;
    property Enabled;
  end;

procedure Register;

implementation

uses bndpetz;

procedure Register;
begin
  registercomponents('Standard', [TProfileListDisplay]);
end;

procedure tprofilelistdisplay.scrollchange(sender: tobject);
begin
  scroll := fscrollbar.Position;
end;

procedure tprofilelistdisplay.SetEnabled(Value: Boolean);
begin
  inherited;
  refresh;
end;

procedure tprofilelistdisplay.resize;
begin
  inherited;
  fscrollbar.height := height;
  fscrollbar.Left := width - fscrollbar.Width;
end;

function tprofilelistdisplay.MaxScroll: integer;
begin
     //ScrollBar throws an exception if max<pagesize
  if Assigned(fmanager) then begin
    result := max(fmanager.count * fitemheight, fscrollbar.pagesize);
  end else result := fscrollbar.pagesize;
end;

procedure TProfileListDisplay.setscroll(value: integer);
begin
  if (value < 0) then value := 0;
  if (value > maxscroll) then value := maxscroll;
  if scroll <> value then begin
    fscroll := value;
    Refresh;
  end;
end;

procedure tprofilelistdisplay.setselindex(value: integer);
begin
  if not assigned(fmanager) then begin
    if fselindex <> -1 then begin
      fselindex := -1;
      refresh;
      if assigned(fonchange) then
        fonchange(self);
    end;
  end else begin
    if value < 0 then value := 0;
    if value > fmanager.count - 1 then
      value := fmanager.count - 1;
  //postcondition: Value is -1 if count=0, otherwise it is a valid index

    if value <> fselindex then begin
      fselindex := value;
      Refresh;
      if assigned(fonchange) then
        fonchange(self);
    end;
  end;
end;


procedure tprofilelistdisplay.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  inherited;
  selindex := (y + scroll) div fitemheight;
end;

function renderwordwrap(bitmap: tbitmap32; text: string; left, top, right, bottom: integer; aalevel: integer; color: tcolor32): integer;
const delimiters: set of char = ['-', ' '];
var pos, lastspace: integer;
  y: integer;
label start;
begin
  y := top;

  while (length(text) > 0) do begin
    lastspace := 0;
    pos := 1;
    while (pos <= length(text)) and (bitmap.TextWidth(copy(text, 1, pos)) < right - left) do begin
      if text[pos] in delimiters then
        lastspace := pos;
      inc(pos);
    end;
    //postcondition: pos is the index of the first character that makes the string too long

    if pos > length(text) then begin //all the text fits on this line
      bitmap.RenderText(left, y, text, aalevel, color);
      text := '';
    end else
      if (y + bitmap.TextHeight(' ')*2 > bottom) then begin //we have reached the end of the container!
        while (pos > 1) and (bitmap.TextWidth(copy(text, 1, pos) + '...') >= right - left) do
          dec(pos);
        if pos >= 1 then
          bitmap.RenderText(left, y, copy(text, 1, pos) + '...', aalevel, color);
        text := '';
      end else
        if (lastspace = 0) then begin //we can go to the next line, but there's nowhere to break it!
          while (pos > 1) and (bitmap.TextWidth(copy(text, 1, pos) + '-') > right - left) do
            dec(pos);
          if pos >= 1 then
            bitmap.RenderText(left, y, copy(text, 1, pos) + '-', aalevel, color);
          text := copy(text, pos + 1, length(text));
        end else begin //we can break at a space
          bitmap.RenderText(left, y, copy(text, 1, lastspace - 1), aalevel, color);
          text := copy(text, lastspace + 1, length(text));
        end;

    if length(text) > 0 then begin
      inc(y, bitmap.TextHeight(' '));
    end;
  end;
  result := y + bitmap.textheight(' ');
end;

function stripfileext(const filename: string): string;
begin
  result := copy(filename, 1, length(filename) - length(extractfileext(filename)));
end;


procedure tprofilelistdisplay.dopaintbuffer;
const textleft = 70;
  textheadingtop = 5;
  textdesctop = 20;
  textright = 20;
  descbottom = 30;
  framesize = 50;
  shadowmargin = 4;
var t1, t2: integer;
  x, y: integer;
  col1, col2: tcolor32;
  itemtop, itembottom: integer;
  temp, shadow: tbitmap32;
  drawshadow: boolean;
  desc: string;
  list: tstringlist;
begin
  if enabled then
    buffer.Clear(clwhite32) else
    buffer.Clear(gray32(240));

  fscrollbar.Max :=MaxScroll;

  if (fscrollbar.max > 0) xor fscrollbar.Visible then begin //need to change state
    fscrollbar.visible := (fscrollbar.max > 0);
  end;

  if not assigned(fmanager) then begin
    selindex := -1;
    exit;
  end;

  for t1 := 0 to fmanager.count - 1 do begin
    itemtop := t1 * fitemheight - scroll;
    itembottom := (t1 + 1) * fitemheight - scroll;

    if (itemtop > height - 1) or (itembottom - 1 < 0) then continue; //not visible at all

   //draw background

    if enabled then begin
      if fselindex = t1 then begin
   //item is selected
        col1 := Color32(220, 220, 255);
        col2 := Color32(180, 180, 255);
        try
          for y := max(itemtop, 0) to min(itembottom - 1, height - 1) do
            buffer.HorzLine(0, y, buffer.width - 1, BlendReg(SetAlpha(col2, ((y - (t1 * fitemheight - scroll)) * 255) div fitemheight), col1));
        finally
          emms;
        end;
        if (itembottom - 1 <= height - 1) and (itembottom - 1 >= 0) then
          buffer.HorzLine(0, itembottom - 1, buffer.Width - 1, cllightGray32);
      end else begin
        buffer.SetStipple([cllightGray32, clwhite32]);
        buffer.HorzLineTSP(0, itembottom - 1, buffer.Width - 1);
      end;
    end else begin //draw disabled state
   //item is selected
      if (fselindex = t1) then begin
        col1 := gray32(245);
        col2 := gray32(175);
        try
          for y := max(itemtop, 0) to min(itembottom - 1, height - 1) do
            buffer.HorzLine(0, y, buffer.width - 1, BlendReg(SetAlpha(col2, ((y - (t1 * fitemheight - scroll)) * 255) div fitemheight), col1));
        finally
          emms;
        end;
        if (itembottom - 1 <= height - 1) and (itembottom - 1 >= 0) then
          buffer.HorzLine(0, itembottom - 1, buffer.Width - 1, cllightGray32);
      end else begin
        buffer.SetStipple([cllightGray32, clwhite32]);
        buffer.HorzLineTSP(0, itembottom - 1, buffer.Width - 1);
      end;
    end;


    buffer.font.Name := 'Arial';

    buffer.font.size := 9;
    buffer.Font.Style := buffer.Font.Style + [fsBold];
    renderwordwrap(Buffer, fmanager[t1].name, textleft, itemtop + textheadingtop, width - textright, -1000, 0, clblack32);

    buffer.font.size := 8;
    buffer.Font.Style := buffer.Font.Style - [fsBold];
    if length(fmanager[t1].description) > 0 then
      y := renderwordwrap(buffer, fmanager[t1].description, textleft, itemtop + textdesctop, width - textright, itembottom - descbottom, 0, clblack32) else
      y := itemtop + textdesctop;

    inc(y, 2); //extra breathing space

    if showenabled and (fmanager.indexof(fmanager.activeprofile) = t1) then
      desc := '(current) ' else
      desc := '';

    list := TStringList.Create;
    try
      if fmanager.findpets(fmanager.profiles[t1], list) then begin
        if list.count > 1 then begin
        if cpetzver=pvbabyz then
          desc := desc + inttostr(list.count) + ' babies: ' else
          desc := desc + inttostr(list.count) + ' pets: ';
        end else begin
        if cpetzver=pvbabyz then
          desc := desc + inttostr(list.count) + ' baby: ' else
          desc := desc + inttostr(list.count) + ' pet: ';
        end;
        
        for t2 := 0 to list.count - 1 do begin
          desc := desc + stripfileext(ExtractFileName(list[t2]));
          if t2 <> list.count - 1 then
            desc := desc + ', ';
        end;
      end else begin
        if cpetzver=pvbabyz then
        desc := desc + 'No babies in this profile' else
        desc := desc + 'No pets in this profile';
      end;
    finally
      list.free;
    end;

    renderwordwrap( Buffer, desc, textleft, y, width - textright, itembottom-2, 0, clblack32);

    //now draw icon and shadow, if any
    if (fmanager[t1].icon.width > 0) and (fmanager[t1].icon.height > 0) then begin

      drawshadow := (fselindex = t1) and (enabled);

      drawframedicon(fmanager[t1].icon,buffer,7,itemtop+7,drawshadow);
    end;
  end;

  if fscrollbar.visible then
    fscrollbar.PaintTo(Buffer.Handle, fscrollbar.Left, 0);
end;

destructor tprofilelistdisplay.destroy;
begin
  fscrollbar.free;
  inherited;
end;

procedure TProfileListDisplay.setmanager(value: TProfileManager);
begin
  fmanager := value;
  if fmanager <> nil then begin
    selindex := fmanager.indexof(fmanager.activeprofile);
  end;
end;

procedure tprofilelistdisplay.KeyDown(var Key: Word; Shift: TShiftState);
begin
  inherited;
  case key of
    vk_down: begin
        selindex := selindex + 1;
      end;
    vk_up: begin
        selindex := selindex - 1;
      end;
  end;
end;

procedure tprofilelistdisplay.doubleclick(sender: TObject);
begin
  if (selindex <> -1) and assigned(fonexecute) then
    fonexecute(self, selindex);
end;

procedure tprofilelistdisplay.wheelmoved(Sender: TObject; Shift: TShiftState;
  WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
begin
  Handled := true;
  fscrollbar.Position := fscrollbar.Position - wheeldelta div 2;
end;

constructor tprofilelistdisplay.create(aOwner: Tcomponent);
begin
  inherited create(aowner);
  OnDblClick := doubleclick;
  Options := options + [pboAutoFocus, pboWantarrowkeys];
  fshowenabled := false;
  fitemheight := 70;
  fselindex := -1;
  fscroll := 0;
  fscrollbar := TScrollBar.Create(self);
  fscrollbar.Kind := sbVertical;
  fscrollbar.top := 0;
  fscrollbar.min:=0;
  fscrollbar.LargeChange := 15;
  fscrollbar.Smallchange := 5;
  fscrollbar.parent := self;
  fscrollbar.OnChange := scrollchange;
  fscrollbar.PageSize := fitemheight;
  OnMouseWheel := wheelmoved;
end;

end.

