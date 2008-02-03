unit petzprofilesunit;

interface

uses sysutils, Windows, gr32, contnrs, classes, filectrl, ECXMLParser, dimime,
  forms, controls, math, framediconunit, bndpetz;

const PETZA_PROFILES = 'PetzAProfiles';

type
  TPetzAProfile = class
  public
    icon: tbitmap32;
    foldername, name, description: string;
    procedure loadicon(icon: TBitmap32);
    constructor create;
    destructor Destroy; override;
    procedure loadfromfile(const filename: string);
    procedure savetofile(const filename: string);
  end;

  TProfileManager = class
  private
    fprofiles: tobjectlist;
    froot: string;
    fuseprofiles: boolean;
    factiveprofile: TPetzAProfile;
    function getprofile(index: Integer): TPetzAProfile;
    procedure setprofile(index: integer; value: TPetzAProfile);
    function getavailprofilepath(name: string): string;
  public
    procedure petzisstarting;

    procedure SaveProfile(profile: TPetzAProfile);
    procedure CreateProfile(const name, description: string; icon: Tbitmap32);
    function indexof(profile: TPetzAProfile): integer;
    procedure add(profile: TPetzAProfile);
    function count: integer;
    function findpets(profile: TPetzAProfile; list: TStringList): boolean;
    procedure loadprofile(profile: TPetzAProfile);
    procedure loadprofiles(createnew:Boolean);
    constructor Create(const rootpath: string);
    destructor Destroy; override;

    property activeprofile: TPetzAProfile read factiveprofile;
    property profiles[index: integer]: TPetzAProfile read getprofile write setprofile; default;
    property useprofiles: boolean read fuseprofiles write fuseprofiles;
  end;

var profilemanager: TProfileManager;

implementation

uses pickprofileunit, Dialogs;

