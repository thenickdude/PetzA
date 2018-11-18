unit fvdMain;
{*******************************************************************************
Unit:        fvdMain
Author:      Michael Burton
             Copyright © 1999 Rimrock Software
             All rights reserved.
Date:        February 3, 1999
Use with:    Delphi 2, 3, 4 only
Description: Main unit for fvDemo program. Exercises the TrsFileVersion object.
Maintenance:
********************************************************************************}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  rsFileVersion, StdCtrls, Mask, ToolEdit, Buttons;

type
  TForm1 = class(TForm)
    btnGetVersion: TButton;
    edtVersion: TEdit;
    edtMajor: TEdit;
    edtMinor: TEdit;
    edtRelease: TEdit;
    edtBuild: TEdit;
    edtFileName: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    btnExit: TButton;
    bbtnOpenFile: TBitBtn;
    OpenDialog1: TOpenDialog;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure edtFileNameChange(Sender: TObject);
    procedure bbtnOpenFileClick(Sender: TObject);
    procedure btnGetVersionClick(Sender: TObject);
    procedure btnExitClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    FV: TrsFileVersion; {variable for instance of file version object}
  end;

var
  Form1: TForm1;

implementation

{$R *.DFM}

{********************************************************************
Function    : FormCreate
Date        : February 3, 1999
Description : Create instance of file version object
Inputs      : None
Outputs     : None
********************************************************************}
procedure TForm1.FormCreate(Sender: TObject);
begin
  FV := TrsFileVersion.Create;
end;

{********************************************************************
Function    : FormDestroy
Date        : February 3, 1999
Description : Free the file version object instance
Inputs      : None
Outputs     : None
********************************************************************}
procedure TForm1.FormDestroy(Sender: TObject);
begin
  FV.Free;
end;

{********************************************************************
Function    : edtFileNameChange
Date        : February 3, 1999
Description : Change status of Get Version button as the file box
              changes
Inputs      : None
Outputs     : None
********************************************************************}
procedure TForm1.edtFileNameChange(Sender: TObject);
begin
  if Length(edtFileName.Text) > 0 then begin
    btnGetVersion.Enabled := True;
  end else begin
    btnGetVersion.Enabled := False;
  end;
end;

{********************************************************************
Function    : bbtnOpenFileClick
Date        : February 3, 1999
Description : Use an file open dialog to get a file name/path
Inputs      : None
Outputs     : None
********************************************************************}
procedure TForm1.bbtnOpenFileClick(Sender: TObject);
begin
  if OpenDialog1.Execute then begin
    edtFileName.Text := OpenDialog1.Filename;
  end;
end;

{********************************************************************
Function    : btnGetVersionClick
Date        : February 3, 1999
Description : Get/display the version information for the file
Inputs      : None
Outputs     : None
********************************************************************}
procedure TForm1.btnGetVersionClick(Sender: TObject);
var
  s: string;
  i: integer;
begin
  edtVersion.text := '';
  edtMajor.text := '';
  edtMinor.text := '';
  edtRelease.text := '';
  edtBuild.text := '';
  s := edtFileName.Text;
  i := Pos('"',s);
  while (i <> 0) do begin
    Delete(s,i,1);
    i := Pos('"',s);
  end;
  if FV.GetFileVersion(s) then begin
    edtVersion.Text := FV.Version;
    edtMajor.Text := IntToStr(FV.Major);
    edtMinor.Text := IntToStr(FV.Minor);
    edtRelease.Text := IntToStr(FV.Release);
    edtBuild.Text := IntToStr(FV.Build);
  end;
end;

{********************************************************************
Function    : btnexitClick
Date        : February 1, 1999
Description : Exit from the program
Inputs      : None
Outputs     : None
********************************************************************}
procedure TForm1.btnExitClick(Sender: TObject);
begin
  Close;
end;

end.
