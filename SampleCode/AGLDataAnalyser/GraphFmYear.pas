unit GraphFmYear;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  // System.Math,
  System.Classes, Vcl.Graphics, System.generics.collections,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, VclTee.TeeGDIPlus, VclTee.TeEngine,
  VclTee.Series, Vcl.ExtCtrls, VclTee.TeeProcs, VclTee.Chart, Vcl.StdCtrls,
  AGLAnalyserObjs, Vcl.WinXPickers, Vcl.ComCtrls;

type
  TFmYears = class(TForm)
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
//    procedure ControlledLoadClick(Sender: TChartSeries; ValueIndex: Integer;
//      Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
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
    FRefenceYear: Word;
    FNextColorIndex:integer;
    FReferenceDate: TDateTime; // Start of Month 12 months ago - Start of chart
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
    procedure BuildSeriesYears;
    procedure BuildMonths(AMinYear, AMaxYear: Word);
    Procedure AlignDateTimePickers;
    Procedure AlignChartToDate;
    Procedure LoadCheckBoxesYear(Var ARec: TSelectionRecord);

  public
    { Public declarations }
  end;

var
  FmYears: TFmYears;



implementation
Uses AglForm;
{$R *.dfm}
// function TFmYearOnYear.AllSeries: TList<TChartSeries>;
// begin
// if FAllSeries = nil then
// FAllSeries := TList<TChartSeries>.Create;
// Result := FAllSeries;
// end;

procedure TFmYears.AlignChartToDate;
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

procedure TFmYears.AlignDateTimePickers;
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

procedure TFmYears.Btn3DClick(Sender: TObject);
begin
  Chart.View3D := Not Chart.View3D;
end;

procedure TFmYears.Btn3DDwnClick(Sender: TObject);
begin
  Chart.View3DOptions.OrthoAngle := Chart.View3DOptions.OrthoAngle - 5;
end;

procedure TFmYears.Btn3DUpClick(Sender: TObject);
begin
  Chart.View3DOptions.OrthoAngle := Chart.View3DOptions.OrthoAngle + 5;
end;

procedure TFmYears.BtnMarkClick(Sender: TObject);
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

procedure TFmYears.BtnScrollLeftClick(Sender: TObject);
begin
  AlignDateTimePickers;
  if FDateHalfScale < 0.1 then
    Exit;
  FDateCentre := FDateCentre + FDateHalfScale;
  AlignChartToDate;
end;

procedure TFmYears.BtnScrollRightClick(Sender: TObject);
begin
  AlignDateTimePickers;
  if FDateHalfScale < 0.001 then
    Exit;
  FDateCentre := FDateCentre - FDateHalfScale;
  AlignChartToDate;
end;

procedure TFmYears.BtnSetAsVertStdClick(Sender: TObject);
begin
  if AGLMeterForm=nil then exit;
  AGLMeterForm.SetChartStdVertical(Chart);
end;

procedure TFmYears.BtnTestClick(Sender: TObject);
Var
  NewSeries: TLineSeries;
begin
  BuildSeriesYears;
end;

procedure TFmYears.BtnUndoZoomClick(Sender: TObject);
begin
  Chart.UndoZoom;
  FDateCentre := FDateCentreStart;
  FDateHalfScale := FDateHalfScaleStart;
  AlignChartToDate;
  Chart.LeftAxis.Minimum := 0.0;
end;

procedure TFmYears.BtnZoomInClick(Sender: TObject);
begin
  AlignDateTimePickers;
  FDateHalfScale := FDateHalfScale / 2;
  AlignChartToDate;
end;

procedure TFmYears.BtnZoomOutClick(Sender: TObject);
begin
  AlignDateTimePickers;
  FDateHalfScale := FDateHalfScale * 2;
  AlignChartToDate;
  // Chart.ZoomPercent(50);
end;

procedure TFmYears.BuildMonths(AMinYear, AMaxYear: Word);
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

  Caption:= 'Year Graph '+FormatDateTime('yyyy',(NewMin + NewMax)/2);
  LblCurrentValue.Caption:=Caption;


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
    else if CbxDoYearOnYear.checked then
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

procedure TFmYears.BuildSeriesYears;
var
  LDb: TAglDb;
  LYear: TAglYearRecord;
  ThisYear, ThisMonth, ThisDay: Word;
  YearDataSeries: TChartSeries;
  SelectionRec: TSelectionRecord;
  YearOnYear: boolean;
  MaxYear, MinYear: Word;
  TotalLoad, UseBarsOnly: boolean;
  BarOffsetPre,BarOffsetPost:Double;
