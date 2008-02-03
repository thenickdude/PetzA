object frmPickProfile: TfrmPickProfile
  Left = 471
  Top = 289
  Width = 548
  Height = 304
  Caption = 'Choose profile...'
  Color = clBtnFace
  Constraints.MinHeight = 200
  Constraints.MinWidth = 250
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object lbl1: TLabel
    Left = 8
    Top = 8
    Width = 172
    Height = 13
    Caption = 'Pick the profile that you want to use:'
  end
  object btnLoad: TButton
    Left = 374
    Top = 244
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'Ok'
    Default = True
    Enabled = False
    ModalResult = 1
    TabOrder = 0
  end
  object btnCancel: TButton
    Left = 454
    Top = 244
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Cancel = True
    Caption = 'Quit Petz'
    ModalResult = 2
    TabOrder = 1
  end
  object Panel1: TPanel
    Left = 16
    Top = 24
    Width = 513
    Height = 209
    Anchors = [akLeft, akTop, akRight, akBottom]
    TabOrder = 2
    object lstProfiles: TProfileListDisplay
      Left = 1
      Top = 1
      Width = 511
      Height = 207
      onExecute = lstProfilesExecute
      onChange = lstProfilesChange
      Align = alClient
      TabStop = True
      TabOrder = 0
    end
  end
end
