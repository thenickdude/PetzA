{***************************************************************}
{                                                               }
{       HTML Help Viewer for Delphi 2005                        }
{       Supports Win32 VCL and .NET VCL                         }
{                                                               }
{       Copyright (c) 2004-2005  Jan Goyvaerts                  }
{                                                               }
{       Design & implementation, by Jan Goyvaerts, 2004         }
{       Delphi 2005 compatibility, by Jan Goyvaerts, 2005       }
{                                                               }
{***************************************************************}

{
  You may use this unit free of charge in all your Delphi applications.
  Distribution of this unit or units derived from it is prohibited.
  If other people would like a copy, they are welcome to download it from:
  http://www.helpscribble.com/delphi-bcb.html

  To enable HTML Help (i.e. using CHM files) in your application, simply
  add this unit to the uses clause in your .dpr project source file.

  Set the Application.HelpFile property to the .chm file you want to use,
  and assign HelpContext properties as usual.

  Do NOT use both HTMLHelpViewer2005 and WinHelpViewer in the same application.
  If you do so, WinHelpViewer will attempt to open the CHM file, and display
  an error message.

  If you're looking for a tool to easily create HLP and/or CHM files,
  take a look at HelpScribble at http://www.helpscribble.com/
  HelpScribble includes a special HelpContext property editor for Delphi
  that makes it very easy to link your help file to your application.
}

unit HTMLHelpViewer2005;

interface

uses
{$IFDEF CLR}
  System.IO,
{$ENDIF}
  Windows, Messages, SysUtils, Types, Classes, Forms;

// Commands to pass to HtmlHelp()
const
  HH_DISPLAY_TOPIC        = $0000;
  HH_HELP_FINDER          = $0000;  // WinHelp equivalent
  HH_DISPLAY_TOC          = $0001;
  HH_DISPLAY_INDEX        = $0002;
  HH_DISPLAY_SEARCH       = $0003;
  HH_SET_WIN_TYPE         = $0004;
  HH_GET_WIN_TYPE         = $0005;
  HH_GET_WIN_HANDLE       = $0006;
  HH_ENUM_INFO_TYPE       = $0007;  // Get Info type name, call repeatedly to enumerate, -1 at end
  HH_SET_INFO_TYPE        = $0008;  // Add Info type to filter.
  HH_SYNC                 = $0009;
  HH_RESERVED1            = $000A;
  HH_RESERVED2            = $000B;
  HH_RESERVED3            = $000C;
  HH_KEYWORD_LOOKUP       = $000D;
  HH_DISPLAY_TEXT_POPUP   = $000E;  // display string resource id or text in a popup window
  HH_HELP_CONTEXT         = $000F;  // display mapped numeric value in dwData
  HH_TP_HELP_CONTEXTMENU  = $0010;  // text popup help, same as WinHelp HELP_CONTEXTMENU
  HH_TP_HELP_WM_HELP      = $0011;  // text popup help, same as WinHelp HELP_WM_HELP
  HH_CLOSE_ALL            = $0012;  // close all windows opened directly or indirectly by the caller
  HH_ALINK_LOOKUP         = $0013;  // ALink version of HH_KEYWORD_LOOKUP
  HH_GET_LAST_ERROR       = $0014;  // not currently implemented // See HHERROR.h
  HH_ENUM_CATEGORY        = $0015;	// Get category name, call repeatedly to enumerate, -1 at end
  HH_ENUM_CATEGORY_IT     = $0016;  // Get category info type members, call repeatedly to enumerate, -1 at end
  HH_RESET_IT_FILTER      = $0017;  // Clear the info type filter of all info types.
  HH_SET_INCLUSIVE_FILTER = $0018;  // set inclusive filtering method for untyped topics to be included in display
  HH_SET_EXCLUSIVE_FILTER = $0019;  // set exclusive filtering method for untyped topics to be excluded from display
  HH_INITIALIZE           = $001C;  // Initializes the help system.
  HH_UNINITIALIZE         = $001D;  // Uninitializes the help system.
  HH_PRETRANSLATEMESSAGE  = $00FD;  // Pumps messages. (NULL, NULL, MSG*).
  HH_SET_GLOBAL_PROPERTY  = $00FC;  // Set a global property. (NULL, NULL, HH_GPROP)

{$IFDEF MSWINDOWS}
type
  HH_AKLINK = record
    cbStruct: Integer;
    fReserved: BOOL;
    pszKeywords: PChar;
    pszURL: PChar;
    pszMsgText: PChar;
    pszMsgTitle: PChar;
    pszWindow: PChar;
    fIndexOnFail: BOOL;
  end;

