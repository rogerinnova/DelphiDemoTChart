unit AGLAnalyserObjs;

interface

Uses
  System.SysUtils, System.Variants, System.Classes, System.zip, VCL.Dialogs,
  VCL.graphics,
  VclTee.TeeGDIPlus, VclTee.TeEngine, VclTee.Series,
  Math,
  IniFiles,
  {IsLogging, IsArrayLib} LibraryExtract, ISMultiUserRemoteDb, ISMultiUserPermObjFileStm,
  ISPermObjFileStm;

Var
  CountOfLineSeries: integer = 0;

Type
  TTestLineSeries = class(TLineSeries)
  Public
    Constructor Create(AOwner: TComponent); overload;
    Destructor Destroy; Override;
  end;

  TSelectionRecord = record
    SelectDays: Boolean;
    RefDateOffsetPre, RefDateOffsetPost: TDateTime;
    ChgOverDate: TDateTime;
    DaysOfWeek: array [1 .. 7] of Boolean;
    NoLabelsOnDays: Array [1 .. 31] of Boolean;
    ShowLabel: Boolean;
    Procedure SetUp(ASelectDays, AShowLabel: Boolean);
    Procedure SetOffsetToYear(ARefDate: TDateTime; AYear: integer;
      ABarOffsetPre, ABarOffsetPost: Double);
    Function SetOffsetToDay(ARefDay: TDateTime; AYearOfOffset: integer;
      ABarOffsetPre, ABarOffsetPost: Double): TDateTime;
    // Returns date of Matching day (eg Monday) in year of offset and sets up the Record
    Function RefDateOffset(AStartDate, AStartTime: TDateTime): TDateTime;
  end;

  TAglMeterPeriod = class(TDbPersistentChildObj)
  Private
    FNext, FPrev: TAglMeterPeriod;
    FStartdate, FStartTime, FEndTime, FPeriod: TDateTime;
    FGeneralUsage, FControledLoad: single;
    procedure UpdateAndFree(var ANew: TAglMeterPeriod);
    // Function TotalMonthUsage: single;
    Function TotalControlledUsage: single;
    Function TotalGeneralUsage: single;
  public
    Destructor Destroy; override;
    procedure Load(var s: Tstream); override;
    procedure Store(var s: Tstream); override;
    Procedure AddOrUpdate(ANew: TAglMeterPeriod;
      var AListRoot: TAglMeterPeriod);
    Procedure PopulateChartSeries(ADataGen, ADataCon: TChartSeries;
      ASelectionRec: TSelectionRecord; ATotals: Boolean);
    // function RecordGridIndexString:ansistring;
    class function AGLDecodeDate(ADate: AnsiString): TDateTime;
    class function CreateFromDate(AStartDate, AEndDate: AnsiString)
      : TAglMeterPeriod;
  end;

  TAglDailyRecord = class(TISMultiUserDbBaseObj)
  Private
    FMeterRecs: TAglMeterPeriod;
    FDeviceNumber, FDeviceType, FAccountNumber, FNMI: AnsiString;
    FTotalControlledUsage: single;
    FTotalGeneralUsage: single;
    // Calc
    FDayOfWeek: integer;
    FDate: TDateTime;
    procedure DoCalcFields;
    Function TotalDayUsage: single;
    Function TotalControlledUsage: single;
    Function TotalGeneralUsage: single;
  Public
    YearNo, MonthNo, DayNo: Word;
    Destructor Destroy; override;
    procedure Load(var s: Tstream); override;
    procedure Store(var s: Tstream); override;
    function UpdateWith(AUpdate: TAglMeterPeriod): Boolean;
    Procedure PopulateDayChartSeries(ADayDataGen, ADayDataCon: TChartSeries;
      ASelectionRec: TSelectionRecord; ATotals: Boolean = False);
    Procedure PopulateDayTotalValueChartSeries(ADataSeries: TChartSeries;
      ATotals, ASelectControledLoad: Boolean; ASelectionRec: TSelectionRecord);
    Function StartDate: TDateTime;
    Function NextDay: TAglDailyRecord;
    Function PrevDay: TAglDailyRecord;
    Function ResidentsOnHoliday(var ARunningAverage: Double;
      Var ANoOfSamples: integer): Boolean;
    Function ListDescripter: String;
    Class Function IndexDescripter(AYear, AMonth, ADay: integer): String;
    Class Function IndexCode(AYear, AMonth, ADay: integer): String;
  end;

  TAglMonthRecord = class(TISMultiUserDbBaseObj)
  Private
    FListOfDays: TStringList; // of TAglDailyRecord
    FTotalControlledUsage: single;
    FTotalGeneralUsage: single;
    Function ListOfDays: TStringList;
    Function TotalMonthUsage: single;
    Function TotalControlledUsage: single;
    Function TotalGeneralUsage: single;
  Public
    YearNo, MonthNo: Word;
    Destructor Destroy; override;
    procedure Load(var s: Tstream); override;
    procedure Store(var s: Tstream); override;
    // function IndexString:ansistring;
    Function DayRecord(ADay: integer; ACreate: Boolean): TAglDailyRecord;
    Procedure PopulateMonthChartSeries(AMonthDataGen, AMonthDataCon
      : TChartSeries; ASelectionRec: TSelectionRecord);
    Procedure PopulateMonthTotalValueChartSeries(ADataSeries: TChartSeries;
      ATotals, ASelectControledLoad: Boolean; ASelectionRec: TSelectionRecord);
    Procedure PopulateDailyTotalValueChartSeries(ADataSeries: TChartSeries;
      ATotals, ASelectControledLoad: Boolean; ASelectionRec: TSelectionRecord);
    Function StartDate: TDateTime;
    Function LastDate: TDateTime;
    Function FirstDay: TAglDailyRecord;
    Class Function StringDescripter(AYear, AMonth: integer): String;
    Class Function IndexCode(AYear, AMonth: integer): String;
  end;

  TAglYearRecord = class(TISMultiUserDbBaseObj)
  Private
    FListOfMonths: TStringList; // of TAglDailyRecord
    Function ListOfMonths: TStringList;
  Public
    YearNo: Word;
    Destructor Destroy; override;
    procedure Load(var s: Tstream); override;
    procedure Store(var s: Tstream); override;
    // function IndexString:ansistring;
    Function MonthRecord(AMonth: integer): TAglMonthRecord;
    Procedure PopulateYearChartSeries(AYearDataGen, AYearDataCon: TChartSeries;
      ASelectionRec: TSelectionRecord);
    Procedure PopulateYearMonthChartSeries(ADataSeries: TChartSeries;
      ATotals, ASelectControledLoad: Boolean; ASelectionRec: TSelectionRecord);
    Function StartDate: TDateTime;
    Class Function StringDescripter(AYear: integer): String;
    Class Function IndexCode(AYear: integer): String;
  end;

  TAglDb = class(TISMultiUserDBRemote)
  Private
    function Index1_Years(APtr: Pointer): AnsiString;
    function Index2_Months(APtr: Pointer): AnsiString;
    function Index3_Days(APtr: Pointer): AnsiString;
  Protected
    procedure LoadIndexs; override;
  Public
    Function LastDate: TDateTime;
    Function FirstDayObj: TAglDailyRecord;
    // Function LogOn(const AUser, APassword: AnsiString): Boolean; override;
    Function YearRecord(AYear: integer; AForceCreate: Boolean = False)
      : TAglYearRecord;
    Function MonthRecord(AYear, AMonth: integer; ACreate: Boolean)
      : TAglMonthRecord;
    Function DayRecord(AYear, AMonth, ADay: integer; ACreate: Boolean)
      : TAglDailyRecord;
    Function CurrentYear: TAglYearRecord;
    Function CurrentMonth: TAglMonthRecord;
    Procedure FillListOfHolidays(AList: TStrings);
    // Function CurrentDay: TAglDailyRecord;
  end;

  TAglAnal = class(Tobject)
  private
    FLastDbDirectory, FCurrentDbFileName: string;
    FCurrentServer, FCurrentServerDbName, FLastDataDir: string;
    FErrorLogFileName: String;
    FDb: TAglDb;
    //FErrorLogObj: TLogFile;
    FServerPort: integer;
    FUsePersonality: Boolean;
    FAccountNumberCol, FNMICol, FDeviceNumberCol, FDeviceTypeCol,
      FRegisterCodeCol, FRateTypeDescriptionCol, FStartDateCol, FEndDateCol,
      FProfileReadValueCol, FRegisterReadValueCol, FQualityFlag: integer;
    Procedure SetHeadersDetails(AHdrArray: TArrayOfAnsiStrings);
    Procedure ReadIniFile;
    Procedure WriteIniFile;
    Procedure OpenDb(ADbFileName: string; ADbServer: string = '';
      ADbPort: integer = 0);
    Function ReadLineFromStream(AReadStream: Tstream;
      Var ARemainder: AnsiString; Var AAllDone, AAllread: Boolean): AnsiString;
    Function RecoverValues(NxtValues: TArrayOfAnsiStrings;
      out ADay, AMonth, AYear: Word; Out AAccount, ANmi, ADeviceNo,
      ARegCode: AnsiString): TAglMeterPeriod;
    Procedure LogError(AError: string);
    Procedure ProcessIncomingZipFile(AZipStream: Tstream);
    Procedure ProcessIncomingFile(AStream: Tstream);
    procedure SetLastDataDir(const Value: String);
    function GetLastDataDir: String;
  Public
    Destructor Destroy; override;
    Procedure ProcessIncomingDataFile(AFileName: String);
    Procedure OpenNewServerDb;
    Procedure OpenNewDb;
    Function AglDB: TAglDb;
    Property LastDataDirectory: String Read GetLastDataDir write SetLastDataDir;
  end;

