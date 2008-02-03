object frmProfileManager: TfrmProfileManager
  Left = 66
  Top = 284
  AutoScroll = False
  Caption = 'Profiles'
  ClientHeight = 307
  ClientWidth = 494
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object chkEnabled: TCheckBox
    Left = 8
    Top = 8
    Width = 97
    Height = 17
    Caption = 'Enable profiles'
    TabOrder = 0
    OnClick = chkEnabledClick
  end
  object grpProfiles: TGroupBox
    Left = 16
    Top = 32
    Width = 475
    Height = 237
    Anchors = [akLeft, akTop, akRight, akBottom]
    Caption = 'Profiles'
    TabOrder = 1
    object bvl1: TBevel
      Left = 398
      Top = 196
      Width = 9
      Height = 25
      Anchors = [akRight, akBottom]
      Shape = bsRightLine
    end
    object btnAddProfile: TButton
      Left = 346
      Top = 196
      Width = 49
      Height = 25
      Anchors = [akRight, akBottom]
      Caption = 'Add'
      TabOrder = 0
      OnClick = btnAddProfileClick
    end
    object Panel1: TPanel
      Left = 8
      Top = 16
      Width = 459
      Height = 174
      Anchors = [akLeft, akTop, akRight, akBottom]
      TabOrder = 2
      object lstProfiles: TProfileListDisplay
        Left = 1
        Top = 1
        Width = 457
        Height = 172
        onExecute = lstProfilesExecute
        onChange = lstProfilesChange
        ShowEnabled = True
        Align = alClient
        TabStop = True
        TabOrder = 0
      end
    end
    object btnEdit: TButton
      Left = 418
      Top = 196
      Width = 49
      Height = 25
      Anchors = [akRight, akBottom]
      Caption = 'Edit'
      Enabled = False
      TabOrder = 1
      OnClick = btnEditClick
    end
  end
  object btnOk: TButton
    Left = 338
    Top = 276
    Width = 73
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'Ok'
    ModalResult = 1
    TabOrder = 2
  end
  object Button1: TButton
    Left = 416
    Top = 276
    Width = 73
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'Help'
    TabOrder = 3
    OnClick = Button1Click
  end
end
