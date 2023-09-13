unit GraphFmMonth;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  // System.Math,
  System.Classes, Vcl.Graphics, System.generics.collections,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, VclTee.TeeGDIPlus, VclTee.TeEngine,
  VclTee.Series, Vcl.ExtCtrls, VclTee.TeeProcs, VclTee.Chart, Vcl.StdCtrls,
  AGLAnalyserObjs, Vcl.WinXPickers, Vcl.ComCtrls;

type
  TFmMonth = class(TForm)
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
    procedure BtnSetAsVertStdClick(Sender: TObject);
    procedure FormResize(Sender: TObject);
  private
    { Private declarations }
    FReferenceDate: TDateTime; // Start of chart
    FNextColorIndex:integer;
    FDateCentre, FDateHalfScale: TDateTime;
    FDateCentreStart, FDateHalfScaleStart: TDateTime;
    // FAllSeries: TList<TChartSeries>;
    // Could use Chart property LinkedSeries: TCustomSeriesList;
    Function NextColor:TColor;
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
    procedure BuildSeriesMonth;
    procedure BuildMonthDayLabels(AYear, AMonth: Word);
    procedure FillPreNowPostSeries(APre, ARec, APost: TAglMonthRecord;
      ASelectionRec: TSelectionRecord; AExtLabel: String);
    Procedure AlignDateTimePickers;
    Procedure AlignChartToDate;
    Procedure LoadCheckBoxesMonth(Var ARec: TSelectionRecord);

  public
    { Public declarations }
  end;

var
  FmMonth: TFmMonth;

implementation
Uses AglForm;

{$R *.dfm}
// function TFmYearOnYear.AllSeries: TList<TChartSeries>;
// begin
// if FAllSeries = nil then
// FAllSeries := TList<TChartSeries>.Create;
// Result := FAllSeries;
// end;

procedure TFmMonth.AlignChartToDate;
Var
  OldMax, OldMin, NewMax, NewMin: double;
begin
  if FDateCentre < 300 then
    Exit;

  OldMax := Chart.BottomAxis.Maximum;
  OldMin := Chart.BottomAxis.Minimum;
  NewMax := FDateCentre + FDateHalfScale;
  NewMin := NewMax - FDateHalfScale * 2 - 1;
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

procedure TFmMonth.AlignDateTimePickers;
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

procedure TFmMonth.Btn3DClick(Sender: TObject);
begin
  Chart.View3D := Not Chart.View3D;
end;

procedure TFmMonth.Btn3DDwnClick(Sender: TObject);
begin
  Chart.View3DOptions.OrthoAngle := Chart.View3DOptions.OrthoAngle - 5;
end;

procedure TFmMonth.Btn3DUpClick(Sender: TObject);
begin
  Chart.View3DOptions.OrthoAngle := Chart.View3DOptions.OrthoAngle + 5;
end;

procedure TFmMonth.BtnMarkClick(Sender: TObject);
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

procedure TFmMonth.BtnScrollLeftClick(Sender: TObject);
begin
  AlignDateTimePickers;
  if FDateHalfScale < 0.001 then
    Exit;
  FDateCentre := FDateCentre + FDateHalfScale;
  AlignChartToDate;
end;

procedure TFmMonth.BtnScrollRightClick(Sender: TObject);
begin
  AlignDateTimePickers;
  if FDateHalfScale < 0.001 then
    Exit;
  FDateCentre := FDateCentre - FDateHalfScale;
  AlignChartToDate;
end;

procedure TFmMonth.BtnSetAsVertStdClick(Sender: TObject);
begin
  if AGLMeterForm=nil then exit;
  AGLMeterForm.SetChartStdVertical(Chart);
end;

procedure TFmMonth.BtnTestClick(Sender: TObject);
Var
  NewSeries: TLineSeries;
begin
  BuildSeriesMonth;
end;

procedure TFmMonth.BtnUndoZoomClick(Sender: TObject);
begin
  Chart.UndoZoom;
  FDateCentre := FDateCentreStart;
  FDateHalfScale := FDateHalfScaleStart;
  AlignChartToDate;
  Chart.LeftAxis.Minimum := 0.0;
end;

procedure TFmMonth.BtnZoomInClick(Sender: TObject);
begin
  AlignDateTimePickers;
  FDateHalfScale := FDateHalfScale / 2;
  AlignChartToDate;
end;

