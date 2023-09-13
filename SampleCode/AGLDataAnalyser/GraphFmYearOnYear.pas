unit GraphFmYearOnYear;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  // System.Math,
  System.Classes, Vcl.Graphics, System.generics.collections,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, VclTee.TeeGDIPlus, VclTee.TeEngine,
  VclTee.Series, Vcl.ExtCtrls, VclTee.TeeProcs, VclTee.Chart, Vcl.StdCtrls,
  AGLAnalyserObjs, Vcl.WinXPickers, Vcl.ComCtrls;

type
  TFmYearOnYear = class(TForm)
    TopPanel: TPanel;
    BtnTest: TButton;
    Btn3D: TButton;
    BtnUndoZoom: TButton;
    PnlBottom: TPanel;
    Chart: TChart;
    GeneralUsage: TLineSeries;
    ControlledLoad: TBarSeries;
    btn2020: TButton;
    Btn2021: TButton;
    Btn2022: TButton;
    Btn2023: TButton;
    PnlDateZoom: TPanel;
    BtnZoomOut: TButton;
    BtnZoomIn: TButton;
    DatePicker: TDatePicker;
    CkbxDoYearOnYear: TCheckBox;
    BtnScrollRight: TButton;
    BtnScrollLeft: TButton;
    LblCurrentValue: TLabel;
    BtnMark: TButton;
    CbxWeekEndsonly: TCheckBox;
    CbxSelectWeekdays: TCheckBox;
    PnlDaysOfWeek: TPanel;
    CbxMonday: TCheckBox;
    CbxTuesday: TCheckBox;
    CbxThursday: TCheckBox;
    CbxSunday: TCheckBox;
    CbxWednesday: TCheckBox;
    CbxFriday: TCheckBox;
    CbxSaturday: TCheckBox;
    Btn3DUp: TButton;
    Btn3DDwn: TButton;
    BtnSetAsVertStd: TButton;
    procedure BtnTestClick(Sender: TObject);
    procedure Btn3DClick(Sender: TObject);
    procedure BtnUndoZoomClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure ChartMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure GeneralUsageMouseEnter(Sender: TObject);
    procedure ControlledLoadMouseLeave(Sender: TObject);
    procedure GeneralUsageClick(Sender: TChartSeries; ValueIndex: Integer;
      Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure GeneralUsageClickPointer(Sender: TCustomSeries;
      ValueIndex, X, Y: Integer);
    procedure Btn2023Click(Sender: TObject);
    procedure Btn2022Click(Sender: TObject);
    procedure Btn2021Click(Sender: TObject);
    procedure btn2020Click(Sender: TObject);
    procedure ChartZoom(Sender: TObject);
    procedure ChartUndoZoom(Sender: TObject);
    procedure ControlledLoadClick(Sender: TChartSeries; ValueIndex: Integer;
      Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure DateTimePickerCloseUp(Sender: TObject);
    procedure BtnZoomInClick(Sender: TObject);
    procedure BtnZoomOutClick(Sender: TObject);
    procedure BtnScrollRightClick(Sender: TObject);
    procedure BtnScrollLeftClick(Sender: TObject);
    procedure BtnMarkClick(Sender: TObject);
    procedure ChartClickLegend(Sender: TCustomChart; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure ChartGetLegendPos(Sender: TCustomChart; Index: Integer;
      var X, Y, XColor: Integer);
    procedure ChartGetLegendRect(Sender: TCustomChart; var Rect: TRect);
    procedure ChartGetLegendText(Sender: TCustomAxisPanel;
      LegendStyle: TLegendStyle; Index: Integer; var LegendText: string);
    procedure CbxSelectWeekdaysClick(Sender: TObject);
    procedure Btn3DDwnClick(Sender: TObject);
    procedure Btn3DUpClick(Sender: TObject);
    procedure CkbxDoYearOnYearClick(Sender: TObject);
    procedure BtnSetAsVertStdClick(Sender: TObject);
    procedure FormResize(Sender: TObject);
  private
    { Private declarations }
    FRefenceYear: Word;
    FReferenceDate: TDateTime; // Start of Month 12 months ago - Start of chart
    FDateCentre, FDateHalfScale: TDateTime;
    FDateCentreStart, FDateHalfScaleStart: TDateTime;
    // FAllSeries: TList<TChartSeries>;
    // Could use Chart property LinkedSeries: TCustomSeriesList;
    Function Db: TAglDb;
    // Function AllSeries: TList<TChartSeries>;
    procedure ChartSeriesOnClick(Sender: TChartSeries; ValueIndex: Integer;
      Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure ChartSeriesOnDbleClick(Sender: TChartSeries; ValueIndex: Integer;
      Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure ChartSeriesListClear;
    Function NewLineSeries(AName: String): TLineSeries;
    Function NewSeries(AName: String; ASeriesClass: TChartSeriesClass)
      : TChartSeries;
    Function NewPiontSeries(AName: String): TPointSeries;
    Function NewBarSeries(AName: String; AStyle: TBarStyle): TBarSeries;
    procedure BuildSeries;
    procedure BuildMonths(AMinYear, AMaxYear: Word);
    Procedure AlignDateTimePickers;
    Procedure AlignChartToDate;
    Procedure AdjustCbxs;
    Procedure LoadCheckBoxes(Var ARec: TSelectionRecord);

  public
    { Public declarations }
  end;

var
  FmYearOnYear: TFmYearOnYear;

implementation
Uses AglForm;
{$R *.dfm}
// function TFmYearOnYear.AllSeries: TList<TChartSeries>;
// begin
// if FAllSeries = nil then
// FAllSeries := TList<TChartSeries>.Create;
// Result := FAllSeries;
// end;

procedure TFmYearOnYear.AdjustCbxs;
begin
  if CbxSelectWeekdays.checked then
    PnlDaysOfWeek.Visible := true
  else
  Begin
    CbxMonday.checked := false;
    CbxTuesday.checked := false;
    CbxWednesday.checked := false;
    CbxThursday.checked := false;
    CbxFriday.checked := false;
    if CbxWeekEndsonly.checked then
    begin
      CbxSaturday.checked := true;
      CbxSunday.checked := true;
    end
    else
    begin
      CbxSaturday.checked := false;
      CbxSunday.checked := false;
    end
  End;
end;

procedure TFmYearOnYear.AlignChartToDate;
Var
  OldMax, OldMin, NewMax, NewMin: double;
begin
  if FDateCentre < 300 then
    Exit;

  OldMax := Chart.BottomAxis.Maximum;
  OldMin := Chart.BottomAxis.Minimum;
  NewMax := FDateCentre + FDateHalfScale;
  NewMin := NewMax - FDateHalfScale * 2;
  // Must be lower than the Axis Maximum value.
  // Use the SetMinMax method to change both Maximum and Minimum.
  Chart.BottomAxis.SetMinMax(NewMin, NewMax);

  // if NewMax < OldMin then
  // Begin
  // Chart.BottomAxis.Minimum := NewMin;
  // Chart.BottomAxis.Maximum := NewMax;
  // End
  // Else
  // Begin
  // Chart.BottomAxis.Maximum := NewMax;
  // Chart.BottomAxis.Minimum := NewMin;
  // End;
end;

procedure TFmYearOnYear.AlignDateTimePickers;
Var
  FirstAccess: boolean;
begin
  FirstAccess := FDateCentre < 1;
  // if Chart.BottomAxis.Maximum < 300 then
  // Begin
  // Chart.BottomAxis.Scroll(1, false);
  // if Chart.BottomAxis.Maximum < 300 then
  // Exit;
  // End;
  FDateCentre := (Chart.BottomAxis.Maximum + Chart.BottomAxis.Minimum) / 2;
  FDateHalfScale := (Chart.BottomAxis.Maximum - Chart.BottomAxis.Minimum) / 2;
  DatePicker.Date := FDateCentre;
  if FirstAccess And (FDateCentre > 300) then
  Begin
    FDateCentreStart := FDateCentre;
    FDateHalfScaleStart := FDateHalfScale;
    PnlDateZoom.Visible := true;
  End;
  // DateTimePicker.DateTime:=FDateCentre;
end;

procedure TFmYearOnYear.btn2020Click(Sender: TObject);
var
  LDb: TAglDb;
  LYear: TAglYearRecord;
  ThisYear: Word;
  YearDataGen, YearDataCon: TChartSeries;
  SelectionRec: TSelectionRecord;
begin
  ChartSeriesListClear;
  // Chart.UndoZoom;
  BuildMonths(0, 0);
  LDb := Db;
  LYear := Db.YearRecord(2020);
  SelectionRec.SetUp(false, false);

  ThisYear := LYear.YearNo;
  SelectionRec.SetOffsetToYear(FReferenceDate, ThisYear, 20 / 24 / 60 / 60,30 / 24 / 60 / 60);
  YearDataGen := NewLineSeries(IntToStr(ThisYear) + 'General Load');
  YearDataCon := NewPiontSeries(IntToStr(ThisYear) + 'Controlled Load');
  LYear.PopulateYearChartSeries(YearDataGen, YearDataCon, SelectionRec);
end;

procedure TFmYearOnYear.Btn2021Click(Sender: TObject);
var
  LDb: TAglDb;
  LYear: TAglYearRecord;
  ThisYear: Word;
  YearDataGen, YearDataCon: TChartSeries;
  SelectionRec: TSelectionRecord;
begin
  ChartSeriesListClear;
  // Chart.UndoZoom;
  BuildMonths(0, 0);
  LDb := Db;
  LYear := Db.YearRecord(2021);
  SelectionRec.SetUp(false, false);

  ThisYear := LYear.YearNo;
//  SelectionRec.SetOffsetToYear(FReferenceDate, ThisYear, 15 / 24 / 60 / 60);
  SelectionRec.SetOffsetToYear(FReferenceDate, ThisYear, 15 / 24 / 60 / 60,20 / 24 / 60 / 60);
  YearDataGen := NewLineSeries(IntToStr(ThisYear) + 'General Load');
  YearDataCon := NewPiontSeries(IntToStr(ThisYear) + 'Controlled Load');
  LYear.PopulateYearChartSeries(YearDataGen, YearDataCon, SelectionRec);
end;

procedure TFmYearOnYear.Btn2022Click(Sender: TObject);
var
  LDb: TAglDb;
  LYear: TAglYearRecord;
  ThisYear: Word;
  YearDataGen, YearDataCon: TChartSeries;
  SelectionRec: TSelectionRecord;
begin
  ChartSeriesListClear;
  // Chart.UndoZoom;
  BuildMonths(0, 0);
  LDb := Db;
  LYear := Db.YearRecord(2022);
  SelectionRec.SetUp(false, false);

  ThisYear := LYear.YearNo;
//  SelectionRec.SetOffsetToYear(FReferenceDate, ThisYear, 10 / 24 / 60 / 60);
  SelectionRec.SetOffsetToYear(FReferenceDate, ThisYear, 10 / 24 / 60 / 60,15 / 24 / 60 / 60);
  YearDataGen := NewLineSeries(IntToStr(ThisYear) + 'General Load');
  YearDataCon := NewPiontSeries(IntToStr(ThisYear) + 'Controlled Load');
  LYear.PopulateYearChartSeries(YearDataGen, YearDataCon, SelectionRec);
end;

procedure TFmYearOnYear.Btn2023Click(Sender: TObject);
var
  LDb: TAglDb;
  LYear: TAglYearRecord;
  ThisYear: Word;
  YearDataGen, YearDataCon: TChartSeries;
  SelectionRec: TSelectionRecord;
begin
  ChartSeriesListClear;
  // Chart.UndoZoom;
  BuildMonths(0, 0);
  LDb := Db;
  LYear := Db.YearRecord(2023);
  SelectionRec.SetUp(false, false);

  ThisYear := LYear.YearNo;
//  SelectionRec.SetOffsetToYear(FReferenceDate, ThisYear, 0 / 24 / 60 / 60);
  SelectionRec.SetOffsetToYear(FReferenceDate, ThisYear, 0 / 24 / 60 / 60,0 / 24 / 60 / 60);
  YearDataGen := NewLineSeries(IntToStr(ThisYear) + 'General Load');
  YearDataCon := NewPiontSeries(IntToStr(ThisYear) + 'Controlled Load');
  LYear.PopulateYearChartSeries(YearDataGen, YearDataCon, SelectionRec);
end;

procedure TFmYearOnYear.Btn3DClick(Sender: TObject);
begin
  Chart.View3D := Not Chart.View3D;
end;

procedure TFmYearOnYear.Btn3DDwnClick(Sender: TObject);
begin
  Chart.View3DOptions.OrthoAngle := Chart.View3DOptions.OrthoAngle - 5;
end;

procedure TFmYearOnYear.Btn3DUpClick(Sender: TObject);
begin
  Chart.View3DOptions.OrthoAngle := Chart.View3DOptions.OrthoAngle + 5;
end;

procedure TFmYearOnYear.BtnMarkClick(Sender: TObject);
Var
  srs: TChartSeries;
  i: Integer;
begin
  // Chart.Legend.Children.Item[0].DisplayName;
  For i := 0 to Chart.SeriesList.Count - 1 do
  Begin
    srs := Chart.SeriesList[i];
    if (srs is TLineSeries) or (srs is TBarSeries) then
      srs.Marks.Visible := not srs.Marks.Visible;
  end;
end;

procedure TFmYearOnYear.BtnScrollLeftClick(Sender: TObject);
begin
  AlignDateTimePickers;
  if FDateHalfScale < 0.1 then
    Exit;
  FDateCentre := FDateCentre + FDateHalfScale;
  AlignChartToDate;
end;

procedure TFmYearOnYear.BtnScrollRightClick(Sender: TObject);
begin
  AlignDateTimePickers;
  if FDateHalfScale < 0.001 then
    Exit;
  FDateCentre := FDateCentre - FDateHalfScale;
  AlignChartToDate;
end;

procedure TFmYearOnYear.BtnSetAsVertStdClick(Sender: TObject);
begin
  if AGLMeterForm=nil then exit;
  AGLMeterForm.SetChartStdVertical(Chart);
end;

procedure TFmYearOnYear.BtnTestClick(Sender: TObject);
Var
  NewSeries: TLineSeries;
begin
  BuildSeries;
end;

procedure TFmYearOnYear.BtnUndoZoomClick(Sender: TObject);
begin
  Chart.UndoZoom;
  FDateCentre := FDateCentreStart;
  FDateHalfScale := FDateHalfScaleStart;
  AlignChartToDate;
  Chart.LeftAxis.Minimum := 0.0;
end;

procedure TFmYearOnYear.BtnZoomInClick(Sender: TObject);
begin
  AlignDateTimePickers;
  FDateHalfScale := FDateHalfScale / 2;
  AlignChartToDate;
end;

procedure TFmYearOnYear.BtnZoomOutClick(Sender: TObject);
begin
  AlignDateTimePickers;
  FDateHalfScale := FDateHalfScale * 2;
  AlignChartToDate;
  // Chart.ZoomPercent(50);
end;

procedure TFmYearOnYear.BuildMonths(AMinYear, AMaxYear: Word);
Var
  Datemonth, DateDays, NewMin, NewMax: TDateTime;
  i, j: Integer;
  LYear, LMonth, LDay: Word;
  Date, Days: TPointSeries;
  Lbl: string;
begin
  if AMinYear > 0 then
  Begin
    NewMin := EncodeDate(AMinYear, 1, 1) - 1;
    NewMax := EncodeDate(AMaxYear, 12, 31) + 1;
    LYear := AMinYear;
    LMonth := 1;
    LDay := 1;
  End
  Else
  Begin
    DecodeDate(Now, FRefenceYear, LMonth, LDay);
    FReferenceDate := EncodeDate(FRefenceYear - 1, LMonth - 1, 1);
    NewMin := FReferenceDate - 1;
    NewMax := EncodeDate(FRefenceYear, LMonth, 1) + 1;
    DecodeDate(FReferenceDate, LYear, LMonth, LDay);
  End;

  Chart.BottomAxis.Automatic := false;
  Chart.BottomAxis.LabelsAngle := 90;
  Chart.BottomAxis.SetMinMax(NewMin, NewMax);

  Date := TPointSeries.Create(Chart);
  Date.Title := 'Month';
  Date.Pointer.Style := TSeriesPointerStyle.psTriangle;
  Date.Marks.Visible := true;
  Date.Marks.Style := smsLabel;
  Date.Marks.Arrow.Visible := true;
  Date.HorizAxis := aBottomAxis;
  // Date.Marks.Arrow.Visible:=true;
  Chart.AddSeries(Date);

  While EncodeDate(LYear, LMonth, 1) < NewMax do
  Begin
    Datemonth := EncodeDate(LYear, LMonth, 1);
    Date.AddXY(Datemonth, 0.001, FormatDateTime('dd/mmm/yyyy',
      Datemonth), clred);
    Inc(LMonth);
    if LMonth > 12 then
    begin
      LMonth := 1;
      Inc(LYear);
    end;
  End;

  Days := TPointSeries.Create(Chart);
  Days.Title := 'Days';
  Days.Pointer.Style := TSeriesPointerStyle.psSmallDot;
  Chart.AddSeries(Days);
  DateDays := NewMin;
  While DateDays < NewMax do
  Begin
    DecodeDate(DateDays, LYear, LMonth, LDay);
    if LDay = 1 then
      Lbl := ''
    else if CkbxDoYearOnYear.checked then
    Begin
      if LDay = 15 then
        Lbl := FormatDateTime('ddd (dd-mmmm)', DateDays)
      Else
        Lbl := FormatDateTime('ddd', DateDays);
    End
    Else
      Lbl := FormatDateTime('ddd d/m/yy', DateDays);

    Days.AddXY(DateDays, 0.005, Lbl);
    DateDays := DateDays + 1;
  End;
  // Chart.Axes.Bottom.CalcXPosValue
  // Application.HandleMessage;
  AlignDateTimePickers;
end;

procedure TFmYearOnYear.BuildSeries;
var
  LDb: TAglDb;
  LYear: TAglYearRecord;
  ThisYear, ThisMonth, ThisDay: Word;
  YearDataGen, YearDataCon: TChartSeries;
  SelectionRec: TSelectionRecord;
  YearOnYear: boolean;
  MaxYear, MinYear: Word;
  UseBarsOnly: boolean;
  BarOffsetPre,BarOffsetPost: TDateTime;
begin
  YearOnYear := CkbxDoYearOnYear.checked;
  UseBarsOnly := CbxWeekEndsonly.checked or CbxSelectWeekdays.checked;

  ChartSeriesListClear;
  // Chart.UndoZoom;
  LDb := Db;
  LYear := Db.CurrentYear;
  if LYear = nil then
    Exit;

  MaxYear := LYear.YearNo;
  SelectionRec.SetUp(false, false);
  LoadCheckBoxes(SelectionRec);
  if YearOnYear then
    BuildMonths(0, 0)
  else
  begin
    if UseBarsOnly then
      YearDataGen := NewBarSeries('General Load', bsRectangle)
    Else
      YearDataGen := NewLineSeries('General Load');
    // YearDataCon := NewLineSeries(IntToStr(ThisYear) + 'Controlled Load');
    // YearDataGen := NewPiontSeries(IntToStr(ThisYear) + 'General Load');
    if UseBarsOnly then
      YearDataCon := NewBarSeries('Controlled Load', bsRectangle)
    Else
      YearDataCon := NewLineSeries('Controlled Load');
  end;
  BarOffsetPre := 0.0;
  while LYear <> nil do
  Begin
    ThisYear := LYear.YearNo;
    MinYear := ThisYear;
    if YearOnYear then
    Begin
      BarOffsetPost:=BarOffsetPre+5 / 24 / 60; //5 Mins
      SelectionRec.SetOffsetToYear(FReferenceDate, ThisYear, BarOffsetPre,BarOffsetPost);
      BarOffsetPre  := BarOffsetPost;
      if UseBarsOnly then
        YearDataGen := NewBarSeries(IntToStr(ThisYear) + 'General Load',
          bsRectangle)
      Else
        YearDataGen := NewLineSeries(IntToStr(ThisYear) + 'General Load');
      // YearDataCon := NewLineSeries(IntToStr(ThisYear) + 'Controlled Load');
      // YearDataGen := NewPiontSeries(IntToStr(ThisYear) + 'General Load');
      // YearDataCon := NewBarSeries(IntToStr(ThisYear) + 'Controlled Load',bsarrow);
      YearDataCon := NewBarSeries(IntToStr(ThisYear) + 'Controlled Load',
        bsCilinder);
      // YearDataCon := NewBarSeries(IntToStr(ThisYear) + 'Controlled Load',bsRectangle);
    End;
    LYear.PopulateYearChartSeries(YearDataGen, YearDataCon, SelectionRec);
    if YearOnYear then
      SelectionRec.ShowLabel := false;
    LYear := Db.YearRecord(LYear.YearNo - 1);
  End;
  if not YearOnYear then
    BuildMonths(MinYear, MaxYear)
end;

procedure TFmYearOnYear.CbxSelectWeekdaysClick(Sender: TObject);
begin
  PnlDaysOfWeek.Visible := CbxSelectWeekdays.checked;
  if Sender = CbxSelectWeekdays then
    if CbxWeekEndsonly.checked then
      if PnlDaysOfWeek.Visible then
        CbxWeekEndsonly.checked := false;
  AdjustCbxs;
end;

procedure TFmYearOnYear.ChartClickLegend(Sender: TCustomChart;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
Var
  s: String;
begin
  s := FloatToStr(X) + '  ' + FloatToStr(Y);
  if Sender = nil then
    Exit;
end;

procedure TFmYearOnYear.ChartGetLegendPos(Sender: TCustomChart; Index: Integer;
  var X, Y, XColor: Integer);
Var
  s: String; // location of index items can be moved??
begin
  s := FloatToStr(X) + '  ' + FloatToStr(Y) + '  index=' + FloatToStr(index);
  if Sender = nil then
    Exit;

end;

procedure TFmYearOnYear.ChartGetLegendRect(Sender: TCustomChart;
  var Rect: TRect);
Var
  s: String;
begin
  // s:=FloatToStr(x)+'  '+FloatToStr(y);
  if Sender = nil then
    Exit;

end;

procedure TFmYearOnYear.ChartGetLegendText(Sender: TCustomAxisPanel;
  LegendStyle: TLegendStyle; Index: Integer; var LegendText: string);
Var
  s: String; // each line of text in legend
begin
  s := FloatToStr(Index) + ' >> ' + LegendText;
  if Sender = nil then
    Exit;

end;

procedure TFmYearOnYear.ChartMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
Var
  Bottom, Left: TChartAxis;
  // xd:double;
  // xi:integer;
begin
  Bottom := Chart.BottomAxis;
  Left := Chart.LeftAxis;
  // Bottom.Scroll(1, false);
  AlignDateTimePickers;
  // xd:=x;
  // xi:=Chart.BottomAxis.CalcXPosValue(now);
  if X > 0 then
    if Y > 0 then
      Exit;
end;

procedure TFmYearOnYear.ChartSeriesListClear;
Var
  srs: TChartSeries;
begin
  while Chart.SeriesList.Count > 0 do
  Begin
    srs := Chart.SeriesList[Chart.SeriesList.Count - 1];
    FreeAndNil(srs);
  end;
  Chart.LeftAxis.Automatic:=true;
end;

procedure TFmYearOnYear.ChartSeriesOnClick(Sender: TChartSeries;
  ValueIndex: Integer; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
Var
  s: string;
  // CList:TChartValueList;
  // CVal:TChartValues;
  B: TChartSeries; // TBarSeries;
begin
  B := Sender; // as TBarSeries;
  // if B.Marks<>nil then
  if FDateHalfScale < 5 then
    B.Marks.Visible := not B.Marks.Visible
  else
    B.Marks.Visible := false;

  s := Sender.Name;
  s := FloatToStr(B.XValues[1]);
  s := FloatToStr(B.YValues[1]);
  s := B.Title + FormatDateTime('  d/mmm/yy hh:nn:ss', B.XValues[ValueIndex]) +
    ' Value:' + FloatToStr(B.YValues[ValueIndex]);
  LblCurrentValue.Caption := s;
  FDateCentre := B.XValues[ValueIndex];
  AlignChartToDate;
  DatePicker.Date := FDateCentre;
end;

procedure TFmYearOnYear.ChartSeriesOnDbleClick(Sender: TChartSeries;
  ValueIndex: Integer; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
Var
  s: string;
  // CList:TChartValueList;
  // CVal:TChartValues;
  B: TChartSeries; // TBarSeries;
begin
  BtnZoomInClick(nil);
  B := Sender; // as TBarSeries;
  s := FloatToStr(B.XValues[1]);
  s := FloatToStr(B.YValues[1]);
  s := FormatDateTime('d/mmm/yy hh:nn:ss', B.XValues[ValueIndex]);
  s := FloatToStr(B.YValues[ValueIndex]);

end;

procedure TFmYearOnYear.ChartUndoZoom(Sender: TObject);
begin
  AlignDateTimePickers;
end;

procedure TFmYearOnYear.ChartZoom(Sender: TObject);
begin
  AlignDateTimePickers;
end;

procedure TFmYearOnYear.CkbxDoYearOnYearClick(Sender: TObject);
Var
  LDateCentre, LDateHalfScale: TDateTime;
begin
  LDateHalfScale := FDateHalfScale;
  LDateCentre := FDateCentre;
  BuildSeries;
  FDateHalfScale := LDateHalfScale;
  FDateCentre := LDateCentre;
  AlignChartToDate;
end;

procedure TFmYearOnYear.ControlledLoadClick(Sender: TChartSeries;
  ValueIndex: Integer; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
Var
  s: string;
  CList: TChartValueList;
  CVal: TChartValues;
  B: TChartSeries; // TBarSeries;
begin
  s := Sender.Name;
  B := Sender; // as TBarSeries;
  B.Marks.Visible := not B.Marks.Visible;
  s := FloatToStr(B.XValues[1]);
  s := FloatToStr(B.YValues[1]);
  s := FormatDateTime('d/mmm/yy hh:nn:ss', B.XValues[ValueIndex]);
  s := FloatToStr(B.YValues[ValueIndex]);
  { CList:=Sender.ValuesList[ValueIndex];
    if CList<>nil then
    Begin
    s:=CList.ToString;  //rubbish
    CVal:=CList.Value;
    s:=CList.ValueToString(1);
    s:=CList.ValueToString(ValueIndex);
    if CVal<>nil then
    s:=CVal[0].ToString;
    s := Sender.ValuesList[ValueIndex].ValueToString(0);

    End; }
  if Sender = GeneralUsage then
    if Sender = nil then
      Exit;
end;

procedure TFmYearOnYear.ControlledLoadMouseLeave(Sender: TObject);
begin
  if Sender = GeneralUsage then
    if Sender = nil then
      Exit;
end;

procedure TFmYearOnYear.DateTimePickerCloseUp(Sender: TObject);
begin
  if Sender = DatePicker then
    FDateCentre := DatePicker.Date;
  AlignChartToDate;
  AlignDateTimePickers;
end;

function TFmYearOnYear.Db: TAglDb;
begin
  Result := AGLObj.AglDB;
end;

procedure TFmYearOnYear.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
end;

procedure TFmYearOnYear.FormCreate(Sender: TObject);
var
  LDb: TAglDb;
  LYear: TAglYearRecord;
  ThisYear, ThisMonth, ThisDay: Word;
  SelectionRec: TSelectionRecord;
  // CursorTool:TCursorTool;
begin
  // AdjustCbxs;
  Chart.View3D := false;
  PnlDaysOfWeek.Visible := false;
  BuildMonths(0, 0);
  LDb := Db;
  LYear := Db.CurrentYear;
  ThisYear := LYear.YearNo;
  SelectionRec.SetUp(false, false);
  SelectionRec.SetOffsetToYear(FReferenceDate, ThisYear,0.0,0.0);
  LYear.PopulateYearChartSeries(GeneralUsage, ControlledLoad, SelectionRec);
end;

procedure TFmYearOnYear.FormResize(Sender: TObject);
begin
  If AGLMeterForm=nil then exit;

  AGLMeterForm.SetChartVerticalToStd(Chart);
end;

procedure TFmYearOnYear.GeneralUsageClick(Sender: TChartSeries;
  ValueIndex: Integer; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if Sender = GeneralUsage then
    if Sender = nil then
      Exit;
end;

procedure TFmYearOnYear.GeneralUsageClickPointer(Sender: TCustomSeries;
  ValueIndex, X, Y: Integer);
begin
  if Sender = GeneralUsage then
    if Sender = nil then
      Exit;
end;

procedure TFmYearOnYear.GeneralUsageMouseEnter(Sender: TObject);
begin
  if Sender = GeneralUsage then
    if Sender = nil then
      Exit;
end;

procedure TFmYearOnYear.LoadCheckBoxes(var ARec: TSelectionRecord);
begin
  if CbxSelectWeekdays.checked or CbxWeekEndsonly.checked then
  Begin
    ARec.SelectDays := true;
    if CbxSunday.checked then
      ARec.DaysOfWeek[1] := true;
    if CbxMonday.checked then
      ARec.DaysOfWeek[2] := true;
    if CbxTuesday.checked then
      ARec.DaysOfWeek[3] := true;
    if CbxWednesday.checked then
      ARec.DaysOfWeek[4] := true;
    if CbxThursday.checked then
      ARec.DaysOfWeek[5] := true;
    if CbxFriday.checked then
      ARec.DaysOfWeek[6] := true;
    if CbxSaturday.checked then
      ARec.DaysOfWeek[7] := true;
  End
  Else
    ARec.SelectDays := false;
end;

function TFmYearOnYear.NewBarSeries(AName: String; AStyle: TBarStyle)
  : TBarSeries;
begin
  Result := NewSeries(AName, TBarSeries) as TBarSeries;
  Result.BarWidthPercent := 1;
  Result.Marks.Angle := 90;
  Result.Marks.ArrowLength := 5;
  Result.Marks.Arrow.Color := clLtGray;
  Result.BarStyle := AStyle; // bsarrow;
end;

function TFmYearOnYear.NewLineSeries(AName: String): TLineSeries;
begin
  Result := NewSeries(AName, TTestLineSeries) as TTestLineSeries;
end;

function TFmYearOnYear.NewPiontSeries(AName: String): TPointSeries;
begin
  Result := NewSeries(AName, TPointSeries) as TPointSeries;
end;

function TFmYearOnYear.NewSeries(AName: String; ASeriesClass: TChartSeriesClass)
  : TChartSeries;
begin
  Result := ASeriesClass.Create(Chart);
  Result.Title := AName;
  Result.Marks.Visible := false;
  Result.OnClick := ChartSeriesOnClick;
  Result.OnDblClick := ChartSeriesOnDbleClick;
  Chart.AddSeries(Result);
end;

end.
