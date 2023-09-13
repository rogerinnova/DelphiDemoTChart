object FmYears: TFmYears
  Left = 0
  Top = 0
  Caption = 'FmYears'
  ClientHeight = 659
  ClientWidth = 941
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnClose = FormClose
  OnCreate = FormCreate
  OnResize = FormResize
  PixelsPerInch = 96
  TextHeight = 13
  object TopPanel: TPanel
    Left = 0
    Top = 0
    Width = 941
    Height = 41
    Align = alTop
    TabOrder = 0
    ExplicitTop = -6
    object BtnTest: TButton
      Left = 64
      Top = 8
      Width = 75
      Height = 30
      Caption = 'BtnTest'
      TabOrder = 0
      OnClick = BtnTestClick
    end
    object Btn3D: TButton
      Left = 186
      Top = 8
      Width = 70
      Height = 30
      Caption = 'Btn3D'
      TabOrder = 1
      OnClick = Btn3DClick
    end
    object BtnUndoZoom: TButton
      Left = 304
      Top = 8
      Width = 75
      Height = 30
      Caption = 'BtnUndoZoom'
      TabOrder = 2
      OnClick = BtnUndoZoomClick
    end
    object Btn3DUp: TButton
      Left = 150
      Top = 8
      Width = 34
      Height = 30
      Caption = '<<<'
      TabOrder = 3
      OnClick = Btn3DUpClick
    end
    object Btn3DDwn: TButton
      Left = 257
      Top = 8
      Width = 41
      Height = 30
      Caption = '>>>'
      TabOrder = 4
      OnClick = Btn3DDwnClick
    end
    object BtnSetAsVertStd: TButton
      Left = 751
      Top = 7
      Width = 98
      Height = 25
      Caption = 'BtnSetAsVertStd'
      TabOrder = 5
      OnClick = BtnSetAsVertStdClick
    end
  end
  object PnlBottom: TPanel
    Left = 0
    Top = 608
    Width = 941
    Height = 51
    Align = alBottom
    TabOrder = 1
    DesignSize = (
      941
      51)
    object LblCurrentValue: TLabel
      Left = 400
      Top = 16
      Width = 133
      Height = 23
      Anchors = [akTop, akRight]
      Caption = 'LblCurrentValue'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = 4678655
      Font.Height = -19
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
    end
    object CbxDoYearOnYear: TCheckBox
      Left = 8
      Top = 6
      Width = 97
      Height = 17
      Caption = 'Do Year On Year'
      TabOrder = 0
      OnClick = CbxDoYearOnYearClick
    end
    object CbxSelectControledLoad: TCheckBox
      Left = 8
      Top = 29
      Width = 97
      Height = 17
      Caption = 'CbxSelectControledLoad'
      TabOrder = 1
      OnClick = CbxDoYearOnYearClick
    end
    object CbxSelectGeneralLoad: TCheckBox
      Left = 160
      Top = 8
      Width = 97
      Height = 17
      Caption = 'CbxSelectGeneralLoad'
      Checked = True
      State = cbChecked
      TabOrder = 2
      OnClick = CbxDoYearOnYearClick
    end
  end
  object Chart: TChart
    Left = 0
    Top = 41
    Width = 941
    Height = 567
    Title.Text.Strings = (
      'TChart')
    OnClickLegend = ChartClickLegend
    OnGetLegendPos = ChartGetLegendPos
    OnGetLegendRect = ChartGetLegendRect
    OnUndoZoom = ChartUndoZoom
    OnZoom = ChartZoom
    View3DOptions.Tilt = 5
    OnGetLegendText = ChartGetLegendText
    Align = alClient
    TabOrder = 2
    OnMouseDown = ChartMouseDown
    DesignSize = (
      941
      567)
    DefaultCanvas = 'TGDIPlusCanvas'
    ColorPaletteIndex = 13
    object PnlDateZoom: TPanel
      Left = 785
      Top = 464
      Width = 153
      Height = 97
      Anchors = [akRight, akBottom]
      TabOrder = 0
      Visible = False
      DesignSize = (
        153
        97)
      object BtnZoomOut: TButton
        Left = 8
        Top = 34
        Width = 65
        Height = 25
        Anchors = [akRight, akBottom]
        Caption = 'Zoom Out'
        TabOrder = 0
        OnClick = BtnZoomOutClick
      end
      object BtnZoomIn: TButton
        Left = 87
        Top = 34
        Width = 58
        Height = 25
        Anchors = [akRight, akBottom]
        Caption = 'Zoom In'
        TabOrder = 1
        OnClick = BtnZoomInClick
      end
      object DatePicker: TDatePicker
        Left = 3
        Top = 65
        Anchors = [akRight, akBottom]
        Date = 45113.000000000000000000
        DateFormat = 'd/MM/yyyy'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -16
        Font.Name = 'Segoe UI'
        Font.Style = []
        MaxYear = 2030
        MinYear = 2000
        TabOrder = 2
        OnCloseUp = DateTimePickerCloseUp
      end
      object BtnScrollRight: TButton
        Left = 104
        Top = 0
        Width = 41
        Height = 28
        Caption = '>>>'
        TabOrder = 3
        OnClick = BtnScrollRightClick
      end
      object BtnScrollLeft: TButton
        Left = 8
        Top = 3
        Width = 33
        Height = 25
        Caption = '<<<'
        TabOrder = 4
        OnClick = BtnScrollLeftClick
      end
      object BtnMark: TButton
        Left = 53
        Top = 3
        Width = 43
        Height = 25
        Caption = 'Mark'
        TabOrder = 5
        OnClick = BtnMarkClick
      end
    end
    object GeneralUsage: TLineSeries
      Marks.Visible = True
      Marks.Callout.Length = 10
      Marks.DrawEvery = 5
      Brush.BackColor = clDefault
      Pointer.InflateMargins = True
      Pointer.Style = psRectangle
      XValues.Name = 'X'
      XValues.Order = loAscending
      YValues.Name = 'Y'
      YValues.Order = loNone
    end
    object ControlledLoad: TBarSeries
      BarBrush.Color = clNone
      Marks.Angle = 90
      Marks.Arrow.Color = clBlue
      Marks.Arrow.Visible = False
      Marks.Callout.Arrow.Color = clBlue
      Marks.Callout.Arrow.Visible = False
      Title = 'Controlled Load'
      BarStyle = bsArrow
      BarWidthPercent = 1
      DepthPercent = 1
      MarksLocation = mlStart
      XValues.Name = 'X'
      XValues.Order = loAscending
      YValues.Name = 'Bar'
      YValues.Order = loNone
    end
  end
end
