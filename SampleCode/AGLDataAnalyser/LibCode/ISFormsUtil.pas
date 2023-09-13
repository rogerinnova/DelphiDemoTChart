unit ISFormsUtil;

{ See Also ISStayOnTopBaseForm }
{ Usage Notes
  Do Not Create a TApplicationFormUtil but always use
  ApplicationFormUtil.Function

  If you wish to specify tile area use
  ApplicationFormUtil.LimitTileArea(......);
  otherwise tile area is the whole screen.

  Add Form classes you do not want Tiled etc to
  ApplicationFormUtil.AddNonTileClass(TMyClass);

  Suggest you put it in the initialization section of the form unit.

  initialization
  ApplicationFormUtil.AddNonTileClass(TStayOnTop);

  The two form classes in this unit can be used if the form needs some action
  when redrawn. It is genenerally not necessary if you use appropriate alignment
  and/or anchors.

  If you are using a stay on top form which is NOT the Main Form then you
  need to inherit from the TFormsUtilsMainBase
  //Do any way 3/8/2009 and add the stay on top to  fStayOnTop///
  or add similar Winprocs code to your form.

  To use these UtlsBases create the form as per normal then replace the
  definition of the form

  Type
  TMyForm = class(TForm)
  ...
  ...
  end;

  in the pas file only
  with either
  TMyForm = class(TFormUtlsBase)
  OR
  TMyForm = class(TFormUtlsMainBase)

  Tile will pick up all forms owned by the application or application forms
  even if they are not currently visable.

  To make sure forms stay closed when closed use
  OnClose Event and set Action to caFree.

  RescaleForm
}
interface

uses Forms, Windows, Messages, sysutils, classes;

type
  TApplicationFormUtil = class(Tobject)
  private
    FListNonTileable: TStringList;
    FTileLeft, FTileTop, FTileWidth, FTileHeight: integer;
    FToggleRestore, FInMinimise: Boolean;
    FMainForm: TComponent;
    procedure DisplayForm(AForm: Tobject;
      ALeftX, ATopY, AHeight, AWidth: integer);
    function ListNonTileable: TStringList;
    procedure FindAllTilableForms(AFormComponent: TComponent; AList: Tlist);
  public
    constructor Create;
    destructor Destroy; override;
    procedure AddNonTileClass(AForm: TFormClass);
    procedure LimitTileArea(ALeft, ATop, AWidth, AHeight: integer);
    procedure MinimizeAll(AConsiderToggle: Boolean = false);
    // Use a toggle if you want to minmise/restore/minimise with same call
    procedure RestoreAll;
    procedure ShowMain(AForceMaximise: Boolean = false);
    procedure TileForms;
    procedure CascadeForms(KeepWidth: Boolean = false;
      KeepHeight: Boolean = false);
  end;

  TFormsUtlsBase = class(TForm)
  public
    procedure ReScaleForm; virtual; abstract;
  end;

  TFormsUtlsMainBase = class(TFormsUtlsBase)
  protected
    // fStayOnTop: TForm;  //Do any way 3/8/2009
    procedure WndProc(var message: TMessage); override;
  public
    procedure ReScaleForm; override;
  end;

function ApplicationFormUtil: TApplicationFormUtil;

implementation

var
  PrvtApplicationFormUtil: TApplicationFormUtil;

function ApplicationFormUtil: TApplicationFormUtil;
begin
  if PrvtApplicationFormUtil = nil then TApplicationFormUtil.Create;
  // populates PrvtApplicationFormUtil
  Result := PrvtApplicationFormUtil;
end;

{ TApplicationFormUtil }

procedure TApplicationFormUtil.AddNonTileClass(AForm: TFormClass);
var
  i: integer;
begin
  i := ListNonTileable.IndexOf(AForm.classname);
  if i < 0 then FListNonTileable.Add(AForm.classname);
end;

procedure TApplicationFormUtil.CascadeForms(KeepWidth: Boolean = false;
  KeepHeight: Boolean = false);
var
  i, J, K, GrphHeight, GrphWidth: integer;
  Across, Down, DisplayMax, MainOffset: integer;
  ToCascade: Tlist;