function TProfileManager.getavailprofilepath(name: string): string;
const maxnamelen = 20;
var pos, i: integer;
begin
  if not DirectoryExists(IncludeTrailingBackslash(froot) + PETZA_PROFILES) then
    CreateDir(IncludeTrailingBackslash(froot) + PETZA_PROFILES);

  pos := 1;
  for i := 1 to length(name) do
    if not (name[i] in ['\', '/', ':', '*', '?', '"', '<', '>', '|']) then begin
      name[pos] := name[i];
      inc(pos);
    end;
  setlength(name, pos - 1);

  name := trim(name);
  name := copy(name, 1, maxnamelen);

  if length(name) = 0 then
    name := 'Unnamed';

  if DirectoryExists(IncludeTrailingBackslash(froot) + PETZA_PROFILES + '\' + name) then begin

    i := 0;
    while DirectoryExists(IncludeTrailingBackslash(froot) + PETZA_PROFILES + '\' + name + inttostr(i)) do
      inc(i);

    result := includetrailingbackslash(froot) + PETZA_PROFILES + '\' + name + inttostr(i);
  end else
    result := includetrailingbackslash(froot) + PETZA_PROFILES + '\' + name;
end;

constructor TPetzAProfile.create;
begin
  icon := tbitmap32.create;
end;

destructor TPetzAProfile.destroy;
begin
  icon.free;
  inherited;
end;

procedure TPetzAProfile.loadicon(icon: TBitmap32);
begin
  if icon = nil then
    self.icon.setsize(0, 0) else begin
    Self.icon.assign(icon);
    bmptrim(self.icon, 64, 64); //trim it down as needed
  end;
end;

procedure TPetzAProfile.loadfromfile(const filename: string);
var xml: TECXMLParser;
  stream: tstringstream;
begin
      //let exceptions leak and the parent deal with it
  xml := TECXMLParser.Create(nil);
  try
    xml.LoadFromFile(filename);
    name := xml.Root.NamedItem['ProfileName'].Text;
    description := xml.Root.NamedItem['Description'].text;
    if xml.root.nameditem['Icon'] <> nil then begin
      stream := TStringStream.create(MimeDecodeString(xml.root.nameditem['Icon'].text));
      try
        stream.position := 0;
        try
          icon.LoadFromStream(stream);
        except
          icon.setsize(0, 0);
        end;
      finally
        stream.free;
      end;
    end;
  finally
    xml.free;
  end;
end;

procedure TPetzAProfile.savetofile(const filename: string);
var xml: TECXMLParser;
  node: TXMLItem;
  stream: tstringstream;
begin
  xml := TECXMLParser.Create(nil);
  try
    xml.root.name := 'Profile';

    node := xml.Root.New;
    node.name := 'ProfileName';
    node.Text := name;

    node := xml.root.New;
    node.name := 'Description';
    node.text := description;

    if not icon.Empty then begin
      stream := TStringStream.create('');
      try
        icon.SaveToStream(stream);
        stream.position := 0;
        node := xml.root.New;
        node.name := 'Icon';
        node.text := MimeEncodeString(stream.DataString);
      finally
        stream.free;
      end;
    end;

    xml.SaveToFile(filename);
  finally
    xml.free;
  end;
end;

procedure TProfileManager.petzisstarting;
label 1;
var picker: TfrmPickProfile;
  oldcur: string;
begin
  //okay, Petz is starting up

  loadprofiles(useprofiles);

  if not useprofiles then exit;

  if fprofiles.Count = 0 then exit; // we have no profiles, just use the Adopted Petz folder

  picker := TfrmPickProfile.Create(nil);
  try
    1:
    picker.showmodal;
    if picker.ModalResult = mrOK then begin
      oldcur := GetCurrentDir;
      try
        setcurrentdir(ExtractFilePath(Application.exename));
        try
          loadprofile(profiles[picker.lstprofiles.selindex]);
        except
          //profile not switched
          MessageDlg('Couldn''t switch profiles. Make sure that no programs have files ' +
            'open in the ' + petzadoptedname(cpetzver) + ' folder and try again. If you continue ' +
            'to have problems, restart your computer.', mtError, [mbOK], 0);
        end;
      finally
        SetCurrentDir(oldcur);
      end;
    end else
      TerminateProcess(GetCurrentProcess, 0);
  finally
    picker.free;
  end;
end;

function TProfileManager.getprofile(index: Integer): TPetzAProfile;
begin
  result := TPetzAProfile(fprofiles[index]);
end;

procedure TProfileManager.setprofile(index: integer; value: TPetzAProfile);
begin
  fprofiles[index] := value;
end;

function TProfileManager.indexof(profile: TPetzAProfile): integer;
begin
  result := fprofiles.IndexOf(profile);
end;

procedure TProfileManager.add(profile: TPetzAProfile);
begin
  fprofiles.add(profile);
end;

function TProfileManager.count: integer;
begin
  result := fprofiles.count;
end;

function folderempty(const path: string): Boolean;
var r: TSearchRec;
begin
  result := true;
  if findfirst(IncludeTrailingBackslash(path) + '*.*', faAnyFile, r) = 0 then begin
    try
      repeat
        if (r.name <> '.') and (r.name <> '..') then begin
          result := false;
          exit;
        end;
      until findnext(r) <> 0;
    finally
      sysutils.FindClose(r);
    end;
  end;
end;

function TProfileManager.findpets(profile: TPetzAProfile; list: TStringList): boolean;
var mask, path: string;
  r: tsearchrec;
begin
  if profile = factiveprofile then
    path := IncludeTrailingBackslash(froot) + petzadoptedname(cpetzver) + '\' else
    path := IncludeTrailingBackslash(froot) + PETZA_PROFILES + '\' + profile.foldername + '\';

  case cpetzver of
    pvBabyz: mask := '*.baby';
  else mask := '*.pet';
  end;

  result := false;
  if findfirst(path + mask, faAnyFile, r) = 0 then begin
    try
      repeat
        if (r.name <> '.') and (r.name <> '..') then
          if (r.Attr and fadirectory = 0) then begin
            result := true;
            list.add(path + r.name);
          end;
      until findnext(r) <> 0;
    finally
      sysutils.FindClose(r);
    end;
  end;
end;

//Persist the given profile to a file

procedure TProfileManager.SaveProfile(profile: TPetzAProfile);
begin
  if profile.foldername = '' then
    raise exception.create('Tried to save unknown profile') else begin

    if factiveprofile = profile then //This profile is mounted, therefore it is in folder "Adopted Petz"
      profile.savetofile(IncludeTrailingBackslash(froot) + petzadoptedname(cpetzver) + '\PetzAProfile.xml') else
      profile.savetofile(IncludeTrailingBackslash(froot) + PETZA_PROFILES + '\' + profile.foldername + '\PetzAProfile.xml');
  end;
end;

//Create a new, empty profile

procedure TProfileManager.CreateProfile(const name, description: string; icon: Tbitmap32);
var prof: TPetzAProfile;
  folder: string;
begin
  prof := TPetzAProfile.create;
  try
    prof.name := name;
    prof.description := description;
    prof.loadicon(icon);
    folder := getavailprofilepath(prof.name);
    CreateDir(folder);
    prof.foldername := extractfilename(folder);
    prof.savetofile(IncludeTrailingBackslash(folder) + 'PetzAProfile.xml');
    fprofiles.Add(prof);
  except
    prof.free;
  end;
end;

procedure TProfileManager.loadprofile(profile: TPetzAProfile);
var adpt, destname: string;
  temp: TPetzAProfile;
begin
  if factiveprofile = profile then exit; //done already!!

  //first we need to deactivate the current profile
  adpt := IncludeTrailingBackslash(froot) + petzadoptedname(cpetzver);
  //already a folder mounted. Is it one of ours?
  if DirectoryExists(adpt) then begin
    if (factiveprofile <> nil) then begin
    //we must have mounted a profile from the adopted petz folder already
      destname := getavailprofilepath(factiveprofile.name);
     //move that folder to our store
      if not RenameFile(adpt, destname) then
        raise exception.create('');
     //update the location of the folder
      factiveprofile.foldername := ExtractFileName(destname);
     //we no longer have an active profile
      factiveprofile := nil;
     //we're done!
    end else begin
      //There's an Adopted Petz folder, but PetzA has no profile for it!
      if folderempty(adpt) then
        if not RemoveDir(adpt) then //now we're done.
        raise exception.create('') else else begin
        destname := getavailprofilepath('Default');
        //move that folder to our store
        if not RenameFile(adpt, destname) then
          raise Exception.Create('');
        //now create a profile for it so that we can find it again!
        temp := TPetzAProfile.Create;
        temp.name := 'Default';
        temp.foldername := ExtractFileName(destname);
        temp.savetofile(IncludeTrailingBackslash(destname) + 'PetzAProfile.xml');
        add(temp);
      end;
    end;
  end;

  //now mount the desired profile
  RenameFile(IncludeTrailingBackslash(froot) + PETZA_PROFILES + '\' + profile.foldername, includetrailingbackslash(froot) + petzadoptedname(cpetzver));
  factiveprofile := profile;
end;

procedure TProfileManager.loadprofiles(createnew:boolean);
var
  pffolder: string;
  r: TSearchRec;
  profile: TPetzAProfile;
begin
  pffolder := IncludeTrailingBackslash(froot) + PETZA_PROFILES;
  if DirectoryExists(pffolder) then begin
    pffolder := pffolder + '\'; //trailing backslash

    if findfirst(pffolder + '*.*', faAnyFile, r) = 0 then begin
      try
        repeat
          if (r.name <> '.') and (r.name <> '..') then
            if (r.Attr and fadirectory <> 0) and
              fileexists(pffolder + r.name + '\PetzAProfile.xml') then begin
              profile := TPetzAProfile.Create;
              try
                profile.loadfromfile(pffolder + r.name + '\PetzAProfile.xml');
                profile.foldername := r.name;
                Add(profile);
              except
                profile.free;
              end;
            end;
        until findnext(r) <> 0;
      finally
        sysutils.FindClose(r);
      end;
    end;
  end;

  factiveprofile := nil;

  if FileExists(includetrailingbackslash(froot) + petzadoptedname(cpetzver) + '\PetzAProfile.xml') then begin
    profile := TPetzAProfile.Create;
    try
      profile.loadfromfile(includetrailingbackslash(froot) + petzadoptedname(cpetzver) + '\PetzAProfile.xml');
      profile.foldername := petzadoptedname(cpetzver);
      factiveprofile := profile;
      fprofiles.insert(0, profile); //add at start of list
    except
      profile.free;
    end;
  end else if createnew then begin //create a new profile for the adopted petz folder
    profile := TPetzAProfile.Create;
    try
      profile.name := 'Default';
      profile.foldername := petzadoptedname(cpetzver);
      profile.savetofile(includetrailingbackslash(froot) + petzadoptedname(cpetzver) + '\PetzAProfile.xml');
      factiveprofile := profile;
      fprofiles.insert(0, profile); //add at start of list
    except
      profile.free;
    end;
  end;
end;

constructor TProfileManager.create(const rootpath: string);
begin
  fprofiles := TObjectList.Create;
  froot := rootpath;
  fuseprofiles := false;
end;

destructor TProfileManager.destroy;
begin
  fprofiles.free;
end;

end.

