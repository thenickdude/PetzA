#define MyAppName "PetzA"
#define MyAppVerName 'PetzA '+copy(getfileversion('build\petza.toy'),1,rpos('.',getfileversion('build\petza.toy'))-1)
#define PetzAVer copy(getfileversion('build\petza.toy'),1,rpos('.',getfileversion('build\petza.toy'))-1)
#define MyAppPublisher "Sherlock Software"
#define MyAppURL "http://www.sherlocksoftware.org/"
#define MyAppUrlName "Visit Sherlock Software.url"

[Setup]
AppName={#MyAppName}
AppVerName={#MyAppVerName}
AppPublisher={#MyAppPublisher}
AppPublisherURL={#MyAppURL}
AppSupportURL={#MyAppURL}
AppUpdatesURL={#MyAppURL}
DefaultDirName={pf}\Sherlock Software\PetzA
DefaultGroupName=Sherlock Software\PetzA
OutputBaseFilename=PetzA{#PetzAVer}
OutputDir=.
Compression=lzma
SolidCompression=true
ShowLanguageDialog=yes

[Languages]
Name: english; MessagesFile: compiler:Default.isl

[Files]
Source: build\verify.dll; Flags: dontcopy; DestDir: {tmp}
Source: build\petza.toy; DestDir: {app}; Flags: ignoreversion
Source: build\PetzAHelp.chm; DestDir: {app}; Flags: ignoreversion
Source: proficons\*.*; DestDir: {app}\Profile Icons; Flags: ignoreversion
Source: build\petza.toy; DestDir: {code:GetPetzAInstallDir|0}; Check: CheckPetzAInstall(0); Flags: ignoreversion
Source: build\petza.toy; DestDir: {code:GetPetzAInstallDir|1}; Check: CheckPetzAInstall(1); Flags: ignoreversion
Source: build\petza.toy; DestDir: {code:GetPetzAInstallDir|2}; Check: CheckPetzAInstall(2); Flags: ignoreversion
Source: build\petza.toy; DestDir: {code:GetPetzAInstallDir|3}; Check: CheckPetzAInstall(3); Flags: ignoreversion
Source: build\petza.toy; DestDir: {code:GetPetzAInstallDir|4}; Check: CheckPetzAInstall(4); Flags: ignoreversion
Source: build\petza.toy; DestDir: {code:GetPetzAInstallDir|5}; Check: CheckPetzAInstall(5); Flags: ignoreversion
Source: build\petza.toy; DestDir: {code:GetPetzAInstallDir|6}; Check: CheckPetzAInstall(6); Flags: ignoreversion
Source: build\petza.toy; DestDir: {code:GetPetzAInstallDir|7}; Check: CheckPetzAInstall(7); Flags: ignoreversion
Source: build\petza.toy; DestDir: {code:GetPetzAInstallDir|8}; Check: CheckPetzAInstall(8); Flags: ignoreversion
Source: build\petza.toy; DestDir: {code:GetPetzAInstallDir|9}; Check: CheckPetzAInstall(9); Flags: ignoreversion
Source: build\petza.toy; DestDir: {code:GetPetzAInstallDir|10}; Check: CheckPetzAInstall(10); Flags: ignoreversion

[Registry]
Root: HKCU; Subkey: Software\Sherlock Software\PetzA; ValueType: string; ValueName: InstallPath; ValueData: {app}; Flags: uninsdeletekey
Root: HKCU; Subkey: Software\Sherlock Software\PetzA; ValueType: string; ValueName: Helpfile; ValueData: {app}\PetzAHelp.chm; Flags: uninsdeletekey

[INI]
Filename: {app}\{#MyAppUrlName}; Section: InternetShortcut; Key: URL; String: {#MyAppURL}

[Icons]
Name: {group}\Read help file; Filename: {app}\PetzAHelp.chm
Name: {group}\Visit Sherlock Software; Filename: {app}\{#MyAppUrlName}
Name: {group}\{cm:UninstallProgram,{#MyAppName}}; Filename: {uninstallexe}

[UninstallDelete]
Type: files; Name: {app}\{#MyAppUrlName}

[Messages]
FinishedLabel=Setup has finished installing [name] on your computer. It will appear as a new menu item ("PetzA") inside the Petz games that you have chosen to automatically install to.%n%nYou can manually install PetzA by copying it from its install folder to the Resource\Toyz folder of the Petz version you want to add it to.

#include ReadReg(HKEY_LOCAL_MACHINE,'Software\Sherlock Software\InnoTools\Downloader','ScriptPath','')

[Code]
const
  CUSTOM_PEXE_COUNT = 3;

type
  TPetzVerName = (pvUnknown, pvpetz2, pvPetz3, pvPetz3German, pvPetz4, pvPetz5, pvBabyz);
  TPetzTaggedString = record
    ver: Tpetzvername;
    s: string;
  end;
  TPetzExeRec = record
    filename, dispname: string;
    ver: TPetzVerName;
  end;

var
  Page: TInputOptionWizardPage;
  Page2: TInputFileWizardPage;
  pickupdates: TInputOptionWizardPage;
  petzexes, totalpetzexes: array of tpetzexerec;
  petznames: array of record
    keyname, filename, dispname: string;
    ver: TPetzVerName;
  end;
  todownload: array of record
    tmpsource, dest: string;
    ver: TPetzvername;
  end;
  willNeedRestart:boolean;

function VerifyPetzExe(path: PChar; var cpetzver: tpetzvername): boolean;
  external 'VerifyPetzExe@files:verify.dll stdcall';

function UnpackDLL(filename, dest: pchar): boolean;
  external 'UnpackDLL@files:verify.dll stdcall';

function checkpetzainstall(index:integer):boolean;
begin
 result:=index<GetArrayLength(TotalPetzExes);
end;

function getpetzainstalldir(param:string):string;
var index:integer;
begin
 index:=strtoint(param);
 if checkpetzainstall(index) then
  result:=extractfilepath(totalpetzexes[index].filename)+'resource\toyz' else
  result:='';
end;

procedure showmessage(const s:string);
begin
 msgbox(s, mbInformation,MB_OK);
end;

function petzvername(ver: tpetzvername): string;
begin
  case ver of
    pvPetz2: result := 'Petz 2';
    pvPetz3: result := 'Petz 3';
    pvPetz3German: result := 'Petz 3 (German)';
    pvPetz4: result := 'Petz 4';
    pvPetz5: result := 'Petz 5';
    pvBabyz: result := 'Babyz';
  else result := 'Petz';
  end;
end;

function includebackslash(const path:string):string;
begin
 if pos(#0,path)>0 then
  setlength(path,pos(#0,path)-1);
 if length(path)>0 then begin
  if path[length(path)]='\' then
   result:=path else
   result:=path+'\';
 end else result:='';
end;

procedure findpetzfolders;
var
  root: string;
  i: integer;
begin
  for i := 0 to getarraylength(petznames) - 1 do begin
    if RegQueryStringValue(HKEY_LOCAL_MACHINE, petznames[i].keyname, 'Petz Root Path', root) then begin
      root := includebackslash(root);
      if FileExists(root + petznames[i].filename) then begin
        setarraylength(petzexes, getarraylength(petzexes) + 1);
        petzexes[getarraylength(petzexes) - 1].filename := root + petznames[i].filename;
        petzexes[getarraylength(petzexes) - 1].dispname := petznames[i].dispname;
      end;
    end;
  end;
end;

procedure checkanddownload(petzver: TPetzvername; const source, destname: string);
var t1: integer;
  fn: string;
  add: boolean;
begin
  add := false;
  fn := expandconstant('{tmp}\' + destname); //so we know where to pick up from later

  for t1 := 0 to getarraylength(todownload) - 1 do
    if pickupdates.values[t1] and (todownload[t1].ver = petzver) then begin
      todownload[t1].tmpsource := fn;
      add := true;
    end;

  if add then itd_addfile(source, fn); //only downloads a file once
end;

function NextButtonClick(CurPageID: Integer): Boolean;
var t1: integer;
  ver: TPetzVerName;
begin
  result := true;

  if curpageid = page2.id then begin
  //Build total list of exes
    setarraylength(totalpetzexes,0);

    for t1 := 0 to getarraylength(petzexes) - 1 do
      if (page<>nil) and page.values[t1] then begin
        setarraylength(totalpetzexes, getarraylength(totalpetzexes) + 1);
        totalpetzexes[getarraylength(totalpetzexes) - 1] := petzexes[t1];
      end;

    for t1 := 0 to CUSTOM_PEXE_COUNT - 1 do
      if length(page2.values[t1]) > 0 then begin
        setarraylength(totalpetzexes, getarraylength(totalpetzexes) + 1);
        totalpetzexes[getarraylength(totalpetzexes) - 1].filename := page2.values[t1];
      end;

  //Just in case:
    itd_clearfiles;

  //Build list of exes that need updating
    pickupdates.checklistbox.items.clear;
    setarraylength(todownload, 0);
    for t1 := 0 to GetArrayLength(totalpetzexes) - 1 do
      if not VerifyPetzExe(pchar(totalpetzexes[t1].filename), ver) then begin
        if ver = pvUnknown then continue; //something bad happened with checking it
        pickupdates.add(petzvername(ver) + ' (' + totalpetzexes[t1].filename + ')');
        pickupdates.values[pickupdates.checklistbox.items.count - 1] := true;

        setarraylength(todownload, getarraylength(todownload) + 1);
        todownload[getarraylength(todownload) - 1].dest := totalpetzexes[t1].filename;
        todownload[getarraylength(todownload) - 1].ver := ver;
      end;

  end else
  if curpageid=pickupdates.id then begin
      itd_clearfiles;

      checkanddownload(pvPetz5, 'http://www.sherlocksoftware.org/petz/files/dogz5.zip', 'Petz 5.zip');
      checkanddownload(pvPetz4, 'http://www.sherlocksoftware.org/petz/files/petz4.zip', 'Petz 4.2.zip');
      checkanddownload(pvPetz3, 'http://www.sherlocksoftware.org/petz/files/petz3.zip', 'Petz 3.zip');
      checkanddownload(pvPetz3German, 'http://www.sherlocksoftware.org/petz/files/petz3german.zip', 'Petz 3 German.zip');
      checkanddownload(pvPetz2, 'http://www.sherlocksoftware.org/petz/files/petz2.zip', 'Petz 2.zip');
      checkanddownload(pvBabyz, 'http://www.sherlocksoftware.org/petz/files/babyz.zip', 'Babyz.zip');

{     checkanddownload(pvPetz5, 'http://carolyn.thepetzwarehouse.com/downloabx/dogzpetz5.zip', 'Petz 5.zip');
      checkanddownload(pvPetz4, 'http://carolyn.thepetzwarehouse.com/downloabx/Petz4ExeForPetza.zip', 'Petz 4.2.zip');
      checkanddownload(pvPetz3, 'http://carolyn.thepetzwarehouse.com/downloabx/Petz3exe.zip', 'Petz 3.zip');
      checkanddownload(pvPetz3German, 'http://carolyn.thepetzwarehouse.com/downloabx/Petz3German.zip', 'Petz 3 German.zip');
      checkanddownload(pvPetz2, 'http://carolyn.thepetzwarehouse.com/downloabx/PetzIIexeForPetza.zip', 'Petz 2.zip');
      checkanddownload(pvBabyz, 'http://carolyn.thepetzwarehouse.com/downloabx/BabyzExeForPetza.zip', 'Babyz.zip');}
  end;
end;

function getbackupname(name: string): string;
begin
  stringchange(name, '.exe', '_petzabackup.exe');
  result := name;
end;

function NeedRestart(): Boolean;
begin
 result:=willneedrestart;
end;

procedure CurStepChanged(CurStep: TSetupStep);
var t1: integer;
begin
  if curstep = ssInstall then begin
  //copy any downloaded Petz exes into place
    for t1 := 0 to getarraylength(todownload) - 1 do
      if (length(todownload[t1].tmpsource) > 0) and fileexists(todownload[t1].tmpsource) then begin
        //First make a backup of the exe. Fail if it already exists (Otherwise installing twice ruins your backup)
        FileCopy(todownload[t1].dest, getbackupname(todownload[t1].dest), true);

        //Unpack the zip we downloaded
        UnpackDLL(todownload[t1].tmpsource, todownload[t1].dest+'.tmp');

        if FileExists(todownload[t1].dest) and not deleteFile(todownload[t1].dest) then begin
            RestartReplace(todownload[t1].dest+'.tmp',todownload[t1].dest);
            willNeedRestart:=true;
        end else
            RenameFile(todownload[t1].dest+'.tmp',todownload[t1].dest);
      end;
  end;
end;

function ShouldSkipPage(PageID: Integer): Boolean;
begin
  result := false;
  if PageId = pickupdates.id then
    result := pickupdates.checklistbox.items.count = 0; //dont show the page if it's blank!
end;

procedure InitializeWizard();
var targetid,t1: integer;
  bpage: TWizardPage;
  label1: tlabel;
begin
  setarraylength(petznames, 5);

  petznames[0].ver := pvPetz2;
  petznames[0].keyname := 'SOFTWARE\PF.Magic\Petz II\1.00.01';
  petznames[0].filename := 'Petz II.exe';
  petznames[0].dispname := 'Petz 2';

  petznames[1].ver := pvPetz3;
  petznames[1].keyname := 'SOFTWARE\PF.Magic\Petz 3\3.00.01';
  petznames[1].filename := 'Petz 3.exe';
  petznames[1].dispname := 'Petz 3';

  petznames[2].ver := pvPetz4;
  petznames[2].keyname := 'SOFTWARE\PF.Magic\Petz 4\4.00.00';
  petznames[2].filename := 'Petz 4.exe';
  petznames[2].dispname := 'Petz 4';

  petznames[3].ver := pvPetz5;
  petznames[3].keyname := 'SOFTWARE\StudioMythos\Petz 5\4.00.00';
  petznames[3].filename := 'Petz 5.exe';
  petznames[3].dispname := 'Petz 5';

  petznames[4].ver := pvBabyz;
  petznames[4].keyname := 'SOFTWARE\PF.Magic\Babyz\1.00.00';
  petznames[4].filename := 'Babyz.exe';
  petznames[4].dispname := 'Babyz';

  findpetzfolders;

  if getarraylength(petzexes) > 0 then begin
    Page := CreateInputOptionPage(wpWelcome,
      'Choose Petz versions to install to', 'PetzA will be automatically installed into selected versions',
      'The following versions of Petz have been detected. ' +
      'If you would like PetzA to automatically install itself into any of these copies of Petz, ' +
      'make sure that the box next to that version is ticked.',
      False, //Not radiobuttons
      False //don't put into a listbox
      );
    for t1 := 0 to GetArrayLength(petzexes) - 1 do begin
      page.add(petzexes[t1].dispname + ' (' + petzexes[t1].filename + ')');
      page.values[t1] := true;
    end;
  end else begin
    BPage := CreateCustomPage(wpWelcome, 'Choose Petz installations to install to', 'No Petz versions found');
    label1 := tlabel.create(bpage);
    label1.parent := bpage.surface;
    label1.align := alTop;
    label1.wordwrap := true;
    label1.caption := 'There were no Petz installations detected. You will need to tell the installer where your Petz ' +
      'versions are installed in the next step, or you will need to manually install PetzA by copying ' +
      'PetzA.toy from the PetzA folder after installation to the Resource\Toyz folder of your Petz game.';
  end;

  if page<>nil then
  targetid:=page.id else
  targetid:=bpage.id;

  Page2 := CreateInputFilePage(targetid,
    'Choose additional Petz versions to install to', 'PetzA will be automatically installed into selected versions',
    'If your copies of Petz were not automatically detected in the previous step, you can select them below. Select ' +
    'the main exe of your Petz installation (eg C:\Program Files\Ubi Soft\Studio Mythos\Petz 5\Petz 5.exe). You may ' +
    'select up to three installations of Petz');

  for t1:=1 to 3 do
  Page2.add('Select:', 'Petz main exe (Babyz.exe,Petz II.exe,Petz 3.exe,Petz 4.exe,Petz 5.exe)|babyz.exe;petz II.exe;Petz 3.exe;Petz 4.exe;Petz 5.exe', '.exe');

  pickupdates := CreateInputOptionPage(page2.id,
    'Pick updates to install to Petz',
    'PetzA needs certain versions of Petz to run correctly',
    'Some of the Petz programs that you are using are slightly different from what PetzA requires. ' +
    'PetzA can automatically download and install the correct versions for you. If you would like ' +
    'PetzA to automatically update your Petz programs, leave the boxes below ticked',
    false, // not radiobuttons
    false); //not a listbox

    itd_init;
    itd_setoption('UI_Caption','Downloading new Petz versions...');
    itd_setoption('UI_AllowContinue','1');
    itd_setoption('UI_FailOrContinueMessage','Sorry, the new Petz .exes could not be downloaded. Check that you are connected to the internet and press retry to try again, press next to continue installation without the downloaded files, or press cancel to abort installation');

	itd_downloadafter(wpReady);

    //itd_setoption('ITD_NoCache','1');
    //itd_setoption('Debug_DownloadDelay','50');
end;

[Run]
Filename: {app}\PetzAHelp.chm; Flags: shellexec skipifdoesntexist postinstall skipifsilent; Languages: ; Description: View the help file (Recommended)
