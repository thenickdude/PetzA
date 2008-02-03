object Form1: TForm1
  Left = 684
  Top = 604
  Width = 196
  Height = 74
  Caption = 'Puppet Master'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object Button1: TButton
    Left = 8
    Top = 8
    Width = 75
    Height = 25
    Caption = 'Inject'
    TabOrder = 0
    OnClick = Button1Click
  end
  object Button2: TButton
    Left = 96
    Top = 8
    Width = 75
    Height = 25
    Caption = 'Button2'
    TabOrder = 1
  end
  object PopupMenu1: TPopupMenu
    Left = 88
    Top = 8
    object wow1: TMenuItem
      Caption = 'wow'
    end
    object cool1: TMenuItem
      Caption = 'cool'
    end
    object beans1: TMenuItem
      Caption = 'beans!'
    end
    object N1: TMenuItem
      Caption = '-'
    end
    object exit1: TMenuItem
      Caption = 'exit'
    end
  end
end
