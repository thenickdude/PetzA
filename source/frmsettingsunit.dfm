object frmSettings: TfrmSettings
  Left = 421
  Top = 372
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsDialog
  Caption = 'PetzA Settings'
  ClientHeight = 183
  ClientWidth = 396
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  DesignSize = (
    396
    183)
  PixelsPerInch = 96
  TextHeight = 13
  object Bevel1: TBevel
    Left = 0
    Top = 142
    Width = 396
    Height = 41
    Align = alBottom
    Shape = bsTopLine
  end
  object lblCameraFormat: TLabel
    Left = 224
    Top = 8
    Width = 106
    Height = 13
    Caption = 'Camera picture format:'
  end
  object btnCancel: TButton
    Left = 254
    Top = 150
    Width = 67
    Height = 25
    Anchors = [akRight, akBottom]
    Cancel = True
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 7
  end
  object btnOk: TButton
    Left = 182
    Top = 150
    Width = 68
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'Ok'
    Default = True
    ModalResult = 1
    TabOrder = 6
    OnClick = btnOkClick
  end
  object chkBrainSliders: TCheckBox
    Left = 8
    Top = 8
    Width = 217
    Height = 17
    Caption = 'Brainsliders should be "Always on top"'
    Checked = True
    State = cbChecked
    TabOrder = 0
  end
  object Button3: TButton
    Left = 6
    Top = 150
    Width = 169
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'Reset hidden warning messages'
    TabOrder = 9
    OnClick = Button3Click
  end
  object chkNameTags: TCheckBox
    Left = 8
    Top = 24
    Width = 217
    Height = 17
    Caption = 'Draw name tags on pets'
    TabOrder = 1
  end
  object btnHelp: TButton
    Left = 326
    Top = 150
    Width = 68
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'Help'
    TabOrder = 8
    OnClick = btnHelpClick
  end
  object chkHideNavigation: TCheckBox
    Left = 8
    Top = 40
    Width = 201
    Height = 17
    Caption = 'Hide Babyz navigation bar'
    TabOrder = 2
  end
  object GroupBox1: TGroupBox
    Left = 8
    Top = 80
    Width = 217
    Height = 57
    Caption = 'Mating'
    TabOrder = 5
    object chkShowHeart: TCheckBox
      Left = 8
      Top = 32
      Width = 201
      Height = 17
      Caption = 'Show love heart when mating'
      TabOrder = 1
    end
    object chkInstantBirth: TCheckBox
      Left = 8
      Top = 16
      Width = 201
      Height = 17
      Caption = 'Babies should be born instantly'
      TabOrder = 0
    end
  end
  object cmbCameraFormat: TComboBox
    Left = 232
    Top = 24
    Width = 145
    Height = 21
    Style = csDropDownList
    TabOrder = 4
    Items.Strings = (
      'Bitmap (Petz Default)'
      'GIF'
      'PNG')
  end
  object chkNoDiapers: TCheckBox
    Left = 8
    Top = 56
    Width = 201
    Height = 17
    Caption = 'Diapers can'#39't be soiled'
    Enabled = False
    TabOrder = 3
  end
end
