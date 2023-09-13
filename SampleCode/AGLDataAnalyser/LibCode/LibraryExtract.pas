unit LibraryExtract;

interface
uses sysutils;
type
  TArrayOfAnsiStrings = array of AnsiString;
  ArrayOfAnsiStrings = TArrayOfAnsiStrings;
  AnsiCharSet = set of Ansichar;

Const
  OpenBracketAnsi: AnsiCharSet = ['{', '[', '(', '<'];
  CloseBracketAnsi: AnsiCharSet = ['}', ']', ')', '>'];
  ZSISOffset = 0;
  IsFirstChar = 1;




function GetArrayFromString(const S: AnsiString; SepVal: AnsiChar;
  ARemoveQuote: Boolean = false; ATrim: Boolean = True;
  ADropNulls: Boolean = false): TArrayOfAnsiStrings; overload;
function IndexInArray(AArray: array of AnsiString; const ATest: AnsiString;
  ACaseSensitive: Boolean = True): Integer; overload;
procedure ResetArray(A: TArrayOfAnsiStrings); overload;
procedure ResetArray(Var A: Array of Boolean); overload;


implementation
function FieldSep(var ss: PAnsiChar; SepVal: Ansichar): AnsiString;
var
  CharPointer: PAnsiChar;
  j: Integer;

begin
  if ss <> nil then
  begin
    if (SepVal <> AnsiChar(0)) then
      while ss[0] = SepVal do
        ss := ss + 1;
    CharPointer := StrScan(ss, SepVal);
    if CharPointer = nil then
      Result := StrPas(ss) { Last Field }
    else
    begin
      j := CharPointer - ss;
      Result := Copy(ss, 0, j);
    end;
    if CharPointer = nil then
      ss := nil
    else
      ss := CharPointer + 1;
  end
  else
    Result := '';
end;







function GetArrayFromString(const S: AnsiString; SepVal: AnsiChar;
  ARemoveQuote: Boolean = false; ATrim: Boolean = True;
  ADropNulls: Boolean = false): TArrayOfAnsiStrings; overload;
var
  i: Integer;
  NextChar, SecondQuoteChar: PAnsiChar;
  CSepVal: AnsiChar;
  QuoteVal: AnsiString;
  ThisS, fs: AnsiString;
begin
  SetLength(Result, 0);
  if S = '' then
    exit;
  ThisS := S;
  NextChar := @ThisS[1];
  CSepVal := SepVal;
  i := 0;
  while Pointer(NextChar) <> nil do
  begin
    if NextChar[0] = CSepVal then
    begin
      inc(NextChar);
      fs := '';
    end
    else if ARemoveQuote and (Char(NextChar[0]) in ['''', '"', '[', '{', '(',
      '<']) then
    begin
      case Char(NextChar[0]) of
        '''', '"':
          QuoteVal := NextChar[0];
        '[':
          QuoteVal := ']';
        '{':
          QuoteVal := '}';
        '(':
          QuoteVal := ')';
        '<':
          QuoteVal := '>';
      else
        QuoteVal := NextChar[0];
      end;

      SecondQuoteChar := StrPos(PAnsiChar(NextChar + 1), PAnsiChar(QuoteVal));
      if (Pointer(SecondQuoteChar) <> nil) and
        ((SecondQuoteChar[1] = CSepVal) or (SecondQuoteChar[1] = #0)) then
      begin
        inc(NextChar);
        if NextChar = SecondQuoteChar then
        Begin
          fs := '';
          inc(NextChar);
        End
        else
          fs := FieldSep(NextChar, QuoteVal[1 + ZSISOffset]);
        if SecondQuoteChar[1] = #0 then
          NextChar := nil
        else
          inc(NextChar);
      end
      else
        fs := FieldSep(NextChar, CSepVal);
    end
    else
      fs := FieldSep(NextChar, CSepVal);
    if i > high(Result) then
      SetLength(Result, i + 6);
    if ATrim then
      Result[i] := Trim(fs)
    else
      Result[i] := fs;
    if ADropNulls And (Result[i] = '') then
    Begin
    End
    Else
      inc(i);
  end;
  SetLength(Result, i);
end;

function IndexInArray(AArray: array of AnsiString; const ATest: AnsiString;
  ACaseSensitive: Boolean = True): Integer; overload;
var
  i: Integer;
begin
  Result := -1;
  if ACaseSensitive then
  begin
    for i := low(AArray) to high(AArray) do
      if AArray[i] = ATest then
      begin
        Result := i;
        break;
      end;
  end
  else
    for i := low(AArray) to high(AArray) do
      if CompareText(AArray[i], ATest) = 0 then
      begin
        Result := i;
        break;
      end;
end;

procedure ResetArray(A: TArrayOfAnsiStrings); overload;
var
  i: Integer;
begin
  for i := low(A) to high(A) do
    SetLength(A[i], 0);
end;

procedure ResetArray(Var A: Array of Boolean); overload;
var
  i: Integer;
begin
  for i := low(A) to high(A) do
    A[i]:=false;
end;

end.
