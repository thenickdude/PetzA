unit mymenuunit;

interface
uses sysutils, windows, classes, contnrs, debugunit;

type TMyMenuItem = class;
  TMyMenuHandler = procedure(sender: tmymenuitem);
  TMyMenuItem = class
  public
    parentmenu: hmenu;
      name: string;
    data: longword;
      index: integer;
    id: longword;
    handler: tmymenuhandler;
  end;


  TMenumanager = class
  private
    procedure updateitemcount;
  public
    petsmenu: hmenu;
    submenu: hmenu;
    menuitems: tobjectlist;
    procedure delete(parent: hmenu; index: integer; deletechildren: boolean = true);
    function wmcommand(id: word): boolean;
    function itembyid(id: longword): tmymenuitem;
    procedure setchecked(item: tmymenuitem; value: boolean);
    procedure addseparator(menu: hmenu);
    procedure deleteitem(id: longword);
    function additem(menu: hmenu; name, caption: string; data: longword; handler: TMyMenuHandler; identifier: hmenu = 0; submenu: boolean = false): tmymenuitem;
    procedure BuildMenu(wnd: hwnd);
    constructor create;
    destructor Destroy; override;
  end;

const menustartid = 40300;

var menumanager: tmenumanager;

implementation
uses bndpetz;

procedure tmenumanager.updateitemcount;
begin
{$IFDEF _petzadebug}
  debuglog('Menu items: ' + inttostr(menuitems.count));
{$ENDIF}
end;

procedure tmenumanager.deleteitem(id: longword);
var t1: integer;
begin
  for t1 := menuitems.count - 1 downto 0 do
    if tmymenuitem(menuitems[t1]).id = id then begin
      DeleteMenu(tmymenuitem(menuitems[t1]).parentmenu, tmymenuitem(menuitems[t1]).id, MF_BYCOMMAND);
      menuitems.Delete(t1);
      break;
    end;
end;

procedure tmenumanager.delete(parent: hmenu; index: integer; deletechildren: boolean = true);
var sub: hmenu;
begin
  sub := GetSubMenu(parent, index);

  if deletechildren then begin
    if sub <> 0 then // delete children of submenu
      while GetMenuItemCount(sub) > 0 do
        delete(sub, 0, deletechildren);
  end;

  if getsubmenu(parent, index) = 0 then
    deleteitem(GetMenuItemID(parent, index)) else
    deleteitem(GetSubMenu(parent, index));
  updateitemcount;
end;

function tmenumanager.wmcommand(id: word): boolean;
var item: TMyMenuItem;
begin
  result := false;
  item := itembyid(id);
  if (item <> nil) and assigned(item.handler) then begin
    item.handler(item);
    result := true;
  end;
end;

function tmenumanager.itembyid(id: longword): tmymenuitem;
var t1: integer;
begin
  result := nil;
  for t1 := 0 to menuitems.count - 1 do
    if TMyMenuItem(menuitems[t1]).id = id then begin
      result := TMyMenuItem(menuitems[t1]);
      exit;
    end;
end;

constructor tmenumanager.create;
begin
  petsmenu:=0;
  submenu:=0;
  menuitems := tobjectlist.create;
end;

destructor tmenumanager.destroy;
begin
  menuitems.free;
  inherited;
end;

procedure tmenumanager.setchecked(item: tmymenuitem; value: boolean);
var p4: MENUITEMINFO;
begin
  fillchar(p4, sizeof(p4), 0);
  p4.cbSize := sizeof(p4);
  p4.fMask := MIIM_STATE;
  if value then
    p4.fState := mfs_checked else p4.fstate := mfs_unchecked;

  SetMenuItemInfo(item.parentmenu, item.id, false, p4);
end;

procedure tmenumanager.addseparator(menu: hmenu);
begin
  appendmenu(menu, mf_separator, 0, nil);
end;

function booltostr(b: boolean): string;
begin
  if b then result := 'True' else
    result := 'False';
end;

function tmenumanager.additem(menu: hmenu; name, caption: string; data: longword; handler: TMyMenuHandler; identifier: hmenu = 0; submenu: boolean = false): tmymenuitem;
var menuitem: tmymenuitem;
  flags: cardinal;
  t1: longword;
  t2:integer;
  used: boolean;
begin
  menuitem := tmymenuitem.create;
  result := menuitem;
  menuitem.index := GetMenuItemCount(menu);
  menuitem.name := name;
  menuitem.handler := handler;
  menuitem.data := data;
  menuitem.parentmenu := menu;

  flags := MF_ENABLED or MF_STRING;

  if submenu then begin
    flags := flags or MF_POPUP;
  end else begin
    if identifier = 0 then begin
      for t1 := menustartid to menustartid + 1000 do begin
        used := false;
        for t2 := 0 to menuitems.count - 1 do
          if TmyMenuItem(menuitems[t2]).id = t1 then begin
            used := true;
            break;
          end;
        if not used then begin
          identifier := t1;
          break;
        end;
      end;
    end;
  end;

{$IFDEF _petzadebug}
  debuglog('TMenumanager:additem(' + inttostr(integer(menu)) + ',''' + name + ''',''' + caption + ''',' + inttostr(data) + ',(),' + inttostr(initvalue) + '-' + inttostr(integer(identifier)) + ',' + booltostr(submenu) + ')');
{$ENDIF}
  menuitem.id := identifier;
  AppendMenu(menu, flags, identifier, pchar(caption));
  menuitems.add(menuitem);
  updateitemcount;
end;

procedure TMenuManager.BuildMenu(wnd: hwnd);
var mainmenu: hmenu;
begin
  if wnd = 0 then exit;

  mainmenu := GetMenu(wnd);
  if mainmenu = 0 then exit;

  submenu := createpopupmenu;
  petsmenu := createpopupmenu;
  
  additem(mainmenu, 'peta', petzvername(cpetzver), 0, nil, submenu, true);
  if cpetzver in verBabyz then
  additem(submenu, '', 'Babies', 0, nil, petsmenu, true) else
  additem(submenu, '', 'Pets', 0, nil, petsmenu, true);
  addseparator(submenu);                               

  drawmenubar(wnd);
end;

end.
