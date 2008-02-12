unit petzcommon1;

interface
uses sysutils, messages, windows, dialogs;
type enotimplemented = class(exception)
  public
    constructor create; reintroduce;
  end;
const
  WM_REBUILDPETZMENU = WM_USER + 2;

function findpetzwindow: hwnd;

implementation

uses bndpetz;

constructor enotimplemented.create;
begin
  inherited create('Petz version not implemented!');
end;

var found: hwnd;

function huntpetzenum(h: hwnd; l: lparam): BOOL; stdcall;
var d: dword; //DWord is a longword
begin
  GetWindowThreadProcessId(h, @d);
  if d = dword(l) then begin
    result := false;
    found := h;
  end else result := true;
end;

function findpetzwindow: hwnd;
begin
  case cpetzver of
    pvPetz5: result := findwindow('Petz 5 Shell Window Class by PF.Magic', nil);
    pvPetz3, pvpetz3german: result := findwindow('Petz 3 Shell Window Class by PF.Magic', nil);
    pvPetz4: result := findwindow('Petz 4 Shell Window Class by PF.Magic', nil);
    pvBabyz: result := findwindow('Babyz Shell Window Class by PF.Magic', nil);
    pvpetz2: result := findwindow('Petz II Shell Window Class by PF.Magic', nil);
  else result := 0;
  end;
{  if result = 0 then begin
    found := 0;
    EnumWindows(@huntpetzenum, lparam(getcurrentprocessid));
    result := found;
  end;      }
end;


end.