begin
  ToCascade := Tlist.Create;
  try
    FindAllTilableForms(Application, ToCascade);
    DisplayMax := ToCascade.Count - 1;
    // mod 3/8/2009
    if (FMainForm = nil) or (ListNonTileable.IndexOf(FMainForm.classname) > -1)
    then MainOffset := 0
    else MainOffset := 1;

    if MainOffset > 0 then Inc(DisplayMax);
    if DisplayMax < 1 then Across := 1
    else Across := Round((FTileWidth / 2) / DisplayMax / 10);
    Down := 30;
    if KeepHeight then GrphHeight := 0
    else GrphHeight := FTileHeight - DisplayMax * Down;
    if KeepWidth then GrphWidth := 0
    else GrphWidth := FTileWidth - DisplayMax * Across;
    J := FTileTop - Down;
    K := FTileLeft - Across;

    // mod 3/8/2009
    if MainOffset > 0 then
    begin
      K := K + Across;
      J := J + Down;
      DisplayForm(FMainForm, K, J, GrphHeight, GrphWidth);
    end;
    for i := 0 to DisplayMax - MainOffset do
    // endmod 3/8/2009
    begin
      K := K + Across;
      J := J + Down;
      DisplayForm(ToCascade[i], K, J, GrphHeight, GrphWidth);
    end;
  finally
    ToCascade.Free;
  end;
end;

constructor TApplicationFormUtil.Create;
begin
  inherited;
  if PrvtApplicationFormUtil <> nil then
      raise Exception.Create('TApplicationFormUtil is a Singleton');
  PrvtApplicationFormUtil := self;

  FTileWidth := Screen.Width;
  FTileHeight := Screen.Height;
end;

destructor TApplicationFormUtil.Destroy;
begin
  FListNonTileable.Free;
  if self = PrvtApplicationFormUtil then PrvtApplicationFormUtil := nil;
  inherited;
end;

procedure TApplicationFormUtil.DisplayForm(AForm: Tobject;
  ALeftX, ATopY, AHeight, AWidth: integer);
var
  Frm: TForm;

begin
  if AForm is TForm then
  begin
    Frm := TForm(AForm);
    if Frm.WindowState <> wsNormal then // mod 3/8/2009
    begin
      Frm.Show;
      Frm.WindowState := wsNormal;
      Application.ProcessMessages;
    end;
    Frm.Left := ALeftX;
    Frm.Top := ATopY;
    if Frm.BorderStyle = bsSizeable then
    begin
      if AHeight > 0 then Frm.Height := AHeight;
      if AWidth > 0 then Frm.Width := AWidth;
    end;
    if Frm is TFormsUtlsBase then TFormsUtlsBase(Frm).ReScaleForm;
    Frm.Show;
  end;
end;

procedure TApplicationFormUtil.FindAllTilableForms(AFormComponent: TComponent;
  AList: Tlist);
var
  i: integer;
  FormObj: TComponent;
begin
  if not((AFormComponent is TCustomForm) or (AFormComponent is TApplication))
  then Exit;

  FToggleRestore := false;
  for i := 0 to AFormComponent.ComponentCount - 1 do
  begin
    FormObj := AFormComponent.Components[i];
    if FormObj is TCustomForm then
    begin // Mod 2/8/2009
      if (FMainForm <> FormObj) then
        if (FMainForm = nil) and (FormObj is TFormsUtlsMainBase) then
            FMainForm := FormObj
        else if (ListNonTileable.IndexOf(FormObj.classname) < 0) then
            AList.Add(FormObj); // \\Mod 2/8/2009
      FindAllTilableForms(FormObj, AList);
    end;
  end;

end;

procedure TApplicationFormUtil.LimitTileArea(ALeft, ATop, AWidth,
  AHeight: integer);
begin
  FTileLeft := ALeft;
  FTileTop := ATop;
  FTileWidth := AWidth;
  FTileHeight := AHeight;
end;

function TApplicationFormUtil.ListNonTileable: TStringList;
begin
  if FListNonTileable = nil then FListNonTileable := TStringList.Create;
  Result := FListNonTileable;
end;

procedure TApplicationFormUtil.MinimizeAll(AConsiderToggle: Boolean = false);
var
  i: integer;
  ToMove: Tlist;
  Frm: TCustomForm;
begin
  if FInMinimise then Exit;

  FInMinimise := true;
  try
    if AConsiderToggle and FToggleRestore then RestoreAll
      // FToggleRestore reset in  FindAllTilableForms
    else
    begin
      ToMove := Tlist.Create;
      try
        FindAllTilableForms(Application, ToMove);
        for i := ToMove.Count - 1 downto 0 do
        begin
          Frm := ToMove[i];
          if Frm is TForm then Frm.WindowState := wsMinimized;
        end;
        if FMainForm <> nil then // Mod 2/8/2009
            TForm(FMainForm).WindowState := wsMinimized;
      finally
        ToMove.Free;
      end;
      FToggleRestore := true;
    end;
    Application.Minimize;
  finally
    FInMinimise := false;
  end;
