unit frmpickiconunit;

interface

uses
  Windows, Contnrs, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, GR32_Image, GR32_Blend, DrawGrid32, Registry, FileCtrl, gr32, math,
  framediconunit, jpeg, GIFImage, pngimage, HCMngr, DECUtil;

type
  TfrmPickIcon = class(TForm)
    icongrid: TItemGrid32;
    Button1: TButton;
    btnOk: TButton;
    Button2: TButton;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure icongridDrawItem(buffer: TBitmap32; itemindex: Integer;
      cellrect: TRect; state: TDrawState32);
    procedure icongridSelectCell(sender: TObject; itemindex: Integer);
  private
    { Private declarations }
  public
    { Public declarations }
    icons: TObjectList;
    procedure eliminatedups;
    function selicon: TBitmap32;
  end;

var
  frmPickIcon: TfrmPickIcon;

implementation
uses petzaunit, petzprofilesunit;
{$R *.DFM}

function TFrmPickIcon.selicon: TBitmap32;
begin
  result := tbitmap32(icons[icongrid.selindex]);
end;

procedure TFrmPickIcon.eliminatedups;
var t1, t2: integer;
  p: PColor32;
  sum: string;
  sums: array of string;
  icon: Tbitmap32;
  found: boolean;
  hash: THashManager;
begin

  hash := THashManager.Create(nil);
  try
    hash.Algorithm := 'Message Digest 5';


    for t1 := icons.Count - 1 downto 0 do begin
      icon := tbitmap32(icons[t1]);
      p := icon.PixelPtr[0, 0];

      hash.CalcBuffer(p^, icon.width * icon.height * sizeof(tcolor32));
      sum := hash.DigestString[fmthex];

   //have we found this icon already..?
      found := false;
      for t2 := 0 to high(sums) do
        if sums[t2] = sum then begin
          found := true;
          Break;
        end;
      if found then
        icons.Delete(t1) else begin //we have this one already
        SetLength(sums, length(sums) + 1);
        sums[high(sums)] := sum;
      end;
    end;
  finally
    hash.free;
  end;
end;

procedure TfrmPickIcon.FormCreate(Sender: TObject);
var reg: TRegistry;
  path: string;
  r: TSearchRec;
  bmp: tbitmap32;
  t1: integer;
  s: string;
  list: tstringlist;
begin
  borderstyle := bsSizeable;

  icons := TObjectlist.create;

  reg := TRegistry.Create;
  try
    reg.rootkey := HKEY_CURRENT_USER;
    if reg.OpenKey(petzakeyname, false) then begin
      if reg.ValueExists('InstallPath') then
        path := IncludeTrailingBackslash(reg.ReadString('InstallPath')) + 'Profile Icons';
    end;
  finally
    reg.free;
  end;

  for t1 := 0 to profilemanager.count - 1 do
    if profilemanager[t1].icon.Width > 0 then begin
      bmp := tbitmap32.create;
      bmp.assign(profilemanager[t1].icon);
      icons.Add(bmp);
    end;

  if (length(path) > 0) and DirectoryExists(path) then begin

  //Find filetypes for images that we can open..
  //Take *.bmp;*.jpg;*.gif and turn into *.bmp,*.jpg etc..
    s := StringReplace(GraphicFileMask(TGraphic), ';', ',', [rfReplaceall]);
    list := tstringlist.create;
    try
      list.commatext := s;
      for t1 := 0 to list.count - 1 do begin
        if FindFirst(path + '\' + list[t1], faAnyFile and not faDirectory, r) = 0 then begin
          if (r.Name = '.') or (r.Name = '..') then Continue;
          repeat
            bmp := tbitmap32.create;
            try
              bmp.loadfromfile(path + '\' + r.Name);
              bmptrim(bmp, 64, 64); //trim a little..
            except
              FreeAndNil(bmp);
            end; //failed to load a bitmap? No problem, just ignore it!
            if bmp <> nil then
              icons.Add(bmp);
          until FindNext(r) <> 0;
          FindClose(r);
        end;
      end;
    finally
      list.free;
    end;
  end;

  eliminatedups;
  icongrid.ItemCount := icons.count;

end;

procedure TfrmPickIcon.FormDestroy(Sender: TObject);
begin
  icons.free;
end;

procedure TfrmPickIcon.icongridDrawItem(buffer: TBitmap32;
  itemindex: Integer; cellrect: TRect; state: TDrawState32);
var col1, col2: TColor32;
  bounds: TRect;
  y: integer;
begin
  if itemindex = icongrid.SelIndex then begin
    bounds.left := max(cellrect.left, 0);
    bounds.right := min(cellrect.right - 1, buffer.width - 1);
    bounds.top := Max(cellrect.Top, 0);
    bounds.bottom := min(cellrect.bottom - 1, buffer.height - 1);
    col1 := Color32(220, 220, 255);
    col2 := Color32(180, 180, 255);
    try
      for y := bounds.top to bounds.bottom do
        buffer.HorzLine(bounds.left, y, bounds.right, BlendReg(SetAlpha(col2, ((y - cellrect.top) * 255) div (cellrect.bottom - cellrect.top)), col1));
    finally
      emms;
    end;
  end;
  drawframedicon(TBitmap32(icons[itemindex]), buffer, cellrect.Left + 6, cellrect.top + 6, true);
end;

procedure TfrmPickIcon.icongridSelectCell(sender: TObject;
  itemindex: Integer);
begin
  btnOk.enabled := itemindex <> -1;

end;

end.