procedure TFmMonth.BtnZoomOutClick(Sender: TObject);
begin
  AlignDateTimePickers;
  FDateHalfScale := FDateHalfScale * 2;
  AlignChartToDate;
  // Chart.ZoomPercent(50);
end;

procedure TFmMonth.BuildMonthDayLabels(AYear, AMonth: Word);
// A series of labels over three months
Var
  DateDays, LabelMin, LabelMax, ChartMin, ChartMax: TDateTime;
  LYear, LMonth, LDay: Word;
  Date, Days: TPointSeries;
begin
  if AMonth < 2 then
  Begin
    LYear := AYear - 1;
    LMonth := 12;
  End
  Else
  Begin
    LYear := AYear;
    LMonth := AMonth - 1;
  End;

  if LYear < 2000 then
    LYear := 2000;

  ChartMin := EncodeDate(AYear, AMonth, 1) - 2;
  ChartMax := ChartMin + 34;

  FDateHalfScale := (ChartMax - ChartMin) / 2;
  FDateCentre := (ChartMax + ChartMin) / 2;

  LabelMin := EncodeDate(LYear, LMonth, 1) - 1;
  LabelMax := LabelMin + 95;
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
  // Date.Marks.Arrow.Visible:=true;
  Chart.AddSeries(Date);
  Days := TPointSeries.Create(Chart);
  Days.Title := 'Days';
  Days.Pointer.Style := TSeriesPointerStyle.psSmallDot;
  Chart.AddSeries(Days);

  DateDays := LabelMin+0.5; //O.5 to offset to midday
  while DateDays < LabelMax do
  Begin
    DateDays := DateDays + 1;
    DecodeDate(DateDays, LYear, LMonth, LDay);
    if LDay = 1 then
      Date.AddXY(DateDays, 0.001, FormatDateTime('dd mmmm ddd',
        DateDays), clred)
    Else if LDay = 15 then
      Date.AddXY(DateDays, 0.001, FormatDateTime('dd mmmm ddd',
        DateDays), clred)
    Else
      Days.AddXY(DateDays, 0.001, FormatDateTime('ddd (dd)', DateDays),
        clBlack);
  End;
  FDateCentreStart := FDateCentre;
  FDateHalfScaleStart := FDateHalfScale;
  PnlDateZoom.Visible := true;
  Chart.BottomAxis.SetMinMax(ChartMin, ChartMax);
  Caption:= 'Month Graph '+FormatDateTime('mmmm  yyyy',(ChartMin + ChartMax)/2);
  LblCurrentValue.Caption:=Caption;
  AlignDateTimePickers;
end;

procedure TFmMonth.BuildSeriesMonth;
var
  LDb: TAglDb;
  MonthPre, MonthPost, MonthRec: TAglMonthRecord;
  ThisYear, ThisMonth, ThisDay: Word;
  SelectionRec: TSelectionRecord;
  YearOnYear: boolean;
  LYear, LMonth: Word;
  LblYr: String;
  BarOffsetPre, BarOffsetPost: double;
begin
  YearOnYear := CbxDoYearOnYear.checked;
  DecodeDate(DatePicker.Date, LYear, LMonth, ThisDay);
  ChartSeriesListClear;
  // Chart.UndoZoom;
  LDb := Db;
  MonthRec := Db.MonthRecord(LYear, LMonth, false);
  if MonthRec = nil then
    Exit;

  if LMonth = 1 then
    MonthPre := Db.MonthRecord(LYear - 1, 12, false)
  Else
    MonthPre := Db.MonthRecord(LYear, LMonth - 1, false);

  FReferenceDate := MonthPre.StartDate - 30;

  if LMonth = 12 then
    MonthPost := Db.MonthRecord(LYear + 1, 1, false)
  Else
    MonthPost := Db.MonthRecord(LYear, LMonth + 1, false);
  SelectionRec.SetUp(false, false);
  LoadCheckBoxesMonth(SelectionRec);
  BuildMonthDayLabels(LYear, LMonth);
  BarOffsetPost := -2.0 / 24; // For YearOnYear
  LblYr := '';
  if not YearOnYear then
    FillPreNowPostSeries(MonthPre, MonthRec, MonthPost, SelectionRec, LblYr)
  Else
    while (MonthPre <> nil) { and (MonthRec <> nil) and (MonthPost <> nil) } do
    begin
      BarOffsetPre := BarOffsetPost + 2 / 24;
      if MonthRec<>nil then
          LblYr := ' (' + IntToStr(MonthRec.YearNo) + ')'
        else
          LblYr := ' (' + IntToStr(MonthPre.YearNo) + ')';
      SelectionRec.SetOffsetToYear(FReferenceDate, MonthRec.YearNo,
        BarOffsetPre, BarOffsetPost);
      FillPreNowPostSeries(MonthPre, MonthRec, MonthPost, SelectionRec, LblYr);
      BarOffsetPost := BarOffsetPre;
      MonthPre := Db.MonthRecord(MonthPre.YearNo - 1, MonthPre.MonthNo, false);
      MonthRec := Db.MonthRecord(MonthRec.YearNo - 1, MonthRec.MonthNo, false);
      if MonthRec = nil then
        MonthPre := nil
      Else if MonthPost = nil then
      Begin
        if LMonth = 12 then
          MonthPost := Db.MonthRecord(MonthRec.YearNo + 1, 1, false)
        Else
          MonthPost := Db.MonthRecord(MonthRec.YearNo,
            MonthRec.MonthNo + 1, false);
      End
      else
        MonthPost := Db.MonthRecord(MonthPost.YearNo - 1,
          MonthPost.MonthNo, false);
    End;
