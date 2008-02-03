object frmPickIcon: TfrmPickIcon
  Left = 241
  Top = 189
  BorderStyle = bsDialog
  Caption = 'Pick profile icon...'
  ClientHeight = 287
  ClientWidth = 488
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object icongrid: TItemGrid32
    Left = 8
    Top = 8
    Width = 471
    Height = 241
    Anchors = [akLeft, akTop, akRight, akBottom]
    Color = -1
    GridLineColor = -1
    DefaultColWidth = 62
    DefaultRowHeight = 62
    ItemCount = 0
    OnDrawItem = icongridDrawItem
    OnSelectCell = icongridSelectCell
  end
  object Button1: TButton
    Left = 408
    Top = 256
    Width = 73
    Height = 25
    Anchors = [akRight, akBottom]
    Cancel = True
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 3
  end
  object btnOk: TButton
    Left = 328
    Top = 256
    Width = 73
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'Ok'
    Default = True
    Enabled = False
    ModalResult = 1
    TabOrder = 2
  end
  object Button2: TButton
    Left = 248
    Top = 256
    Width = 73
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'Clear Icon'
    ModalResult = 7
    TabOrder = 1
  end
end
