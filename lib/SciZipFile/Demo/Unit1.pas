unit Unit1;

//--------------------------------------------------------------
// Application to demonstrate use of
// Patrik Spanel's SciZipFile
// By Nick Naimo (nick@naimo.com)  July 6, 2004
//--------------------------------------------------------------

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls;

type
  TForm1 = class(TForm)
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    ListBox1: TListBox;
    Label4: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure ListBox1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

uses
  SciZipFile, Unit2 ;

var
  ZipFileMem : TZipFile ;

{$R *.dfm}

procedure TForm1.FormCreate(Sender: TObject);
var
  BitmapTotal, i : Integer ;
begin
  BitmapTotal := 0 ;
  ListBox1.Items.Clear ;
  Screen.Cursor := crHourglass ;

  { Load & get contents of zip file }
  ZipFileMem := TZipFile.Create ;
  ZipFileMem.LoadFromFile(ExtractFilePATH(Application.EXEName) + 'Bitmaps.zip');
  for i := 0 to ZipFileMem.Count -1
  do begin
     { Paths currently use "/". Change them to "\" }
     ListBox1.Items.Add(StringReplace(ZipFileMem.Name[i],
                                     '/', '\', [rfReplaceAll])) ;
     if Lowercase(ExtractFileExt(ListBox1.Items[i])) = '.bmp' then
        inc(BitmapTotal) ;
  end;

  Label2.Caption := Label2.Caption
                  + ' Total files = ' + IntToStr(ListBox1.Items.Count) + ', '
                  + ' Total bitmaps = ' + IntToStr(BitmapTotal) ;
  Label3.Caption := '' ;

  Screen.Cursor := crDefault ;
end;

procedure TForm1.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  ZipFileMem.Free ;
end;

procedure TForm1.ListBox1Click(Sender: TObject);
var
  StrStream : TStringStream ;
  ABitmap   : TBitmap ;
begin
  if Lowercase(ExtractFileExt(ListBox1.Items[ListBox1.ItemIndex])) <> '.bmp'
  then begin
       Label3.Caption := 'Not a Bitmap file, select another.' ;
       exit;
  end
  else Label3.Caption := '' ;

  { Convert string to stream }
  StrStream := TStringStream.Create(ZipFileMem.Data[ListBox1.ItemIndex]) ;

  { Clears current image }
  Form2.Image1.Picture := nil ;
  Form2.Image1.Refresh ;

  { Assign bitmap }
  ABitmap := TBitmap.Create ;
  ABitmap.LoadFromStream (StrStream) ;
  Form2.Image1.Picture.Bitmap := ABitmap ;

  { Position & show form }
  Form2.Left   := Left + Width ;
  Form2.Top    := Top + 2 ;
  Form2.ClientHeight:= ABitmap.Height ;
  Form2.ClientWidth := ABitmap.Width ;
  Form2.Show ;

  { Free resources }
  ABitmap.Free ;
  StrStream.Free ;
end;

end.