begin
  YearOnYear := CbxDoYearOnYear.checked;
  // UseBarsOnly := CbxWeekEndsonly.checked or CbxSelectWeekdays.checked;
  UseBarsOnly := true;
  TotalLoad := CbxSelectControledLoad.Checked and CbxSelectGeneralLoad.Checked;

  ChartSeriesListClear;
  // Chart.UndoZoom;
  LDb := Db;
  LYear := Db.CurrentYear;
  if LYear = nil then
    Exit;

  MaxYear := LYear.YearNo;
  SelectionRec.SetUp(false, false);
  LoadCheckBoxesYear(SelectionRec);
  if YearOnYear then
    BuildMonths(0, 0)
  else
  begin  //Just create one series
    if not CbxSelectControledLoad.checked then
      YearDataSeries := NewBarSeries('General Load', bsRectangle)
    else if CbxSelectGeneralLoad.checked then
    Begin
      YearDataSeries := NewBarSeries('Total Load', bsRectangle);
    End
    Else
      YearDataSeries := NewBarSeries('Controled Load', bsRectangle);
  end;
  BarOffsetPost := -4.0; //For YearOnYear
  while LYear <> nil do
  Begin
    ThisYear := LYear.YearNo;
    MinYear := ThisYear;
    if YearOnYear then  //Create Series per year
    Begin
      BarOffsetPre:=BarOffsetPost+2;
      SelectionRec.SetOffsetToYear(FReferenceDate, ThisYear,  BarOffsetPre,BarOffsetPost);
      BarOffsetPost:=BarOffsetPre;
      if TotalLoad then
        YearDataSeries := NewBarSeries(IntToStr(ThisYear) + 'Total Load',
          bsRectangle)
      Else if CbxSelectControledLoad.checked then
        YearDataSeries := NewBarSeries(IntToStr(ThisYear) + 'Controlled Load',
          bsRectangle)
      else
        YearDataSeries := NewBarSeries(IntToStr(ThisYear) + 'General Load',
          bsRectangle);
      // YearDataCon := NewLineSeries(IntToStr(ThisYear) + 'Controlled Load');
      // YearDataGen := NewPiontSeries(IntToStr(ThisYear) + 'General Load');
      // YearDataCon := NewBarSeries(IntToStr(ThisYear) + 'Controlled Load',bsRectangle);
    End;
    LYear.PopulateYearMonthChartSeries(YearDataSeries, TotalLoad,
      CbxSelectControledLoad.checked, SelectionRec);
    if YearOnYear then
      SelectionRec.ShowLabel := false;
    LYear := Db.YearRecord(LYear.YearNo - 1);
  End;
  if not YearOnYear then
    BuildMonths(MinYear, MaxYear);
end;

