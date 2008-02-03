unit pptunit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, madcodehook, Menus;

type
  TForm1 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    PopupMenu1: TPopupMenu;
    wow1: TMenuItem;
    cool1: TMenuItem;
    beans1: TMenuItem;
    N1: TMenuItem;
    exit1: TMenuItem;
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;
  h: cardinal;

implementation

{$R *.DFM}

procedure TForm1.Button1Click(Sender: TObject);
var
  StartUpInfo: TStartUpInfo;
  ProcInfo: Process_Information;
  errno: integer;
  msg: pchar;
begin
  FillChar(StartUpInfo, SizeOf(StartUpInfo), 0);
  StartUpInfo.cb := SizeOf(StartUpInfo);
  if not CreateProcessex(nil,
    'C:\Program Files\Ubi Soft\Studio Mythos\Petz 5\petz 5.exe',
    nil, nil, False, 0, nil, nil, // dir
    StartUpInfo, ProcInfo, extractfilepath(application.exename) + 'puppetdll.dll') then begin
    ErrNo := GetLastError;
    Msg := AllocMem(4096);
    try
      FormatMessage(FORMAT_MESSAGE_FROM_SYSTEM, nil, ErrNo,
        0, Msg, 4096, nil);
      showmessage('Create Process Error #' + IntToStr(ErrNo) + ': ' + string(Msg));
    finally
      FreeMem(Msg);
    end;
  end;
  h := procinfo.hprocess;
end;

end.