Function AGLObj: TAglAnal;
Function MonthCode(AMonth: integer): AnsiString;

const
  SomeText: AnsiString = 'Will We ever encrpt This DB';
  CodedPersonaliy: AnsiString = 'FGT286$C$VENfffg';

  IndexColors: Array [0 .. 5] of TColor = (clblue, clLime, clMaroon, clred,
    clNavy, clLtGray);

implementation

//uses {, ISNetDBLogOn} IsProcCl;

Var
  SingletonAgl: TAglAnal;

Function AGLObj: TAglAnal;
Begin
  if SingletonAgl = nil then
  Begin
    SingletonAgl := TAglAnal.Create;
    SingletonAgl.AglDB;
  End;
  Result := SingletonAgl;
End;

Function MonthCode(AMonth: integer): AnsiString;
Const
  MonthArray: Array [1 .. 12] of AnsiString = ('Jan', 'Feb', 'Mar', 'Apr',
    'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec');

begin
  Try
    Result := MonthArray[AMonth];
  Except
    Result := 'TAglDailyRecord.IndexDescripter Error';
  End;
end;

{ TAglAnal }

function TAglAnal.AglDB: TAglDb;
begin
  if FDb = nil then
  begin
    if (FCurrentDbFileName = '') and (FCurrentDbFileName = '') then
      ReadIniFile;
    if (FCurrentDbFileName <> '') and (FCurrentServer <> '') then
      Try
        OpenDb(FCurrentDbFileName, FCurrentServer, FServerPort);
      Except
      End;
    if FDb = nil then
      OpenDb(FCurrentDbFileName);
  end;
  Result := FDb;
end;

destructor TAglAnal.Destroy;
begin
  if SingletonAgl = self then
    SingletonAgl := nil;
  FreeAndNil(FDb);
//  FreeAndNil(FErrorLogObj);
  inherited;
end;

function TAglAnal.GetLastDataDir: String;
begin
  if FLastDataDir = '' then
    ReadIniFile;
  Result := FLastDataDir;
end;

procedure TAglAnal.LogError(AError: string);
Const
  DefaultLogFile = 'C:\InnovaObjectDbs\AglAnal\AGLErrorLog.log';
begin
//  if FErrorLogObj = nil then
//  Begin
//    ReadIniFile;
//    if FErrorLogFileName = '' then
//      FErrorLogFileName := DefaultLogFile;
//    FErrorLogObj := AppendLogFile(FErrorLogFileName, 10000, true);
//  end;
//  FErrorLogObj.LogALine(AError);
end;

procedure TAglAnal.OpenDb(ADbFileName, ADbServer: string; ADbPort: integer);
Const
  NewDbFilename = 'C:\InnovaObjectDbs\AglAnal\AGLANALDb.idb';
begin
  FreeAndNil(FDb);
  Try
    if ADbServer = '' then
    begin
      if ADbFileName = '' then
        ADbFileName := NewDbFilename;

      if not FileExists(ADbFileName) then // Create A new Db
      Begin
        ForceDirectories(ExtractFileDir(NewDbFilename));
        // wil only creat speced dir
        FDb := TAglDb.Create(ADbFileName, fmCreate);
        FreeAndNil(FDb);
      End;
      FDb := TAglDb.Create(ADbFileName, fmopendb, SomeText);
    end
    else
      FDb := TAglDb.Create(ADbFileName, fmopendb, SomeText, ADbServer, ADbPort);
    if ADbServer <> '' then
      if (FDb <> nil) and FUsePersonality then
        FDb.Personality := CodedPersonaliy;
    if FDb <> nil then
      WriteIniFile;
  Except
    On E: Exception do
      raise Exception.Create('TAglAnal.OpenDb:' + E.Message);
  End;
end;

procedure TAglAnal.OpenNewDb;
var
  Dlg: TOpenDialog;
begin
  { if fDb <> nil then
    if MessageDlg('All unsaved changes to current DB will be lost',
    mtWarning, mbOKCancel, 0) <> mrOk then Exit; }
  ReadIniFile;
  if FLastDbDirectory = '' then
    FLastDbDirectory := ExtractFilePath(FCurrentDbFileName);

  Dlg := TOpenDialog.Create(nil);
  Dlg.Title := 'Open AGL Database';
  Dlg.Filter := 'Database|*.idb|All Files|*.*';
  Dlg.InitialDir := FLastDbDirectory;
  try
    if Dlg.Execute then
      try
        OpenDb(Dlg.FileName);
      except
        FreeAndNil(FDb);
        raise;
      end;
  finally
    Dlg.free;
  end;
end;

procedure TAglAnal.OpenNewServerDb;
// var
// Dlg: TGetRemoteDbDlg;

begin
  // Dlg := TGetRemoteDbDlg.Create(nil);
  // try
  // Dlg.SetData(CurrentServer, CurrentServerDbName, '', '',
  // 'Log on to Networked AGL Database', '', '', '',
  // '','', TAGLDb, FDb,
  // ServerPort, UsePersonality, SomeText, false,'',true);
  // if Dlg.Execute then
  // begin
  // Fdb:=Dlg.Database as TAGLDb;
  // if not Dlg.LoggedOn then
  // FDb.LogOn(Dlg.Username, Dlg.Password);
  // UsePersonality := Dlg.ConnectWithPersonality;
  // end;
  // finally
  // Dlg.free;
  // end;
end;

procedure TAglAnal.ProcessIncomingDataFile(AFileName: String);
Var
  FileExt: String;
  Strm: TFileStream;
begin
  Try
    if not FileExists(AFileName) then
      exit;
    Strm := TFileStream.Create(AFileName, fmopenread);
    Try
      FileExt := LowerCase(ExtractFileExt(AFileName));
      if FileExt = '.zip' then
        ProcessIncomingZipFile(Strm)
      else
        ProcessIncomingFile(Strm);
      LastDataDirectory := ExtractFileDir(AFileName);
    Finally
      Strm.free;
    End;
  Except
    on E: Exception do
      LogError('ProcessIncomingDataFile Error::' + E.Message)
  End;
end;

procedure TAglAnal.ProcessIncomingFile(AStream: Tstream);
Var
  Length: Int64;
  Hdrs, NxtValues: TArrayOfAnsiStrings;
  NxtLn, LeftOver, SaveData: AnsiString;
  AllDone, AllRead: Boolean;
  NxtRead: TAglMeterPeriod;
  Account, Nmi, Device, Code: AnsiString;
  Day, Month, Year: Word;
  ThisYear: TAglYearRecord;
  ThisMonth: TAglMonthRecord;
  ThisDay: TAglDailyRecord;
  LinesDone: integer;
