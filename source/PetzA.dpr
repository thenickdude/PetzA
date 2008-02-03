library petza;



uses
  madListHardware,
  madListProcesses,
  madListModules,
  madExcept,
  madLinkDisAsm,
  SysUtils,
  petzaunit in 'petzaunit.pas',
  bndpetz in 'bndpetz.pas',
  Classes,
  madkernel,
  dialogs,
  controls,
  forms,
  windows,
  contnrs,
  messages,
  HCMngr,
  decutil,
  clipbrd,
  registry,
  typinfo,
  dllpatchunit in 'dllpatchunit.pas',
  petzclassesunit in 'petzclassesunit.pas',
  aboutunit in 'aboutunit.pas' {frmAbout},
  mymenuunit in 'mymenuunit.pas',
  sliderbrainunit in 'sliderbrainunit.pas' {frmSliderBrain},
  petzcommon in 'petzcommon.pas',
  frmmateunit in 'frmmateunit.pas' {frmMate},
  mymessageunit in 'mymessageunit.pas' {frmMyMessage},
  setchildrenunit in 'setchildrenunit.pas' {frmSetnumchildren},
  debugunit in 'debugunit.pas' {frmDebug},
  gamespeedunit in 'gamespeedunit.pas' {frmGameSpeed},
  trimfamilytreeunit in 'trimfamilytreeunit.pas' {frmTrimFamilyTree},
  nomatchunit in 'nomatchunit.pas' {frmNoMatch},
  profilemanagerunit in 'profilemanagerunit.pas' {frmProfileManager},
  pickprofileunit in 'pickprofileunit.pas' {frmPickProfile},
  profilelistdisplay in 'profilelistdisplay.pas',
  petzprofilesunit in 'petzprofilesunit.pas',
  profileeditunit in 'profileeditunit.pas' {frmProfileEdit},
  frmpickiconunit in 'frmpickiconunit.pas' {frmPickIcon},
  framediconunit in 'framediconunit.pas',
  frmsettingsunit in 'frmsettingsunit.pas' {frmSettings},
  nakedbitmaploader in 'nakedbitmaploader.pas',
  vectorUnit in 'vectorUnit.pas';

{$E toy}
{$R *.RES}

type tfileidrecord = record
    date: tdatetime;
    size: integer;
  end;
  thashrecord = record
    matches: boolean;
    hash: string;
  end;

function checkhash: thashrecord;
var hash: THashManager;
  t1: integer;
  s: string;
begin
  result.matches := false;
  hash := THashManager.Create(nil);
  try
    hash.Algorithm := 'Message Digest 5';
    hash.CalcFile(application.exename);
    s := hash.DigestString[fmthex];
    Clipboard.AsText := s;
    result.hash := s;
    for t1 := 0 to high(petzhashes) do
      if (petzhashes[t1].ver = cpetzver) and (petzhashes[t1].hash = s) then begin
        result.matches := true;
        break;
      end;

  finally
    hash.free;
  end;
end;

function getfiledetails(sFileName: string): tfileidrecord;
var
  ffd: TWin32FindData;
  dft: DWORD;
  lft: TFileTime;
  h: THandle;
begin
  h := Windows.FindFirstFile(PChar(sFileName), ffd);
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

function petz3isgerman: boolean;
var
  nHwnd: DWORD;
  BufferSize: DWORD;
  Buffer: Pointer;
  temp: string;
  tempsize: cardinal;
  p: pointer;
begin
  BufferSize := GetFileVersionInfoSize(pchar(application.exename), nHWnd);

  result := false;

  if BufferSize <> 0 then begin {if zero, there is no version info}
    GetMem(Buffer, BufferSize); {allocate buffer memory}
    try
      if GetFileVersionInfo(PChar(application.exename), nHWnd, BufferSize, Buffer) then begin
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

function IsKeyDown(vk: integer): Boolean;
begin
  Result := (GetAsyncKeyState(vk) < 0);
end;

function PetzScreensaverActive(out name: string): Boolean;
var
  t1: integer;
  p: IProcesses;
begin
  result := false;
  p := processes;
  for t1 := 0 to p.ItemCount - 1 do
    if AnsiCompareText(ExtractFileName(p[t1].ExeFile), ChangeFileExt(extractfilename(application.exename), '.scr')) = 0 then begin
      name := p[t1].ExeFile;
      result := True;
      exit;
    end;
end;

var name: string;
  temp: string;
  reg: tregistry;
  pre: string;
  proghash: thashrecord;
  details: tfileidrecord;
begin
  try
    petzaunit.petza := nil;
    frmdebug := nil;
 //   frmportdisplay := nil;

    logging := iskeydown(VK_CONTROL);

    if logging then begin
      doLog('');
      doLog('PetzA started ' + datetimetostr(now));
      doLog('');
    end;

    if iskeydown(VK_CONTROL) and iskeydown(VK_MENU) then begin
      doLog('Control and Alt held down, PetzA is aborting');
      exit; // do not load;
    end;

    if PetzScreensaverActive(temp) then begin
      doLog('Screensaver running: "' + temp + '", PetzA is aborting');
      exit;
    end;
     {don't load if there is a program with extension .scr running}

    name := uppercase(extractfilename(application.exename));

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
      if petz3isgerman then cpetzver := pvPetz3german
      else
        cpetzver := pvpetz3;
    end;
    if name = 'PETZ II.EXE' then begin
      cpetzver := pvpetz2;
    end;

    if cpetzver = pvunknown then begin
      showmessage('This is an unknown version of Petz! PetzA will not run');
      exit;
    end;


    reg := TRegistry.Create;
    try
      reg.RootKey := HKEY_CURRENT_USER;
      if reg.OpenKey(petzakeyname, true) then begin
        pre := uppercase(GetEnumName(TypeInfo(tpetzvername), integer(cpetzver)));
        details := getfiledetails(application.exename);

        if not (reg.ValueExists(pre + '-filesize') and (reg.ReadInteger(pre + '-filesize') = details.size) and
          reg.ValueExists(pre + '-filedate') and (abs(reg.ReadFloat(pre + '-filedate') - details.date) < 10 / secsperday)) then begin
        //is not checked yet
          proghash := checkhash;
          if not proghash.matches then begin
            frmNoMatch := TfrmNoMatch.Create(nil);
            frmnomatch.showmodal;
            exit; //abort!
          end else begin
      //exe is checked and valid. store identifying information so we don't scan again
            reg.writeinteger(pre + '-filesize', details.size);
            reg.WriteFloat(pre + '-filedate', details.date);
          end;
        end;
      end;
    finally
      reg.free;
    end;

    loadimports;
{$IFDEF petzadebug}
    frmdebug := tfrmdebug.create(application);
    frmdebug.show;
{$ENDIF}
    if logging then
      dolog('Starting PetzA...');
    petzaunit.petza := TPetza.create;
  except
    showmessage('Couldn''t load PetzA!');
    HandleException;
  end;
end.

