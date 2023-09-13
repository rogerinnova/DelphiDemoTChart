unit GraphFmDay;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  // System.Math,
  System.Classes, Vcl.Graphics, System.generics.collections,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, VclTee.TeeGDIPlus, VclTee.TeEngine,
  VclTee.Series, Vcl.ExtCtrls, VclTee.TeeProcs, VclTee.Chart, Vcl.StdCtrls,
  AGLAnalyserObjs, Vcl.WinXPickers, Vcl.ComCtrls;

type
  TFmDay = class(TForm)
    TopPanel: TPanel;
    BtnTest: TButton;
    Btn3D: TButton;
    BtnUndoZoom: TButton;
    PnlBottom: TPanel;
    Chart: TChart;
    GeneralUsage: TLineSeries;
    ControlledLoad: TBarSeries;
    PnlDateZoom: TPanel;
    BtnZoomOut: TButton;
    BtnZoomIn: TButton;
    DatePicker: TDatePicker;
    CbxDoYearOnYear: TCheckBox;
    BtnScrollRight: TButton;
    BtnScrollLeft: TButton;
    LblCurrentValue: TLabel;
    BtnMark: TButton;
    CbxSelectControledLoad: TCheckBox;
    CbxSelectGeneralLoad: TCheckBox;
    Btn3DUp: TButton;
    Btn3DDwn: TButton;
    CbxForceLine: TCheckBox;
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
    procedure Btn3DDwnClick(Sender: TObject);
    procedure Btn3DUpClick(Sender: TObject);
    procedure CbxDoYearOnYearClick(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure BtnSetAsVertStdClick(Sender: TObject);
  private
    { Private declarations }
    FReferenceDate: TDateTime; // Start of chart
    FNextColorIndex: Integer;
    FDateCentre, FDateHalfScale: TDateTime;
    FDateCentreStart, FDateHalfScaleStart: TDateTime;
    // FAllSeries: TList<TChartSeries>;
    // Could use Chart property LinkedSeries: TCustomSeriesList;
    Function NextColor: TColor;
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
    procedure BuildSeriesForDay;
    Procedure NewBuildOnCenter;
    procedure BuildDayHourLabels(AYear, AMonth, ADay: Word);
    procedure FillPreNowPostSeries(APre, ARec, APost: TAglDailyRecord;
      ASelectionRec: TSelectionRecord; AExtLabel: String);
    Procedure AlignDateTimePickers;
    Procedure AlignChartToDate;
    Procedure LoadCheckBoxeDay(Var ARec: TSelectionRecord);

  public
    { Public declarations }
  end;

var
  FmDay: TFmDay;

implementation
Uses AglForm;

{$R *.dfm}
// function TFmYearOnYear.AllSeries: TList<TChartSeries>;
// begin
// if FAllSeries = nil then
// FAllSeries := TList<TChartSeries>.Create;
// Result := FAllSeries;
// end;

procedure TFmDay.AlignChartToDate;
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

procedure TFmDay.AlignDateTimePickers;
Var
  FirstAccess: boolean;
  NewMin, NewMax: TDateTime;
begin
  FDateCentre := (Chart.BottomAxis.Maximum + Chart.BottomAxis.Minimum) / 2;

  NewMax := FDateCentre + FDateHalfScale;
  NewMin := NewMax - FDateHalfScale * 2;
  // Must be lower than the Axis Maximum value.
  // Use the SetMinMax method to change both Maximum and Minimum.
  Chart.BottomAxis.SetMinMax(NewMin, NewMax);

  DatePicker.Date := FDateCentre;
end;

procedure TFmDay.Btn3DClick(Sender: TObject);
begin
  Chart.View3D := Not Chart.View3D;
end;

procedure TFmDay.Btn3DDwnClick(Sender: TObject);
begin
  Chart.View3DOptions.OrthoAngle := Chart.View3DOptions.OrthoAngle - 5;
end;

procedure TFmDay.Btn3DUpClick(Sender: TObject);
begin
  Chart.View3DOptions.OrthoAngle := Chart.View3DOptions.OrthoAngle + 5;
end;

procedure TFmDay.BtnMarkClick(Sender: TObject);
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

procedure TFmDay.BtnScrollLeftClick(Sender: TObject);
begin
  AlignDateTimePickers;
  if FDateHalfScale < 0.000001 then
    Exit;
  FDateCentre := FDateCentre + FDateHalfScale;
  if FDateCentre>FDateCentreStart+0.8 then
      NewBuildOnCenter
    else
      AlignChartToDate;
end;

procedure TFmDay.BtnScrollRightClick(Sender: TObject);
begin
  AlignDateTimePickers;
  if FDateHalfScale < 0.000001 then
    Exit;
  FDateCentre := FDateCentre - FDateHalfScale;
  if FDateCentre<FDateCentreStart-0.8 then
      NewBuildOnCenter
    else
  AlignChartToDate;
end;

procedure TFmDay.BtnSetAsVertStdClick(Sender: TObject);
begin
  if AGLMeterForm=nil then exit;
  AGLMeterForm.SetChartStdVertical(Chart);
end;

procedure TFmDay.BtnTestClick(Sender: TObject);
Var
  NewSeries: TLineSeries;
begin
  BuildSeriesForDay;
end;

procedure TFmDay.BtnUndoZoomClick(Sender: TObject);
begin
  Chart.UndoZoom;
  FDateCentre := FDateCentreStart;
  FDateHalfScale := FDateHalfScaleStart;
  AlignChartToDate;
  Chart.LeftAxis.Minimum := 0.0;
end;

procedure TFmDay.BtnZoomInClick(Sender: TObject);
begin
  AlignDateTimePickers;
  FDateHalfScale := FDateHalfScale / 2;
  AlignChartToDate;
end;

procedure TFmDay.BtnZoomOutClick(Sender: TObject);
begin
  AlignDateTimePickers;
  FDateHalfScale := FDateHalfScale * 2;
  AlignChartToDate;
  // Chart.ZoomPercent(50);
end;

procedure TFmDay.BuildDayHourLabels(AYear, AMonth, ADay: Word);
// A series of labels over three months
Var
  HourMarksr, LabelMin, LabelMax, ChartMin, ChartMax: TDateTime;
  LYear, LMonth, LDay, LHour, LMIn, LSec, LMsec: Word;
  Date, Hours: TPointSeries;
begin
  Try
    ChartMin := EncodeDate(AYear, AMonth, ADay);
  Except
    Exit; // Bad Data
  End;
  ChartMax := ChartMin + 1;

  FDateHalfScale := (ChartMax - ChartMin) / 2;
  FDateCentre := (ChartMax + ChartMin) / 2;

  LabelMin := ChartMin - 2;
  LabelMax := LabelMin + 5;
  Chart.BottomAxis.Automatic := false;
  Chart.BottomAxis.LabelsAngle := 90;
  Chart.BottomAxis.SetMinMax(LabelMin, LabelMax);

  Date := TPointSeries.Create(Chart);
  Date.Title := 'Month';
  Date.Pointer.Style := TSeriesPointerStyle.psTriangle;
  Date.Marks.Visible := true;
  Date.Marks.Style := smsLabel;
  Date.Marks.Arrow.Visible := true;
  Date.HorizAxis := aBottomAxis;
  Chart.AddSeries(Date);

  Hours := TPointSeries.Create(Chart);
  Hours.Title := 'Hours';
  Hours.Pointer.Style := TSeriesPointerStyle.psSmallDot;
  Chart.AddSeries(Hours);

  HourMarksr := LabelMin; // O.5 to offset to midday
  while HourMarksr < LabelMax do
  Begin
    HourMarksr := HourMarksr + 1 / 24;
    DecodeDate(HourMarksr, LYear, LMonth, LDay);
    DecodeTime(HourMarksr, LHour, LMIn, LSec, LMsec);
    if (LHour = 0) { and (LMin=0) } then
      Date.AddXY(HourMarksr, 0.001, FormatDateTime('dd mmmm ddd',
        HourMarksr), clred)
    Else if LHour = 12 then
      Hours.AddXY(HourMarksr, 0.001, FormatDateTime('dd mmmm ddd  hh:mm',
        HourMarksr), clred)
    Else
      Hours.AddXY(HourMarksr, 0.001, FormatDateTime('hh:mm',
        HourMarksr), clBlack);
  End;
  FDateCentreStart := FDateCentre;
  FDateHalfScaleStart := FDateHalfScale;
  PnlDateZoom.Visible := true;
  Chart.BottomAxis.SetMinMax(ChartMin, ChartMax);
  AlignDateTimePickers;
  Caption:= 'Day Graph '+FormatDateTime('dd mmmm ddd  hh:mm',(ChartMin + ChartMax)/2);
  LblCurrentValue.Caption:=Caption;
end;

procedure TFmDay.BuildSeriesForDay;
var
  LDb: TAglDb;
  DayPre, DayPost, DayRec: TAglDailyRecord;
  LFirstDay: TDateTime;
  ThisYear, ThisMonth, ThisDay: Word;
  SelectionRec: TSelectionRecord;
  YearOnYear: boolean;
  LYear, LMonth, LDay: Word;
  LblYr: String;
  BarOffsetPre, BarOffsetPost: double;
begin
  YearOnYear := CbxDoYearOnYear.checked;
  DecodeDate(DatePicker.Date, ThisYear, ThisMonth, ThisDay);
  ChartSeriesListClear;
  // Chart.UndoZoom;
  LDb := Db;
  DayRec := Db.DayRecord(ThisYear, ThisMonth, ThisDay, false);
  if DayRec = nil then
    Exit;

  DayPre := DayRec.PrevDay;
  DayPost := DayRec.NextDay;
  FReferenceDate := DayPre.StartDate;
  SelectionRec.SetUp(false, false);
  LoadCheckBoxeDay(SelectionRec);
  BuildDayHourLabels(ThisYear, ThisMonth, ThisDay);
  BarOffsetPost := -6.0 / 24 / 60; // For YearOnYear
  LblYr := '';
  if not YearOnYear then
    FillPreNowPostSeries(DayPre, DayRec, DayPost, SelectionRec, LblYr)
  Else
    while (DayPre <> nil) { and (MonthRec <> nil) and (MonthPost <> nil) } do
    begin
      BarOffsetPre := BarOffsetPost + 6 / 24 / 60;
      if DayRec <> nil then
        LblYr := ' (' + IntToStr(DayRec.YearNo) + ')'
      else
        LblYr := ' (' + IntToStr(DayPre.YearNo) + ')';

      LFirstDay := SelectionRec.SetOffsetToDay(FReferenceDate, DayRec.YearNo,
        BarOffsetPre, BarOffsetPost);
      DecodeDate(LFirstDay,LYear, LMonth, LDay);
      DayPre:=db.DayRecord(LYear, LMonth, LDay,False);
      if DayPre<>nil then
          DayRec:=DayPre.NextDay;
      if DayRec<>nil then
         DayPost :=DayRec.NextDay;
      FillPreNowPostSeries(DayPre, DayRec, DayPost, SelectionRec, LblYr);

      ThisYear:=ThisYear-1;
      DayRec := Db.DayRecord(ThisYear, ThisMonth, ThisDay, false);
      if DayRec <> nil then
          Begin
           DayPre := DayRec.PrevDay;
           DayPost := DayRec.NextDay;
          End
          Else
           DayPre := nil;
      BarOffsetPost := BarOffsetPre;
  end;
end;
procedure TFmDay.ChartClickLegend(Sender: TCustomChart; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
Var
  s: String;
begin
  s := FloatToStr(X) + '  ' + FloatToStr(Y);
  if Sender = nil then
    Exit;
end;

procedure TFmDay.ChartGetLegendPos(Sender: TCustomChart; Index: Integer;
  var X, Y, XColor: Integer);
Var
  s: String; // location of index items can be moved??
begin
  s := FloatToStr(X) + '  ' + FloatToStr(Y) + '  index=' + FloatToStr(index);
  if Sender = nil then
    Exit;

end;

procedure TFmDay.ChartGetLegendRect(Sender: TCustomChart; var Rect: TRect);
Var
  s: String;
begin
  // s:=FloatToStr(x)+'  '+FloatToStr(y);
  if Sender = nil then
    Exit;

end;

procedure TFmDay.ChartGetLegendText(Sender: TCustomAxisPanel;
  LegendStyle: TLegendStyle; Index: Integer; var LegendText: string);
Var
  s: String; // each line of text in legend
begin
  s := FloatToStr(Index) + ' >> ' + LegendText;
  if Sender = nil then
    Exit;

end;

procedure TFmDay.ChartMouseDown(Sender: TObject; Button: TMouseButton;
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

procedure TFmDay.ChartSeriesListClear;
Var
  srs: TChartSeries;
begin
  FNextColorIndex := 0;
  while Chart.SeriesList.Count > 0 do
  Begin
    srs := Chart.SeriesList[Chart.SeriesList.Count - 1];
    FreeAndNil(srs);
  end;
  Chart.LeftAxis.Automatic:=true;
end;

procedure TFmDay.ChartSeriesOnClick(Sender: TChartSeries; ValueIndex: Integer;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
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
  s := B.Title + FormatDateTime(' h:nn ddd (d) mmmm', B.XValues[ValueIndex]) +
    ' Value:' + FormatFloat('0.000',B.YValues[ValueIndex]);
  LblCurrentValue.Caption := s;
  FDateCentre := B.XValues[ValueIndex];
  AlignChartToDate;
  DatePicker.Date := FDateCentre;
end;

procedure TFmDay.ChartSeriesOnDbleClick(Sender: TChartSeries;
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

procedure TFmDay.ChartUndoZoom(Sender: TObject);
begin
  AlignDateTimePickers;
end;

procedure TFmDay.ChartZoom(Sender: TObject);
begin
  AlignDateTimePickers;
end;

procedure TFmDay.CbxDoYearOnYearClick(Sender: TObject);
Var
  LDateCentre, LDateHalfScale: TDateTime;
begin
  LDateHalfScale := FDateHalfScale;
  LDateCentre := FDateCentre;
  BuildSeriesForDay;
  FDateHalfScale := LDateHalfScale;
  FDateCentre := LDateCentre;
  AlignChartToDate;
end;

procedure TFmDay.ControlledLoadClick(Sender: TChartSeries; ValueIndex: Integer;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
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

procedure TFmDay.ControlledLoadMouseLeave(Sender: TObject);
begin
  if Sender = GeneralUsage then
    if Sender = nil then
      Exit;
end;

procedure TFmDay.DateTimePickerCloseUp(Sender: TObject);
begin
  if Sender = DatePicker then
    FDateCentre := DatePicker.Date;
  AlignChartToDate;
  AlignDateTimePickers;
  CbxDoYearOnYearClick(nil);
end;

function TFmDay.Db: TAglDb;
begin
  Result := AGLObj.AglDB;
end;

procedure TFmDay.FillPreNowPostSeries(APre, ARec, APost: TAglDailyRecord;
  ASelectionRec: TSelectionRecord; AExtLabel: String);
Var
  DailyDataSeries,ControlledDataSeries: TChartSeries;
  TotalLoad: boolean;
    Function NewSeries(AName: String; AStyle: TBarStyle): TChartSeries;
     Begin
       if CbxForceLine.Checked then
         Result:=NewLineSeries(AName)
        Else
         Result:=NewBarSeries(AName,AStyle)
     End;
begin
  TotalLoad := false;
  ControlledDataSeries:=nil;
  DailyDataSeries:=nil;
  if not CbxSelectControledLoad.checked then
    DailyDataSeries := NewSeries('General Load' + AExtLabel, bsRectangle)
  else if CbxSelectGeneralLoad.checked then
  Begin
    DailyDataSeries := NewSeries('Total Load' + AExtLabel, bsRectangle);
    TotalLoad := true;
  End
  Else
    ControlledDataSeries := NewSeries('Controled Load' + AExtLabel, bsRectangle);
  if APre <> nil then
    APre.PopulateDayChartSeries(DailyDataSeries,ControlledDataSeries, ASelectionRec,TotalLoad);
  if ARec <> nil then
    ARec.PopulateDayChartSeries(DailyDataSeries,ControlledDataSeries, ASelectionRec,TotalLoad);
  if APost <> nil then
    APost.PopulateDayChartSeries(DailyDataSeries,ControlledDataSeries, ASelectionRec,TotalLoad);
end;

procedure TFmDay.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
end;

procedure TFmDay.FormCreate(Sender: TObject);
var
  LDb: TAglDb;
  LYear: TAglYearRecord;
  ThisYear, ThisMonth, ThisDay: Word;
begin
  Chart.View3D := false;
  LDb := Db;
  LYear := Db.CurrentYear;
  ThisYear := LYear.YearNo;
end;

procedure TFmDay.FormResize(Sender: TObject);
begin
  If AGLMeterForm=nil then exit;

  AGLMeterForm.SetChartVerticalToStd(Chart);
end;

procedure TFmDay.GeneralUsageClick(Sender: TChartSeries; ValueIndex: Integer;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if Sender = GeneralUsage then
    if Sender = nil then
      Exit;
end;

procedure TFmDay.GeneralUsageClickPointer(Sender: TCustomSeries;
  ValueIndex, X, Y: Integer);
begin
  if Sender = GeneralUsage then
    if Sender = nil then
      Exit;
end;

procedure TFmDay.GeneralUsageMouseEnter(Sender: TObject);
begin
  if Sender = GeneralUsage then
    if Sender = nil then
      Exit;
end;

procedure TFmDay.LoadCheckBoxeDay(var ARec: TSelectionRecord);
begin
  ARec.SelectDays := false;
end;

function TFmDay.NewBarSeries(AName: String; AStyle: TBarStyle): TBarSeries;
begin
  Result := NewSeries(AName, TBarSeries) as TBarSeries;
  Result.BarWidthPercent := 30;
  // Result.BarWidthPercent := 1;
  Result.Marks.Angle := 90;
  Result.Marks.ArrowLength := 15;
  Result.Marks.Arrow.Color := clLtGray;
  Result.BarStyle := AStyle; // bsarrow;
end;

procedure TFmDay.NewBuildOnCenter;
begin
  DatePicker.Date:=FDateCentre;
  BuildSeriesForDay;
end;

function TFmDay.NewLineSeries(AName: String): TLineSeries;
begin
  Result := NewSeries(AName, TTestLineSeries) as TTestLineSeries;
end;

function TFmDay.NewPiontSeries(AName: String): TPointSeries;
begin
  Result := NewSeries(AName, TPointSeries) as TPointSeries;
end;

function TFmDay.NewSeries(AName: String; ASeriesClass: TChartSeriesClass)
  : TChartSeries;
begin
  Result := ASeriesClass.Create(Chart);
  Result.Title := AName;
  Result.Marks.Visible := false;
  Result.OnClick := ChartSeriesOnClick;
  Result.OnDblClick := ChartSeriesOnDbleClick;
  Result.Color := NextColor;

  Chart.AddSeries(Result);
end;

function TFmDay.NextColor: TColor;
begin
  begin
    Result := IndexColors[FNextColorIndex];
    Inc(FNextColorIndex);
    if FNextColorIndex > high(IndexColors) then
      FNextColorIndex := 0;
  end;
end;

end.
