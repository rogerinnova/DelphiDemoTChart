unit AGLForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Menus, Vcl.StdCtrls,
  Vcl.WinXPickers,VclTee.Chart,
  GraphFmDay, ISFormsUtil;

type
  TAGLMeterForm = class(TForm)
    MainMenu1: TMainMenu;
    File1: TMenuItem;
    OpenData1: TMenuItem;
    OpenDatabase1: TMenuItem;
    OpenServerDb1: TMenuItem;
    BtnShowChart: TButton;
    BtnShowYonY: TButton;
    LbxForms: TListBox;
    BtnShowMonth: TButton;
    DatePicker1: TDatePicker;
    BtnShowDay: TButton;
    BtnCascade: TButton;
    BtnTile: TButton;
    BtnShowHolidays: TButton;
    BtnStopVertSync: TButton;
    procedure OpenData1Click(Sender: TObject);
    procedure OpenDatabase1Click(Sender: TObject);
    procedure OpenServerDb1Click(Sender: TObject);
    procedure BtnShowChartClick(Sender: TObject);
    procedure BtnShowYonYClick(Sender: TObject);
    procedure LbxFormsClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure BtnShowMonthClick(Sender: TObject);
    procedure BtnShowDayClick(Sender: TObject);
    procedure BtnCascadeClick(Sender: TObject);
    procedure BtnTileClick(Sender: TObject);
    procedure BtnShowHolidaysClick(Sender: TObject);
    procedure BtnStopVertSyncClick(Sender: TObject);
  private
    StdChartVertMin,StdChartVertMax:Double;
    Function ListOfForms: TStrings;
    { Private declarations }
  public
    { Public declarations }
    FormUtils: TApplicationFormUtil;
    Procedure SetChartStdVertical(AStdVert:TChart);
    Procedure SetChartVerticalToStd(AChart:TChart);
  end;

var
  AGLMeterForm: TAGLMeterForm;

implementation

{$R *.dfm}

uses AGLAnalyserObjs {, ISNetDBLogOn} , GraphFmYearOnYear, GraphFmYear,
  GraphFmMonth, ResidentHolidaysForm;

procedure TAGLMeterForm.BtnCascadeClick(Sender: TObject);
begin
  FormUtils.CascadeForms;
//  BringToFront;
end;

procedure TAGLMeterForm.BtnShowChartClick(Sender: TObject);
Var
  ChartFm: TFmYears;
begin
  ChartFm := TFmYears.Create(Application);
  ListOfForms.AddObject(ChartFm.caption, ChartFm);
  ChartFm.Show;
end;

procedure TAGLMeterForm.BtnShowDayClick(Sender: TObject);
Var
  ChartFm: TFmDay;
begin
  ChartFm := TFmDay.Create(Application);
  ChartFm.DatePicker.Date := DatePicker1.Date;
  ListOfForms.AddObject(ChartFm.caption, ChartFm);
  ChartFm.BtnTestClick(nil);
  ChartFm.Show;
end;

procedure TAGLMeterForm.BtnShowHolidaysClick(Sender: TObject);
Var
  HolidayFm: TResHolidayForm;
begin
  HolidayFm := TResHolidayForm.Create(self);
  ListOfForms.AddObject(HolidayFm.caption, HolidayFm);
  HolidayFm.Show;
end;

procedure TAGLMeterForm.BtnShowMonthClick(Sender: TObject);
Var
  ChartFm: TFmMonth;
begin
  ChartFm := TFmMonth.Create(Application);
  ChartFm.DatePicker.Date := DatePicker1.Date;
  ListOfForms.AddObject(ChartFm.caption, ChartFm);
  ChartFm.BtnTestClick(nil);
  ChartFm.Show;
end;

procedure TAGLMeterForm.BtnShowYonYClick(Sender: TObject);
Var
  ChartFm: TFmYearOnYear;
begin
  ChartFm := TFmYearOnYear.Create(Application);
  ListOfForms.AddObject(ChartFm.caption, ChartFm);
  ChartFm.Show;
end;

procedure TAGLMeterForm.BtnStopVertSyncClick(Sender: TObject);
begin
  SetChartStdVertical(nil);
end;

procedure TAGLMeterForm.BtnTileClick(Sender: TObject);
begin
  FormUtils.TileForms;
end;

procedure TAGLMeterForm.FormCreate(Sender: TObject);
Var
  Db: TAglDb;
begin
  Db := AGLObj.AglDB;
  if Db <> nil then
  begin
    DatePicker1.Date := Db.LastDate - 90;
  end;
  FormUtils := ApplicationFormUtil;
  Show;
end;

procedure TAGLMeterForm.LbxFormsClick(Sender: TObject);
Var
  idx: integer;
  LForm: TForm;
begin
  LForm := nil;
  idx := LbxForms.ItemIndex;
  if LbxForms.Items.Objects[idx] is TForm then
    LForm := TForm(LbxForms.Items.Objects[idx]);
  if LForm <> nil then
    Try
      LForm.WindowState := wsNormal;
      LForm.Show;
      LForm.BringToFront;
    Except
      LbxForms.Items.Delete(idx);
    End;
end;

function TAGLMeterForm.ListOfForms: TStrings;
begin
  Result := LbxForms.Items;
end;

procedure TAGLMeterForm.OpenData1Click(Sender: TObject);
Var
  Dlg: TOpenDialog;
begin
  Dlg := TOpenDialog.Create(self);
  Try
    Dlg.Filter :=
      'Zip Files (*.zip)|*.ZIP|Csv Files (*.csv)|*.CSV|All Files (*.*)|*.*';
    Dlg.InitialDir := AGLObj.LastDataDirectory;
    if Dlg.Execute then
    Begin
      AGLObj.ProcessIncomingDataFile(Dlg.FileName);
    End;
  Finally
    Dlg.Free;
  End;
end;

procedure TAGLMeterForm.OpenDatabase1Click(Sender: TObject);
begin
  AGLObj.OpenNewDb;
end;

procedure TAGLMeterForm.OpenServerDb1Click(Sender: TObject);
begin
  AGLObj.OpenNewServerDb;
end;

procedure TAGLMeterForm.SetChartStdVertical(AStdVert: TChart);
begin
  if AStdVert=nil then
    Begin
      StdChartVertMin:=0.0;
      StdChartVertMax:=0.0;
    End
   else
    Begin
      StdChartVertMin:=AStdVert.LeftAxis.Minimum;
      StdChartVertMax:=AStdVert.LeftAxis.Maximum;
      BtnCascadeClick(nil);
      BtnTileClick(nil);
    End
end;

procedure TAGLMeterForm.SetChartVerticalToStd(AChart: TChart);
begin
  if AChart=nil then Exit;
  if (StdChartVertMax-StdChartVertMin)>0.0001 then
     AChart.LeftAxis.SetMinMax(StdChartVertMin,StdChartVertMax);
end;

end.
