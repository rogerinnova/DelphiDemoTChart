object AGLMeterForm: TAGLMeterForm
  Left = 0
  Top = 0
  Caption = 'AGLMeterForm'
  ClientHeight = 483
  ClientWidth = 635
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  Menu = MainMenu1
  OldCreateOrder = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object BtnShowChart: TButton
    Left = 136
    Top = 32
    Width = 75
    Height = 25
    Caption = 'BtnShowChart'
    TabOrder = 0
    OnClick = BtnShowChartClick
  end
  object BtnShowYonY: TButton
    Left = 136
    Top = 80
    Width = 75
    Height = 25
    Caption = 'BtnShowYonY'
    TabOrder = 1
    OnClick = BtnShowYonYClick
  end
  object LbxForms: TListBox
    Left = 344
    Top = 40
    Width = 241
    Height = 393
    ItemHeight = 13
    TabOrder = 2
    OnClick = LbxFormsClick
  end
  object BtnShowMonth: TButton
    Left = 136
    Top = 136
    Width = 75
    Height = 25
    Caption = 'BtnShowMonth'
    TabOrder = 3
    OnClick = BtnShowMonthClick
  end
  object DatePicker1: TDatePicker
    Left = 40
    Top = 401
    Date = 45140.000000000000000000
    DateFormat = 'd/MM/yyyy'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'Segoe UI'
    Font.Style = []
    TabOrder = 4
  end
  object BtnShowDay: TButton
    Left = 136
    Top = 192
    Width = 75
    Height = 25
    Caption = 'BtnShowDay'
    TabOrder = 5
    OnClick = BtnShowDayClick
  end
  object BtnCascade: TButton
    Left = 8
    Top = 40
    Width = 75
    Height = 25
    Caption = 'BtnCascade'
    TabOrder = 6
    OnClick = BtnCascadeClick
  end
  object BtnTile: TButton
    Left = 8
    Top = 96
    Width = 75
    Height = 25
    Caption = 'BtnTile'
    TabOrder = 7
    OnClick = BtnTileClick
  end
  object BtnShowHolidays: TButton
    Left = 136
    Top = 240
    Width = 75
    Height = 25
    Caption = 'BtnShowHolidays'
    TabOrder = 8
    OnClick = BtnShowHolidaysClick
  end
  object BtnStopVertSync: TButton
    Left = 16
    Top = 344
    Width = 121
    Height = 25
    Caption = 'BtnStopVertSync'
    TabOrder = 9
    OnClick = BtnStopVertSyncClick
  end
  object MainMenu1: TMainMenu
    Left = 232
    Top = 168
    object File1: TMenuItem
      Caption = 'File'
      object OpenData1: TMenuItem
        Caption = 'Open Data'
        OnClick = OpenData1Click
      end
      object OpenDatabase1: TMenuItem
        Caption = 'OpenDatabase'
        OnClick = OpenDatabase1Click
      end
      object OpenServerDb1: TMenuItem
        Caption = 'Open Server Db'
        OnClick = OpenServerDb1Click
      end
    end
  end
end
