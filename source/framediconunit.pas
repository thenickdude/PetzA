unit framediconunit;

interface

uses types, sysutils, classes, math, GR32, G32_Interface, FastBoxBlur;

procedure drawframedicon(icon: TBitmap32; dest: TBitmap32; destx, desty: integer; drawshadow: boolean; framesize: integer = 50; shadowradius: integer = 2);
procedure bmptrim(var bitmap: TBitmap32; maxwidth, maxheight: integer);

implementation

procedure bmptrim(var bitmap: TBitmap32; maxwidth, maxheight: integer);
var temp: tbitmap32;
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

procedure drawframedicon(icon: TBitmap32; dest: TBitmap32; destx, desty: integer; drawshadow: boolean; framesize: integer = 50; shadowradius: integer = 2);
const shadowoffset = 2;
var temp, shadow: TBitmap32;
  x, y: integer;
  shadowmargin: integer;
begin
 // inflate the shadow bitmap a little to allow for blurirng beyond original boundaries
  shadowmargin := shadowradius;

  icon.OuterColor := clWhite32;
  temp := tbitmap32.create;
  shadow := tbitmap32.create;
  try
    temp.setsize(framesize, framesize);
    temp.Clear(clblack32);

    if drawshadow then begin
      shadow.setsize(framesize + shadowmargin * 2, framesize + shadowmargin * 2);
      shadow.drawmode := dmblend;
      shadow.masteralpha := 100;
      shadow.clear(color32(0, 0, 0, 0));
    end;

        //draw mask
    gRectangleRounded(temp, FixedRect(rect(0, 0, framesize - 1, framesize - 1)), fixed(5), clwhite32, pdoFilling or pdoAntialising);

    for y := 0 to temp.height - 1 do
      for x := 0 to temp.width - 1 do begin
        if drawshadow then shadow.pixel[x + shadowmargin, y + shadowmargin] := temp.pixel[x, y] shl 24;
        temp.Pixel[x, y] := icon.PixelS[x, y] and $FFFFFF or (temp.pixel[x, y] shl 24);
      end;

        //draw frame
    gRectangleRounded(temp, FixedRect(rect(0, 0, framesize - 1, framesize - 1)), fixed(5), color32(0, 0, 0, 200), pdoAntialising or pdoFloat);

    if drawshadow then begin
      boxblur(shadow, shadowradius, 2);
      shadow.drawto(dest, destx - shadowmargin + shadowoffset, desty - shadowmargin + shadowoffset);
    end;

    temp.drawmode := dmBlend;
    temp.drawto(dest, destx, desty);
  finally
    temp.free;
    shadow.free;
  end;
end;
end.

 