end;

procedure TApplicationFormUtil.RestoreAll;
var
  i: integer;
  ToMove: Tlist;
  Frm: TCustomForm;
begin
  ToMove := Tlist.Create;
  try
    FindAllTilableForms(Application, ToMove);
    if FMainForm <> nil then // Mod 2/8/2009
    begin
      TForm(FMainForm).WindowState := wsNormal;
      if FMainForm is TFormsUtlsBase then TFormsUtlsBase(FMainForm).ReScaleForm;
    end; // \\Mod 2/8/2009
    for i := 0 to ToMove.Count - 1 do
    begin
      Frm := ToMove[i];
      if Frm is TForm then Frm.WindowState := wsNormal;
      if Frm is TFormsUtlsBase then TFormsUtlsBase(Frm).ReScaleForm;
    end;
  finally
    ToMove.Free;
  end;
end;

procedure TApplicationFormUtil.ShowMain(AForceMaximise: Boolean = false);
begin
  if not(FMainForm is TForm) then Exit;
  TForm(FMainForm).Show;
  TForm(FMainForm).BringToFront;
  if AForceMaximise then
    with TForm(FMainForm) do
      if WindowState <> wsMaximized then
      begin
        Application.ProcessMessages;
        WindowState := wsMaximized;
        Application.ProcessMessages;
      end;
end;

procedure TApplicationFormUtil.TileForms;
var
  i, J, K, GrphHeight, GrphWidth: integer;
  Across, Down, DisplayMax, MainOffset: integer;
  ToTile: Tlist;

begin
  ToTile := Tlist.Create;
  try
    FindAllTilableForms(Application, ToTile);

    Across := 2;
    Down := 2;
    DisplayMax := ToTile.Count - 1;
    // Mod 3/8/2009
    if (FMainForm = nil) or (FListNonTileable.IndexOf(FMainForm.classname) > -1)
    then MainOffset := 0
    else MainOffset := 1;

    if MainOffset > 0 then Inc(DisplayMax);

    if DisplayMax > -1 then
    begin
      case DisplayMax of
        0:
          begin
            Across := 1;
            Down := 1;
          end;
        1:
          begin
            Across := 1;
            Down := 2;
          end;
        2 .. 3:
          begin
            Across := 2;
            Down := 2;
          end;
        4 .. 5:
          begin
            Across := 3;
            Down := 2;
          end;
        6 .. 8:
          begin
            Across := 3;
            Down := 3;
          end;
        9 .. 11:
          begin
            Across := 4;
            Down := 3;
          end;
        12 .. 15:
          begin
            Across := 4;
            Down := 4;
          end;
        16 .. 19:
          begin
            Across := 4;
            Down := 5;
          end;
        20 .. 24:
          begin
            Across := 5;
            Down := 5;
          end;
      end; // case
      GrphHeight := FTileHeight div Down;
      GrphWidth := FTileWidth div Across;
      J := FTileTop - GrphHeight;
      K := FTileLeft;
      // mod 3/8/2009
      if MainOffset > 0 then
      begin
        K := FTileLeft;
        J := J + GrphHeight;
        DisplayForm(FMainForm, K, J, GrphHeight, GrphWidth);
      end;
      for i := 0 to DisplayMax - MainOffset do
      begin
        if (0 = ((i + MainOffset) mod Across)) then
        // endmod 3/8/2009
        begin
          K := FTileLeft;
          J := J + GrphHeight;
        end
        else K := K + GrphWidth;
        DisplayForm(ToTile[i], K, J, GrphHeight, GrphWidth);
      end;
    end;
  finally
    ToTile.Free;
  end;
end;

{ TFormsUtlsMainbase }

procedure TFormsUtlsMainBase.ReScaleForm;
begin
  inherited;
end;

procedure TFormsUtlsMainBase.WndProc(var message: TMessage);
// Code to put in main Form to stop it minimising the stay on top with a - click

begin
  // if fStayOnTop <> nil then   //Do any way 3/8/2009
  with message do
    case Msg of
      WM_SYSCOMMAND: case WParam and $FFF0 of
          SC_MINIMIZE:
            begin
              message.Result := 0;
              ApplicationFormUtil.MinimizeAll;
              // WindowState:=wsMinimized;
              Exit;
            end;
          SC_RESTORE:
            begin
              message.Result := 0;
              ApplicationFormUtil.RestoreAll;
              // WindowState:=wsNormal;
              Exit;
            end;
        end;
    end;
  inherited;
end;

initialization

finalization

ApplicationFormUtil.Free;

end.
