unit nakedbitmaploader;

interface

uses sysutils, Classes, windows, graphics, math;

type
  TNakedBitmapLoader = class(TBitmap)
  public
    procedure LoadNakedFromStream(stream: TStream);
    procedure LoadNakedFromBuffer(buffer: Pointer; size: integer);
  end;

implementation

procedure TNakedBitmapLoader.LoadNakedFromStream(stream: TStream);
var
  header: BITMAPINFOHEADER;
  size: longword;
  palette: TMaxLogPalette;
  y, t1: integer;
  bytesperpixel: Byte;
  scanlinepadding, scanlinewidth: integer;

begin
  stream.Read(size, 4);
  stream.read(header.biWidth, min(size - 4, sizeof(bitmapinfoheader)));
  stream.position := size; //if header was larger than expected we now need to correct a little
       //allow changes in header size

  height := header.biHeight;
  Width := header.biWidth;

  case header.bibitcount of
    8: PixelFormat := pf8bit;
    16: PixelFormat := pf16bit;
    24: PixelFormat := pf24bit;
    32: PixelFormat := pf32bit;
  end;

  if (pixelformat = pf8bit) then begin //palletized
   //how many entries are there in this palette?
    if (header.biClrUsed = 0) then
      header.biClrUsed := 1 shl header.biBitCount; //we use the maximum number of entries

    palette.palVersion := $0300; // "Magic Number" for Windows LogPalette
    palette.palNumEntries := header.biClrUsed;

    for t1 := 0 to header.biClrUsed - 1 do begin
      stream.read(palette.palPalEntry[t1].peBlue, 1);
      stream.read(palette.palPalEntry[t1].peGreen, 1);
      stream.read(palette.palPalEntry[t1].peRed, 1);
      stream.read(palette.palPalEntry[t1].peFlags, 1);
    end;

    self.Palette := CreatePalette(plogpalette(@palette)^); //nasty, nasty typecast. Stupid delphi :)
  end;

  case header.biBitCount of
    8: bytesperpixel := 1;
    16: bytesperpixel := 2;
    24: bytesperpixel := 3;
    32: bytesperpixel := 4;
  else raise exception.create('Unknown bitmap depth ' + inttostr(header.biBitCount));
  end;

  if (header.biWidth * bytesperpixel) and 3 = 0 then
    scanlinepadding := 0 else
    scanlinepadding := 4 - ((header.biWidth * bytesperpixel) and 3);

  scanlinewidth := header.biWidth * bytesperpixel + scanlinepadding;

  //bitmaps are stored upside down
  for y := height - 1 downto 0 do
    stream.read(scanline[y]^, scanlinewidth);
end;

procedure TNakedBitmapLoader.LoadNakedFromBuffer(buffer: Pointer; size: integer);
begin
end;


end.

