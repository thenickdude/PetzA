object frmProfileEdit: TfrmProfileEdit
  Left = 279
  Top = 232
  BorderStyle = bsDialog
  Caption = 'Edit profile...'
  ClientHeight = 138
  ClientWidth = 414
  Color = clBtnFace
  Constraints.MaxHeight = 170
  Constraints.MinHeight = 165
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  Scaled = False
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnShow = FormShow
  DesignSize = (
    414
    138)
  PixelsPerInch = 96
  TextHeight = 13
  object lblTitle: TLabel
    Left = 104
    Top = 8
    Width = 31
    Height = 13
    Caption = 'Name:'
  end
  object Label1: TLabel
    Left = 104
    Top = 56
    Width = 56
    Height = 13
    Caption = 'Description:'
  end
  object Label2: TLabel
    Left = 8
    Top = 8
    Width = 24
    Height = 13
    Caption = 'Icon:'
  end
  object edtTitle: TEdit
    Left = 112
    Top = 24
    Width = 293
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    TabOrder = 0
    Text = 'Untitled'
  end
  object edtDesc: TEdit
    Left = 112
    Top = 72
    Width = 293
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    TabOrder = 1
    Text = 'My new profile'
  end
  object btnCancel: TButton
    Left = 332
    Top = 104
    Width = 75
    Height = 25
    Anchors = [akTop, akRight]
    Cancel = True
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 3
  end
  object btnOk: TButton
    Left = 252
    Top = 104
    Width = 75
    Height = 25
    Anchors = [akTop, akRight]
    Caption = 'Ok'
    Default = True
    ModalResult = 1
    TabOrder = 2
  end
  object imgIcon: TImage32
    Left = 16
    Top = 24
    Width = 73
    Height = 73
    Cursor = crHandPoint
    Bitmap.ResamplerClassName = 'TNearestResampler'
    BitmapAlign = baTopLeft
    Scale = 1.000000000000000000
    ScaleMode = smNormal
    TabOrder = 4
    OnClick = imgIconClick
  end
end