begin
  Try
    ThisYear := nil;
    ThisMonth := nil;
    ThisDay := nil;
    LinesDone := 0;
    if AStream = nil then
      exit;
    Length := AStream.Seek(0, soFromEnd);
    if Length < 5 then
      exit;
    AStream.Seek(0, soBeginning);
    LeftOver := '';
    AllDone := False;
    AllRead := False;
    NxtLn := ReadLineFromStream(AStream, LeftOver, AllDone, AllRead);
    Hdrs := GetArrayFromString(NxtLn, ',', true, true, False);
    SetHeadersDetails(Hdrs);
    while not AllDone do
    begin
      inc(LinesDone);
      SaveData := NxtLn;
      NxtLn := ReadLineFromStream(AStream, LeftOver, AllDone, AllRead);
      NxtValues := GetArrayFromString(NxtLn, ',', true, true, False);
      NxtRead := RecoverValues(NxtValues, Day, Month, Year, Account, Nmi,
        Device, Code);
      if NxtRead = nil then
      Begin
        LogError('Failed Data At Line:' + IntToStr(LinesDone));
        LogError('Last Record:' + SaveData);
        LogError('Failed Data:' + NxtLn);
      end
      else
      begin
        if (ThisYear = nil) or (ThisYear.YearNo <> Year) then
        Begin
          // if ThisYear <> nil then
          // ThisYear.SaveToDb; // Lock in values?????
          ThisYear := AglDB.YearRecord(Year, true);
        End;
        if (ThisMonth = nil) or (ThisMonth.YearNo <> Year) or
          (ThisMonth.MonthNo <> Month) then
        Begin
          // if ThisMonth <> nil then
          // ThisMonth.SaveToDb; // Lock in values?????
          ThisMonth := ThisYear.MonthRecord(Month);
        End;
        if (ThisDay = nil) or (ThisDay.YearNo <> Year) or
          (ThisDay.MonthNo <> Month) or (ThisDay.DayNo <> Day) then
        begin
          if ThisDay <> nil then
            ThisDay.SaveToDb; // Lock in values?????
          ThisDay := ThisMonth.DayRecord(Day, true);
        end;
        if not ThisDay.UpdateWith(NxtRead) then
          LogError('Failed Update ' + 'ThisDay.indexstring');
      end;
    end;
  Except
    On E: Exception do
      LogError('Failed Update ' + E.Message);
  End;
end;

procedure TAglAnal.ProcessIncomingZipFile(AZipStream: Tstream);
Var
  LFileStream: Tstream;
  idx: integer;
  ZipObj: TZipFile;
  Hdr: TZipHeader;
  FileNames: TArray<string>;
begin
  ZipObj := TZipFile.Create;
  Try
    ZipObj.Open(AZipStream, zmread);
    FileNames := ZipObj.FileNames;
    LFileStream := nil;
    for idx := Low(FileNames) to High(FileNames) do
      Try
        ZipObj.Read(FileNames[idx], LFileStream, Hdr);
        ProcessIncomingFile(LFileStream);
      Finally
        FreeAndNil(LFileStream);
      End;
  Finally
    ZipObj.free;
  End;

end;

procedure TAglAnal.ReadIniFile;
Var
  IniFile: TIniFile;
  FileName, DirName: string;
begin
  FileName := {GetMyAppsDataFolder +} 'C:\Innova Solutions\AGLData\' +
    ChangeFileExt(ExtractFileName(ParamStr(0)), 'DbConfig.ini');
  if not FileExists(FileName) then
    WriteIniFile;
  IniFile := TIniFile.Create(FileName);
  try
    try
      FCurrentDbFileName := IniFile.ReadString('Files', 'LastAccesDb', '');
      FErrorLogFileName := IniFile.ReadString('Files', 'LogFile', '');
      FCurrentServer := IniFile.ReadString('Server', 'LastDbServer', '');
      FCurrentServerDbName := IniFile.ReadString('Server',
        'LastDbServerFile', '');
      FServerPort := IniFile.ReadInteger('Server', 'ServerPort', 1600);
      FUsePersonality := IniFile.ReadBool('Server', 'UsePersonality', False);
      FLastDataDir := IniFile.ReadString('Files', 'LastDataDir', '');
    except
      On E: Exception do
        raise Exception.Create('TAglAnal.ReadIniFile:' + E.Message);
    end;
  finally
    IniFile.free;
  end;
end;

function TAglAnal.ReadLineFromStream(AReadStream: Tstream;
  Var ARemainder: AnsiString; Var AAllDone, AAllread: Boolean): AnsiString;
Const
  MaxLineSz: integer = 256;
Var
  DataLength, Count, idx: integer;
  Data: AnsiString;
begin
  if not AAllread and (Length(ARemainder) < MaxLineSz) then
  begin
    SetLength(Data, MaxLineSz);
    Count := AReadStream.Read(Data[1], MaxLineSz);
    if Count <> MaxLineSz then
    Begin
      SetLength(Data, Count);
      AAllread := true;
    End;
    Data := ARemainder + Data;
  end
  Else
    Data := ARemainder;

  Count := Length(Data);
  if Count < 1 then
  begin
    Result := '';
    AAllread := true;
    AAllDone := true;
  end
  else
  begin
    DataLength := 1;
    while (DataLength <= Count) and (Ord(Data[DataLength]) > 16) do
      inc(DataLength);
    idx := DataLength;
    while (idx <= Count) and (Ord(Data[idx]) < 16) do
      inc(idx);
    if idx < Count then
      ARemainder := Copy(Data, idx, 5 * MaxLineSz)
    Else
    begin
      if AAllread then
        AAllDone := true;
      ARemainder := '';
    end;
    SetLength(Data, DataLength - 1);
    Result := Data;
  end;
end;

function TAglAnal.RecoverValues(NxtValues: TArrayOfAnsiStrings;
  out ADay, AMonth, AYear: Word; out AAccount, ANmi, ADeviceNo,
  ARegCode: AnsiString): TAglMeterPeriod;
Var
  StartDate, EndDate: AnsiString;
begin
  Try
    Result := nil;
    if Length(NxtValues) < FQualityFlag then
      raise Exception.Create('Error NxtValues)<FQualityFlag');
    StartDate := NxtValues[FStartDateCol];
    EndDate := NxtValues[FEndDateCol];
    Result := TAglMeterPeriod.CreateFromDate(StartDate, EndDate);
    if Result <> nil then
    begin
      case NxtValues[FRateTypeDescriptionCol][1] of
        'G':
          Result.FGeneralUsage := StrToFloat(NxtValues[FProfileReadValueCol]);
        'C':
          Result.FControledLoad := StrToFloat(NxtValues[FProfileReadValueCol]);
      else
        LogError('RecoverValues:' + NxtValues[FRateTypeDescriptionCol]);
      end;
      AAccount := NxtValues[FAccountNumberCol];
      ANmi := NxtValues[FNMICol];
      ADeviceNo := NxtValues[FDeviceNumberCol];
      ARegCode := NxtValues[FRegisterCodeCol];
      DecodeDate(Result.FStartdate, AYear, AMonth, ADay);
      SetLength(ARegCode, Pos('#E', ARegCode) - 1);
    end;
  Except
    On E: Exception do
    Begin
      LogError('Exception RecoverValues:' + E.Message);
      FreeAndNil(Result);
    end;
  End;
end;

procedure TAglAnal.SetHeadersDetails(AHdrArray: TArrayOfAnsiStrings);
begin
  FAccountNumberCol := IndexInArray(AHdrArray, 'AccountNumber');
  FNMICol := IndexInArray(AHdrArray, 'NMI');
  FDeviceNumberCol := IndexInArray(AHdrArray, 'DeviceNumber');
  FDeviceTypeCol := IndexInArray(AHdrArray, 'DeviceType');
  FRegisterCodeCol := IndexInArray(AHdrArray, 'RegisterCode');
  FRateTypeDescriptionCol := IndexInArray(AHdrArray, 'RateTypeDescription');
  FStartDateCol := IndexInArray(AHdrArray, 'StartDate');
  FEndDateCol := IndexInArray(AHdrArray, 'EndDate');
  FProfileReadValueCol := IndexInArray(AHdrArray, 'ProfileReadValue');
  FRegisterReadValueCol := IndexInArray(AHdrArray, 'RegisterReadValue');
  FQualityFlag := IndexInArray(AHdrArray, 'QualityFlag');
  if (FRateTypeDescriptionCol < 1) or (FProfileReadValueCol < 1) then
    raise Exception.Create('Error SetHeadersDetails');
