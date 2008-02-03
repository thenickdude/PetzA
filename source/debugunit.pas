unit debugunit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls;

type
  TfrmDebug = class(TForm)
    Memo1: TMemo;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmDebug: TfrmDebug;

{$IFDEF petzadebug}
procedure debuglog(s: string);
{$ENDIF}

implementation

{$R *.DFM}

{$IFDEF petzadebug}

procedure debuglog(s: string);
begin
  frmdebug.Memo1.lines.add(s);
end;
{$ENDIF}

procedure TfrmDebug.FormCreate(Sender: TObject);
begin
  memo1.lines.add('Started: ' + DateTimeToStr(now));
end;

procedure TfrmDebug.FormDestroy(Sender: TObject);
begin
 memo1.lines.savetofile('C:\debug.log');
end;

end.
