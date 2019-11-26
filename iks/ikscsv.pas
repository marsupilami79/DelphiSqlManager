unit ikscsv;

interface

uses Classes, Types, DB, SysUtils;

type
  TFileEncoding = (feUnknown, feWIN1252, feCP850, feUTF8, feUTF16BE, feUTF16LE);

  TCSVContainer = Class(TComponent)
    protected
      CSVContents: Array of TStringDynArray;
      FMaxRow: Integer;
      FMaxCol: Integer;
      FColNamesRow: Integer;
      FNames: TStringDynArray;
      FAltNames: TStringDynArray;
      procedure setColNamesRow(newRow: Integer);
      procedure setAltName(ColIdx: Integer; newName: String);
      function getAltName(ColIdx: Integer): String;
    public
      function GetCell(const x, y: Integer): String; overload; virtual;
      function GetCell(ColName: String; Row: Integer): String; overload; virtual;
      function GetCellAlt(ColAltName: String; Row: Integer): String; virtual;
      procedure LoadData(Src: TStrings; Delimiter: Char);
      function getColIdxByName(ColName: String): Integer;
      function getColIdxByAltName(ColName: String): Integer;
      procedure LoadFromFile(FileName: String);
      constructor Create(AOwner: TComponent); override;
      property AltNames[ColIdx: Integer]: String read getAltName write setAltName;
      procedure RemoveEmptyLines;
    published
      property MaxRow: Integer read FMaxRow;
      property MaxCol: Integer read FMaxCol;
      property ColNamesRow: Integer read FColNamesRow write SetColNamesRow;
  End;

type
  TExplodeResult = (erOk, erNeedMoreData);

function GuessFileEncoding(FileName: String): TFileEncoding;
Function Explode2(InStr: String; Delimiter: Char; out FieldContents: TStringDynArray): TExplodeResult;
function CsvEncode(InStr: String): String;
procedure CsvExport(DataSet: TDataSet; ExportInvisibleColumns: Boolean; FileName: String; Encoding: TEncoding = nil);

implementation

uses Math;

