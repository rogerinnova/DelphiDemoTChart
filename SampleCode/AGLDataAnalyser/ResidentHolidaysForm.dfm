object ResHolidayForm: TResHolidayForm
  Left = 0
  Top = 0
  Caption = 'ResHolidayForm'
  ClientHeight = 562
  ClientWidth = 635
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object LbxHolidays: TListBox
    Left = 272
    Top = 0
    Width = 363
    Height = 562
    Align = alRight
    ItemHeight = 13
    TabOrder = 0
    OnDblClick = LbxHolidaysDblClick
  end
end
