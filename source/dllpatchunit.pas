unit dllpatchunit;

interface
uses sysutils, windows, classes, contnrs, dialogs, madexcept;

var patches: tobjectlist;

const retn = $C3;
  nop = $90;
  ipush = $68;
  iret = $C3;
  icall = $E8;
  ipusheax = $50;
type
  thookprocedure = procedure(injectpoint: pointer; eax, ecx, edx, esi: longword);
  tthiscalljumpstruct = packed record
    d1, d2, d3, d4, d5, d6: byte;
    push1: byte;
    oldaddress: pointer;
    pusheax: byte;
    push2: byte;
    newaddress: pointer;
    ret: byte;
  end;

  tjumpstruct = packed record
    push1: byte;
    oldaddress: pointer;
    push2: byte;
    newaddress: pointer;
    ret: byte;
  end;

  TPatch = class
  public
    oldaddress, newaddress: pointer;
    handler: thookprocedure;
    buf: string;

    restorepoint: pointer;
    restorebuf: string;

    procedure patch; virtual;
    procedure patchrestorer; virtual;

    procedure backup; virtual;
    procedure restore; virtual;
    procedure restorerestorepoint; virtual;
  end;

  TPatchThiscall = class(tpatch)
  public
    function callorigproc(classref: pointer; params: array of longword): longword;
    procedure patch; override;
    procedure patchrestorer; override;
    procedure backup; override;
    procedure restore; override;
    procedure restorerestorepoint; override;
  end;


procedure injmain;
procedure patchcode(address: pointer; datasize, totalsize: integer; newdata: pointer);
procedure patchcustom(injectpoint, restorepoint, newproc: pointer);
procedure patchgeneric(injectpoint, restorepoint: pointer; handler: thookprocedure);
function patchthiscall(injectpoint, newproc: pointer): TPatchThiscall;
procedure replacecdecl(injectpoint, newproc: pointer);
function Thiscall(ClassRef, ProcRef: Pointer;
  Params: array of Longword): LongWord;
procedure restorepatches;
procedure retargetcall(callloc:pointer; newtarget:pointer);

implementation

procedure restorepatches;
var t1: integer;
begin
  for t1 := 0 to patches.count - 1 do begin
    TPatch(patches[t1]).restore;
    TPatch(patches[t1]).restorerestorepoint;
  end;
  patches.clear;
end;

procedure patchcode(address: pointer; datasize, totalsize: integer; newdata: pointer);
var oldprotect: cardinal;
begin
  if datasize > totalsize then begin
    showmessage('Patchcode: Data is greater than size!');
    exit;
  end;
  VirtualProtect(address, totalsize, PAGE_EXECUTE_READWRITE, oldprotect);
  move(newdata^, address^, datasize);
  if datasize < totalsize then
    FillChar(ptr(cardinal(address) + cardinal(datasize))^, totalsize - datasize, byte(nop));
end;

function Thiscall(ClassRef, ProcRef: Pointer;
  Params: array of Longword): LongWord;
asm
  PUSH       EBX
  MOV        EBX,      [EBP+8]
  TEST       EBX,      EBX
  JS         @@ParamsDone

  LEA        ECX,      [ECX+EBX*4]
@@ParamLoop:
  PUSH       DWORD PTR [ECX]
  LEA        ECX,      [ECX-4]
  DEC        EBX
  JNS        @@ParamLoop

@@ParamsDone:
  MOV        ECX,      EAX
  CALL       EDX
  POP        EBX
end;

procedure dohook(esi, edx, ecx: longword; ainjection: pointer; eax: longword); stdcall;
var t1: integer;
  myfunc: thookprocedure;
begin
  try
    for t1 := 0 to patches.count - 1 do
      if tpatch(patches[t1]).oldaddress = ainjection then begin
        myfunc := tpatch(patches[t1]).handler;
        myfunc(ainjection, eax, ecx, edx, esi); // call registered handler
        tpatch(patches[t1]).restore; // return the original code at injection site
        tpatch(patches[t1]).patchrestorer; // install the restorer hook
        exit;
      end;
    showmessage('Hook not found!');
  except
    on E: Exception do
      HandleException(etnormal, E);
  end;
end;

procedure dorestore(ainjection: pointer);
var t1: integer;
begin
  try
    for t1 := 0 to patches.count - 1 do
      if tpatch(patches[t1]).restorepoint = ainjection then begin
        tpatch(patches[t1]).restorerestorepoint; // return original code at restore point
        tpatch(patches[t1]).patch; // install injection hook
        exit;
      end;
  except
    on E: Exception do
      HandleException(etnormal, E);
  end;
end;

procedure injmain;
asm
 pushad
 push eax
 mov eax,[esp+$24] // injection point address
 push eax
 push ecx
 push edx
 push esi
 call dohook
 popad
 ret
end;

procedure resmain;
asm
 pushad
 mov eax,[esp+$20] // injection point address
 call dorestore
 popad
 ret
end;

procedure tpatch.patch;
var
  oldprotect: cardinal;
  j: tjumpstruct;
  jumplength: integer;
begin
  j.push1 := ipush;
  j.oldaddress := oldaddress;
  j.push2 := ipush;
  j.newaddress := newaddress;
  j.ret := iret;

  jumplength := sizeof(j);
  VirtualProtect(oldaddress, jumplength, PAGE_EXECUTE_READWRITE, oldprotect);
  Move(j, oldaddress^, sizeof(j));
