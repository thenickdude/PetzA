object frmGameSpeed: TfrmGameSpeed
  Left = 273
  Top = 376
  BorderStyle = bsDialog
  Caption = 'Set game speed'
  ClientHeight = 111
  ClientWidth = 408
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnClose = FormClose
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 8
    Top = 16
    Width = 63
    Height = 13
    Caption = 'Game speed:'
  end
  object lbl1: TLabel
    Left = 128
    Top = 8
    Width = 273
    Height = 65
    AutoSize = False
    Caption = 
      'Use this dialog to change the speed of your Petz game.'#13#10#13#10'Smalle' +
      'r numbers are faster. The default speed for this version of Petz' +
      ' is %d.'
    WordWrap = True
  end
  object Bevel1: TBevel
    Left = 0
    Top = 72
    Width = 408
    Height = 39
    Align = alBottom
    Shape = bsTopLine
  end
  object btnCancel: TButton
    Left = 328
    Top = 80
    Width = 75
    Height = 25
    Cancel = True
    Caption = 'Cancel'
    TabOrder = 4
    OnClick = btnCancelClick
  end
  object btnOk: TButton
    Left = 248
    Top = 80
    Width = 75
    Height = 25
    Caption = 'Ok'
    Default = True
    TabOrder = 3
    OnClick = btnOkClick
  end
  object Button3: TButton
    Left = 88
    Top = 80
    Width = 75
    Height = 25
    Caption = 'Default'
    TabOrder = 1
    OnClick = Button3Click
  end
  object btnApply: TButton
    Left = 168
    Top = 80
    Width = 75
    Height = 25
    Caption = 'Apply'
    TabOrder = 2
    OnClick = btnApplyClick
  end
  object spnSpeed: TSpinEdit
    Left = 16
    Top = 32
    Width = 97
    Height = 22
    MaxValue = 10000
    MinValue = 1
    TabOrder = 0
    Value = 30
  end
end
