unit bndpetz;

interface

uses sysutils, windows;


type tpetzvername = (pvUnknown, pvpetz2, pvPetz3, pvPetz3German, pvPetz4, pvPetz5, pvBabyz);
  tpetzhashrec = record
    ver: tpetzvername;
    hash: string;
  end;

const
  verPetz: set of tpetzvername = [pvpetz2, pvpetz3, pvpetz3german, pvpetz4, pvpetz5];
  verBabyz: set of tpetzvername = [pvbabyz];
  verBreeding: set of tpetzvername = [pvPetz5, pvpetz4, pvpetz3, pvpetz3german];
  verAdoptcenter: set of tpetzvername = [pvpetz3, pvpetz3german, pvpetz4, pvpetz5];
  verUnibreed: set of TPetzvername = [pvpetz3, pvpetz3german, pvpetz4, pvpetz5];
  verCamera: set of TPetzvername = [pvpetz4, pvpetz5, pvpetz3, pvpetz3german,pvBabyz];

  petzhashes: array[0..7] of tpetzhashrec = (
    (ver: pvpetz5; hash: '0A5AE8C8965C5F8DBB1F22B4EE6F252F'), {orig}
    (ver: pvpetz5; hash: '9C392A6AF9BEA84DF454728E0FF68273'), {carolyn's free mother}
    (ver: pvpetz3; hash: '89045E5E435DE0310176CCC5BE8F4117'), {original english}
    (ver: pvpetz4; hash: '5FBB8B4CE25FE917D53776D3E64B014A'), {patch version 1.2}
    (ver: pvpetz3german; hash: '7A023E245EC3369E62996F9D6D41713E'), {original}
    (ver: pvbabyz; hash: '5981FCD9B3DA938AFD52D80B64F04C84'), {original}
    (ver: pvbabyz; hash: '45AFC90762F5C1AA64DE7E52895A7EC5'), {Carolyn's}
    (ver: pvpetz2; hash: '53B29DB678A4228702ACD76BFCA7A5A1') {demo fooler}
(*    (ver: pvpetz2; hash: 'D0EBB7FFB603DB1CF51010DBE0ABED74') {carolyn's slider modified ver}*)
    );


function petzvername(ver: tpetzvername): string;
function petzadoptedname(ver: tpetzvername): string;

type
  Tpetsprite_mate = function(pet1, pet2: pointer): bool; cdecl;
  TGetshlglobals = function: pointer; cdecl;
  TPetzGetDLGGlobals = function: pointer; cdecl;
  TXDrawport_Openscreendrawport = function: bool; cdecl;
  TXdrawport_closescreendrawport = function: bool; cdecl;
  TPetzallocmem = function(size: integer): pointer; cdecl;
  TXDownload_getdefaultloadinfo = function(loadinfo: pointer; loadtype: longword; s: pchar; xlibrarylist: pointer): bool; cdecl;
  TXDownload_getfilmstrip = function(p: pchar; xlibrarylist: pointer): pointer; cdecl;
  PPointer = ^pointer;

  trimports = record
 {Unibreed BEGIN}
    xdownload_getdefaultloadinfo: TXDownload_getdefaultloadinfo;
    xdownload_getfilmstrip: TXDownload_getfilmstrip;
    dogsprite_dogsprite, catsprite_catsprite: pointer;

    petsprite_xsound_vftable,
      petsprite_initpetsprite: pointer;

    xdownload_vftable, xdownload_xdownload, xdownload_initdownload: pointer;
 {Unibreed END}

 {Stateconceive BEGIN}
    stateconceive_stateconceive: pointer;
    stateconceive_execute: pointer;
 {Stateconceive END}

    charactersprite_xsound_vftable: pointer;
    charactersprite_host_vftable: pointer;
    charactersprite_vftable: pointer;
    charactersprite_xsmartobject_vftable: pointer;

    scriptsprite_vbtable: pointer;

    xdlink_vftable: pointer;

    statemachine_vftable: pointer;

    host_vbtable, host_vftable: pointer;

    xsmartobject_vftable: pointer;

    xstage_redostage:pointer;

 {common}
    petzapp_createmainwindow: pointer;

    petsprite_getpetbiorhythm, petsprite_setpetbiorhythm: pointer;
    petsprite_enterpetdoor, petsprite_getisbehindpetdoor, petsprite_locomotetopoint: pointer;
    petsprite_getisdependent, petsprite_isoffspringdue: pointer;
    petsprite_mate: tpetsprite_mate;
    petsprite_conceiveto: pointer;

    scriptsprite_setdiaperstatus:Pointer;

    goalinsanity_create: pointer;

    sprite_hart_start:Pointer;

    petsprite_petsprite, petsprite_free: pointer;

    petzallocmem: tpetzallocmem;

    get_dlgglobals:tpetzgetdlgglobals;

    ancestryinfo_create: pointer;
    ancestryinfo_setadopter, ancestryinfo_setname, ancestryinfo_setbreed: pointer;

    spriteadpt_killpetz, spriteadpt_loadpetz,
      spriteadpt_spriteadpt, spriteadpt_free: pointer;

    oberon_getarea, area_gotoarea: pointer;

 {petz 3 only}
    petsprite_isfemale: pointer;

 {petz 2 only}
    shelfsprite_loadpet: pointer;

 {petz5 only}
    cdatafile_getinstdata: pointer;

    getshlglobals: tgetshlglobals;
    shlglobals_setshlrect: pointer;

    alposprite_isthisapet: pointer;

    scriptsprite_transneu, scriptsprite_pushstoredaction,
      scriptsprite_pushscript, scriptsprite_settargetlocation,
      scriptsprite_resetstack: pointer;

    petzapp_dodrawframe: pointer;
    petzapp_preparedrawframe: pointer;
    xdrawport_openscreendrawport: TXDrawport_Openscreendrawport;
    xdrawport_closescreendrawport: txdrawport_closescreendrawport;
    petmodule_dodrawframe: pointer;
    xstage_copytileport, xstage_copysaveport, xstage_setdirty: pointer;
    xdrawport_xfillrect, xdrawport_xdrawtext: pointer;
    alposprite_getgrabrect: pointer;
    xdrawport_gethicolorbits, xdrawport_getdepth, xdrawport_getbits, xdrawport_getsize, xdrawport_enablehicolorbitmap: pointer;

 {babyz only}
    petzapp_checkforbabyzcd: pointer;
  end;

// procedure petsprite_isfemale; external 'Petz 5.exe' name '?IsFemale@PetSprite@@QBE_NXZ';

(*
procedure xstage_copytileport; external 'Petz 5.exe' name '?CopyTilePort@XStage@@QAEABU?$XTRect@HJ@@AAVXDrawPort@@ABU2@@Z';
procedure xstage_setdirty; external 'Petz 5.exe' name '?SetDirty@XStage@@QAEABU?$XTRect@HJ@@ABU2@_N@Z';
procedure jumptoceiling; external 'Petz 5.exe' name '?JumpToCeiling1@PetSprite@@UAEXPAVAlpoSprite@@@Z';
procedure jumptorotation; external 'Petz 5.exe' name '?BounceToRotation1@PetSprite@@UAEXH@Z';
procedure snootynose; external 'Petz 5.exe' name '?SnootyNose@PetSprite@@UAEXXZ';
procedure crawltosprite; external 'Petz 5.exe' name '?CrawlToSprite1@PetSprite@@UAEXPAVAlpoSprite@@@Z';
procedure loadpetz; external 'Petz 5.exe' name '?LoadPetz@Sprite_Case@@UAE_NH_N00@Z';
procedure get_g_case; external 'Petz 5.exe' name '?Get_g_Case@@YA?AV?$XTSmartPtr@PAVSprite_Case@@@@XZ';
procedure pickpetz; external 'Petz 5.exe' name '?PickPetz@Sprite_Case@@UAEXH@Z';
procedure pickloadpetz; external 'Petz 5.exe' name '?PickLoadPetz@Sprite_Case@@QAE_NXZ';
procedure getadoptedpetindex; external 'Petz 5.exe' name '?GetMyAdoptedPetIndex@PetSprite@@UBEH_N@Z';
procedure dopetzprofiledialog(id: longword); cdecl; external 'Petz 5.exe' name '?DoPetProfileDialog@@YAXH@Z';
procedure spriteadptloadpetz; external 'Petz 5.exe' name '?LoadPetz@Sprite_Adpt@@QAE_NH_N0@Z';
procedure oberonloadarea; external 'Petz 5.exe' name '?LoadArea@Oberon@@QAEXXZ';
procedure oberonpickarea; external 'Petz 5.exe' name '?PickArea@Oberon@@QAEXU?$XTPoint@H@@@Z';
*)

procedure loadimports;

var cpetzver: tpetzvername;
  rimports: trimports;


implementation

function getprocaddress(hmodule: hinst; name: string): Pointer;
begin
  result := windows.GetProcAddress(hmodule, pchar(name));
  if result = nil then begin
    raise exception.create('Couldn''t find procedure "' + name + '" in "' + paramstr(0) + '"');
  end;
end;

procedure loadimports;
var hmod: HINST;
begin
  fillchar(rimports, sizeof(rimports), 0);
  hmod := LoadLibrary(pchar(paramstr(0)));

  case cpetzver of
    pvpetz5: rimports.xdownload_getfilmstrip := getprocaddress(hmod, '?GetFilmstripFromDLL@XDownload@@SAPAVPetz5Filmstrip@@PBDPAVXLibraryList@@@Z');
    pvpetz4, pvpetz3, pvpetz3german, pvpetz2: rimports.xdownload_getfilmstrip := getprocaddress(hmod, '?GetFilmstripFromDLL@XDownload@@SAPAVFilmstrip@@PBDPAVXLibraryList@@@Z');
  end;

  if cpetzver in verUnibreed then begin
    rimports.xdownload_getdefaultloadinfo := getprocaddress(hmod, '?GetDefaultLoadInfoFromDLL@XDownload@@SA_NAAV?$pfvector@VLoadInfo@@PBD@@W4ELoadType@@PBDPAVXLibraryList@@@Z');
    rimports.xdownload_xdownload := getprocaddress(hmod, '??0XDownload@@QAE@XZ');
    rimports.xdownload_vftable := getprocaddress(hmod, '??_7XDownload@@6B@');
    rimports.xdownload_initdownload := getprocaddress(hmod, '?InitDownload@XDownload@@QAEXABVLoadInfo@@PAVXLibraryList@@@Z');
    rimports.xdlink_vftable := getprocaddress(hmod, '??_7XDLink@@6B@');
    rimports.statemachine_vftable := getprocaddress(hmod, '??_7StateMachine@@6B@');
    rimports.scriptsprite_vbtable := getprocaddress(hmod, '??_8ScriptSprite@@7B@');

    rimports.host_vftable := getprocaddress(hmod, '??_7Host@@6B0@@');
    rimports.host_vbtable := getprocaddress(hmod, '??_8Host@@7B@');
    rimports.xsmartobject_vftable := getprocaddress(hmod, '??_7XSmartObject@@6B@');

    rimports.petsprite_xsound_vftable := getprocaddress(hmod, '??_7PetSprite@@6BXSound@@@');
    rimports.petsprite_initpetsprite := getprocaddress(hmod, '?InitPetSprite@PetSprite@@QAEXABVLoadInfo@@W4EChrz@@PAD22_NH@Z');
    rimports.charactersprite_xsound_vftable := getprocaddress(hmod, '??_7CharacterSprite@@6BXSound@@@');
    rimports.charactersprite_host_vftable := getprocaddress(hmod, '??_7CharacterSprite@@6BHost@@@');
    rimports.charactersprite_vftable := getprocaddress(hmod, '??_7CharacterSprite@@6B@');
    rimports.charactersprite_xsmartobject_vftable := getprocaddress(hmod, '??_7CharacterSprite@@6BXSmartObject@@@');
  end;

  if cpetzver in verBreeding then begin
    rimports.sprite_hart_start:=getprocaddress(hmod,'?Start@Sprite_Hart@@QAEXABU?$XTPoint@H@@PBD11@Z');
  end;

  case cpetzver of
    pvpetz5, pvpetz4, pvpetz3, pvpetz3german: begin
        rimports.dogsprite_dogsprite := getprocaddress(hmod, '??0DogSprite@@QAE@XZ');
        rimports.catsprite_catsprite := getprocaddress(hmod, '??0CatSprite@@QAE@XZ');
      end;
    pvpetz2: {petsprite, but it is linked later on};
  end;

  if cpetzver in verAdoptCenter then begin
    rimports.spriteadpt_loadpetz := getprocaddress(hmod, '?LoadPetz@Sprite_Adpt@@QAE_NH_N0@Z');
    rimports.spriteadpt_spriteadpt := getprocaddress(hmod, '??0Sprite_Adpt@@QAE@XZ');
    rimports.spriteadpt_free := getprocaddress(hmod, '??1Sprite_Adpt@@UAE@XZ');
  end;
  if cpetzver in verPetz then begin
    rimports.petsprite_petsprite := getprocaddress(hmod, '??0PetSprite@@QAE@XZ');
    rimports.petsprite_free := getprocaddress(hmod, '??1PetSprite@@UAE@XZ');
  end;
  if cpetzver in verBabyz then begin
    rimports.petsprite_petsprite := getprocaddress(hmod, '??0BabySprite@@QAE@XZ');
    rimports.petsprite_free := getprocaddress(hmod, '??1BabySprite@@UAE@XZ');
  end;
  if cpetzver in [pvbabyz, pvpetz3, pvpetz3german, pvpetz4, pvpetz5] then
    rimports.petzapp_createmainwindow := getprocaddress(hmod, '?CreateMainWindow@PetzApp@@QAEXXZ');

  if cpetzver<>pvpetz2 then //Petz2 doesn't support this method
  rimports.xstage_redostage:=getprocaddress(hmod,'?RedoStage@XStage@@QAEXXZ');

  case cpetzver of
    pvpetz5: begin
        rimports.getshlglobals := getprocaddress(hmod, '?Get_ShlGlobals@@YAPAVCShlGlobals@@XZ');
        rimports.shlglobals_setshlrect := getprocaddress(hmod, '?SetShlRect@CShlGlobals@@QAEABU?$XTRect@HJ@@ABU2@@Z');

        rimports.scriptsprite_pushstoredaction := getprocaddress(hmod, '?PushStoredAction@ScriptSprite@@UAEHJH_N@Z');
        rimports.scriptsprite_transneu := getprocaddress(hmod, '?PushTransitionToNeutralPos@ScriptSprite@@QAE_NH@Z');
        rimports.scriptsprite_pushscript := getprocaddress(hmod, '?PushScript@ScriptSprite@@UAEXPBJHPAVStack@@@Z');
        rimports.scriptsprite_settargetlocation := getprocaddress(hmod, '?SetTargetLocation@ScriptSprite@@UAEXPAU?$XTPoint@H@@@Z');
        rimports.scriptsprite_resetstack := getprocaddress(hmod, '?ResetStack@ScriptSprite@@UAEXW4ResetType@@H@Z');
        rimports.alposprite_isthisapet := getprocaddress(hmod, '?IsThisAPet@AlpoSprite@@UBE_NPAVXSprite@@@Z');

        rimports.goalinsanity_create := getprocaddress(hmod, '??0GoalInsanity@@QAE@XZ');

//        rimports.spriteadpt_killpetz:=getprocaddress(hmod,'?KillPetz@Sprite_Adpt@@QAEXXZ');

        //drawing code:
        rimports.petzapp_dodrawframe := getprocaddress(hmod, '?DoDrawFrame@PetzApp@@QAEXXZ');
        rimports.petzapp_preparedrawframe := getprocaddress(hmod, '?PrepareDrawFrame@PetzApp@@QAEX_N@Z');
        rimports.xdrawport_openscreendrawport := getprocaddress(hmod, '?OpenScreenDrawPort@XDrawPort@@SA_NXZ');
        rimports.xdrawport_closescreendrawport := getprocaddress(hmod, '?CloseScreenDrawPort@XDrawPort@@SA_NXZ');
        rimports.petmodule_dodrawframe := getprocaddress(hmod, '?DoDrawFrame@PetModule@@QAEXXZ');
        rimports.xdrawport_xfillrect := getprocaddress(hmod, '?XFillRect@XDrawPort@@UAEXABU?$XTRect@HJ@@H@Z');
        rimports.xdrawport_xdrawtext := getprocaddress(hmod, '?XDrawText@XDrawPort@@QAEXPADPAU?$XTRect@HJ@@HHJHH@Z');
        rimports.xstage_copytileport := getprocaddress(hmod, '?CopyTilePort@XStage@@QAEABU?$XTRect@HJ@@AAVXDrawPort@@ABU2@@Z');
        rimports.xstage_copysaveport := getprocaddress(hmod, '?CopySavePort@XStage@@QAEABU?$XTRect@HJ@@AAVXDrawPort@@ABU2@@Z');
        rimports.xstage_setdirty := getprocaddress(hmod, '?SetDirty@XStage@@QAEABU?$XTRect@HJ@@ABU2@_N@Z');
        rimports.alposprite_getgrabrect := getprocaddress(hmod, '?GetGrabRect@AlpoSprite@@UBEABU?$XTRect@HJ@@XZ');
        rimports.xdrawport_gethicolorbits := getprocaddress(hmod, '?GetHiColorBits@XDrawPort@@UAEPAEXZ');
        rimports.xdrawport_getbits := getprocaddress(hmod, '?GetBits@XDrawPort@@UAEPAEXZ');
        rimports.xdrawport_getdepth := getprocaddress(hmod, '?GetDepth@XDrawPort@@UBEHXZ');
        rimports.xdrawport_getsize := getprocaddress(hmod, '?GetSize@XDrawPort@@QBE?AV?$XTSize@HJ@@XZ');
        rimports.xdrawport_enablehicolorbitmap := getprocaddress(hmod, '?EnableHiColorBitmap@XDrawPort@@QAEX_N@Z');
        //end drawing code^

      end;
    pvpetz3, pvpetz3german, pvbabyz: begin
        rimports.petsprite_isfemale := getprocaddress(hmod, '?IsFemale@PetSprite@@QBE_NXZ');
      end;
  end;

  case cpetzver of
    pvPetz5, pvpetz4, pvpetz3, pvpetz3german: begin
        rimports.petsprite_getpetbiorhythm := GetProcAddress(hmod, '?GetPetBiorhythm2@PetSprite@@UBEHPBVAlpoSprite@@W4PetBiorhythm@@@Z');
        rimports.petsprite_setpetbiorhythm := GetProcAddress(hmod, '?SetPetBiorhythm3@PetSprite@@UBEXPAVAlpoSprite@@W4PetBiorhythm@@H@Z');
        rimports.petsprite_locomotetopoint := GetProcAddress(hmod, '?LocomoteToPoint2@PetSprite@@UAEXHH@Z');
      end;
    pvPetz2: begin
        rimports.petsprite_getpetbiorhythm := GetProcAddress(hmod, '?GetPetBiorhythm2@PetSprite@@UAEHPAVAlpoSprite@@W4PetBiorhythm@@@Z');
        rimports.petsprite_setpetbiorhythm := GetProcAddress(hmod, '?SetPetBiorhythm3@PetSprite@@UAEXPAVAlpoSprite@@W4PetBiorhythm@@H@Z');
        rimports.petsprite_locomotetopoint := getprocaddress(hmod, '?LocomoteToPoint2@PetSprite@@UAEXHH@Z');
      end;
    pvbabyz: begin
        rimports.petsprite_getpetbiorhythm := GetProcAddress(hmod, '?GetBabyBiorhythm2@BabySprite@@UBEHPBVAlpoSprite@@W4BabyBiorhythm@@@Z');
        rimports.petsprite_setpetbiorhythm := GetProcAddress(hmod, '?SetBabyBiorhythm3@BabySprite@@UBEXPAVAlpoSprite@@W4BabyBiorhythm@@H@Z');
        rimports.petsprite_locomotetopoint := getprocaddress(hmod, '?LocomoteToPoint2@BabySprite@@UAEXHH@Z');
      end;
  end;

  if cpetzver=pvpetz5 then
  rimports.get_dlgglobals:=getprocaddress(hmod,'?Get_DlgGlobals@@YAPAVCDlgGlobals@@XZ');

  case cpetzver of
    pvpetz3german: rimports.petzallocmem := ptr($543E10);
    pvpetz3: rimports.petzallocmem := ptr($543110);
    pvpetz4: rimports.petzallocmem := ptr($45BA10);
    pvpetz5: //rimports.petzallocmem := ptr($463FF0);
      rimports.petzallocmem := getprocaddress(hmod, '?PetzNew@@YAPAXI@Z');
  end;

  if cpetzver = pvbabyz then begin
    rimports.petzapp_checkforbabyzcd := getprocaddress(hmod, '?CheckForBabyzCD@PetzApp@@QAE_NXZ');
    rimports.scriptsprite_setdiaperstatus := getprocaddress(hmod, '?SetDiaperStatus@ScriptSprite@@UAEXW4EDiaperStatus@@@Z');    
  end;

  case cpetzver of
    pvpetz5, pvpetz4, pvpetz3, pvpetz3german, pvpetz2: begin
        rimports.petsprite_enterpetdoor := GetProcAddress(hmod, '?EnterPetDoor0@PetSprite@@UAEXXZ');
      end;
  end;

  case cpetzver of
    pvpetz2: begin
        rimports.shelfsprite_loadpet := GetProcAddress(hmod, '?LoadPet@ShelfSprite@@QAE?AW4pfbool@@FW42@@Z');
      end;
  end;

  if cpetzver = pvpetz5 then begin
    rimports.cdatafile_getinstdata := getprocaddress(hmod, '?GetInstData@CDataFile@@QBE_NPBDPAXKK_N@Z');
  end;

  case cpetzver of
    pvPetz5, pvpetz4, pvpetz3, pvpetz3german: begin {games that support breeding/sexes}
        rimports.petsprite_getisbehindpetdoor := GetProcAddress(hmod, '?GetIsBehindPetDoor@PetSprite@@UBE_NXZ');

        rimports.ancestryinfo_setadopter := getprocaddress(hmod, '?SetAdopter@AncestryInfo@@QAEXPBD@Z');
        rimports.ancestryinfo_setname := getprocaddress(hmod, '?SetName@AncestryInfo@@QAEXPBD@Z');
        rimports.ancestryinfo_setbreed := getprocaddress(hmod, '?SetBreed@AncestryInfo@@QAEXPBD@Z');
        rimports.ancestryinfo_create := getprocaddress(hmod, '??0AncestryInfo@@QAE@XZ');
        rimports.petsprite_mate := getprocaddress(hmod, '?Mate@PetSprite@@SA_NABV1@AAV1@@Z');
        rimports.petsprite_conceiveto := getprocaddress(hmod, '?Conceive2@PetSprite@@UAEXW4UAction@@PAVAlpoSprite@@@Z');
        rimports.petsprite_isoffspringdue := getprocaddress(hmod, '?IsOffspringDue@PetSprite@@QBE_NXZ');
        rimports.petsprite_getisdependent := getprocaddress(hmod, '?GetIsDependent@PetSprite@@UBE_NXZ');

        rimports.stateconceive_stateconceive := getprocaddress(hmod, '??0StateConceive@@QAE@XZ');
        rimports.stateconceive_execute := getprocaddress(hmod, '?Execute@StateConceive@@UAEXAAVCharacterSprite@@_N1@Z');
      end;
  end;

  if cpetzver <> pvpetz2 then begin //area functions
    rimports.oberon_getarea := getprocaddress(hmod, '?GetArea@Oberon@@QBEPAVArea@@PBD@Z');
    rimports.area_gotoarea := getprocaddress(hmod, '?GoToArea@Area@@UAEXXZ');
  end;
end;

function petzadoptedname(ver: tpetzvername): string;
begin
  case ver of
    pvBabyz: result := 'Adopted Babyz';
  else result := 'Adopted Petz';
  end;
end;

function petzvername(ver: tpetzvername): string;
begin
  result:='PetzA'; //"Localizing" this value is just confusing
{  case ver of
    pvPetz2, pvPetz3, pvPetz3German, pvPetz4, pvPetz5: result := 'PetzA';
    pvBabyz: result := 'BabyzA';
  else result := 'Petz';
  end;}
end;

end.