procedure TFmYears.ChartClickLegend(Sender: TCustomChart; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
Var
  s: String;
begin
  s := FloatToStr(X) + '  ' + FloatToStr(Y);
  if Sender = nil then
    Exit;
end;

procedure TFmYears.ChartGetLegendPos(Sender: TCustomChart; Index: Integer;
  var X, Y, XColor: Integer);
Var
  s: String; // location of index items can be moved??
begin
  s := FloatToStr(X) + '  ' + FloatToStr(Y) + '  index=' + FloatToStr(index);
  if Sender = nil then
    Exit;

end;

procedure TFmYears.ChartGetLegendRect(Sender: TCustomChart; var Rect: TRect);
Var
  s: String;
begin
  // s:=FloatToStr(x)+'  '+FloatToStr(y);
  if Sender = nil then
    Exit;

end;

procedure TFmYears.ChartGetLegendText(Sender: TCustomAxisPanel;
  LegendStyle: TLegendStyle; Index: Integer; var LegendText: string);
Var
  s: String; // each line of text in legend
begin
  s := FloatToStr(Index) + ' >> ' + LegendText;
  if Sender = nil then
    Exit;

end;

procedure TFmYears.ChartMouseDown(Sender: TObject; Button: TMouseButton;
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

procedure TFmYears.ChartSeriesListClear;
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

procedure TFmYears.ChartSeriesOnClick(Sender: TChartSeries; ValueIndex: Integer;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
Var
  s: string;
  // CList:TChartValueList;
  // CVal:TChartValues;
  B: TChartSeries; // TBarSeries;
begin
  if Sender=nil then
    Begin
      LblCurrentValue.Caption := 'Click a bar to select a value, Dble Click to Zoom in';
      Exit;
    End;
  B := Sender; // as TBarSeries;
  // if B.Marks<>nil then
  if FDateHalfScale < 5 then
    B.Marks.Visible := not B.Marks.Visible
  else
    B.Marks.Visible := false;

  s := Sender.Name;
  s := FloatToStr(B.XValues[1]);
  s := FloatToStr(B.YValues[1]);
  s := B.Title + FormatDateTime('  mmmm', B.XValues[ValueIndex]) +
    ' Value:' + FormatFloat(' 0.000',B.YValues[ValueIndex]);
  LblCurrentValue.Caption := s;
  FDateCentre := B.XValues[ValueIndex];
  AlignChartToDate;
  DatePicker.Date := FDateCentre;
end;

procedure TFmYears.ChartSeriesOnDbleClick(Sender: TChartSeries;
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

procedure TFmYears.ChartUndoZoom(Sender: TObject);
begin
  AlignDateTimePickers;
end;

procedure TFmYears.ChartZoom(Sender: TObject);
begin
  AlignDateTimePickers;
end;

procedure TFmYears.CbxDoYearOnYearClick(Sender: TObject);
Var
  LDateCentre, LDateHalfScale: TDateTime;
begin
  LDateHalfScale := FDateHalfScale;
  LDateCentre := FDateCentre;
  BuildSeriesYears;
  FDateHalfScale := LDateHalfScale;
  FDateCentre := LDateCentre;
  AlignChartToDate;
end;

{procedure TFmYears.ControlledLoadClick(Sender: TChartSeries;
Var
  s: string;
  CList: TChartValueList;
  CVal: TChartValues;
  B: TChartSeries; // TBarSeries;
begin
  if Sender = nil then
    Begin
      ??
    End;
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
{  if Sender = GeneralUsage then
    if Sender = nil then
      Exit;
end;
}
procedure TFmYears.ControlledLoadMouseLeave(Sender: TObject);
begin
  if Sender = GeneralUsage then
    if Sender = nil then
      Exit;
end;

procedure TFmYears.DateTimePickerCloseUp(Sender: TObject);
begin
  if Sender = DatePicker then
    FDateCentre := DatePicker.Date;
  AlignChartToDate;
  AlignDateTimePickers;
  CbxDoYearOnYearClick(nil);
end;

function TFmYears.Db: TAglDb;
begin
  Result := AGLObj.AglDB;
end;

procedure TFmYears.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
end;

procedure TFmYears.FormCreate(Sender: TObject);
var
  LDb: TAglDb;
  LYear: TAglYearRecord;
  ThisYear, ThisMonth, ThisDay: Word;
  SelectionRec: TSelectionRecord;
begin
  Chart.View3D := false;
  BuildMonths(0, 0);
  LDb := Db;
  LYear := Db.CurrentYear;
  ThisYear := LYear.YearNo;
  SelectionRec.SetUp(false, false);
  SelectionRec.SetOffsetToYear(FReferenceDate, ThisYear,0.0,0.0);
  // LYear.PopulateYearChartSeries(GeneralUsage, ControlledLoad, SelectionRec);
  ChartSeriesOnClick(nil,0,mbLeft,[],0,0);
  CbxDoYearOnYearClick(nil);
end;

procedure TFmYears.FormResize(Sender: TObject);
begin
  If AGLMeterForm=nil then exit;

  AGLMeterForm.SetChartVerticalToStd(Chart);
end;

procedure TFmYears.GeneralUsageClick(Sender: TChartSeries; ValueIndex: Integer;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if Sender = GeneralUsage then
    if Sender = nil then
      Exit;
end;

procedure TFmYears.GeneralUsageClickPointer(Sender: TCustomSeries;
  ValueIndex, X, Y: Integer);
begin
  if Sender = GeneralUsage then
    if Sender = nil then
      Exit;
end;

procedure TFmYears.GeneralUsageMouseEnter(Sender: TObject);
begin
  if Sender = GeneralUsage then
    if Sender = nil then
      Exit;
end;

procedure TFmYears.LoadCheckBoxesYear(var ARec: TSelectionRecord);
begin
  ARec.SelectDays := false;
  if not CbxSelectControledLoad.checked then
         CbxSelectGeneralLoad.Checked:=true;
end;

function TFmYears.NewBarSeries(AName: String; AStyle: TBarStyle): TBarSeries;
begin
  Result := NewSeries(AName, TBarSeries) as TBarSeries;
  Result.BarWidthPercent := 30;
  Result.Marks.Angle := 90;
  Result.Marks.ArrowLength := 15;
  Result.Marks.Arrow.Color := clLtGray;
  Result.BarStyle := AStyle; // bsarrow;
end;

function TFmYears.NewLineSeries(AName: String): TLineSeries;
begin
  Result := NewSeries(AName, TTestLineSeries) as TTestLineSeries;
end;

function TFmYears.NewPiontSeries(AName: String): TPointSeries;
begin
  Result := NewSeries(AName, TPointSeries) as TPointSeries;
end;

function TFmYears.NewSeries(AName: String; ASeriesClass: TChartSeriesClass) : TChartSeries;
begin
  Result := ASeriesClass.Create(Chart);
  Result.Title := AName;
  Result.Marks.Visible := false;
  Result.OnClick := ChartSeriesOnClick;
  Result.OnDblClick := ChartSeriesOnDbleClick;
  Result.Color:=NextColor;

  Chart.AddSeries(Result);
end;

function TFmYears.NextColor: TColor;
begin
 Result:=IndexColors[FNextColorIndex];
 Inc(FNextColorIndex);
 if FNextColorIndex>high(IndexColors) then
   FNextColorIndex:=0;
end;

end.
