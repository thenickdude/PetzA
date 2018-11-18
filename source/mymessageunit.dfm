object frmMyMessage: TfrmMyMessage
  Left = 219
  Top = 164
  BorderStyle = bsDialog
  Caption = 'Message'
  ClientHeight = 79
  ClientWidth = 360
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  FormStyle = fsStayOnTop
  OldCreateOrder = False
  Position = poScreenCenter
  OnClose = FormClose
  PixelsPerInch = 96
  TextHeight = 13
  object lblmain: TLabel
    Left = 8
    Top = 8
    Width = 32
    Height = 13
    Caption = 'lblmain'
  end
  object btnOkay: TButton
    Left = 144
    Top = 48
    Width = 75
    Height = 25
    Cancel = True
    Caption = 'Ok'
    Default = True
    TabOrder = 0
    OnClick = btnOkayClick
  end
  object chkDontShowAgain: TCheckBox
    Left = 8
    Top = 24
    Width = 177
    Height = 17
    Caption = 'Don'#39't show this message again'
    TabOrder = 1
  end
end