// HtmlHelp API function.
// You can use this to directly control HTML Help.
// However, using Application.HelpContext() etc. is recommended.
function HtmlHelp(hwndCaller: THandle; pszFile: PChar; uCommand: cardinal; dwData: longint): THandle; stdcall;
{$ENDIF}

{$IFDEF CLR}
type
  HH_AKLINK = record
    cbStruct: Integer;
    fReserved: BOOL;
    pszKeywords: IntPtr;
    pszURL: IntPtr;
    pszMsgText: IntPtr;
    pszMsgTitle: IntPtr;
    pszWindow: IntPtr;
    fIndexOnFail: BOOL;
  end;

// HtmlHelp API function.
// You can use this to directly control HTML Help.
// However, using Application.HelpContext() etc. is recommended.
function HtmlHelp(hwndCaller: THandle; pszFile: string; uCommand: Cardinal; dwData: LongInt): THandle; overload;
function HtmlHelp(hwndCaller: THandle; pszFile: string; uCommand: Cardinal; dwData: IntPtr): THandle; overload;
{$ENDIF}

implementation

uses
{$IFDEF CLR}
  System.Security, System.Runtime.InteropServices,
{$ENDIF}
  HelpIntfs;

{$IFDEF MSWINDOWS}
function HtmlHelp(hwndCaller: THandle; pszFile: PChar; uCommand: cardinal; dwData: longint): THandle; stdcall;
         external 'hhctrl.ocx' name 'HtmlHelpA';
{$ENDIF}

{$IFDEF CLR}
[SuppressUnmanagedCodeSecurity, DllImport('hhctrl.ocx', CharSet = CharSet.Auto, SetLastError = True, EntryPoint = 'HtmlHelp')]
function HtmlHelp(hwndCaller: THandle; pszFile: string; uCommand: Cardinal; dwData: LongInt): THandle; external;
[SuppressUnmanagedCodeSecurity, DllImport('hhctrl.ocx', CharSet = CharSet.Auto, SetLastError = True, EntryPoint = 'HtmlHelp')]
function HtmlHelp(hwndCaller: THandle; pszFile: string; uCommand: Cardinal; dwData: IntPtr): THandle; external;
{$ENDIF}

type
  THTMLHelpViewer = class(TInterfacedObject, ICustomHelpViewer, IExtendedHelpViewer)
  private
    FViewerID : Integer;
    FHelpManager : IHelpManager;
    function HTMLHelpFileAvailable: Boolean;
  public
    { ICustomHelpViewer }
    function GetViewerName: string;
    function UnderstandsKeyword(const HelpString: String): Integer;
    function GetHelpStrings(const HelpString: String): TStringList;
    function CanShowTableOfContents: Boolean;
    procedure ShowHelp(const HelpString: String);
    procedure ShowTableOfContents;
    procedure NotifyID(const ViewerID: Integer);
    procedure SoftShutDown;
    procedure ShutDown;
    property HelpManager: IHelpManager read FHelpManager write FHelpManager;
    property ViewerID: Integer read FViewerID;
  public
    { IExtendedHelpViewer }
    function UnderstandsTopic(const Topic: String): Boolean;
    procedure DisplayTopic(const Topic: String);
    function UnderstandsContext(const ContextID: Integer; const HelpFileName: String): Boolean;
    procedure DisplayHelpByContext(const ContextID: Integer; const HelpFileName: String);
  end;


{ THTMLHelpViewer }

function THTMLHelpViewer.CanShowTableOfContents: Boolean;
begin
  Result := HTMLHelpFileAvailable;
end;

function THTMLHelpViewer.GetHelpStrings(const HelpString: String): TStringList;
begin
  Result := TStringList.Create;
  // We cannot query the HTML Help API to get a list of topic titles.
  // So we just return HelpString if a .chm file is available.
  if HTMLHelpFileAvailable then Result.Add(HelpString);
  Assert(Result <> nil, 'ENSURE: GetHelpStrings must always return a valid string list');
end;

function THTMLHelpViewer.GetViewerName: String;
begin
  Result := 'HTMLHelp Viewer';
end;

function THTMLHelpViewer.HTMLHelpFileAvailable: Boolean;
begin
  Result := SameText(ExtractFileExt(FHelpManager.GetHelpFile), '.chm');
end;

procedure THTMLHelpViewer.NotifyID(const ViewerID: Integer);
begin
  FViewerID := ViewerID;
end;