end;

procedure TAglAnal.SetLastDataDir(const Value: String);
begin
  ReadIniFile;
  if FLastDataDir <> Value then
  begin
    FLastDataDir := Value;
    WriteIniFile;
  end;
end;

procedure TAglAnal.WriteIniFile;
Var
  IniFile: TIniFile;
  FileName, DirName: string;
begin
  FileName := {GetMyAppsDataFolder +} 'C:\Innova Solutions\AGLData\' +
    ChangeFileExt(ExtractFileName(ParamStr(0)), 'DbConfig.ini');
  IniFile := TIniFile.Create(FileName);
  try
    try
      if not FileExists(FileName) then
      Begin
        ForceDirectories(ExtractFilePath(FileName));
        IniFile.WriteString('Server', 'LastDbServer', '');
        IniFile.WriteString('Server', 'LastDbServerFile', '');
        IniFile.WriteInteger('Server', 'ServerPort', 1500);
        IniFile.WriteBool('Server', 'UsePersonality', False);
        IniFile.WriteString('Files', 'LastAccesDb', '');
        IniFile.WriteString('Files', 'LogFile', '');
      End;
      if FDb <> nil then
        if FDb.RemoteFile then
        Begin
          IniFile.WriteString('Server', 'LastDbServer', FDb.ServerName);
          IniFile.WriteString('Server', 'LastDbServerFile', FDb.ServerDbName);
          IniFile.WriteInteger('Server', 'ServerPort', FDb.ServerPort);
          IniFile.WriteBool('Server', 'UsePersonality', FDb.Personality <> '');
        End
        Else
          IniFile.WriteString('Files', 'LastAccesDb', FDb.FileName);
      IniFile.WriteString('Files', 'LastDataDir', FLastDataDir);
    except
      On E: Exception do
        raise Exception.Create('TAglAnal.WriteIniFile:' + E.Message);
    end;
  finally
    IniFile.free;
  end;
end;

{ TAglDb }

// function TAglDb.CurrentDay: TAglDailyRecord;
// Var
// LDay, LMonth, LYear: Word;
// begin
// DecodeDate(Now, LYear, LMonth, LDay);
// Result := DayRecord(LYear, LMonth, LDay);
// end;

function TAglDb.CurrentMonth: TAglMonthRecord;
Var
  LDay, LMonth, LYear: Word;
begin
  DecodeDate(Now, LYear, LMonth, LDay);
  Result := MonthRecord(LYear, LMonth, true);
end;

function TAglDb.CurrentYear: TAglYearRecord;
Var
  LDay, LMonth, LYear: Word;
begin
  DecodeDate(Now, LYear, LMonth, LDay);
  Result := YearRecord(LYear, true);
end;

function TAglDb.DayRecord(AYear, AMonth, ADay: integer; ACreate: Boolean)
  : TAglDailyRecord;
Var
  Index: AnsiString;
begin
  Index := TAglDailyRecord.IndexCode(AYear, AMonth, ADay);
  Result := TAglDailyRecord(ReadFileObjectBySecondaryIndex(index, idx3, true,
    False, TAglDailyRecord));
  if Result = nil then
    Result := TAglDailyRecord(ReadFileObjectBySecondaryIndex(index, idx3, true,
      true, TAglDailyRecord));

  if (Result = nil) and ACreate then
  Begin
    Result := TAglDailyRecord.Create(nil, nil);
    Result.YearNo := AYear;
    Result.MonthNo := AMonth;
    Result.DayNo := ADay;
    Result.DoCalcFields;
    if Result.FDayOfWeek > 0 then
      WriteIndexedObject(Result)
    else
      FreeAndNil(Result);
  End;
end;

procedure TAglDb.FillListOfHolidays(AList: TStrings);
Var
  ThisDailyRec: TAglDailyRecord;
  DayItems: integer;
  RunningAverage: Double;
begin
  if AList = nil then
    exit;

  DayItems := 0;
  ThisDailyRec := FirstDayObj;
  while ThisDailyRec <> nil do
  Begin
    if ThisDailyRec.ResidentsOnHoliday(RunningAverage, DayItems) then
      AList.AddObject(ThisDailyRec.ListDescripter, ThisDailyRec);
    ThisDailyRec := ThisDailyRec.NextDay;
  End;
end;

function TAglDb.FirstDayObj: TAglDailyRecord;
Var
  ThisYear, ThisMonth, ThisDay: Word;
  MonthObj: TAglMonthRecord;
begin
  Result := nil;
  ThisYear := 2000;
  ThisMonth := 1;
  ThisDay := 1;
  MonthObj := MonthRecord(ThisYear, ThisMonth, False);
  while (MonthObj = nil) And (ThisYear < 2100) do
  Begin
    MonthObj := MonthRecord(ThisYear, ThisMonth, False);
    if MonthObj <> nil then
    begin
      Result := MonthObj.FirstDay;
      If Result = nil then
        MonthObj := nil;
    end;
    if MonthObj = nil then
    Begin
      inc(ThisMonth);
      If ThisMonth > 12 Then
      Begin
        ThisMonth := 1;
        inc(ThisYear);
      End;
    End;
  end;
end;

function TAglDb.Index1_Years(APtr: Pointer): AnsiString;
begin
  if Tobject(APtr) is TAglYearRecord then
    Result := TAglYearRecord.IndexCode(TAglYearRecord(APtr).YearNo)
  else
    Result := '';
end;

function TAglDb.Index2_Months(APtr: Pointer): AnsiString;
begin
  if Tobject(APtr) is TAglMonthRecord then
    Result := TAglMonthRecord.IndexCode(TAglMonthRecord(APtr).YearNo,
      TAglMonthRecord(APtr).MonthNo)
  else
    Result := '';
end;

function TAglDb.Index3_Days(APtr: Pointer): AnsiString;
begin
  if Tobject(APtr) is TAglDailyRecord then
    Result := TAglDailyRecord.IndexCode(TAglDailyRecord(APtr).YearNo,
      TAglDailyRecord(APtr).MonthNo, TAglDailyRecord(APtr).DayNo)
  else
    Result := '';
end;

function TAglDb.LastDate: TDateTime;
Var
  ThisYear, ThisMonth, ThisDay: Word;
  // YearObj:TAglYearRecord;
  MonthObj: TAglMonthRecord;
begin
  DecodeDate(Now, ThisYear, ThisMonth, ThisDay);
  MonthObj := MonthRecord(ThisYear, ThisMonth, False);
  while (MonthObj = nil) And (ThisYear > 2000) do
  Begin
    MonthObj := MonthRecord(ThisYear, ThisMonth, False);
    if MonthObj = nil then
    Begin
      Dec(ThisMonth);
      If ThisMonth < 1 Then
      Begin
        ThisMonth := 12;
        Dec(ThisYear);
      End;
    End;
  End;
  if MonthObj <> nil then
    Result := MonthObj.LastDate
  else
    Result := Now - 90;
end;

procedure TAglDb.LoadIndexs;
begin
  inherited;
  AddIndex(Index1_Years, idx1);
  AddIndex(Index2_Months, idx2);
  AddIndex(Index3_Days, idx3);
end;

function TAglDb.MonthRecord(AYear, AMonth: integer; ACreate: Boolean)
  : TAglMonthRecord;
Var
  Index: AnsiString;
begin
  Index := TAglMonthRecord.IndexCode(AYear, AMonth);
  Result := TAglMonthRecord(ReadFileObjectBySecondaryIndex(index, idx2, true,
    False, TAglMonthRecord));
  if Result = nil then
    Result := TAglMonthRecord(ReadFileObjectBySecondaryIndex(index, idx3, true,
      true, TAglMonthRecord));
  if (Result = nil) and ACreate then
  Begin
    Result := TAglMonthRecord.Create(nil, nil);
    Result.YearNo := AYear;
    Result.MonthNo := AMonth;
    WriteIndexedObject(Result);
  End;
end;

function TAglDb.YearRecord(AYear: integer; AForceCreate: Boolean)
  : TAglYearRecord;
Var
  IndexStr: AnsiString;

