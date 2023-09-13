unit ResidentHolidaysForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, AGLAnalyserObjs;

type
  TResHolidayForm = class(TForm)
    LbxHolidays: TListBox;
    procedure FormCreate(Sender: TObject);
    procedure LbxHolidaysDblClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  ResHolidayForm: TResHolidayForm;

implementation

{$R *.dfm}

uses GraphFmDay;

procedure TResHolidayForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
end;

procedure TResHolidayForm.FormCreate(Sender: TObject);
Var
  HolidayList:TStrings;
  Db:TAglDb;
  I:Integer;
begin
  Db:=AGLObj.AglDB;
  if Db=nil then Exit;

  HolidayList:=LbxHolidays.Items;
  Db.FillListOfHolidays(HolidayList);
end;

procedure TResHolidayForm.LbxHolidaysDblClick(Sender: TObject);
var
  ThisObj:TAglDailyRecord;
  ChartFm:TFmDay;
begin
     ThisObj:=LbxHolidays.Items.Objects[LbxHolidays.ItemIndex] AS TAglDailyRecord;
     ChartFm:=TFmDay.Create(Application);
     ChartFm.DatePicker.Date:=ThisObj.StartDate;
     ChartFm.BtnTestClick(nil);
     ChartFm.Show;
end;

end.