procedure THTMLHelpViewer.ShowHelp(const HelpString: String);
var
  AKLink: HH_AKLink;
{$IFDEF CLR}
  Data: IntPtr;
{$ENDIF}
begin
  AKLink.cbStruct := SizeOf(AKLink);
  AKLink.fReserved := False;
{$IFDEF CLR}
  AKLink.pszKeywords := Marshal.StringToHGlobalAuto(HelpString);
{$ENDIF}
{$IFDEF MSWINDOWS}
  AKLink.pszKeywords := PChar(HelpString);
{$ENDIF}
  AKLink.pszURL := nil;
  AKLink.pszMsgText := nil;
  AKLink.pszMsgTitle := nil;
  AKLink.pszWindow := nil;
  AKLink.fIndexOnFail := True;
{$IFDEF MSWINDOWS}
  HTMLHelp(HelpManager.GetHandle, PChar(HelpManager.GetHelpFile), HH_KEYWORD_LOOKUP, Integer(@AKLink));
{$ENDIF}
{$IFDEF CLR}
  Data := Marshal.AllocHGlobal(Marshal.SizeOf(AKLink));
  Marshal.StructureToPtr(AKLink, Data, False);
  HTMLHelp(HelpManager.GetHandle, HelpManager.GetHelpFile, HH_KEYWORD_LOOKUP, Data);
  Marshal.DestroyStructure(Data, TypeOf(AKLink));
{$ENDIF}
end;

procedure THTMLHelpViewer.ShowTableOfContents;
begin
{$IFDEF MSWINDOWS}
  HTMLHelp(HelpManager.GetHandle, PChar(HelpManager.GetHelpFile), HH_DISPLAY_TOC, 0);
{$ENDIF}
{$IFDEF CLR}
  HTMLHelp(HelpManager.GetHandle, HelpManager.GetHelpFile, HH_DISPLAY_TOC, 0);
{$ENDIF}
end;

procedure THTMLHelpViewer.ShutDown;
begin
  SoftShutDown;
  FHelpManager := nil;
end;

procedure THTMLHelpViewer.SoftShutDown;
begin
{$IFDEF MSWINDOWS}
  HTMLHelp(0, nil, HH_CLOSE_ALL, 0);
{$ENDIF}
{$IFDEF CLR}
  HTMLHelp(0, '', HH_CLOSE_ALL, 0);
{$ENDIF}
end;

function THTMLHelpViewer.UnderstandsKeyword(const HelpString: String): Integer;
begin
  // It is not possible to check if a .chm file's index contains a particular keyword through the HTML Help API
  // So we assume it does, if a .chm file is available at all
  if HTMLHelpFileAvailable then Result := 1
    else Result := 0
end;

procedure THTMLHelpViewer.DisplayHelpByContext(const ContextID: Integer; const HelpFileName: String);
begin
{$IFDEF MSWINDOWS}
  HTMLHelp(HelpManager.GetHandle, PChar(HelpFileName), HH_HELP_CONTEXT, ContextID);
{$ENDIF}
{$IFDEF CLR}
  HTMLHelp(HelpManager.GetHandle, HelpFileName, HH_HELP_CONTEXT, ContextID);
{$ENDIF}
end;

procedure THTMLHelpViewer.DisplayTopic(const Topic: String);
var
  URL: string;
begin
  if Topic = '' then URL := ''
    else if Topic[1] = '/' then URL := '::' + Topic
    else URL := '::/' + Topic;
{$IFDEF MSWINDOWS}
  HTMLHelp(HelpManager.GetHandle, PChar(HelpManager.GetHelpFile + URL), HH_DISPLAY_TOPIC, 0);
{$ENDIF}
{$IFDEF CLR}
  HTMLHelp(HelpManager.GetHandle, HelpManager.GetHelpFile + URL, HH_DISPLAY_TOPIC, 0);
{$ENDIF}
end;

function THTMLHelpViewer.UnderstandsContext(const ContextID: Integer; const HelpFileName: String): Boolean;
begin
  // It is not possible to check if the given context ID is mapped to a topic in the .chm file
  // So we assume it does, if a .chm file is available at all
  Result := HTMLHelpFileAvailable;
end;

function THTMLHelpViewer.UnderstandsTopic(const Topic: String): Boolean;
begin
  // It is not possible to check if .chm file contains a topic with the given file name
  // So we assume it does, if a .chm file is available at all
  Result := HTMLHelpFileAvailable;
end;

var
  HelpViewer: THTMLHelpViewer;

initialization
  // Enable support for CHM files
  HelpViewer := THTMLHelpViewer.Create;
  HelpIntfs.RegisterViewer(HelpViewer, HelpViewer.FHelpManager);
end.
