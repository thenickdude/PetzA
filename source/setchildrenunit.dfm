object frmSetnumchildren: TfrmSetnumchildren
  Left = 319
  Top = 277
  BorderStyle = bsDialog
  Caption = 'Set number of children...'
  ClientHeight = 125
  ClientWidth = 392
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 16
    Top = 72
    Width = 48
    Height = 13
    Caption = 'Number:'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object btnCancel: TButton
    Left = 312
    Top = 96
    Width = 75
    Height = 25
    Cancel = True
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 2
  end
  object btrnSet: TButton
    Left = 232
    Top = 96
    Width = 75
    Height = 25
    Caption = 'Set'
    Default = True
    ModalResult = 1
    TabOrder = 1
    OnClick = btrnSetClick
  end
  object Memo1: TMemo
    Left = 8
    Top = 8
    Width = 377
    Height = 57
    TabStop = False
    BorderStyle = bsNone
    Color = clBtnFace
    Lines.Strings = (
      
        'By choosing a number below and clicking "Set", you can change ho' +
        'w many '
      
        'babies your pets will have when they are pregnant. You must set ' +
        'this every time '
      
        'you play Petz (It doesn'#39't remember what you choose), and you mus' +
        't set it before '
      'your pet gets pregnant.')
    ReadOnly = True
    TabOrder = 3
  end
  object cmbNumber: TComboBox
    Left = 72
    Top = 72
    Width = 121
    Height = 21
    Style = csDropDownList
    TabOrder = 0
    Items.Strings = (
      '1'
      '2'
      '3'
      '4')
  end
end