end;

procedure tpatch.patchrestorer;
var
  oldprotect: cardinal;
  j: tjumpstruct;
  jumplength: integer;
begin
  j.push1 := ipush;
  j.oldaddress := restorepoint;
  j.push2 := ipush;
  j.newaddress := @resmain;
  j.ret := iret;

  jumplength := sizeof(j);
  VirtualProtect(restorepoint, jumplength, PAGE_EXECUTE_READWRITE, oldprotect);
  Move(j, restorepoint^, sizeof(j));
end;

procedure tpatch.backup;
var jumplength: integer;
begin
  jumplength := sizeof(tjumpstruct);

  setlength(buf, jumplength);
  move(oldaddress^, buf[1], jumplength);

  setlength(restorebuf, jumplength);
  move(restorepoint^, restorebuf[1], jumplength);
end;

procedure tpatch.restore;
begin
  move(buf[1], oldaddress^, length(buf)); // move old code back
end;

procedure tpatch.restorerestorepoint;
begin
  move(restorebuf[1], restorepoint^, length(restorebuf)); // move old code back
end;

function tpatchthiscall.callorigproc(classref: pointer; params: array of longword): longword;
begin
  restore;
  try
    result := Thiscall(classref, oldaddress, params);
  finally
    patch;
  end;
end;

procedure tpatchthiscall.patch;
var
  oldprotect: cardinal;
  j: tthiscalljumpstruct;
  jumplength: integer;
begin
 { mov eax,[esp+$04] // load caller ptr into eax
  mov [esp+$04],ecx // now write class pointer over that
  push injectpoint // so that handler knows what hook called it
  push eax // put caller ptr after it
  push newaddress
  ret

  before:
  params
  callerptr

  now:
  params
  ecx
  injectpoint
  callerptr - so that the new routine returns to the caller of this routine
  new address
  }

  j.d1 := $8B; {Mov eax,[esp] callerptr}
  j.d2 := $04;
  j.d3 := $24;

  j.d4 := $89; {Mov [esp], ecx}
  j.d5 := $0C;
  j.d6 := $24;

  {Push inject point}
  j.push1 := ipush;
  j.oldaddress := oldaddress;
  {/Push}

  {Push caller so that new routine returns to the original caller}
  j.pusheax := ipusheax;
  {/Push}

  {Jump to new routine}
  j.push2 := ipush;
  j.newaddress := newaddress;
  j.ret := iret;
  {/Jump}

  jumplength := sizeof(j);
  VirtualProtect(oldaddress, jumplength, PAGE_EXECUTE_READWRITE, oldprotect);
  Move(j, oldaddress^, sizeof(j));
end;

procedure tpatchthiscall.patchrestorer;
begin
//
end;

procedure tpatchthiscall.backup;
var jumplength: integer;
begin
  jumplength := sizeof(tthiscalljumpstruct);

  setlength(buf, jumplength);
  move(oldaddress^, buf[1], jumplength);
end;

procedure tpatchthiscall.restore;
begin
  move(buf[1], oldaddress^, length(buf)); // move old code back
end;

procedure tpatchthiscall.restorerestorepoint;
begin
      //
end;

procedure retargetcall(callloc:pointer; newtarget:pointer);
type ppointer=^pointer;
var p:pointer;
 oldprotect:cardinal;
begin
  if pbyte(callLoc)^<> icall then
   showmessage('Target is not a call!');

  p := ptr(longword(callloc)+1);
  VirtualProtect(p, 4, PAGE_EXECUTE_READWRITE, oldprotect);
  ppointer(p)^ := ptr(longword(newtarget)-(integer(callloc)+5));
end;

function patchthiscall(injectpoint, newproc: pointer): TPatchThiscall;
begin
  result := tpatchthiscall.Create;

  result.oldaddress := injectpoint;
  result.newaddress := newproc;
  result.handler := nil;

  patches.add(result);
  result.backup;
  result.patch;
end;

procedure replacecdecl(injectpoint, newproc: pointer);
var j: packed record
    push: byte;
    address: pointer;
    ret: byte;
  end;
  oldprotect: longword;
begin
  j.push := ipush;
  j.address := newproc;
  j.ret := iret;

  VirtualProtect(injectpoint, SizeOf(j), PAGE_EXECUTE_READWRITE, oldprotect);
  Move(j, injectpoint^, sizeof(j));
end;    

procedure patchcustom(injectpoint, restorepoint, newproc: pointer);
var patch: tpatch;
begin
  patch := tpatch.Create;

  patch.oldaddress := injectpoint;
  patch.newaddress := newproc;
  patch.restorepoint := restorepoint;

  patch.handler := nil;

  patches.add(patch);
  patch.backup;
  patch.patch;
end;

procedure patchgeneric(injectpoint, restorepoint: pointer; handler: thookprocedure);
var patch: tpatch;
begin
  patch := tpatch.Create;

  patch.oldaddress := injectpoint;
  patch.newaddress := @injmain;
  patch.restorepoint := restorepoint;
  patch.handler := handler;

  patches.add(patch);
  patch.backup;
  patch.patch;
end;

end.

