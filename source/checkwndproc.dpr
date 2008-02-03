program checkwndproc;

uses
  madExcept,
  madLinkDisAsm,
  Forms,
  wndprocunit in 'wndprocunit.pas' {Form1};

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
