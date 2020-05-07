unit FormMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, SynEdit, SynEditHighlighter,
  SynHighlighterSQL, ZAbstractConnection, ZConnection, Vcl.StdCtrls,
  Vcl.ExtCtrls, Vcl.ComCtrls, Vcl.Grids, Vcl.DBGrids, Data.DB,
  ZAbstractRODataset, ZAbstractDataset, ZDataset, ZSqlMonitor, ZSqlMetadata,
  SynEditMiscClasses, SynEditSearch, Vcl.DBCtrls, ZSqlProcessor;

type
  TConnectionProfile = record
    Protocol: String;
    HostName: String;
    Database: String;
    ClientLibrary: String;
    UserName: String;
    Properties: String;
  end;

  TForm1 = class(TForm)
    SynSQLSyn: TSynSQLSyn;
    HostEdt: TEdit;
    Label1: TLabel;
    DatabaseEdt: TEdit;
    Label2: TLabel;
    DBConn: TZConnection;
    RunSqlBtn: TButton;
    ResultTS: TPageControl;
    MessagesSheet: TTabSheet;
    DataSheet: TTabSheet;
    Splitter1: TSplitter;
    SynEdit: TSynEdit;
    MessagesM: TMemo;
    MainDS: TDataSource;
    DBGrid1: TDBGrid;
    MainQ: TZQuery;
    ConnectBtn: TButton;
    ZSQLMonitor1: TZSQLMonitor;
    PageControl2: TPageControl;
    SqlTS: TTabSheet;
    Panel1: TPanel;
    MetadataTS: TTabSheet;
    Panel2: TPanel;
    DBGrid2: TDBGrid;
    MetadataMD: TZSQLMetadata;
    MetadataDS: TDataSource;
    MetadataCB: TComboBox;
    MetaDataObjectNameCB: TComboBox;
    fetchMetadataBtn: TButton;
    Label3: TLabel;
    ProtocolsCB: TComboBox;
    ClientLibEdt: TEdit;
    BrowseClientLibBtn: TButton;
    ClientLibraryOD: TOpenDialog;
    Label4: TLabel;
    BrowseDatabaseBtn: TButton;
    FirebirdDatabaseOD: TOpenDialog;
    Label5: TLabel;
    UserNameEdt: TEdit;
    Label6: TLabel;
    PasswordEdt: TEdit;
    ConnectionTS: TTabSheet;
    PropertiesM: TMemo;
    Label7: TLabel;
    StartTransactionBtn: TButton;
    CommitBtn: TButton;
    RollbackBtn: TButton;
    SynEditSearch: TSynEditSearch;
    FindReplaceBtn: TButton;
    SqlReplaceDialog: TReplaceDialog;
    OpenFileBtn: TButton;
    SaveFileBtn: TButton;
    SqlFileOD: TOpenDialog;
    SqlFileSD: TSaveDialog;
    Label8: TLabel;
    MetaDataObjectNameL: TLabel;
    exportMetadataCsvBtn: TButton;
    exportCsvSD: TSaveDialog;
    StatusSB: TStatusBar;
    DBNavigator1: TDBNavigator;
    ConnectionSB: TStatusBar;
    MetaDataObjectName2CB: TComboBox;
    MetaDataObjectName2L: TLabel;
    MetadataTreeV: TTreeView;
    Splitter2: TSplitter;
    SqlProc: TZSQLProcessor;
    Panel3: TPanel;
    Memo1: TMemo;
    exportDataCsvBtn: TButton;
    Splitter3: TSplitter;
    procedure ConnectBtnClick(Sender: TObject);
    procedure RunSqlBtnClick(Sender: TObject);
    procedure MetadataCBChange(Sender: TObject);
    procedure fetchMetadataBtnClick(Sender: TObject);
    procedure MetadataMDAfterOpen(DataSet: TDataSet);
    procedure FormCreate(Sender: TObject);
    procedure BrowseClientLibBtnClick(Sender: TObject);
    procedure BrowseDatabaseBtnClick(Sender: TObject);
    procedure DBConnAfterConnect(Sender: TObject);
    procedure DBConnAfterDisconnect(Sender: TObject);
    procedure ProtocolsCBChange(Sender: TObject);
    procedure HostEdtExit(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure StartTransactionBtnClick(Sender: TObject);
    procedure DBConnStartTransaction(Sender: TObject);
    procedure DBConnRollback(Sender: TObject);
    procedure DBConnCommit(Sender: TObject);
    procedure CommitBtnClick(Sender: TObject);
    procedure RollbackBtnClick(Sender: TObject);
    procedure FindReplaceBtnClick(Sender: TObject);
    procedure SqlReplaceDialogFind(Sender: TObject);
    procedure OpenFileBtnClick(Sender: TObject);
    procedure SaveFileBtnClick(Sender: TObject);
    procedure SqlReplaceDialogReplace(Sender: TObject);
    procedure exportMetadataCsvBtnClick(Sender: TObject);
    procedure exportDataCsvBtnClick(Sender: TObject);
    procedure MainQAfterOpen(DataSet: TDataSet);
    procedure MainQAfterClose(DataSet: TDataSet);
    procedure MetadataTreeVDblClick(Sender: TObject);
    procedure DBGrid1ColEnter(Sender: TObject);
  private
    { Private-Deklarationen }
    FConnectionProfiles: Array of TConnectionProfile;
    FIniFileName: String;
    LastFindTxt: String;
    CurrentFileName: String;
    procedure LoadConnectionProfile(const Protocol: String; const Server: String = '<unknown>');
    procedure StoreConnectionProfile;
    procedure LoadConnectionProfiles;
    procedure UpdateMessages;
    procedure doCsvExport(DataSet: TDataSet; FileName: String);
  public
    { Public-Deklarationen }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

uses {$IFNDEF FPC}ADODB,{$IFEND} ZDBCIntfs, Math, IniFiles, ZClasses, IksCsv, ShellApi, ZDbcOdbcUtils, System.UITypes, Types;

const
  ConnectionProfilePrefix = 'ConnectionProfile_';

type
  TSpecialFolder = (sfAppData);

function GetSpecialFolder(FolderType: TSpecialFolder; AppName: String): String;
begin
  {$IF NOT DEFINED(FPC)}
  Result := GetEnvironmentVariable('APPDATA') + PathDelim + AppName;
  {$ELSEIF DEFINED(WINDOWS)}
  Result := GetEnvironmentVariable('APPDATA') + PathDelim + AppName;
  {$ELSEIF DEFINED(UNIX)}
  Result := GetEnvironmentVariable('HOME') + PathDelim + '.' + LowerCase(AppName);
  {$ELSE}
  Result := '';
  {$ENDIF}
end;

procedure OpenWebAddress(Address: String);
begin
  ShellExecute(0, 'open', PChar(Address), nil, nil, SW_SHOWNORMAL)
end;

procedure TForm1.doCsvExport(DataSet: TDataSet; FileName: String);
begin
  if exportCsvSD.Execute then begin
    if DataSet is TZAbstractRODataset then with (DataSet as TZAbstractRODataset) do begin
      if Assigned(Connection)
      then Connection.ShowSQLHourGlass;
    end;
    try
      CsvExport(DataSet, false, exportCsvSD.FileName);
    finally
      if DataSet is TZAbstractRODataset then with (DataSet as TZAbstractRODataset) do begin
        if Assigned(Connection)
        then Connection.HideSQLHourGlass;
      end;
    end;
  end;
  if MessageDlg('The CSV data was exported. Do you want to open it?', mtConfirmation, [mbYes, mbNo], 0) = mrYes
  then OpenWebAddress(FileName);
end;

procedure autosizeDS(DataSet: TDataSet);
var
  x: Integer;
  FieldLengths: Array of Integer;
begin
  DataSet.DisableControls;
  try
    SetLength(FieldLengths, DataSet.FieldCount);
    DataSet.First;
    while not DataSet.Eof do begin
      for x := 0 to DataSet.FieldCount - 1
      do FieldLengths[x] := Max(FieldLengths[x], Length(DataSet.Fields[x].AsString));
      DataSet.Next;
    end;

    for X := 0 to DataSet.FieldCount - 1
    do DataSet.Fields[x].DisplayWidth := Max(1, FieldLengths[x]);
  finally
    DataSet.First;
    DataSet.EnableControls;
  end;
end;

procedure TForm1.BrowseClientLibBtnClick(Sender: TObject);
begin
  if ClientLibraryOD.Execute then begin
    ClientLibEdt.Text := ClientLibraryOD.FileName;
  end;
end;

procedure TForm1.BrowseDatabaseBtnClick(Sender: TObject);
var
  ConnStr: WideString;
begin
  if LowerCase(Copy(ProtocolsCB.Text, 1, 8)) = 'firebird' then begin
    if FirebirdDatabaseOD.Execute
    then DatabaseEdt.Text := FirebirdDatabaseOD.FileName;
  end;
  if LowerCase(Copy(ProtocolsCB.Text, 1, 4)) = 'odbc' then begin
    ConnStr := ZDbcOdbcUtils.GetConnectionString(Pointer(Application.Handle), DatabaseEdt.Text, '');
    DatabaseEdt.Text := ConnStr;
  end;
  {$IFNDEF FPC}
  if LowerCase(ProtocolsCB.Text) = 'ado' then begin
    ConnStr := ADODB.PromptDataSource(self.Handle, ConnStr);
    if ConnStr <> '' then begin
      HostEdt.Text := '';
      DatabaseEdt.Text := ConnStr;
    end;
  end;
  {$IFEND}
end;

procedure TForm1.fetchMetadataBtnClick(Sender: TObject);
begin
  MetadataMD.Close;
  MetadataMD.TableName := '';
  MetadataMD.ProcedureName := '';
  MetadataMD.SequenceName := '';
  MetadataMD.TypeName := '';

  case MetadataCB.ItemIndex of
    0: begin
      MetadataMD.TableName := MetaDataObjectNameCB.Text;
      MetadataMD.MetadataType := mdBestRowIdentifier;
      MetadataMD.Open;
    end;
    1: begin
      MetadataMD.MetadataType := mdCatalogs;
      MetadataMD.Open;
    end;
    2: begin
      MetadataMD.TableName := MetaDataObjectNameCB.Text;
      MetadataMD.ColumnName := trim(MetaDataObjectName2CB.Text);
      MetadataMD.MetadataType := mdColumnPrivileges;
      MetadataMD.Open;
    end;
    3: begin
      MetadataMD.TableName := trim(MetaDataObjectNameCB.Text);
      MetadataMD.ColumnName := trim(MetaDataObjectName2CB.Text);
      MetadataMD.MetadataType := mdColumns;
      MetadataMD.Open;
    end;
    4: begin
      MessageDlg('Using Cross Reference is not implemented yet.', mtError, [mbOk], 0);
    end;
    5: begin
      MetadataMD.TableName := MetaDataObjectNameCB.Text;
      MetadataMD.MetadataType := mdExportedKeys;
      MetadataMD.Open;
    end;
    6:  begin
      MetadataMD.TableName := MetaDataObjectNameCB.Text;
      MetadataMD.MetadataType := mdImportedKeys;
      MetadataMD.Open;
    end;
    7: begin
      MetadataMD.TableName := MetaDataObjectNameCB.Text;
      MetadataMD.MetadataType := mdIndexInfo;
      MetadataMD.Open;
    end;
    8: begin
      MetadataMD.TableName := MetaDataObjectNameCB.Text;
      MetadataMD.MetadataType := mdPrimaryKeys;
      MetadataMD.Open;
    end;
    9: begin
      MetadataMD.ProcedureName := MetaDataObjectNameCB.Text;
      MetadataMD.MetadataType := mdProcedureColumns;
      MetadataMD.Open;
    end;
    10: begin
      MetadataMD.ProcedureName := '';
      MetadataMD.MetadataType := mdProcedures;
      MetadataMD.Open;
    end;
    11: begin
      MetadataMD.MetadataType := mdSchemas;
      MetadataMD.Open;
    end;
    12: begin
      MetadataMD.SequenceName := MetaDataObjectNameCB.Text;
      MetadataMD.MetadataType := mdSequences;
      MetadataMD.Open;
    end;
    13: begin
      MetadataMD.TableName := MetaDataObjectNameCB.Text;
      MetadataMD.MetadataType := mdTablePrivileges;
      MetadataMD.Open;
    end;
    14: begin
      MetadataMD.TableName := MetaDataObjectNameCB.Text;
      MetadataMD.MetadataType := mdTables;
      MetadataMD.Open;
    end;
    15: begin
      MetadataMD.MetadataType := mdTableTypes;
      MetadataMD.Open;
    end;
    16: begin
      MetadataMD.TableName := MetaDataObjectNameCB.Text;
      MetadataMD.MetadataType := mdTriggers;
      MetadataMD.Open;
    end;
    17: begin
      MetadataMD.MetadataType := mdTypeInfo;
      MetadataMD.Open;
    end;
    18: begin
      MetadataMD.TypeName := MetaDataObjectNameCB.Text;
      MetadataMD.MetadataType := mdUserDefinedTypes;
      MetadataMD.Open;
    end;
    19: begin
      MetadataMD.TableName := MetaDataObjectNameCB.Text;
      MetadataMD.MetadataType := mdVersionColumns;
      MetadataMD.Open;
    end;
  end;
end;

procedure TForm1.CommitBtnClick(Sender: TObject);
begin
  DBConn.Commit;
end;

procedure TForm1.ConnectBtnClick(Sender: TObject);
var
  DbProtocol: String;
  TableNames: TStringList;
  TableTypes: TStringDynArray;
  x: Integer;
  TablesNode: TTreeNode;
  Node: TTreeNode;
begin
  if not DBConn.Connected then begin
    DBConn.Properties.Text := PropertiesM.Lines.Text;
    DBConn.Protocol := ProtocolsCB.Text;
    DBConn.HostName := HostEdt.Text;
    DBConn.Database := DatabaseEdt.Text;
    DBConn.LibraryLocation := Trim(ClientLibEdt.Text);
    DBConn.User := UserNameEdt.Text;
    DBConn.Password := PasswordEdt.Text;
    DBConn.LoginPrompt := false;
  end;

  if DBConn.Connected then begin
    DBConn.Disconnect;
    ConnectBtn.Caption := 'Connect';
  end else begin
    try
      DBConn.Connect;
    except
      on E: Exception do begin
        MessageDlg('There was an error on connecting to the database:' + #13 + E.Message, mtError, [mbOk], 0);
        Abort;
      end;
    end;
    ConnectBtn.Caption := 'Disconnect';

    // setup synedit:
    DbProtocol := LowerCase(DBConn.Protocol);
    if Copy(DbProtocol, 1, 8) = 'firebird' then begin
      SynSQLSyn.SQLDialect := sqlInterbase6;
    end else if Copy(DbProtocol, 1, 13) = 'freetds_mssql' then begin
      SynSQLSyn.SQLDialect := sqlMSSQL2K;
    end else if Copy(DbProtocol, 1, 14) = 'freetds_sybase' then begin
      SynSQLSyn.SQLDialect := sqlSybase;
    end else if Copy(DbProtocol, 1, 9) = 'interbase' then begin
      SynSQLSyn.SQLDialect := sqlInterbase6;
    end else if Copy(DbProtocol, 1, 5) = 'mssql' then begin
      SynSQLSyn.SQLDialect := sqlMSSQL2K;
    end else if Copy(DbProtocol, 1, 5) = 'mysql' then begin
      SynSQLSyn.SQLDialect := sqlMySQL;
    end else if Copy(DbProtocol, 1, 7) = 'mariadb' then begin
      SynSQLSyn.SQLDialect := sqlMySQL;
    end else if Copy(DbProtocol, 1, 6) = 'oracle' then begin
      SynSQLSyn.SQLDialect := sqlOracle;
    end else if Copy(DbProtocol, 1, 10) = 'postgresql' then begin
      SynSQLSyn.SQLDialect := sqlPostgres;
    end else if Copy(DbProtocol, 1, 6) = 'sybase' then begin
      SynSQLSyn.SQLDialect := sqlSybase;
    end else begin
      SynSQLSyn.SQLDialect := sqlStandard;
    end;

    TablesNode := MetadataTreeV.Items.AddChild(nil, 'Tables');
    SetLength(TableTypes, 1);
    TableTypes[0] := 'TABLE';
    TableNames := TStringList.Create;
    try
      TableNames.BeginUpdate;
      try
        DBConn.GetTableNames('', '', TableTypes, TableNames);
      finally
        TableNames.EndUpdate;
      end;
      TableNames.Sort;
      SynSQLSyn.TableNames.Assign(TableNames);

      MetadataTreeV.Items.BeginUpdate;
      try
        for X := 0 to TableNames.Count - 1 do begin
          Node := MetadataTreeV.Items.AddChild(TablesNode, TableNames.Strings[X]);
          Node.SelectedIndex := 1;
        end;
      finally
        MetadataTreeV.Items.EndUpdate;
      end;
    finally
      FreeAndNil(TableNames);
    end;

    SynSQLSyn.ProcNames.BeginUpdate;
    try
      DBConn.GetStoredProcNames('%', SynSQLSyn.ProcNames);
    finally
      SynSQLSyn.ProcNames.EndUpdate;
    end;

    PageControl2.ActivePage := SqlTS;
    StoreConnectionProfile;
    UpdateMessages;
  end;
end;

procedure TForm1.DBConnAfterConnect(Sender: TObject);
begin
  SqlTS.TabVisible := true;
  MetadataTS.TabVisible := true;

  StartTransactionBtn.Enabled := true;
  CommitBtn.Enabled := false;
  RollbackBtn.Enabled := false;
end;

procedure TForm1.DBConnAfterDisconnect(Sender: TObject);
var
  Node: TTreeNode;
  X: Integer;
begin
  SqlTS.TabVisible := False;
  MetadataTS.TabVisible := false;

  StartTransactionBtn.Enabled := false;
  CommitBtn.Enabled := false;
  RollbackBtn.Enabled := false;

  MetadataTreeV.Items.Clear;
end;

procedure TForm1.DBConnCommit(Sender: TObject);
begin
  StartTransactionBtn.Enabled := true;
  CommitBtn.Enabled := false;
  RollbackBtn.Enabled := false;
end;

procedure TForm1.DBConnRollback(Sender: TObject);
begin
  StartTransactionBtn.Enabled := true;
  CommitBtn.Enabled := false;
  RollbackBtn.Enabled := false;
end;

procedure TForm1.DBConnStartTransaction(Sender: TObject);
begin
  StartTransactionBtn.Enabled := false;
  CommitBtn.Enabled := true;
  RollbackBtn.Enabled := true;
end;

procedure TForm1.DBGrid1ColEnter(Sender: TObject);
var
  Grid: TDBGrid;
  TargetStr: String;
begin
  TargetStr := '';
  Grid := (Sender as TDBGrid);
  if Assigned(Grid.SelectedField) then
    if (Grid.SelectedField is TMemoField) or (Grid.SelectedField is TWideMemoField)  then
      TargetStr := Grid.SelectedField.AsString;
  Memo1.Lines.Text := TargetStr;
end;

procedure TForm1.exportDataCsvBtnClick(Sender: TObject);
begin
  doCsvExport(MainQ, exportCsvSD.FileName);
end;

procedure TForm1.exportMetadataCsvBtnClick(Sender: TObject);
begin
  doCsvExport(MetadataMD, exportCsvSD.FileName);
end;

procedure TForm1.FindReplaceBtnClick(Sender: TObject);
begin
  SqlReplaceDialog.Execute;
  LastFindTxt := '';
end;

procedure TForm1.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  DBConn.Disconnect;
end;

procedure TForm1.FormCreate(Sender: TObject);
var
  index: Integer;
  IniFileName: String;
begin
  ConnectionSB.SimpleText := 'Zeos version: ' + DBConn.Version;
  DBConn.GetProtocolNames(ProtocolsCB.Items);
  index := ProtocolsCB.Items.IndexOf('FreeTDS_MsSQL>=2005');
  if index >= 0 then begin
    ProtocolsCB.ItemIndex := index
  end else begin
    if ProtocolsCB.Items.Count > 0
    then ProtocolsCB.ItemIndex := 0;
  end;

  SqlTS.TabVisible := false;
  MetadataTS.TabVisible := false;

  IniFileName := GetSpecialFolder(sfAppData, 'DelphiSqlManager');
  if IniFileName <> ''
  then FIniFileName := IniFileName + PathDelim + 'DelphiSqlManager.ini';

  LoadConnectionProfiles;
end;

procedure TForm1.HostEdtExit(Sender: TObject);
begin
  LoadConnectionProfile(ProtocolsCB.Text, HostEdt.Text);
end;

procedure TForm1.MainQAfterClose(DataSet: TDataSet);
begin
  exportDataCsvBtn.Enabled := false;
end;

procedure TForm1.MainQAfterOpen(DataSet: TDataSet);
begin
  exportDataCsvBtn.Enabled := true;
  autosizeDS(DataSet);
end;

procedure TForm1.MetadataCBChange(Sender: TObject);
begin
  MetaDataObjectNameCB.Items.Clear;
  MetaDataObjectNameCB.Style := csDropDown;
  MetaDataObjectNameCB.Enabled := true;
  MetaDataObjectNameL.Caption := '';

  case MetadataCB.ItemIndex of
    4: begin // mdCrossReference
      MessageDlg('Using CrossReference is not supported yet.', mtError, [mbOk], 0);
    end;
    1, 11, 15, 17: begin // mdCatalogs, mdSchemas, mdTableTypes, mdTypeInfo -> do nothing;
      MetaDataObjectNameL.Visible := false;
      MetaDataObjectNameCB.Visible := false;
    end;
    0, 2, 3, 5, 6, 7, 8, 13, 14, 16, 19: begin //mdBestRowIdentifier, mdColumnPrivileges, mdColumns, mdExportedKeys, mdImportedKeys, mdIndexInfo, mdPrimaryKeys, mdTablePrivileges, mdTables, mdTriggers, mdVersionColumns
      MetaDataObjectNameL.Caption := 'Table Name:';
      DBConn.GetTableNames('', MetaDataObjectNameCB.Items);
      MetaDataObjectNameL.Visible := true;
      MetaDataObjectNameCB.Visible := true;
    end;
    9, 10: begin // mdProcedureColumns, mdProcedures
      MetaDataObjectNameL.Caption := 'Procedure Name:';
      DBConn.GetStoredProcNames('', MetaDataObjectNameCB.Items);
      MetaDataObjectNameL.Visible := true;
      MetaDataObjectNameCB.Visible := true;
    end;
    12: begin // mdSequences
      MetaDataObjectNameL.Caption := 'Sequence Name:';
      MetaDataObjectNameCB.Items.Clear;
      MetaDataObjectNameL.Visible := true;
      MetaDataObjectNameCB.Visible := true;
    end;
    18: begin // mdSequences
      MetaDataObjectNameL.Caption := 'Type Name:';
      MetaDataObjectNameCB.Items.Clear;
      MetaDataObjectNameL.Visible := true;
      MetaDataObjectNameCB.Visible := true;
    end;
  end;

  case MetadataCB.ItemIndex of
    2, 3: begin //mdColumnPrivileges, mdColumns
      MetaDataObjectName2L.Caption := 'Field Name:';
      MetaDataObjectName2CB.Items.Clear;
      MetaDataObjectName2L.Visible := true;
      MetaDataObjectName2CB.Visible := true;
      end
    else begin
      MetaDataObjectName2L.Visible := false;
      MetaDataObjectName2CB.Visible := false;
    end;
  end;
end;

procedure TForm1.MetadataMDAfterOpen(DataSet: TDataSet);
begin
  autosizeDS(MetadataMD);
end;

procedure TForm1.MetadataTreeVDblClick(Sender: TObject);
begin
  if MetadataTreeV.Selected.SelectedIndex = 1 then begin
    SynEdit.SelText := MetadataTreeV.Selected.Text;
  end;
end;

procedure TForm1.OpenFileBtnClick(Sender: TObject);
begin
  if SqlFileOD.Execute and FileExists(SqlFileOD.FileName) then begin
    SynEdit.Lines.LoadFromFile(SqlFileOD.FileName);
    CurrentFileName := SqlFileOD.FileName;
  end;
end;

procedure TForm1.ProtocolsCBChange(Sender: TObject);
begin
  LoadConnectionProfile(ProtocolsCB.Text);
end;

procedure TForm1.RollbackBtnClick(Sender: TObject);
begin
  DBConn.Rollback;
end;

procedure TForm1.RunSqlBtnClick(Sender: TObject);
var
  StartTime, Endtime: TDateTime;
  x: Integer;
begin
  MainQ.Close;
  MainQ.SQL.Text := SynEdit.Lines.Text;
  StatusSB.SimpleText := '';
  DBConn.ShowSQLHourGlass;
  try
    StartTime := now;
    MainQ.DisableControls;
    try
      StartTime := now;
      MainQ.Open;
    except
      on E: EZSQLException do begin
        MessagesM.Lines.Add(E.Message);
      end;
    end;
    Endtime := now;
    if MainQ.Active and (MainQ.FieldCount = 0)
    then MainQ.Close;
    StatusSB.SimpleText := 'Runtime: ' + FormatDateTime('nn:ss.zzz', Endtime - StartTime);
  finally
    MainQ.EnableControls;
    DBConn.HideSQLHourGlass;
  end;

  UpdateMessages;

  for x := 0 to MainQ.FieldCount - 1 do begin
    MessagesM.Lines.Add(MainQ.Fields[x].DisplayLabel + ': ' + MainQ.Fields[x].ClassName);
  end;

  if MainQ.Active then begin
    ResultTS.ActivePageIndex := DataSheet.PageIndex

  end else begin
    ResultTS.ActivePageIndex := MessagesSheet.PageIndex;
  end;
end;

procedure TForm1.LoadConnectionProfiles;
var
  IniFile: TIniFile;
  x: Integer;
  SectionName: String;
  Properties: TStringList;
begin
  IniFile := TIniFile.Create(FIniFileName);
  try
    x := 0;
    SectionName := ConnectionProfilePrefix + IntToStr(x);
    while IniFile.SectionExists(SectionName) do begin
      SetLength(FConnectionProfiles, x + 1);
      FConnectionProfiles[x].Protocol := IniFile.ReadString(SectionName, 'Protocol', '');
      FConnectionProfiles[x].HostName := IniFile.ReadString(SectionName, 'HostName', '');
      FConnectionProfiles[x].Database := IniFile.ReadString(SectionName, 'DataBase', '');
      FConnectionProfiles[x].ClientLibrary := IniFile.ReadString(SectionName, 'ClientLibrary', '');
      FConnectionProfiles[x].UserName := IniFile.ReadString(SectionName, 'UserName', '');
      Properties := TStringList.Create;
      try
        Properties.Delimiter := ';';
        Properties.DelimitedText := IniFile.ReadString(SectionName, 'Properties', '');
        FConnectionProfiles[x].Properties := Properties.Text;
      finally
        FreeAndNil(Properties);
      end;
      inc(x);
      SectionName := ConnectionProfilePrefix + IntToStr(x);
    end;
  finally
    FreeAndNil(IniFile);
  end;
end;

procedure TForm1.LoadConnectionProfile(const Protocol: String; const Server: String = '<unknown>');
var
  x: Integer;
  found: Boolean;
begin
  x := -1;
  found := false;

  while not found and ((x + 1) < Length(FConnectionProfiles)) do begin
    inc(x);
    if (Protocol = FConnectionProfiles[x].Protocol) and
       ((Server = '<unknown>') or (Server = FConnectionProfiles[x].HostName))
    then found := true;
  end;

  if found then begin
    if Server = '<unknown>' then HostEdt.Text := FConnectionProfiles[x].HostName;
    DatabaseEdt.Text := FConnectionProfiles[x].Database;
    ClientLibEdt.Text := FConnectionProfiles[x].ClientLibrary;
    UserNameEdt.Text := FConnectionProfiles[x].UserName;
    PropertiesM.Lines.Text := FConnectionProfiles[x].Properties;
  end;
end;

procedure TForm1.SaveFileBtnClick(Sender: TObject);
begin
  SqlFileSD.FileName := CurrentFileName;
  if SqlFileSD.Execute
  then SynEdit.Lines.SaveToFile(SqlFileSD.FileName);
end;

procedure TForm1.SqlReplaceDialogFind(Sender: TObject);
var
  SelStart: Integer;
begin
  if LastFindTxt <> SqlReplaceDialog.FindText then begin
    LastFindTxt := SqlReplaceDialog.FindText;
    SynEditSearch.Pattern := LastFindTxt;
    SelStart := SynEditSearch.FindFirst(Synedit.Lines.Text);
  end else begin
    SelStart := SynEditSearch.Next;
  end;
  if SelStart > 0 then begin
    SynEdit.SelStart := SelStart - 1;
    SynEdit.SelLength := length(LastFindTxt);
  end;
end;

procedure TForm1.SqlReplaceDialogReplace(Sender: TObject);
begin
  MessageDlg('Replace is not implemented yet.', mtError, [mbOk], 0);
end;

procedure TForm1.StartTransactionBtnClick(Sender: TObject);
begin
  DBConn.StartTransaction;
end;

procedure TForm1.StoreConnectionProfile;
var
  x: Integer;
  found: Boolean;
  Protocol: String;
  Server: String;
  IniFile: TIniFile;
  SectionName: String;
  Properties: TStringList;
begin
  Protocol := ProtocolsCB.Text;
  Server := HostEdt.Text;

  x := -1;
  found := false;

  while not found and ((x + 1) < Length(FConnectionProfiles)) do begin
    inc(x);
    if (Protocol = FConnectionProfiles[x].Protocol) and
       (Server = FConnectionProfiles[x].HostName)
    then found := true;
  end;

  if not found then begin
    x := Length(FConnectionProfiles);
    SetLength(FConnectionProfiles, x + 1);
  end;

  FConnectionProfiles[x].Protocol := DBConn.Protocol;
  FConnectionProfiles[x].HostName := DBConn.HostName;
  FConnectionProfiles[x].Database := DBConn.Database;
  FConnectionProfiles[x].ClientLibrary := DBConn.LibraryLocation;
  FConnectionProfiles[x].UserName := DBConn.User;
  FConnectionProfiles[x].Properties := PropertiesM.Text;

  if FIniFileName <> '' then begin
    SectionName := ConnectionProfilePrefix + IntToStr(x);
    if ForceDirectories(ExtractFileDir(FIniFileName)) then begin
      IniFile := TIniFile.Create(FIniFileName);
      try
        IniFile.WriteString(SectionName, 'Protocol', FConnectionProfiles[x].Protocol);
        IniFile.WriteString(SectionName, 'HostName', FConnectionProfiles[x].HostName);
        IniFile.WriteString(SectionName, 'DataBase', FConnectionProfiles[x].Database);
        IniFile.WriteString(SectionName, 'ClientLibrary', FConnectionProfiles[x].ClientLibrary);
        IniFile.WriteString(SectionName, 'UserName', FConnectionProfiles[x].UserName);
        Properties := TStringList.Create;
        try
          Properties.Text := FConnectionProfiles[x].Properties;
          Properties.Delimiter := ';';
          IniFile.WriteString(SectionName, 'Properties', Properties.DelimitedText);
        finally
          FreeAndNil(Properties);
        end;
      finally
        FreeAndNil(IniFile);
      end;
    end;
  end;
end;

procedure TForm1.UpdateMessages;
var
  Warning: EZSQLThrowable;
  Statement: IZStatement;
  Result: IZResultSet;
begin
  Warning := DBConn.DbcConnection.GetWarnings;
  if Assigned(Warning)
  then MessagesM.Lines.Add(Warning.Message);
  DBConn.DbcConnection.ClearWarnings;

  Statement := MainQ.DbcStatement;
  if assigned(Statement) then begin
    Warning := Statement.GetWarnings;
    if Assigned(Warning)
    then MessagesM.Lines.Add(Warning.Message);
    Statement.ClearWarnings;
  end;

  Result := MainQ.DbcResultSet;
  if assigned(Result) then begin
    Warning := Result.GetWarnings;
    if Assigned(Warning)
    then MessagesM.Lines.Add(Warning.Message);
    Result.ClearWarnings;
  end;
end;

end.