end;

procedure TFmMonth.ChartClickLegend(Sender: TCustomChart; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
Var
  s: String;
begin
  s := FloatToStr(X) + '  ' + FloatToStr(Y);
  if Sender = nil then
    Exit;
end;

procedure TFmMonth.ChartGetLegendPos(Sender: TCustomChart; Index: Integer;
  var X, Y, XColor: Integer);
Var
  s: String; // location of index items can be moved??
begin
  s := FloatToStr(X) + '  ' + FloatToStr(Y) + '  index=' + FloatToStr(index);
  if Sender = nil then
    Exit;

end;

procedure TFmMonth.ChartGetLegendRect(Sender: TCustomChart; var Rect: TRect);
Var
  s: String;
begin
  // s:=FloatToStr(x)+'  '+FloatToStr(y);
  if Sender = nil then
    Exit;

end;

procedure TFmMonth.ChartGetLegendText(Sender: TCustomAxisPanel;
  LegendStyle: TLegendStyle; Index: Integer; var LegendText: string);
Var
  s: String; // each line of text in legend
begin
  s := FloatToStr(Index) + ' >> ' + LegendText;
  if Sender = nil then
    Exit;

end;

procedure TFmMonth.ChartMouseDown(Sender: TObject; Button: TMouseButton;
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

procedure TFmMonth.ChartSeriesListClear;
Var
  srs: TChartSeries;
begin
    FNextColorIndex:=0;
  while Chart.SeriesList.Count > 0 do
  Begin
    srs := Chart.SeriesList[Chart.SeriesList.Count - 1];
    FreeAndNil(srs);
  end;
  Chart.LeftAxis.Automatic:=true;
end;

procedure TFmMonth.ChartSeriesOnClick(Sender: TChartSeries; ValueIndex: Integer;
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
  s := B.Title + FormatDateTime('  ddd (d) mmmm', B.XValues[ValueIndex]) +
    ' Value:' + FloatToStr(B.YValues[ValueIndex]);
  LblCurrentValue.Caption := s;
  FDateCentre := B.XValues[ValueIndex];
  AlignChartToDate;
  DatePicker.Date := FDateCentre;
end;

procedure TFmMonth.ChartSeriesOnDbleClick(Sender: TChartSeries;
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

procedure TFmMonth.ChartUndoZoom(Sender: TObject);
begin
  AlignDateTimePickers;
end;

procedure TFmMonth.ChartZoom(Sender: TObject);
begin
  AlignDateTimePickers;
end;

procedure TFmMonth.CbxDoYearOnYearClick(Sender: TObject);
Var
  LDateCentre, LDateHalfScale: TDateTime;
begin
  LDateHalfScale := FDateHalfScale;
  LDateCentre := FDateCentre;
  BuildSeriesMonth;
  FDateHalfScale := LDateHalfScale;
  FDateCentre := LDateCentre;
  AlignChartToDate;
end;

procedure TFmMonth.ControlledLoadClick(Sender: TChartSeries;
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

procedure TFmMonth.ControlledLoadMouseLeave(Sender: TObject);
begin
  if Sender = GeneralUsage then
    if Sender = nil then
      Exit;
end;

procedure TFmMonth.DateTimePickerCloseUp(Sender: TObject);
begin
  if Sender = DatePicker then
    FDateCentre := DatePicker.Date;
  AlignChartToDate;
  AlignDateTimePickers;
  CbxDoYearOnYearClick(nil);
 end;

function TFmMonth.Db: TAglDb;
begin
  Result := AGLObj.AglDB;
end;

procedure TFmMonth.FillPreNowPostSeries(APre, ARec, APost: TAglMonthRecord;
  ASelectionRec: TSelectionRecord; AExtLabel: String);
Var
  MonthDataSeries: TChartSeries;
  TotalLoad, UseBarsOnly: boolean;

begin
  UseBarsOnly := true;
  TotalLoad := false;

  if not CbxSelectControledLoad.checked then
    MonthDataSeries := NewBarSeries('General Load' + AExtLabel, bsRectangle)
  else if CbxSelectGeneralLoad.checked then
  Begin
    MonthDataSeries := NewBarSeries('Total Load' + AExtLabel, bsRectangle);
    TotalLoad := true;
  End
  Else
    MonthDataSeries := NewBarSeries('Controled Load' + AExtLabel, bsRectangle);
  if APre <> nil then
    APre.PopulateDailyTotalValueChartSeries(MonthDataSeries, TotalLoad,
      CbxSelectControledLoad.checked, ASelectionRec);
  if ARec <> nil then
    ARec.PopulateDailyTotalValueChartSeries(MonthDataSeries, TotalLoad,
      CbxSelectControledLoad.checked, ASelectionRec);
  if APost <> nil then
    APost.PopulateDailyTotalValueChartSeries(MonthDataSeries, TotalLoad,
      CbxSelectControledLoad.checked, ASelectionRec);
end;

procedure TFmMonth.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
end;

procedure TFmMonth.FormCreate(Sender: TObject);
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

procedure TFmMonth.FormResize(Sender: TObject);
begin
  If AGLMeterForm=nil then exit;

  AGLMeterForm.SetChartVerticalToStd(Chart);
end;

procedure TFmMonth.GeneralUsageClick(Sender: TChartSeries; ValueIndex: Integer;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if Sender = GeneralUsage then
    if Sender = nil then
      Exit;
end;

procedure TFmMonth.GeneralUsageClickPointer(Sender: TCustomSeries;
  ValueIndex, X, Y: Integer);
begin
  if Sender = GeneralUsage then
    if Sender = nil then
      Exit;
end;

procedure TFmMonth.GeneralUsageMouseEnter(Sender: TObject);
begin
  if Sender = GeneralUsage then
    if Sender = nil then
      Exit;
end;

procedure TFmMonth.LoadCheckBoxesMonth(var ARec: TSelectionRecord);
begin
  ARec.SelectDays := false;
end;

function TFmMonth.NewBarSeries(AName: String; AStyle: TBarStyle): TBarSeries;
begin
  Result := NewSeries(AName, TBarSeries) as TBarSeries;
  Result.BarWidthPercent := 30;
//  Result.BarWidthPercent := 1;
  Result.Marks.Angle := 90;
  Result.Marks.ArrowLength := 15;
  Result.Marks.Arrow.Color := clLtGray;
  Result.BarStyle := AStyle; // bsarrow;
end;

function TFmMonth.NewLineSeries(AName: String): TLineSeries;
begin
  Result := NewSeries(AName, TTestLineSeries) as TTestLineSeries;
end;

function TFmMonth.NewPiontSeries(AName: String): TPointSeries;
begin
  Result := NewSeries(AName, TPointSeries) as TPointSeries;
end;

function TFmMonth.NewSeries(AName: String; ASeriesClass: TChartSeriesClass)
  : TChartSeries;
begin
  Result := ASeriesClass.Create(Chart);
  Result.Title := AName;
  Result.Marks.Visible := false;
  Result.OnClick := ChartSeriesOnClick;
  Result.OnDblClick := ChartSeriesOnDbleClick;
  Result.Color:=NextColor;

  Chart.AddSeries(Result);
end;

function TFmMonth.NextColor: TColor;
begin
begin
 Result:=IndexColors[FNextColorIndex];
 Inc(FNextColorIndex);
 if FNextColorIndex>high(IndexColors) then
   FNextColorIndex:=0;
end;
end;

end.
