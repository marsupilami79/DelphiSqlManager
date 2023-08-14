object Form1: TForm1
  Left = 0
  Top = 0
  Caption = 'Form1'
  ClientHeight = 612
  ClientWidth = 970
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  DesignSize = (
    970
    612)
  TextHeight = 13
  object Label9: TLabel
    Left = 306
    Top = 41
    Width = 36
    Height = 13
    Caption = 'Server:'
  end
  object PageControl2: TPageControl
    Left = 8
    Top = 8
    Width = 953
    Height = 596
    ActivePage = ConnectionTS
    Anchors = [akLeft, akTop, akRight, akBottom]
    TabOrder = 0
    ExplicitWidth = 949
    ExplicitHeight = 595
    object ConnectionTS: TTabSheet
      Caption = 'Connection'
      ImageIndex = 2
      DesignSize = (
        945
        568)
      object Label1: TLabel
        Left = 167
        Top = 9
        Width = 36
        Height = 13
        Caption = 'Server:'
      end
      object Label2: TLabel
        Left = 350
        Top = 6
        Width = 50
        Height = 13
        Caption = 'Database:'
      end
      object Label3: TLabel
        Left = 16
        Top = 8
        Width = 43
        Height = 13
        Caption = 'Protocol:'
      end
      object Label5: TLabel
        Left = 16
        Top = 97
        Width = 56
        Height = 13
        Caption = 'User Name:'
      end
      object Label6: TLabel
        Left = 167
        Top = 97
        Width = 56
        Height = 13
        AutoSize = False
        Caption = 'Password:'
      end
      object Label4: TLabel
        Left = 16
        Top = 52
        Width = 67
        Height = 13
        Caption = 'Client Library:'
      end
      object Label7: TLabel
        Left = 16
        Top = 141
        Width = 53
        Height = 13
        Caption = 'Properties:'
      end
      object Label10: TLabel
        Left = 294
        Top = 9
        Width = 24
        Height = 13
        Caption = 'Port:'
      end
      object BrowseClientLibBtn: TButton
        Left = 733
        Top = 68
        Width = 108
        Height = 25
        Anchors = [akTop, akRight]
        Caption = 'Browse'
        TabOrder = 5
        OnClick = BrowseClientLibBtnClick
        ExplicitLeft = 729
      end
      object BrowseDatabaseBtn: TButton
        Left = 733
        Top = 23
        Width = 108
        Height = 25
        Anchors = [akTop, akRight]
        Caption = 'Browse'
        TabOrder = 3
        OnClick = BrowseDatabaseBtnClick
        ExplicitLeft = 729
      end
      object ClientLibEdt: TEdit
        Left = 16
        Top = 70
        Width = 711
        Height = 21
        Anchors = [akLeft, akTop, akRight]
        TabOrder = 4
        ExplicitWidth = 707
      end
      object ConnectBtn: TButton
        Left = 845
        Top = 23
        Width = 96
        Height = 115
        Anchors = [akTop, akRight]
        Caption = 'Connect'
        Default = True
        TabOrder = 9
        OnClick = ConnectBtnClick
        ExplicitLeft = 841
      end
      object DatabaseEdt: TEdit
        Left = 350
        Top = 25
        Width = 377
        Height = 21
        Anchors = [akLeft, akTop, akRight]
        TabOrder = 2
        Text = 'St'#246'rk'
        ExplicitWidth = 373
      end
      object HostEdt: TEdit
        Left = 167
        Top = 25
        Width = 121
        Height = 21
        TabOrder = 1
        Text = 'paulchen\sqlexpress2016'
        OnExit = HostEdtExit
      end
      object PasswordEdt: TEdit
        Left = 167
        Top = 116
        Width = 560
        Height = 21
        Anchors = [akLeft, akTop, akRight]
        PasswordChar = '*'
        TabOrder = 7
        ExplicitWidth = 556
      end
      object ProtocolsCB: TComboBox
        Left = 16
        Top = 25
        Width = 145
        Height = 21
        Style = csDropDownList
        Sorted = True
        TabOrder = 0
        OnChange = ProtocolsCBChange
      end
      object UserNameEdt: TEdit
        Left = 16
        Top = 116
        Width = 145
        Height = 21
        TabOrder = 6
      end
      object PropertiesM: TMemo
        Left = 16
        Top = 160
        Width = 825
        Height = 377
        Anchors = [akLeft, akTop, akRight, akBottom]
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Courier New'
        Font.Style = []
        ParentFont = False
        TabOrder = 8
        ExplicitWidth = 821
        ExplicitHeight = 376
      end
      object ConnectionSB: TStatusBar
        Left = 0
        Top = 549
        Width = 945
        Height = 19
        Panels = <>
        SimplePanel = True
        ExplicitTop = 548
        ExplicitWidth = 941
      end
      object PortEdt: TEdit
        Left = 294
        Top = 25
        Width = 50
        Height = 21
        TabOrder = 11
        Text = '0'
        OnExit = HostEdtExit
      end
    end
    object SqlTS: TTabSheet
      Caption = 'SQL'
      object Splitter1: TSplitter
        Left = 0
        Top = 401
        Width = 945
        Height = 3
        Cursor = crVSplit
        Align = alBottom
        Beveled = True
        ExplicitLeft = 3
        ExplicitTop = 255
        ExplicitWidth = 846
      end
      object Splitter2: TSplitter
        Left = 168
        Top = 41
        Height = 360
        ExplicitTop = 96
        ExplicitHeight = 100
      end
      object ResultTS: TPageControl
        Left = 0
        Top = 404
        Width = 945
        Height = 145
        ActivePage = DataSheet
        Align = alBottom
        TabOrder = 0
        object MessagesSheet: TTabSheet
          Caption = 'Messages'
          object MessagesM: TMemo
            Left = 0
            Top = 0
            Width = 937
            Height = 117
            Align = alClient
            TabOrder = 0
          end
        end
        object DataSheet: TTabSheet
          Caption = 'Data'
          ImageIndex = 1
          object Panel3: TPanel
            Left = 0
            Top = 0
            Width = 752
            Height = 117
            Align = alClient
            Caption = 'Panel3'
            TabOrder = 0
            DesignSize = (
              752
              117)
            object Splitter3: TSplitter
              Left = 748
              Top = 1
              Height = 115
              Align = alRight
              ExplicitLeft = 752
              ExplicitTop = 24
              ExplicitHeight = 100
            end
            object DataG: TDBGrid
              Left = 0
              Top = 0
              Width = 744
              Height = 81
              Anchors = [akLeft, akTop, akRight, akBottom]
              DataSource = MainDS
              Options = [dgEditing, dgTitles, dgIndicator, dgColumnResize, dgColLines, dgRowLines, dgTabs, dgConfirmDelete, dgCancelOnExit, dgMultiSelect, dgTitleClick, dgTitleHotTrack]
              TabOrder = 0
              TitleFont.Charset = DEFAULT_CHARSET
              TitleFont.Color = clWindowText
              TitleFont.Height = -11
              TitleFont.Name = 'Tahoma'
              TitleFont.Style = []
              OnColEnter = DataGColEnter
            end
            object DBNavigator1: TDBNavigator
              Left = 3
              Top = 87
              Width = 240
              Height = 25
              DataSource = MainDS
              Anchors = [akLeft, akBottom]
              TabOrder = 1
            end
            object exportDataCsvBtn: TButton
              Left = 646
              Top = 87
              Width = 100
              Height = 25
              Anchors = [akRight, akBottom]
              Caption = 'export to CSV'
              Enabled = False
              TabOrder = 2
              OnClick = exportDataCsvBtnClick
            end
          end
          object Memo1: TMemo
            Left = 752
            Top = 0
            Width = 185
            Height = 117
            Align = alRight
            Lines.Strings = (
              'Memo1')
            TabOrder = 1
          end
        end
      end
      object SynEdit: TSynEdit
        Left = 171
        Top = 41
        Width = 774
        Height = 360
        Align = alClient
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = 'Courier New'
        Font.Style = []
        TabOrder = 1
        CodeFolding.GutterShapeSize = 11
        CodeFolding.CollapsedLineColor = clGrayText
        CodeFolding.FolderBarLinesColor = clGrayText
        CodeFolding.IndentGuidesColor = clGray
        CodeFolding.IndentGuides = True
        CodeFolding.ShowCollapsedLine = False
        CodeFolding.ShowHintMark = True
        UseCodeFolding = False
        Gutter.Font.Charset = DEFAULT_CHARSET
        Gutter.Font.Color = clWindowText
        Gutter.Font.Height = -11
        Gutter.Font.Name = 'Courier New'
        Gutter.Font.Style = []
        Gutter.ShowLineNumbers = True
        Highlighter = SynSQLSyn
        Lines.Strings = (
          '')
        SearchEngine = SynEditSearch
        FontSmoothing = fsmNone
      end
      object Panel1: TPanel
        Left = 0
        Top = 0
        Width = 945
        Height = 41
        Align = alTop
        TabOrder = 2
        object RunSqlBtn: TButton
          Left = 0
          Top = 10
          Width = 63
          Height = 25
          Caption = 'Run'
          TabOrder = 0
          OnClick = RunSqlBtnClick
        end
        object StartTransactionBtn: TButton
          Left = 197
          Top = 10
          Width = 100
          Height = 25
          Caption = 'Start Transaction'
          TabOrder = 1
          OnClick = StartTransactionBtnClick
        end
        object CommitBtn: TButton
          Left = 302
          Top = 10
          Width = 100
          Height = 25
          Caption = 'Commit'
          TabOrder = 2
          OnClick = CommitBtnClick
        end
        object RollbackBtn: TButton
          Left = 408
          Top = 10
          Width = 100
          Height = 25
          Caption = 'Rollback'
          TabOrder = 3
          OnClick = RollbackBtnClick
        end
        object FindReplaceBtn: TButton
          Left = 514
          Top = 10
          Width = 100
          Height = 25
          Caption = 'Find / Replace'
          TabOrder = 4
          OnClick = FindReplaceBtnClick
        end
        object OpenFileBtn: TButton
          Left = 620
          Top = 10
          Width = 100
          Height = 25
          Caption = 'Open File'
          TabOrder = 5
          OnClick = OpenFileBtnClick
        end
        object SaveFileBtn: TButton
          Left = 726
          Top = 10
          Width = 100
          Height = 25
          Caption = 'Save File'
          TabOrder = 6
          OnClick = SaveFileBtnClick
        end
      end
      object StatusSB: TStatusBar
        Left = 0
        Top = 549
        Width = 945
        Height = 19
        Panels = <>
        SimplePanel = True
      end
      object MetadataTreeV: TTreeView
        Left = 0
        Top = 41
        Width = 168
        Height = 360
        Align = alLeft
        Indent = 19
        PopupMenu = MetadataPM
        ReadOnly = True
        TabOrder = 4
        OnContextPopup = MetadataTreeVContextPopup
        OnDblClick = MetadataTreeVDblClick
      end
    end
    object MetadataTS: TTabSheet
      Caption = 'Metadata'
      ImageIndex = 1
      object Panel2: TPanel
        Left = 0
        Top = 0
        Width = 945
        Height = 57
        Align = alTop
        TabOrder = 0
        object Label8: TLabel
          Left = 0
          Top = 5
          Width = 77
          Height = 13
          Caption = 'Metadata Type:'
        end
        object MetaDataObjectNameL: TLabel
          Left = 160
          Top = 5
          Width = 111
          Height = 13
          Caption = 'MetaDataObjectNameL'
        end
        object MetaDataObjectName2L: TLabel
          Left = 311
          Top = 5
          Width = 111
          Height = 13
          Caption = 'MetaDataObjectNameL'
        end
        object MetadataCB: TComboBox
          Left = 0
          Top = 24
          Width = 154
          Height = 21
          Style = csDropDownList
          ItemIndex = 14
          TabOrder = 0
          Text = 'Tables'
          OnChange = MetadataCBChange
          Items.Strings = (
            'BestRowIdentifier'
            'Catalogs'
            'ColumnPrivileges'
            'Columns'
            'CrossReference'
            'ExportedKeys'
            'ImportedKeys'
            'IndexInfo'
            'PrimaryKeys'
            'ProcedureColumns'
            'Procedures'
            'Schemas'
            'Sequences'
            'TablePrivileges'
            'Tables'
            'TableTypes'
            'Triggers'
            'TypeInfo'
            'UserDefinedTypes'
            'VersionColumns')
        end
        object MetaDataObjectNameCB: TComboBox
          Left = 160
          Top = 24
          Width = 145
          Height = 21
          TabOrder = 1
        end
        object fetchMetadataBtn: TButton
          Left = 463
          Top = 24
          Width = 100
          Height = 25
          Caption = 'Fetch Metadata'
          TabOrder = 3
          OnClick = fetchMetadataBtnClick
        end
        object exportMetadataCsvBtn: TButton
          Left = 569
          Top = 24
          Width = 100
          Height = 25
          Caption = 'export to CSV'
          TabOrder = 4
          OnClick = exportMetadataCsvBtnClick
        end
        object MetaDataObjectName2CB: TComboBox
          Left = 311
          Top = 24
          Width = 145
          Height = 21
          TabOrder = 2
        end
      end
      object DBGrid2: TDBGrid
        Left = 0
        Top = 57
        Width = 945
        Height = 511
        Align = alClient
        DataSource = MetadataDS
        TabOrder = 1
        TitleFont.Charset = DEFAULT_CHARSET
        TitleFont.Color = clWindowText
        TitleFont.Height = -11
        TitleFont.Name = 'Tahoma'
        TitleFont.Style = []
      end
    end
  end
  object SynSQLSyn: TSynSQLSyn
    Options.AutoDetectEnabled = False
    Options.AutoDetectLineLimit = 0
    Options.Visible = False
    CommentAttri.Foreground = clGreen
    StringAttri.Foreground = clBlue
    TableNameAttri.Foreground = clBlue
    TableNameAttri.Style = [fsBold]
    SQLDialect = sqlMSSQL2K
    Left = 232
    Top = 128
  end
  object DBConn: TZConnection
    ControlsCodePage = cCP_UTF16
    ClientCodepage = 'UTF8'
    Catalog = ''
    Properties.Strings = (
      'codepage=UTF8')
    TransactIsolationLevel = tiReadCommitted
    LoginPrompt = True
    AfterConnect = DBConnAfterConnect
    AfterDisconnect = DBConnAfterDisconnect
    SQLHourGlass = True
    OnCommit = DBConnCommit
    OnRollback = DBConnRollback
    OnStartTransaction = DBConnStartTransaction
    HostName = ''
    Port = 0
    Database = ''
    User = ''
    Password = ''
    Protocol = 'firebird'
    LibraryLocation = 'sybdb.dll'
    Left = 312
    Top = 128
  end
  object MainDS: TDataSource
    DataSet = MainQ
    Left = 416
    Top = 128
  end
  object MainQ: TZQuery
    AfterOpen = MainQAfterOpen
    AfterClose = MainQAfterClose
    Connection = DBConn
    Params = <>
    Options = [doCalcDefaults, doSmartOpen]
    Left = 360
    Top = 128
  end
  object ZSQLMonitor1: TZSQLMonitor
    AutoSave = True
    FileName = 'c:\users\jan\desktop\zeoslog.txt'
    MaxTraceCount = 100
    Left = 312
    Top = 187
  end
  object MetadataMD: TZSQLMetadata
    AfterOpen = MetadataMDAfterOpen
    Connection = DBConn
    MetadataType = mdProcedures
    Left = 316
    Top = 252
  end
  object MetadataDS: TDataSource
    DataSet = MetadataMD
    Left = 364
    Top = 252
  end
  object ClientLibraryOD: TOpenDialog
    DefaultExt = '*.dll'
    Filter = 'Libraries (*.dll)|*.dll'
    Left = 544
    Top = 56
  end
  object FirebirdDatabaseOD: TOpenDialog
    DefaultExt = '*.fdb'
    Filter = 'Firebird Database (*.fdb)|*.fdb'
    Left = 544
    Top = 8
  end
  object SynEditSearch: TSynEditSearch
    Left = 228
    Top = 184
  end
  object SqlReplaceDialog: TReplaceDialog
    Options = [frDown, frDisableMatchCase, frDisableWholeWord]
    OnFind = SqlReplaceDialogFind
    OnReplace = SqlReplaceDialogReplace
    Left = 476
    Top = 64
  end
  object SqlFileOD: TOpenDialog
    DefaultExt = '*.sql'
    Filter = 'SQL Files (*.sql)|*.sql|All Files (*.*)|*.*'
    Title = 'Open SQL File'
    Left = 632
    Top = 8
  end
  object SqlFileSD: TSaveDialog
    DefaultExt = '*.sql'
    Filter = 'SQL Files (*.sql)|*.sql|All Files (*.*)|*.*'
    Title = 'Save SQL File'
    Left = 628
    Top = 56
  end
  object exportCsvSD: TSaveDialog
    DefaultExt = '*.csv'
    Filter = 'CSV Files (*.csv)|*.csv|All File Types|*.*'
    Left = 548
    Top = 112
  end
  object SqlProc: TZSQLProcessor
    Params = <>
    Connection = DBConn
    DelimiterType = dtSetTerm
    Delimiter = ';'
    Left = 356
    Top = 184
  end
  object MetadataPM: TPopupMenu
    Left = 92
    Top = 336
  end
  object ZMemTable1: TZMemTable
    ControlsCodePage = cDynamic
    Left = 212
    Top = 336
  end
end
