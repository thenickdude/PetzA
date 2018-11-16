object frmSliderBrain: TfrmSliderBrain
  Left = 428
  Top = 248
  BorderStyle = bsDialog
  Caption = 'Petz brain'
  ClientHeight = 227
  ClientWidth = 220
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
  OnCreate = FormCreate
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object tmrRefresh: TTimer
    OnTimer = tmrRefreshTimer
    Left = 72
    Top = 72
  end
end