begin
  IndexStr := IntToStr(AYear) + '|-';
  Result := TAglYearRecord(ReadFileObjectBySecondaryIndex(IndexStr, idx1, true,
    False, TAglYearRecord));

  if Result = nil then
    Result := TAglYearRecord(ReadFileObjectBySecondaryIndex(IndexStr, idx1,
      true, true, TAglYearRecord));

  if (Result = nil) and AForceCreate then
  Begin
    Result := TAglYearRecord.Create(nil, nil);
    Result.YearNo := AYear;
    WriteIndexedObject(Result);
  End;
end;

{ TAglYearRecord }

destructor TAglYearRecord.Destroy;
begin
  FreeAndNil(FListOfMonths);
  inherited;
end;

class function TAglYearRecord.IndexCode(AYear: integer): String;
begin
  Result := IntToStr(AYear) + '|-';
end;

function TAglYearRecord.ListOfMonths: TStringList;
begin
  if FListOfMonths = nil then
  begin
    FListOfMonths := TStringList.Create;
    FListOfMonths.Sorted := False;
    FListOfMonths.Duplicates := dupAccept;
  end;
  Result := FListOfMonths;
end;

procedure TAglYearRecord.Load(var s: Tstream);
begin
  inherited;
  s.Read(YearNo, SizeOf(YearNo));
  ReadStrmListAsIntegers(s, ListOfMonths);
end;

function TAglYearRecord.MonthRecord(AMonth: integer): TAglMonthRecord;
var
  MonthIndex: integer;
begin
  Result := nil;
  MonthIndex := AMonth - 1;
  if MonthIndex > 11 then
    raise Exception.Create('Month too great:' + IntToStr(AMonth));
  while ListOfMonths.Count < (AMonth) do
    FListOfMonths.Add(TAglMonthRecord.StringDescripter(YearNo,
      ListOfMonths.Count));
  if FListOfMonths.Objects[MonthIndex] <> nil then
    Result := DbFileRef.ReadFOByIndexASClass(FListOfMonths.Objects[MonthIndex],
      TAglMonthRecord);

  if Result = nil then
  Begin
    Result := TAglDb(DbFileRef).MonthRecord(YearNo, AMonth, true);
    if Result = nil then
    begin
      Result := TAglMonthRecord.Create(nil, nil);
      Result.YearNo := YearNo;
      Result.MonthNo := AMonth;
      DbFileRef.WriteIndexedObject(Result);
    end;
    FListOfMonths.Objects[MonthIndex] := Tobject(Result.Index);
    SaveToDb;
  End;
end;

procedure TAglYearRecord.PopulateYearChartSeries(AYearDataGen,
  AYearDataCon: TChartSeries; ASelectionRec: TSelectionRecord);
Var
  i: integer;
  ThisMonth: TAglMonthRecord;
begin
  if FListOfMonths = nil then
    exit;
  for i := 0 to FListOfMonths.Count - 1 do
  Begin
    if FListOfMonths.Objects[i] <> nil then
      ThisMonth := DbFileRef.ReadFOByIndexASClass(FListOfMonths.Objects[i],
        TAglMonthRecord)
    else
      ThisMonth := nil;

    if ThisMonth <> nil then
      ThisMonth.PopulateMonthChartSeries(AYearDataGen, AYearDataCon,
        ASelectionRec);
  End;
end;

procedure TAglYearRecord.PopulateYearMonthChartSeries(ADataSeries: TChartSeries;
  ATotals, ASelectControledLoad: Boolean; ASelectionRec: TSelectionRecord);
Var
  i: integer;
  ThisMonth: TAglMonthRecord;
begin
  if FListOfMonths = nil then
    exit;
  for i := 0 to FListOfMonths.Count - 1 do
  Begin
    if FListOfMonths.Objects[i] <> nil then
      ThisMonth := DbFileRef.ReadFOByIndexASClass(FListOfMonths.Objects[i],
        TAglMonthRecord)
    else
      ThisMonth := nil;

    if ThisMonth <> nil then
      ThisMonth.PopulateMonthTotalValueChartSeries(ADataSeries, ATotals,
        ASelectControledLoad, ASelectionRec);
  End;
end;

function TAglYearRecord.StartDate: TDateTime;
begin
  Result := EncodeDate(YearNo, 1, 1);
end;

procedure TAglYearRecord.Store(var s: Tstream);
begin
  inherited;
  s.Write(YearNo, SizeOf(YearNo));
  WriteStrmListAsIntegers(s, ListOfMonths);
end;

class function TAglYearRecord.StringDescripter(AYear: integer): String;
begin
  Result := IntToStr(AYear);
end;

{ TAglMonthRecord }

function TAglMonthRecord.DayRecord(ADay: integer; ACreate: Boolean)
  : TAglDailyRecord;
var
  DayIndex: integer;
begin
  Result := nil;
  DayIndex := ADay - 1;
  if DayIndex > 30 then
    raise Exception.Create('Days too great:' + IntToStr(ADay));
  while ListOfDays.Count < (ADay) do
    FListOfDays.Add(TAglDailyRecord.IndexDescripter(YearNo, MonthNo,
      ListOfDays.Count));
  if FListOfDays.Objects[DayIndex] <> nil then
    Result := DbFileRef.ReadFOByIndexASClass(FListOfDays.Objects[DayIndex],
      TAglDailyRecord);

  if (Result = nil) and ACreate then
  Begin
    Result := TAglDb(DbFileRef).DayRecord(YearNo, MonthNo, ADay, true);
    if Result = nil then
    begin
      Result := TAglDailyRecord.Create(nil, nil);
      Result.YearNo := YearNo;
      Result.MonthNo := MonthNo;
      Result.DayNo := ADay;
      DbFileRef.WriteIndexedObject(Result);
    end;
    FListOfDays.Objects[DayIndex] := Tobject(Result.Index);
    SaveToDb;
  End;
end;

destructor TAglMonthRecord.Destroy;
begin
  FreeAndNil(FListOfDays);
  inherited;
end;

function TAglMonthRecord.FirstDay: TAglDailyRecord;
Var
  DayIndex: integer;
begin
  DayIndex := 0;
  Result := nil;
  if FListOfDays.Count > 0 then
    Result := DbFileRef.ReadFileObjectByIndex(FListOfDays.Objects[0]);
  while (Result = nil) and (DayIndex < FListOfDays.Count) do
  Begin
    inc(DayIndex);
    Result := DbFileRef.ReadFileObjectByIndex(FListOfDays.Objects[DayIndex]);
  End;
end;

function TAglMonthRecord.StartDate: TDateTime;
begin
  Result := EncodeDate(YearNo, MonthNo, 1);
end;

procedure TAglMonthRecord.Store(var s: Tstream);
begin
  inherited;
  s.Write(YearNo, SizeOf(YearNo));
  s.Write(MonthNo, SizeOf(MonthNo));
  WriteStrmListAsIntegers(s, ListOfDays);
end;

class function TAglMonthRecord.StringDescripter(AYear, AMonth: integer): String;
begin
  Result := IntToStr(AYear) + ' Month=' + IntToStr(AMonth);
end;

function TAglMonthRecord.TotalControlledUsage: single;
begin
  If FTotalGeneralUsage < 0.000000000000000000001 then
    TotalGeneralUsage;
  Result := FTotalControlledUsage;
end;

function TAglMonthRecord.TotalGeneralUsage: single;
Var
  i: integer;
  Day: TAglDailyRecord;
begin
  If FTotalGeneralUsage < 0.000000000000000000001 then
    for i := 0 to ListOfDays.Count - 1 do
      if FListOfDays.Objects[i] <> nil then
      Begin
        Day := DbFileRef.ReadFOByIndexASClass(FListOfDays.Objects[i],
          TAglDailyRecord);
        if Day <> nil then
        Begin
          FTotalGeneralUsage := FTotalGeneralUsage + Day.TotalGeneralUsage;
          FTotalControlledUsage := FTotalControlledUsage +
            Day.TotalControlledUsage;
        End;
      End;
  Result := FTotalGeneralUsage;
end;

function TAglMonthRecord.TotalMonthUsage: single;
begin
  Result := TotalControlledUsage + TotalGeneralUsage;
end;

class function TAglMonthRecord.IndexCode(AYear, AMonth: integer): String;
begin
  Result := IntToStr(AYear) + '|' + IntToStr(AMonth) + '|-';
