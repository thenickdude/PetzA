unit FramedIcons;

interface

uses types, sysutils, classes, math, GR32, GR32_Polygons, GR32_VectorUtils, FastBoxBlur;

procedure DrawFramedIcon(icon: TBitmap32; dest: TBitmap32; destx, desty: integer; drawshadow: boolean; framesize: integer = 50; shadowradius: integer = 2);
procedure BmpTrim(var bitmap: TBitmap32; maxwidth, maxheight: integer);

implementation

procedure BmpTrim(var bitmap: TBitmap32; maxwidth, maxheight: integer);
var
  temp: tbitmap32;
  newwidth, newheight: integer;
begin
  newwidth := min(maxwidth, bitmap.width);
  newheight := min(maxheight, bitmap.height);

  if (newwidth <> bitmap.width) or (newheight <> bitmap.height) then begin
    temp := tbitmap32.create;
    temp.outercolor := bitmap.outercolor;
    temp.setsize(newwidth, newheight);
    bitmap.DrawTo(temp, 0, 0);
    bitmap.free;
    bitmap := temp;
  end;
end;

function FixedPoints(const floatPoints: TArrayOfFloatPoint; xoffs: integer = 0; yoffs: integer = 0):TArrayOfFixedPoint;
var
  i: Integer;
  point:TFloatPoint;
begin
  SetLength(result, length(floatPoints));

  for i := 0 to high(floatPoints) do begin
    point.X := floatpoints[i].X + xoffs;
    point.Y := floatPoints[i].Y + yoffs;
    result[i] := FixedPoint(point);
  end;
end;

procedure DrawFramedIcon(icon: TBitmap32; dest: TBitmap32; destx, desty: integer; drawshadow: boolean; framesize: integer = 50; shadowradius: integer = 2);
const
  shadowoffset = 2;
  frameWidth = 1;
var
  temp, shadow: TBitmap32;
  x, y: integer;
  shadowmargin: integer;

  maskrect: TArrayOfFloatPoint;
begin
 // inflate the shadow bitmap a little to allow for blurring beyond original boundaries
  shadowmargin := shadowradius;

  MaskRect := RoundRect(FloatRect(0.5, 0.5, framesize - 1.5, framesize - 1.5), 5);

  // Close off the boundary of the rounded rect
  SetLength(maskrect, length(maskrect) + 1);
  maskrect[high(maskrect)] := maskrect[0];

  temp := tbitmap32.create;
  shadow := tbitmap32.create;
  try
    temp.setsize(framesize, framesize);
    temp.Clear(color32(0, 0, 0, 0));

    if drawshadow then begin
      shadow.setsize(framesize + shadowmargin * 2, framesize + shadowmargin * 2);
      shadow.clear(color32(0, 0, 0, 0));
    end;

    // Draw rounded rectangle mask to hold the icon
    PolygonXS(temp, FixedPoints(maskrect), clwhite32);

    // Shadow gets a copy of the mask in black
    if drawshadow then begin
      for y := 0 to temp.height - 1 do begin
        for x := 0 to temp.width - 1 do begin
          shadow.pixel[x + shadowmargin, y + shadowmargin] := temp.pixel[x, y] shl 24;
        end;
      end;

      // Then blurred and composited onto the dest
      boxblur(shadow, shadowradius, 2);
      shadow.DrawMode := dmBlend;
      shadow.drawto(dest, destx - shadowmargin + shadowoffset, desty - shadowmargin + shadowoffset);
    end;

    // Icon image gets masked into the temp buffer

    // Icons smaller than required will be filled with this colour around the edges
    icon.OuterColor := clWhite32;

    for y := 0 to temp.height - 1 do begin
      for x := 0 to temp.width - 1 do begin
        temp.pixel[x, y] := icon.PixelS[x, y] and $FFFFFF or (temp.pixel[x, y] shl 24);
      end;
    end;

    // And drawn onto the target
    temp.DrawMode := dmBlend;
    temp.DrawTo(dest, destx, desty);

    // Draw a frame on top
    PolylineXS(
      dest,
      FixedPoints(maskrect, destx, desty),
      color32(0, 0, 0, 200),
      false,
      Fixed(1.0)
    );
  finally
    temp.free;
    shadow.free;
  end;
end;
end.

