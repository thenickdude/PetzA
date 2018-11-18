object Form1: TForm1
  Left = 192
  Top = 114
  BorderStyle = bsSingle
  Caption = 'Direct Data Access Demo'
  ClientHeight = 265
  ClientWidth = 336
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Shell Dlg 2'
  Font.Style = []
  OldCreateOrder = False
  Position = poDesktopCenter
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 22
    Top = 13
    Width = 260
    Height = 39
    Caption = 
      'Very simple Bitmap viewer demonstrates how to access'#13#10'file data ' +
      'directly within a Zip file without un-zipping and'#13#10'without using' +
      ' temporary files.'
  end
  object Label2: TLabel
    Left = 22
    Top = 85
    Width = 120
    Height = 13
    Caption = 'Contents of demo Zip file:'
  end
  object Label3: TLabel
    Left = 22
    Top = 240
    Width = 39
    Height = 13
    Caption = 'Label3'
    Font.Charset = ANSI_CHARSET
    Font.Color = clRed
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object Label4: TLabel
    Left = 89
    Top = 66
    Width = 136
    Height = 13
    Caption = 'Click a file name below:'
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object ListBox1: TListBox
    Left = 22
    Top = 102
    Width = 291
    Height = 129
    ItemHeight = 13
    TabOrder = 0
    OnClick = ListBox1Click
  end
end