end;

function TAglMonthRecord.LastDate: TDateTime;
begin
  if (FListOfDays = nil) or (FListOfDays.Count < 1) then
    Result := EncodeDate(YearNo, MonthNo, 1)
  Else
    Result := EncodeDate(YearNo, MonthNo, FListOfDays.Count);
end;

function TAglMonthRecord.ListOfDays: TStringList;
begin
  if FListOfDays = nil then
  begin
    FListOfDays := TStringList.Create;
    FListOfDays.Sorted := False;
    FListOfDays.Duplicates := dupAccept;
  end;
  Result := FListOfDays;
end;

procedure TAglMonthRecord.Load(var s: Tstream);
begin
  inherited;
  s.Read(YearNo, SizeOf(YearNo));
  s.Read(MonthNo, SizeOf(MonthNo));
  ReadStrmListAsIntegers(s, ListOfDays);
end;

procedure TAglMonthRecord.PopulateDailyTotalValueChartSeries
  (ADataSeries: TChartSeries; ATotals, ASelectControledLoad: Boolean;
  ASelectionRec: TSelectionRecord);
Var
  ThisDay: TAglDailyRecord;
  i: integer;
begin
  i := 0;
  while i < 31 do
  Begin
    inc(i);
    ThisDay := DayRecord(i, False);
    if ThisDay <> nil then
      ThisDay.PopulateDayTotalValueChartSeries(ADataSeries, ATotals,
        ASelectControledLoad, ASelectionRec);
  end;
end;

procedure TAglMonthRecord.PopulateMonthChartSeries(AMonthDataGen,
  AMonthDataCon: TChartSeries; ASelectionRec: TSelectionRecord);
Var
  i: integer;
  ThisDay: TAglDailyRecord;
begin
  if FListOfDays = nil then
    exit;
  for i := 0 to FListOfDays.Count - 1 do
  Begin
    if FListOfDays.Objects[i] <> nil then
      ThisDay := DbFileRef.ReadFOByIndexASClass(FListOfDays.Objects[i],
        TAglDailyRecord)
    Else
      ThisDay := nil;
    if ThisDay <> nil then
      ThisDay.PopulateDayChartSeries(AMonthDataGen, AMonthDataCon,
        ASelectionRec);
  End;
end;

procedure TAglMonthRecord.PopulateMonthTotalValueChartSeries
  (ADataSeries: TChartSeries; ATotals, ASelectControledLoad: Boolean;
  ASelectionRec: TSelectionRecord);

Var
  DateRef: TDateTime;
  // LDay, LMonth, LYear: Word;
  // RDay, RMonth, RYear: Word;
  YValue: single;
  // s: String;

begin
  Try
    DateRef := ASelectionRec.RefDateOffset(EncodeDate(YearNo, MonthNo,
      15), 0.0);
    if ATotals then
      YValue := TotalMonthUsage
    Else if ASelectControledLoad then
      YValue := TotalControlledUsage
    Else
      YValue := TotalGeneralUsage;
    ADataSeries.AddXY(DateRef, YValue);
  Except
    DateRef := EncodeDate(YearNo, MonthNo, 15);
  End;
end;

{ TAglDailyRecord }

destructor TAglDailyRecord.Destroy;
begin
  FreeAndNil(FMeterRecs);
  inherited;
end;

procedure TAglDailyRecord.DoCalcFields;
begin
  Try
    FDate := EncodeDate(YearNo, MonthNo, DayNo);
    FDayOfWeek := DayOfWeek(FDate);
  Except
    FDayOfWeek := 0;
  End;
end;

class function TAglDailyRecord.IndexCode(AYear, AMonth, ADay: integer): String;
begin
  Result := IntToStr(AYear) + '|' + IntToStr(AMonth) + '|' +
    IntToStr(ADay) + '|-'
end;

class function TAglDailyRecord.IndexDescripter(AYear, AMonth,
  ADay: integer): String;
begin
  Result := IntToStr(AYear) + ' ' + IntToStr(ADay) + ' ' + MonthCode(AMonth);
end;

function TAglDailyRecord.ListDescripter: String;
begin
  Result := IndexDescripter(YearNo, MonthNo, DayNo);
end;

procedure TAglDailyRecord.Load(var s: Tstream);

begin
  inherited;
  s.Read(YearNo, SizeOf(YearNo));
  s.Read(MonthNo, SizeOf(MonthNo));
  s.Read(DayNo, SizeOf(DayNo));
  FMeterRecs := ReadStrmObject(s, self);
  FDeviceNumber := ReadStrmAnsiString(s);
  FDeviceType := ReadStrmAnsiString(s);
  FAccountNumber := ReadStrmAnsiString(s);
  FNMI := ReadStrmAnsiString(s);
  DoCalcFields;
end;

function TAglDailyRecord.NextDay: TAglDailyRecord;
Var
  Db: TAglDb;
  NxtDay: TDateTime;
  LYear, LMonth, LDay: Word;

begin
  Result := nil;
  Try
    Db := DbFileRef as TAglDb;
    if Db = nil then
      exit;
    DecodeDate(StartDate + 1, LYear, LMonth, LDay);
    Result := Db.DayRecord(LYear, LMonth, LDay, False);
  Except
    Result := nil;
  End;
end;

procedure TAglDailyRecord.PopulateDayChartSeries(ADayDataGen,
  ADayDataCon: TChartSeries; ASelectionRec: TSelectionRecord;
  ATotals: Boolean = False);
begin
  if FDayOfWeek < 1 then
    DoCalcFields;

  if FDayOfWeek < 1 then
    exit;

  if ASelectionRec.SelectDays then
    if not ASelectionRec.DaysOfWeek[FDayOfWeek] then
      exit;

  if ASelectionRec.NoLabelsOnDays[DayNo] then
    ASelectionRec.ShowLabel := False;

  if FMeterRecs <> nil then
    FMeterRecs.PopulateChartSeries(ADayDataGen, ADayDataCon,
      ASelectionRec, ATotals);
end;

procedure TAglDailyRecord.PopulateDayTotalValueChartSeries
  (ADataSeries: TChartSeries; ATotals, ASelectControledLoad: Boolean;
  ASelectionRec: TSelectionRecord);
Var
  Total: Double;
  Lbl: string;
begin
  if ASelectionRec.ShowLabel then
    Lbl := FormatDateTime('mm dd', FDate)
  else
    Lbl := '';
  if ATotals then
    Total := TotalDayUsage
  else if ASelectControledLoad then
    Total := TotalControlledUsage
  else
    Total := TotalGeneralUsage;
  ADataSeries.AddXY(ASelectionRec.RefDateOffset(StartDate, 0.5), Total, Lbl)
end;

function TAglDailyRecord.PrevDay: TAglDailyRecord;
Var
  Db: TAglDb;
  NxtDay: TDateTime;
  LYear, LMonth, LDay: Word;

begin
  Result := nil;
  Try
    Db := DbFileRef as TAglDb;
    if Db = nil then
      exit;
    DecodeDate(StartDate - 1, LYear, LMonth, LDay);
    Result := Db.DayRecord(LYear, LMonth, LDay, False);
  Except
    Result := nil;
  End;
end;

function TAglDailyRecord.ResidentsOnHoliday(var ARunningAverage: Double;
  var ANoOfSamples: integer): Boolean;
// If we have a running average and this days general usage is less than 20% assume holiday
Var
  LTotalGeneralUsage: Double;
begin
  inc(ANoOfSamples);
  LTotalGeneralUsage := TotalGeneralUsage;
  if ANoOfSamples < 2 then
    ARunningAverage := LTotalGeneralUsage
  else
    ARunningAverage := ARunningAverage + (LTotalGeneralUsage - ARunningAverage)
      / ANoOfSamples;
  if ANoOfSamples < 20 then
    Result := False
  else
    Result := LTotalGeneralUsage < 0.2 * ARunningAverage;
end;

function TAglDailyRecord.StartDate: TDateTime;
begin
  Result := EncodeDate(YearNo, MonthNo, DayNo);
end;

