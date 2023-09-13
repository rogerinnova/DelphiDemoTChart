program AGLDataView;

uses
  Vcl.Forms,
  AGLForm in 'AGLForm.pas' {AGLMeterForm},
  AGLAnalyserObjs in 'AGLAnalyserObjs.pas',
  GraphFmDay in 'GraphFmDay.pas' {FmDay},
  GraphFmYearOnYear in 'GraphFmYearOnYear.pas' {FmYearOnYear},
  GraphFmYear in 'GraphFmYear.pas' {FmYears},
  GraphFmMonth in 'GraphFmMonth.pas' {FmMonth},
  ResidentHolidaysForm in 'ResidentHolidaysForm.pas' {ResHolidayForm},
  LibraryExtract in 'LibCode\LibraryExtract.pas',
  ISPermObjConst in 'LibCode\ISPermObjConst.pas';

{$R *.res}

begin
  Application.Initialize;
 // Application.MainFormOnTaskbar := True;
  Application.CreateForm(TAGLMeterForm, AGLMeterForm);
  Application.Run;
end.
