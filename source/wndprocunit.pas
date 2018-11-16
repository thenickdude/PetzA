unit wndprocunit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls, StdCtrls;

type
  TForm1 = class(TForm)
    Label1: TLabel;
    Button1: TButton;
    Timer1: TTimer;
    Label2: TLabel;
    procedure Timer1Timer(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.DFM}

procedure TForm1.Timer1Timer(Sender: TObject);
var wnd:hwnd;
p:integer;
s:string;
begin
 wnd:=WindowFromPoint(mouse.cursorpos);
 if wnd<>0 then begin
  p:=getwindowlong(wnd, GWL_WNDPROC);
  label1.Caption:=inttohex(p,8);
  setlength(s,100);
  setlength(s,GetWindowText(wnd,pchar(s),100));
  label2.caption:=s;
 end;
end;

end.