procedure TAglDailyRecord.Store(var s: Tstream);
begin
  inherited;
  s.Write(YearNo, SizeOf(YearNo));
  s.Write(MonthNo, SizeOf(MonthNo));
  s.Write(DayNo, SizeOf(DayNo));
  WriteStrmObject(s, FMeterRecs);
  WriteStrmString(s, FDeviceNumber);
  WriteStrmString(s, FDeviceType);
  WriteStrmString(s, FAccountNumber);
  WriteStrmString(s, FNMI);
end;

function TAglDailyRecord.TotalControlledUsage: single;
begin
  If FTotalGeneralUsage < 0.000000000000000000001 then
    TotalGeneralUsage;
  Result := FTotalControlledUsage
end;

function TAglDailyRecord.TotalDayUsage: single;
begin
  Result := TotalControlledUsage + TotalGeneralUsage;
end;

function TAglDailyRecord.TotalGeneralUsage: single;
begin
  If FTotalGeneralUsage < 0.000000000000000000001 then
    if FMeterRecs <> nil then
    Begin
      FTotalGeneralUsage := FMeterRecs.TotalGeneralUsage;
      FTotalControlledUsage := FMeterRecs.TotalControlledUsage;
    End;
  Result := FTotalGeneralUsage;
end;

// function TAglDailyRecord.TotalMonthUsage: single;
// begin
// Result := TotalGeneralUsage + TotalControlledUsage;
// end;

function TAglDailyRecord.UpdateWith(AUpdate: TAglMeterPeriod): Boolean;
begin
  Result := true;
  AUpdate.FOwnerList := self;
  AUpdate.FOwner := nil;
  Try
    if FMeterRecs = nil then
      FMeterRecs := AUpdate
    Else
      FMeterRecs.AddOrUpdate(AUpdate, FMeterRecs);
  Except
    Result := False;
  End;
end;

{ TAglMeterPeriod }

procedure TAglMeterPeriod.AddOrUpdate(ANew: TAglMeterPeriod;
  var AListRoot: TAglMeterPeriod);
begin
  if ANew = nil then
    exit;
  ANew.FOwnerList := FOwnerList;

  Case CompareValue(ANew.FStartTime, FStartTime, 0.00000000000001) of
    - 1 { LessThanValue } :
      Begin
        // put before
        ANew.FNext := self;
        ANew.FPrev := FPrev;
        if FPrev = nil then
          if AListRoot = self then
          Begin
            AListRoot := ANew;
            ANew.FOwner := nil;
            FOwner := ANew;
          End
          else
            raise Exception.Create('Error Message AddOrUpdate');
        FPrev := ANew;
      End;
    0 { EqualsValue } :
      begin // Match
        UpdateAndFree(ANew);
      end;
    1 { GreaterThanValue } :
      if FNext = nil then
      Begin
        ANew.FOwner := self;
        ANew.FPrev := self;
        FNext := ANew;
      End
      else
        FNext.AddOrUpdate(ANew, AListRoot);
  End;

end;

class function TAglMeterPeriod.CreateFromDate(AStartDate, AEndDate: AnsiString)
  : TAglMeterPeriod;
Var
  StartDate, EndDate, Period: TDateTime;
begin
  Result := nil;
  StartDate := AGLDecodeDate(AStartDate);
  EndDate := AGLDecodeDate(AEndDate);
  Period := EndDate - StartDate;
  if not((Period > 0.0000000001) and (Period < (1 / 12))) then
  Begin
    EndDate := StartDate + 1 / 49;
    Period := EndDate - StartDate;
  End;

  if (Period > 0.0000000001) and (Period < (1 / 12)) then
  Begin
    Result := TAglMeterPeriod.Create(nil, nil);
    Result.FStartdate := Trunc(StartDate);
    Result.FStartTime := StartDate - Result.FStartdate;
    Result.FEndTime := EndDate - Result.FStartdate;
    Result.FPeriod := Period;
  End;
end;

class function TAglMeterPeriod.AGLDecodeDate(ADate: AnsiString): TDateTime;
// Var
// DayData, TimeData: TArrayOfAnsiStrings;
// Error: String;
begin
  // Try
  Result := StrToDateTime(ADate);
  {
    TimeData:=GetArrayFromString(ADate,' ',false,false);
    if length(TimeData)=2 then
    Begin
    DayData:=GetAnsiArrayFromString(TimeData[0],'/');
    TimeData:=GetAnsiArrayFromString(TimeData[1],':')
    End;
    Result:=TDateTime(Now); }
  // Except
  // On E:Exception do
  // Begin
  // Error:=e.Message;
  // Result:=Now;
  // End;
  // End;
end;

destructor TAglMeterPeriod.Destroy;
begin
  FreeAndNil(FNext);
  inherited;
end;

procedure TAglMeterPeriod.Load(var s: Tstream);
begin
  inherited;
  s.Read(FGeneralUsage, SizeOf(FGeneralUsage));
  s.Read(FControledLoad, SizeOf(FControledLoad));
  s.Read(FStartdate, SizeOf(FStartdate));
  s.Read(FStartTime, SizeOf(FStartTime));
  s.Read(FEndTime, SizeOf(FEndTime));
  s.Read(FPeriod, SizeOf(FPeriod));
  FNext := ReadStrmObject(s, FOwnerList);
  if FNext <> nil then
    FNext.FPrev := self;
end;

procedure TAglMeterPeriod.PopulateChartSeries(ADataGen, ADataCon: TChartSeries;
  ASelectionRec: TSelectionRecord; ATotals: Boolean);
Var
  DateRef: TDateTime;
  LGenValue: single;
  LDay, LMonth, LYear: Word;
  RDay, RMonth, RYear: Word;
  s: String;
begin
  Try
    DateRef := ASelectionRec.RefDateOffset(FStartdate, FStartTime) +
      FPeriod / 2;
    DecodeDate(FStartdate, LYear, LMonth, LDay);
    // if DayOfWeek(FStartdate) <> DayOfWeek(DateRef) then
    // Begin
    // s := Formatdatetime('dddd dd/mm/yy   ', FStartdate) + ' Ref: ' +
    // Formatdatetime('dddd dd/mm/yy   ', DateRef);
    // End;
    if ATotals then
      LGenValue := FGeneralUsage + FControledLoad
    else
      LGenValue := FGeneralUsage;
    If Not SameValue(ASelectionRec.RefDateOffsetPre, 0.0, 0.000001) Then
      if (LMonth = 1) and (LDay = 1) then
        Try
          DecodeDate(DateRef, RYear, RMonth, RDay);
          If (RMonth = 12) then
          Begin
            DateRef := EncodeDate(RYear + 1, 1, 1);
            if (ADataCon <> nil) then
              ADataCon.AddXY(DateRef, 0.0);
            if (ADataGen <> nil) then
              ADataGen.AddXY(DateRef, 0.0);
            if FNext <> nil then
              FNext.PopulateChartSeries(ADataGen, ADataCon,
                ASelectionRec, ATotals);
            exit;
          End
        Except
          On E: Exception do
          Begin
            s := E.Message;
            exit;
          End;
        End;

    if (ADataGen <> nil) { and (FGeneralUsage > 0.000000000000001) } then
    begin
      if (SameValue(FStartTime, 0.5, 0.0000001)) and ASelectionRec.ShowLabel
      then
        ADataGen.AddXY(DateRef, LGenValue, FormatDateTime('d', FStartdate))
      else
        ADataGen.AddXY(DateRef, LGenValue);
    end;

    if (ADataCon <> nil) and Not(Not(ADataCon is TLineSeries) and
      (FControledLoad < 0.000000000000001)) then
      ADataCon.AddXY(DateRef, FControledLoad);

    if FNext <> nil then
      FNext.PopulateChartSeries(ADataGen, ADataCon, ASelectionRec, ATotals)
    Else If Not SameValue(ASelectionRec.RefDateOffsetPre, 0.0, 0.0001) then
      if FStartTime > (1 - 1 / 23) then
      Begin
        // DecodeDate(FStartdate, LYear, LMonth, LDay);
        If (LMonth = 12) and (LDay = 31) then
        Begin
          if (ADataCon <> nil) then
            ADataCon.AddXY(DateRef + 0.00001, 0.0);
          if (ADataGen <> nil) then
            ADataGen.AddXY(DateRef + 0.00001, 0.0);
        End;
      End;
  Except
    DateRef := FStartdate + FPeriod / 2;
  End;
end;

