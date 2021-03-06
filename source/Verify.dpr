library Verify;

{Utility DLL for the installer}
uses
  SysUtils,
  Classes,
  windows,
  bndpetz,
  DECHash,
  DECFormat,
  scizipfile;

type
  tfileidrecord = record
    date: tdatetime;
    size: integer;
  end;
  thashrecord = record
    matches: boolean;
    hash: string;
  end;

function MD5File(const filename:string):string;
var
  hash: THash_MD5;
begin
  hash := THash_MD5.Create();
  try
    hash.CalcFile(filename);
    result := hash.DigestAsString(TFormat_HEX);
  finally
    hash.Free;
  end;
end;

function checkhash(cpetzver: tpetzvername; const filename: string): thashrecord;
var t1: integer;
begin
  result.matches := false;
  Result.hash := MD5File(filename);
  for t1 := 0 to high(petzhashes) do
    if (petzhashes[t1].ver = cpetzver) and (petzhashes[t1].hash = result.hash) then begin
      result.matches := true;
      break;
    end;
end;

function getfiledetails(const sFileName: string): tfileidrecord;
var
  ffd: TWin32FindData;
  dft: DWORD;
  lft: TFileTime;
  h: THandle;
begin
  h := Windows.FindFirstFile(PWideChar(sFileName), ffd);
  if (INVALID_HANDLE_VALUE <> h) then
  begin
    Windows.FindClose(h);

    //
    // convert the FILETIME to
    // local FILETIME
    FileTimeToLocalFileTime(ffd.ftLastWriteTime, lft);
    //
    // convert FILETIME to
    // DOS time
    FileTimeToDosDateTime(lft, LongRec(dft).Hi, LongRec(dft).Lo);
    //
    // finally, convert DOS time to
    // TDateTime for use in Delphi's
    // native date/time functions
    Result.date := FileDateToDateTime(dft);
    result.size := ffd.nFileSizeLow
  end;
end;

function petz3isgerman(const filename: string): boolean;
var
  nHwnd: DWORD;
  BufferSize: DWORD;
  Buffer: Pointer;
  temp: string;
  tempsize: cardinal;
  p: pointer;
begin
  BufferSize := GetFileVersionInfoSize(PWideChar(filename), nHWnd);

  result := false;

  if BufferSize <> 0 then begin {if zero, there is no version info}
    GetMem(Buffer, BufferSize); {allocate buffer memory}
    try
      if GetFileVersionInfo(PWideChar(filename), nHWnd, BufferSize, Buffer) then begin
            {got version info}
        setlength(temp, 1000);
        p := @temp[1];
        if VerQueryValue(Buffer, '\StringFileInfo\040904b0\Kommentare', p, tempsize) then begin
          result := true;
        end else begin
          Result := False;
        end;
      end;
    finally
      FreeMem(Buffer, BufferSize); {release buffer memory}
    end;
  end;
end;

{Unpack the single file in the zip file 'filename', overwriting the file
 'dest'}
function UnpackDLL(filename, dest: PWideChar): boolean; stdcall;
var
  zip: TZipFile;
  t1: integer;
  uncompressed: ansistring;
  output:tfilestream;
begin
  try
    zip := TZipFile.Create;
    try
      zip.LoadFromFile(String(filename));
      for t1 := 0 to zip.Count - 1 do begin
        output:=TFileStream.Create(dest, fmcreate or fmsharedenywrite);
        try
        uncompressed := zip.Uncompressed[t1];
        if length(uncompressed)>0 then
         output.write(uncompressed[1], length(uncompressed));
        finally
          output.free;
        end;
       end;
    finally
      zip.Free;
    end;
    result := true;
  except
    result := false;
  end;
end;

function VerifyPetzExe(path: PWideChar; var cpetzver: tpetzvername): boolean; stdcall;
var name: string;
begin
  try
    name := uppercase(extractfilename(string(path)));

    cpetzver := pvUnknown;
    if name = 'BABYZ.EXE' then begin
      cpetzver := pvBabyz;
    end;
    if name = 'PETZ 5.EXE' then begin
      cpetzver := pvPetz5;
    end;
    if name = 'PETZ 4.EXE' then begin
      cpetzver := pvPetz4;
    end;
    if name = 'PETZ 3.EXE' then begin
      if petz3isgerman(path) then cpetzver := pvPetz3german
      else
        cpetzver := pvpetz3;
    end;
    if name = 'PETZ II.EXE' then begin
      cpetzver := pvpetz2;
    end;

    result := checkhash(cpetzver, path).matches;
  except
    cpetzver := pvUnknown;
    result := false;
  end;
end;

exports VerifyPetzExe, UnpackDLL;

begin
end.