const
  Utf8Bom: RawByteString = RawByteString(#239#187#191);
  Utf16BeBom: RawByteString = RawByteString(#254#255);
  Utf16LeBom: RawByteString = RawByteString(#255#254);

{    WIN1252 CP850 CP437 UTF8
   ä 228     $84   <=    $E4
   ö 246     $94   <=    $F6
   ü 252     $81   <=    $FC
   Ä 196     $8E   <=    $C4
   Ö 214     $99   <=    $D6
   Ü 220     $9A   <=    $DC
   ß 223     $E1   <=    $DF
}

function CheckBom(const Line: RawByteString): TFileEncoding;
begin
  if Copy(Line, 1, Length(Utf8Bom)) = Utf8Bom then Result := feUTF8
  else if Copy(Line, 1, Length(Utf16BeBom)) = Utf16BeBom then Result := feUTF16BE
  else if Copy(Line, 1, Length(Utf16LeBom)) = Utf16LeBom then Result := feUTF16LE
  else Result := feUnknown;
end;

function CheckWin1252(const Line: RawByteString): Boolean;
const
  chars: Array[0..6] of RawByteString = (#228, #246, #252, #196, #214, #220, #223);
var
  x: Integer;
begin
  Result := False;
  for x := Low(chars) to High(chars) do begin
    if Pos(chars[x], Line) <> 0 then begin
      Result := True;
      Break;
    end;
  end;
end;

function CheckCp850(const Line: RawByteString): Boolean;
const
  chars: Array[0..6] of RawByteString = (RawByteString(#$84), RawByteString(#$94), RawByteString(#$81), RawByteString(#$8E), RawByteString(#$99), RawByteString(#$9A), RawByteString(#$E1));
var
  x: Integer;
begin
  Result := False;
  for x := Low(chars) to High(chars) do begin
    if Pos(chars[x], Line) <> 0 then begin
      Result := True;
      Break;
    end;
  end;
end;

function CheckUtf8(const Line: RawByteString): Boolean;
const
  chars: Array[0..6] of RawByteString = (RawByteString(#195#164), RawByteString(#195#182), RawByteString(#195#188), RawByteString(#195#132), RawByteString(#195#150), RawByteString(#195#156), RawByteString(#195#159));
var
  x: Integer;
begin
  Result := False;
  for x := Low(chars) to High(chars) do begin
    if Pos(chars[x], Line) <> 0 then begin
      Result := True;
      Break;
    end;
  end;
end;

function GuessFileEncoding(FileName: String): TFileEncoding;
var
  Line: RawByteString;
  InFile: TextFile;

  function GuessLineEncoding: TFileEncoding;
  begin
    // wichtig: UTF8 vor CP850 testen -> sonst gibt es eine
    // Überschneidung zwischen dem UTF8-Ä und dem CP850-ä
    if CheckUtf8(Line) then Result := feUTF8
    else if CheckWin1252(Line) then Result := feWIN1252
    else if CheckCp850(Line) then Result := feCP850
    else Result := feUnknown;
  end;
begin
  AssignFile(InFile, FileName);
  Reset(InFile);
  Readln(InFile, Line);
  Result := CheckBom(Line);
  if Result = feUnknown then Result := GuessLineEncoding;
  if result = feUnknown then begin
    try
      while not EOF(InFile) do begin
        Readln(InFile, Line);
        Result := GuessLineEncoding;
        if Result <> feUnknown then break;
      end;
    finally
      CloseFile(InFile);
    end;
  end;

  if Result = feUnknown then Result := feWIN1252
end;

Function Explode2(InStr: String; Delimiter: Char; out FieldContents: TStringDynArray): TExplodeResult;
type
  TCSVState = (csOutside, csInsideQuoted, csInsideUnquoted, csEscaped);
var
  Start: Integer;
  x: Integer;
  CSVState: TCSVState;
  procedure AppendToResult(Ende: Integer; RemoveDoubleQuotes: Boolean = false);
  var
    value: String;
    idx: Integer;
    LastWasQuote: Boolean;
  begin
    value := copy(InStr, Start, Ende - Start + 1);
    if RemoveDoubleQuotes then begin
      LastWasQuote := False;
      for idx := Length(value) downto 1 do begin
        if LastWasQuote then begin
          LastWasQuote := false;
          if value[idx] = '"' then Delete(value, idx, 1);
        end else begin
          if value[idx] = '"' then LastWasQuote := True;
        end;
      end;
    end;
    idx := Length(FieldContents);
    SetLength(FieldContents, idx + 1);
    FieldContents[idx] := value;
  end;
begin
  SetLength(FieldContents, 0);
  if Length(InStr) = 0 then begin
    SetLength(FieldContents, 0);
    Result := erOk;
    Exit;
  end;

  Start := 1;
  CSVState := csOutside;

  for x := 1 to Length(InStr) do begin
    if InStr[x] = Delimiter then begin
      case CSVState of
        csOutside: begin
          AppendToResult(Start - 1);
        end;
        csInsideQuoted: ; //do nothing
        csInsideUnquoted: begin
          AppendToResult(x - 1);
          CSVState := csOutside;
        end;
        csEscaped: begin
          AppendToResult(x - 2, true);
          CSVState := csOutside;
        end;
      end;
    end else if InStr[x] = '"' then begin
      case CSVState of
        csOutside: begin
          Start := x + 1;
          CSVState := csInsideQuoted;
        end;
        csInsideQuoted: begin
          CSVState := csEscaped;
        end;
        csInsideUnquoted: ; // do nothing, use it as a regular character
        csEscaped: begin
          CSVState := csInsideQuoted;
        end;
      end;
    end else begin
      case CSVState of
        csOutside: begin
          Start := x;
          CSVState := csInsideUnquoted;
        end;
        csInsideQuoted: ; // do nothing
        csInsideUnquoted: ; // do nothing
        csEscaped: raise Exception.Create('After the beginning of an escape, no other character than " or ' + Delimiter + ' is allowed.');
      end;
    end;
  end;

  case CSVState of
    csOutside: begin
      AppendToResult(Start - 1);
      Result := erOk;
    end;
    csInsideQuoted: begin
      Result := erNeedMoreData;
    end;
    csInsideUnquoted: begin
      AppendToResult(Length(InStr));
      Result := erOk;
    end;
    csEscaped: begin
      AppendToResult(Length(InStr) - 1, true);
      Result := erOk;
    end;
    else Result := erOk;
  end;
end;

procedure TCSVContainer.LoadData(Src: TStrings; Delimiter: Char);
var
  x: Integer;
  MaxColCount: Integer;
  CsvLine: String;
  CurrentRow: Integer;
  FieldContents: TStringDynArray;
  ExplodeResult: TExplodeResult;
begin
  FMaxRow := -1;
  FMaxCol := -1;
  MaxColCount := 0;
  SetLength(CSVContents, 0);
  SetLength(CSVContents, Src.Count);
  CurrentRow := 0;
  CsvLine := '';
  ExplodeResult := ErOk;
  for x := 0 to Src.Count - 1 do begin
    if CsvLine = ''
    then CsvLine := Src.Strings[x]
    else CsvLine := CsvLine + ' - ' + Src.Strings[x];
    ExplodeResult := Explode2(CsvLine, Delimiter, FieldContents);
    case ExplodeResult of
      erOk: begin
        CSVContents[CurrentRow] := FieldContents;
        MaxColCount := Max(Length(FieldContents), MaxColCount);
        CsvLine := '';
        Inc(CurrentRow);
      end;
      erNeedMoreData: begin
        // simply do nothing. The CSV-Line will be concatenated wit the next line in the CSV file.
      end;
    end;
  end;

  if ExplodeResult = erNeedMoreData
  then raise Exception.Create('Die CSV-Datei beginnt ein Feld, beendet es aber nicht.');

  SetLength(CSVContents, CurrentRow);

  FMaxRow := CurrentRow - 1;
  FMaxCol := MaxColCount - 1;
  SetLength(FNames, MaxColCount);
  SetLength(FAltNames, MaxColCount);
end;

function TCSVContainer.GetCell(const x, y: Integer): String;
begin
  if x < 0 then raise Exception.Create('The CSV cell x index may not be smaller than 0.');
  if y < 0 then raise Exception.Create('The CSV cell y index may not be smaller than 0.');

  if y > MaxRow then Result := '' else begin
    if x < Length(CSVContents[y])
    then Result := CSVContents[y][x]
    else Result := '';
  end;
end;

procedure TCSVContainer.setColNamesRow(newRow: Integer);
var
  x: Integer;
begin
  if FColNamesRow <> newRow then begin
    if newRow >= 0 then begin
      for x := 0 to Length(FNames) - 1
      do FNames[x] := Trim(LowerCase(GetCell(x, newRow)));
    end else begin
      for x := 0 to Length(FNames) - 1
      do FNames[x] := '';
    end;
  end;
end;

function TCSVContainer.GetCell(ColName: String; Row: Integer): String;
var
  ColIdx: Integer;
begin
  ColIdx := getColIdxByName(ColName);
  if ColIdx >= 0
  then Result := getCell(ColIdx, Row)
  else Result := '';
end;

function TCSVContainer.GetCellAlt(ColAltName: String; Row: Integer): String;
var
  ColIdx: Integer;
begin
  ColIdx := getColIdxByAltName(ColAltName);
  if ColIdx >= 0
  then Result := getCell(ColIdx, Row)
  else Result := '';
end;

function TCSVContainer.getColIdxByName(ColName: String): Integer;
var
  x: Integer;
begin
  Result := -1;
  ColName := LowerCase(ColName);
  for x := 0 to Length(FNames) - 1 do begin
    if FNames[x] = ColName then begin
      Result := x;
      break;
    end;
  end;
end;

function TCSVContainer.getColIdxByAltName(ColName: String): Integer;
var
  x: Integer;
begin
  Result := -1;
  ColName := LowerCase(ColName);
  for x := 0 to Length(FAltNames) - 1 do begin
    if FAltNames[x] = ColName then begin
      Result := x;
      break;
    end;
  end;
end;

procedure TCSVContainer.setAltName(ColIdx: Integer; newName: String);
begin
  if (ColIdx >= 0) and (ColIdx < Length(FAltNames))
  then FAltNames[ColIdx] := LowerCase(newName);
end;

function TCSVContainer.getAltName(ColIdx: Integer): String;
begin
  if (ColIdx >= 0) and (ColIdx < Length(FAltNames))
  then Result := FAltNames[ColIdx]
  else Result := '';
end;

constructor TCSVContainer.Create(AOwner: TComponent);
begin
  inherited;
  FColNamesRow := -1;
end;

procedure TCSVContainer.LoadFromFile(FileName: String);
var
  FileEncoding: TFileEncoding;
  Encoding: TEncoding;
  x, y: Integer;
  Semikolon, Komma: Integer;
  CSVContents: TStringList;
  FieldSeparator: Char;
begin
  CSVContents := TStringList.Create;

  if not FileExists(FileName) then raise Exception.Create('Mist...');
  FileEncoding := GuessFileEncoding(FileName);
  case FileEncoding of
    //Codepage Identifier von https://msdn.microsoft.com/de-de/dd317756
    feUnknown, feWIN1252: Encoding := TEncoding.GetEncoding(1252);
    feCP850: Encoding := TEncoding.GetEncoding(850);
    feUTF8: Encoding := TUTF8Encoding.Create;
    feUTF16BE: Encoding := TBigEndianUnicodeEncoding.Create;
    feUTF16LE: Encoding := TUnicodeEncoding.Create;
    else Encoding := TEncoding.GetEncoding(1252);
  end;

  CSVContents.LoadFromFile(FileName, Encoding);

  Semikolon := 0;
  Komma := 0;
  for x := 0 to Min(CSVContents.Count, 11) - 1 do begin
    for y := 1 to length(CSVContents.Strings[x]) do begin
      case CSVContents.Strings[x][y] of
        ',': Inc(Komma);
        ';': Inc(Semikolon);
      end;
    end;
  end;
  if Komma > Semikolon then FieldSeparator := ',' else FieldSeparator := ';';

  LoadData(CSVContents, FieldSeparator);
end;

procedure TCSVContainer.RemoveEmptyLines;
var
  x, y: Integer;
  Remove: Boolean;
begin
  for y := FMaxRow downto 0 do begin
    Remove := true;
    for x := 0 to MaxCol do begin
      if Trim(GetCell(x, y)) <> '' then begin
        Remove := false;
        Break;
      end;
    end;
    if Remove then begin
      Delete(CSVContents, y, 1);
      Dec(FMaxRow);
    end;
  end;
end;

function CsvEncode(InStr: String): String;
var
  x: Integer;
begin
  for x := Length(InStr) downto 1
  do if InStr[x] = '"' then Insert('"', InStr, x);
  Result := '"' + InStr + '"';
end;

procedure CsvExport(DataSet: TDataSet; ExportInvisibleColumns: Boolean; FileName: String; Encoding: TEncoding = nil);
var
  Bookmark: TBookmark;
  Lines: TStringList;
  Line: String;
  x: Integer;
  IsFirst: Boolean;
begin
  Line := '';

  Bookmark := DataSet.Bookmark;
  try
    DataSet.DisableControls;
    try
      Lines := TStringList.Create;

      for x := 0 to DataSet.FieldCount - 1 do begin
        if DataSet.Fields[x].Visible or ExportInvisibleColumns then begin
          if Line <> '' then line := line + ';';
          Line := Line + CsvEncode(DataSet.Fields[x].DisplayLabel);
        end;
      end;
      Lines.Add(Line);

      DataSet.First;
      while not DataSet.Eof do begin
        Line := '';
        IsFirst := True;
        for x := 0 to DataSet.FieldCount - 1 do begin
          if DataSet.Fields[x].Visible or ExportInvisibleColumns then begin
            if IsFirst then isfirst := False else line := line + ';';
            if DataSet.Fields[x].DataType in [ftString, ftFixedChar, ftWideString, ftOraClob, ftFixedWideChar, ftWideMemo]
            then Line := Line + CsvEncode(DataSet.Fields[x].AsString)
            else Line := Line + DataSet.Fields[x].AsString;
          end;
        end;
        Lines.Add(Line);
        DataSet.Next;
      end;
      if Assigned(Encoding)
      then Lines.SaveToFile(FileName, Encoding)
      else Lines.SaveToFile(FileName);
    finally
      FreeAndNil(Lines);
    end;
  finally
    DataSet.Bookmark := Bookmark;
    DataSet.EnableControls;
  end;
end;

end.
