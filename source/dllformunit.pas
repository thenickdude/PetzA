unit dllformunit;

interface

uses
  Windows, Messages, SysUtils, Classes, Vcl.Forms,
  Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.Menus, contnrs, mymenuunit, Vcl.Controls;

type
  TfrmDLLMain = class(TForm)
    Memo1: TMemo;
    Button1: TButton;
    Button3: TButton;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmDLLMain: TfrmDLLMain;
  oldwndproc: pointer;
  petsfollowmouse: boolean;
  lastmousefollowtime: tdatetime;


//playdogaction looks interesting!!
//pushdogaction even more so
implementation
uses dllpatchunit, petzclassesunit, aboutunit;
{$R *.DFM}


end.