procedure TAglMeterPeriod.Store(var s: Tstream);
begin
  inherited;
  s.Write(FGeneralUsage, SizeOf(FGeneralUsage));
  s.Write(FControledLoad, SizeOf(FControledLoad));
  s.Write(FStartdate, SizeOf(FStartdate));
  s.Write(FStartTime, SizeOf(FStartTime));
  s.Write(FEndTime, SizeOf(FEndTime));
  s.Write(FPeriod, SizeOf(FPeriod));
  WriteStrmObject(s, FNext);
end;

function TAglMeterPeriod.TotalControlledUsage: single;
begin
  if FNext <> nil then
    Result := FNext.TotalControlledUsage + FControledLoad
  else
    Result := FControledLoad;
end;

function TAglMeterPeriod.TotalGeneralUsage: single;
begin
  if FNext <> nil then
    Result := FNext.TotalGeneralUsage + FGeneralUsage
  else
    Result := FGeneralUsage;
end;

// function TAglMeterPeriod.TotalMonthUsage: single;
// begin
// Result := TotalGeneralUsage + TotalControlledUsage;
// end;

procedure TAglMeterPeriod.UpdateAndFree(Var ANew: TAglMeterPeriod);
begin
  if ANew = nil then
    exit;
  Try
    Case CompareValue(ANew.FEndTime, FEndTime, 0.00000000000001) of
      - 1 { LessThanValue } :
        Begin
          // ignore
          raise Exception.Create('Error Message TAglMeterPeriod.UpdateAndFree');
        End;
      0 { EqualsValue } :
        begin // Match
          if CompareValue(ANew.FGeneralUsage, FGeneralUsage,
            0.00000000000001) > 0 Then
            FGeneralUsage := ANew.FGeneralUsage;
          if CompareValue(ANew.FControledLoad, FControledLoad,
            0.00000000000001) > 0 Then
            FControledLoad := ANew.FControledLoad;
          FreeAndNil(ANew);
        end;
      1 { GreaterThanValue } :
        Begin
          // ignore
          raise Exception.Create('Error Message TAglMeterPeriod.UpdateAndFree');
        End;

    End;
  Finally
    if ANew <> nil then
      FreeAndNil(ANew)
  End;
end;

{ TTestLineSeries }

constructor TTestLineSeries.Create(AOwner: TComponent);
begin
  inc(CountOfLineSeries);
  inherited Create(AOwner);
end;

destructor TTestLineSeries.Destroy;
begin
  Dec(CountOfLineSeries);
  if not(owner = nil) then // Testing for destroy
    if (owner = nil) then // Testing for destroy
      SeriesColor := 0;
  inherited;
end;

{ TSelectionRecord }

function TSelectionRecord.RefDateOffset(AStartDate, AStartTime: TDateTime)
  : TDateTime;
Var
  Year, Month, Day: Word; // for debugging
begin
  DecodeDate(AStartDate, Year, Month, Day);
  if AStartDate < ChgOverDate then
    Result := AStartDate + RefDateOffsetPre + AStartTime
  Else
    Result := AStartDate + RefDateOffsetPost + AStartTime;
  DecodeDate(Result, Year, Month, Day);
end;

function TSelectionRecord.SetOffsetToDay(ARefDay: TDateTime;
  AYearOfOffset: integer; ABarOffsetPre, ABarOffsetPost: Double): TDateTime;
// Returns date of Matching day (eg Monday) in year of offset and sets up the Record
Var
  LYear, LMonth, LDay: Word;
  LFirstDay: integer;
  TestDate: TDateTime;
begin
  LFirstDay := DayOfWeek(ARefDay);
  DecodeDate(ARefDay, LYear, LMonth, LDay);
  Result := ARefDay;
  if AYearOfOffset <> LYear then
  Begin
    TestDate := EncodeDate(AYearOfOffset, LMonth, LDay) - 3;
    while DayOfWeek(TestDate) <> LFirstDay do
      TestDate := TestDate + 1;
    Result := TestDate;
  End;
  RefDateOffsetPre := ARefDay - Result;
  RefDateOffsetPost := ARefDay - Result; // ??????????? never go there
  ChgOverDate := Result + 20;

  RefDateOffsetPost := RefDateOffsetPost + ABarOffsetPost;
  RefDateOffsetPre := RefDateOffsetPre + ABarOffsetPre;
end;

procedure TSelectionRecord.SetOffsetToYear(ARefDate: TDateTime; AYear: integer;
  ABarOffsetPre, ABarOffsetPost: Double);
Var
  LYear, LMonth, LDay: Word;
  LFirstDay: integer;
  LYearStartPre, LYearStartPost, StartOfScanYear: TDateTime;
  OffsetIsNotDays: Boolean;
begin
  DecodeDate(ARefDate, LYear, LMonth, LDay);
  OffsetIsNotDays := (Abs(ABarOffsetPre) < 1) and (Abs(ABarOffsetPost) < 1);
  if (LYear < AYear) or ((LYear = AYear) and (LMonth = 1)) then
  Begin
    RefDateOffsetPost := ABarOffsetPost;
    RefDateOffsetPre := ABarOffsetPre;
    // ChgOverDate := EncodeDate(LYear+1, LMonth, LDay);//ARefDate+365;
    ChgOverDate := EncodeDate(AYear + 1, LMonth, LDay);
  End
  Else
  Begin
    StartOfScanYear := EncodeDate(LYear, 1, 1);
    LFirstDay := DayOfWeek(StartOfScanYear);
    // if (LYear = AYear) or ((LYear - AYear = 1) and (LMonth = 1)) then
    // RefDateOffsetPre := 0
    // else
    // Begin
    if OffsetIsNotDays then // If Offset is in days Day does not matter
    begin
      LYearStartPre := EncodeDate(AYear - 1, 1, 1) - 4;
      while DayOfWeek(LYearStartPre) <> LFirstDay do
        LYearStartPre := LYearStartPre + 1;
    End
    Else
    Begin
      LYearStartPre := EncodeDate(AYear - 1, 1, 1);
      if ((AYear - 1) Mod 4) = 0 then
        LYearStartPre := LYearStartPre + 1;
    End;
    RefDateOffsetPre := StartOfScanYear - LYearStartPre;

    if OffsetIsNotDays then // If Offset is in days Day does not matter
    Begin
      ChgOverDate := EncodeDate(AYear, LMonth, LDay) - 4;
      LYearStartPost := EncodeDate(AYear, 1, 1) - 4;
      while DayOfWeek(LYearStartPost) <> LFirstDay do
      Begin
        LYearStartPost := LYearStartPost + 1;
        // LYearStartPost := LYearStartPost + 1;
        ChgOverDate := ChgOverDate + 1;
      End;
    End
    Else
    Begin
      ChgOverDate := EncodeDate(AYear, LMonth, LDay);
      LYearStartPost := EncodeDate(AYear, 1, 1);
      if (AYear Mod 4) = 0 then
        LYearStartPost := LYearStartPost + 1;
    end;
    RefDateOffsetPost := StartOfScanYear - LYearStartPost;

    // Now offset bars by 10 minutes so they do not overlay
    // OffsetYears:=AYear-Lyear;
    // OffsetYears := LYear - AYear + 1;
    // if (Offsetyears mod 2)=0 then
    // Begin
    // RefDateOffsetPost:=RefDateOffsetPost+1/24/60/6*Offsetyears;
    // RefDateOffsetPre:=RefDateOffsetPre+1/24/60/6*Offsetyears;
    // End
    // else
    // Begin
    RefDateOffsetPost := RefDateOffsetPost + ABarOffsetPost;
    RefDateOffsetPre := RefDateOffsetPre + ABarOffsetPre;
    // End;

  End;
end;

procedure TSelectionRecord.SetUp(ASelectDays, AShowLabel: Boolean);
begin
  SelectDays := ASelectDays;
  ShowLabel := AShowLabel;
  ResetArray(DaysOfWeek);
  ResetArray(NoLabelsOnDays);
  RefDateOffsetPre := 0.0;
  RefDateOffsetPost := 0.0;
  ChgOverDate := 0.0;
end;

Initialization

RegPersistentClasses([TAglMeterPeriod, TAglDailyRecord, TAglMonthRecord,
  TAglYearRecord]);

Finalization

FreeAndNil(SingletonAgl);

end.
