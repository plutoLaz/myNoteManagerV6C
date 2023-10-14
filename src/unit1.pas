unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, clocale, Forms, Controls, Graphics, Dialogs, ExtCtrls, ComCtrls,
  Buttons, StdCtrls, CheckLst, ActnList, fpjson, jsonparser, StrUtils, DateUtils,
  LCLType, unit2,
  uplmyhorizontalbar, unit_EditorFrame, unmv6c_sqlite, unmv6c_type, unmv6c_createtextbricks, Types;

type

  { TNMV6C_TabSheet }
  TNMV6C_TabSheet = class(TTabSheet)
  private
    fModified: Boolean;
    procedure SetModified(AValue: Boolean);

  protected

  public
    NoteObject:TJSONObject;
    Editor_Frame:TEditorFrame;
    NoEvent:Boolean;

    constructor Create(TheOwner: TComponent); override;
    destructor Destroy; override;

    procedure UpdateNoteObject();
    procedure UpdateChangeStatus();

    procedure ChangeUserInput(sender:TObject);
    property Modified:Boolean read fModified write SetModified;
  published
  end; // TNMV6C_TabSheet

  { TForm1 }
  TForm1 = class(TForm)
    acSaveNote: TAction;
    acDeleteNote: TAction;
    acNewNote: TAction;
    ActionList1: TActionList;
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    BitBtn3: TBitBtn;
    BitBtn4: TBitBtn;
    BitBtn5: TBitBtn;
    BitBtn6: TBitBtn;
    BitBtn7: TBitBtn;
    btDeleteNote: TBitBtn;
    btNewNote: TBitBtn;
    btSaveNote: TBitBtn;
    btNewDB: TBitBtn;
    btOpenDB: TBitBtn;
    btSaveDB: TBitBtn;
    btSaveAsDB: TBitBtn;
    btImportOldDB: TBitBtn;
    CheckBox1: TCheckBox;
    CheckListBox1: TCheckListBox;
    Label2: TLabel;
    Label3: TLabel;
    lbDataBaseName: TLabel;
    lbNoteCount: TLabel;
    NoteBrowser: TListView;
    OpenDialog1: TOpenDialog;
    PageControl1: TPageControl;
    OpenNotes: TPageControl;
    PageControl2: TPageControl;
    Panel1: TPanel;
    Panel2: TPanel;
    Panel3: TPanel;
    Panel4: TPanel;
    SaveDialog1: TSaveDialog;
    SpeedButton1: TSpeedButton;
    SpeedButton2: TSpeedButton;
    Splitter1: TSplitter;
    Splitter2: TSplitter;
    Splitter3: TSplitter;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    TabSheet3: TTabSheet;
    tsDataBase: TTabSheet;
    tsTags: TTabSheet;
    tsFilter1: TTabSheet;
    tsFilter2: TTabSheet;
    procedure acDeleteNoteExecute(Sender: TObject);
    procedure acNewNoteExecute(Sender: TObject);
    procedure acSaveNoteExecute(Sender: TObject);
    procedure BitBtn2Click(Sender: TObject);
    procedure BitBtn3Click(Sender: TObject);
    procedure BitBtn4Click(Sender: TObject);
    procedure BitBtn5Click(Sender: TObject);
    procedure BitBtn6Click(Sender: TObject);
    procedure BitBtn7Click(Sender: TObject);
    procedure btImportOldDBClick(Sender: TObject);
    procedure btNewDBClick(Sender: TObject);
    procedure btNewNoteClick(Sender: TObject);
    procedure btOpenDBClick(Sender: TObject);
    procedure CheckBox1Click(Sender: TObject);
    procedure CheckListBox1ClickCheck(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure NoteBrowserColumnClick(Sender: TObject; Column: TListColumn);
    procedure NoteBrowserCompare(Sender: TObject; Item1, Item2: TListItem;
      Data: Integer; var Compare: Integer);
    procedure NoteBrowserMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure OpenNotesChange(Sender: TObject);
    procedure OpenNotesCloseTabClicked(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
  private
    fLastDBFile: String;
    procedure SetLastDBFile(AValue: String);

  public
    NoteManagerV6C:TPLNMV6C_sqlite;
    CreateTextBricks:TNMV6C_CreateTextBricks;
    MyHorizontalBar:TMyHorizontalBar;

    AppDir, ConfigFile:String;
    LastSortedColumn:Integer;

    procedure InitDB();

    procedure NoteAddToNoteBrowser(aNoteObject:TJSONObject);
    procedure NotesAddToNoteBrowser(aNoteObject:TJSONObject; const aClear:Boolean = False);
    function FindNoteIDInNoteBrowser(const aUUID:String):TListItem;
    function FindNoteIDInOpenNotes(const aUUID:String):TNMV6C_TabSheet;
    function NoteSave(aEditorTab:TNMV6C_TabSheet):Boolean;

    procedure TagAddToTagList(aTagObject:TJSONObject);
    procedure TagsAddToTagList(aTagObject:TJSONObject; const aClear:Boolean= False);
    function FindTagInCheckList(const aID:integer):integer;
    procedure UpdateTagCheckList(const aNoteUUID: String);

    procedure AddOrChangeEditorTabSheet(aNoteObject:TJSONObject; aNewTab:Boolean);

    function LoadDataBase(const aFileName:String; const aReloadDB:Boolean = False):Boolean;
    function Clear():Boolean;

    procedure CheckAllTab(var aStringList:TStrings);
    function CheckSave(EditorTab:TNMV6C_TabSheet):boolean;
    function CheckSaveNotes():Boolean;

    procedure SQLResultAddNotes(aNoteObject:TJSONObject);
    procedure SQLResultGetNotes(aNoteObject:TJSONObject);
    procedure SQLResultUpdateNote(aNoteObject:TJSONObject);
    procedure SQLResultDeleteNote(aNoteIDList: TJSONArray);

    procedure SQLResultAddTag(aTagObject:TJSONObject);
    procedure SQLResultGetTags(aTagObject:TJSONObject);

    procedure BarChecked(sender:TObject);

    procedure LoadConfigFile(const aConfigFile:String);
    procedure SaveConfigFile(const aConfigFile:String);

    property LastDBFile:String read fLastDBFile write SetLastDBFile;
  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

function CompareTextAsDateTime(const s1, s2: string): Integer;
var
  DateTime1, DateTime2:TDateTime;
begin
  DateTime1:=StrToDateTime(s1, Form1.NoteManagerV6C.myFormatSettings);
  DateTime2:=StrToDateTime(s2, Form1.NoteManagerV6C.myFormatSettings);
  Result := CompareDateTime(DateTime1, DateTime2);
end; // CompareTextAsDateTime

{ TNMV6C_TabSheet }

procedure TNMV6C_TabSheet.SetModified(AValue: Boolean);
begin
  if fModified <> AValue then begin
    fModified:=AValue;
    UpdateChangeStatus();
  end;
end; // TNMV6C_TabSheet.SetModified

constructor TNMV6C_TabSheet.Create(TheOwner: TComponent);
begin
  inherited Create(TheOwner);
  NoEvent:=False;
  NoteObject:=nil;
  Editor_Frame:=TEditorFrame.Create(self);
  Editor_Frame.Parent:=self;
  Editor_Frame.Align:=alClient;
  Editor_Frame.edTitle.OnChange:=@ChangeUserInput;
  Editor_Frame.SEEditor.OnChange:=@ChangeUserInput;

  fModified:=False;
end; // TNMV6C_TabSheet.Create

destructor TNMV6C_TabSheet.Destroy;
begin
  FreeAndNil(Editor_Frame);
  inherited Destroy;
end; // TNMV6C_TabSheet.Destroy

procedure TNMV6C_TabSheet.UpdateNoteObject();
var
  jData:TJSONData;
begin
  jData:=NoteObject.find('title');
  if Assigned(jData) then
    jData.AsString:=Editor_Frame.edTitle.Text;

  jData:=NoteObject.find('content');
  if Assigned(jData) then
    jData.AsString:=Editor_Frame.SEEditor.Lines.Text;
end; // TNMV6C_TabSheet.UpdateNoteObject

procedure TNMV6C_TabSheet.UpdateChangeStatus();
var
  Title, Status:String;
  jData:TJSONData;
begin
  Title:=''; Status:='';
  if not NoEvent then begin
    if Assigned(NoteObject) then begin
      jData:=NoteObject.Find('title');
      if Assigned(jData) then begin
        Title:=jData.AsString;
      end;

      if fModified then begin
        Status:='geändert';
        Caption:='*' + Title;
      end
      else begin
        Status:='nicht geändert';
        Caption:=Title;
      end;

      Editor_Frame.Caption:=Status;
    end;
  end;
end; // TNMV6C_TabSheet.UpdateChangeStatus

procedure TNMV6C_TabSheet.ChangeUserInput(sender: TObject);
begin
  Modified:=True;
end; // TNMV6C_TabSheet.ChangeUserInput


procedure TForm1.acSaveNoteExecute(Sender: TObject);
begin
  if Assigned(OpenNotes.ActivePage) then
    NoteSave(OpenNotes.ActivePage as TNMV6C_TabSheet);
end;

procedure TForm1.acDeleteNoteExecute(Sender: TObject);
var
  msgStr, uuidStr:String;
  NoteObject:TJSONObject;
  JArray:TJSONArray;

  Reply, BoxStyle: Integer;
  i:Integer;
begin
  try
    BoxStyle := MB_ICONERROR+ MB_YESNOCANCEL;
    Reply := Application.MessageBox('Wirklich löschen ?', 'Löschen?', BoxStyle);
    if Reply = IDCANCEL then
      exit
    else begin
      if Reply = IDYES then begin
        JArray:=TJSONArray.Create();
        for i:=NoteBrowser.Items.Count -1 downto 0 do begin
          if NoteBrowser.Items[i].Selected then begin
            NoteObject:=TJSONObject(NoteBrowser.Items[i].Data);
            uuidStr:=NoteObject.Elements['uuid'].AsString;
            JArray.Add(uuidStr);
          end;
        end; // for i
        NoteManagerV6C.DeleteNote(JArray);
      end
    end;

  except
    on E: Exception do begin
      msgStr:=E.Message;
      writeln(#13, 'TPLNMV6C_sqlite.DeleteNote:',msgStr);
//      doOnSQLResultError(EVT_ERROR,msgStr,'TPLNMV6C_sqlite.DeleteNote');
      raise;
    end;
  end;
end;

procedure TForm1.acNewNoteExecute(Sender: TObject);
var
  JNoteObject:TJSONObject;
  NoteTitle:String;
begin
  NoteTitle:='';
  if InputQuery('Notiz Title eingeben', 'Title', NoteTitle) then begin
    JNoteObject:=TJSONObject.Create();
    JNoteObject.Add('title', NoteTitle);
    JNoteObject.Add('AutoOpen', True);
    NoteManagerV6C.AddNote(JNoteObject);
  end;
end;

procedure TForm1.BitBtn2Click(Sender: TObject);
var
  NoteObject:TJSONObject;
begin
  NoteObject:=TJSONObject.Create;
  NoteObject.Add('title', 'Note 1');
  NoteObject.Add('content', 'Ein Sinnloser Content');

  NoteManagerV6C.AddNote(NoteObject);
end; // TForm1.BitBtn2Click

procedure TForm1.BitBtn3Click(Sender: TObject);
var
  NoteObject, AddNote, TemplatObject:TJSONObject;
  Notes:TJSONArray;
  i, Count:Integer;
  Title, Content, CountStr:String;
begin
  CountStr:='10';
  if InputQuery('Anzahl der Einträge ?', 'Anzahl',CountStr) then begin
    Notes:=TJSONArray.Create;
    Count:=CountStr.ToInteger;

    for i:=0 to Count do begin
      TemplatObject:=CreateTextBricks.RandomFromTemplate(CreateTextBricks.RandomTemplate());
      Title:=TemplatObject.Elements['Title'].AsString;
      Content:=TemplatObject.Elements['Text'].AsString;

      NoteObject:=TJSONObject.Create;
      NoteObject.Add('title', Title);
      NoteObject.Add('content', Content);
      Notes.Add(NoteObject);
    end;

    AddNote:=TJSONObject.Create;
    AddNote.Add('Notes', Notes);
    NoteManagerV6C.AddNote(AddNote);
  end;

end; // TForm1.BitBtn3Click

procedure TForm1.BitBtn4Click(Sender: TObject);
begin
  NoteManagerV6C.SQLTransaction.Commit;
end;

procedure TForm1.BitBtn5Click(Sender: TObject);
begin
  NoteManagerV6C.GetNotes(nil, true);
end;

procedure TForm1.BitBtn6Click(Sender: TObject);
var
  TagName:String;
  TagObject:TJSONObject;
begin
  TagName:='';
  if InputQuery('Tag Name', 'Name', TagName) then begin
    TagObject:=TJSONObject.Create();
    TagObject.Add('name', TagName);

    NoteManagerV6C.AddTag(TagObject);
  end;
end;

procedure TForm1.BitBtn7Click(Sender: TObject);
begin
  NoteManagerV6C.GetTags(False);
end;

procedure TForm1.btImportOldDBClick(Sender: TObject);
begin
  OpenDialog1.InitialDir:=AppDir;
  if OpenDialog1.Execute then begin
    NoteManagerV6C.ImportFromOldDataBase(OpenDialog1.FileName);
  end;
end;

procedure TForm1.btNewDBClick(Sender: TObject);
var
  CanNew:Boolean;
begin
  SaveDialog1.InitialDir:=AppDir;
  CanNew:=CheckSaveNotes();
  if (CanNew) and (SaveDialog1.Execute) then begin
    if Clear() then begin
      if Assigned(NoteManagerV6C) then FreeAndNil(NoteManagerV6C);
      lbDataBaseName.Caption:=ExtractFileName(SaveDialog1.FileName);
      lbDataBaseName.Hint:=SaveDialog1.FileName;
      InitDB();
      NoteManagerV6C.DB_Name:=SaveDialog1.FileName;
    end;
  end;
end;

procedure TForm1.btNewNoteClick(Sender: TObject);
begin
end;

procedure TForm1.btOpenDBClick(Sender: TObject);
begin
  OpenDialog1.InitialDir:=AppDir;
  if OpenDialog1.Execute then begin
    LoadDataBase(OpenDialog1.FileName, true);
  end;
end;

procedure TForm1.CheckBox1Click(Sender: TObject);
begin
  NoteManagerV6C.AutoCommit:=CheckBox1.Checked;
  if CheckBox1.Checked then NoteManagerV6C.SQLTransaction.Commit;
end;

procedure TForm1.CheckListBox1ClickCheck(Sender: TObject);
var
  NoteObject, TagObject:TJSONObject;
  jData:TJSONData;
  TabSheet:TNMV6C_TabSheet;
  TagID:Integer;
  NoteID:String;
begin
  if CheckListBox1.ItemIndex > -1 then begin
    TabSheet:=OpenNotes.ActivePage as TNMV6C_TabSheet;
    NoteObject:=TabSheet.NoteObject;
    jData:=NoteObject.Find('uuid');
    if Assigned(jData) then begin
      NoteID:=jData.AsString;

      TagObject:=CheckListBox1.Items.Objects[CheckListBox1.ItemIndex] as TJSONObject;
      TagID:=TagObject.Elements['id'].AsInteger;
      if CheckListBox1.Checked[CheckListBox1.ItemIndex] then begin
        NoteManagerV6C.NoteLinketToTag(NoteID, TagID, TA_ADD)
      end
      else begin
        NoteManagerV6C.NoteLinketToTag(NoteID, TagID,TA_REMOVE)
      end;
    end;
  end;
end;

procedure TForm1.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  SaveConfigFile(ConfigFile);
end;

procedure TForm1.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  CanClose:=CheckSaveNotes();
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  CheckListBox1.Enabled:=False;
  Randomize;
  AppDir:=ExtractFileDir(ParamStr(0)) + DirectorySeparator;
  ConfigFile:=AppDir + 'config.json';
  CreateTextBricks:=TNMV6C_CreateTextBricks.Create(AppDir + 'template' + DirectorySeparator);

  MyHorizontalBar:=TMyHorizontalBar.Create(tsTags);
  MyHorizontalBar.Parent:=tsTags;
  MyHorizontalBar.Align:=alClient;
//  MyHorizontalBar.OnChangeIndex:=@ChangeItemIndex;
  MyHorizontalBar.OnChecked:=@BarChecked;

  InitDB();
  CheckBox1.Checked:=NoteManagerV6C.AutoCommit;

  LoadConfigFile(ConfigFile);

  LoadDataBase(AppDir + 'test01.db');
//   NoteManagerV6C.GetTags(False);
end; // TForm1.FormCreate

procedure TForm1.FormDestroy(Sender: TObject);
begin
  FreeAndNil(NoteManagerV6C); FreeAndNil(CreateTextBricks); FreeAndNil(MyHorizontalBar);
end; // TForm1.FormDestroy

procedure TForm1.NoteBrowserColumnClick(Sender: TObject; Column: TListColumn);
begin
  LastSortedColumn:=Column.Index;
  if Column.SortIndicator = siAscending then
    Column.SortIndicator:=siDescending
  else
    Column.SortIndicator:=siAscending;
end;

procedure TForm1.NoteBrowserCompare(Sender: TObject; Item1, Item2: TListItem; Data: Integer; var Compare: Integer);
var
  JObject1, JObject2:TJSONObject;
  DateTime1, DateTime2:String;
  msgStr:String;
begin
  try
    case NoteBrowser.SortColumn of
      0 : Compare := NaturalCompareText(Item1.Caption, Item2.Caption);

      1 : begin
        JObject1:=TJSONObject(Item1.Data);
        JObject2:=TJSONObject(Item2.Data);
        DateTime1:=JObject1.Elements['ctime'].AsString;
        DateTime2:=JObject2.Elements['ctime'].AsString;
        if (DateTime1 <> '') and (DateTime2 <> '') then
          Compare := CompareTextAsDateTime(DateTime1, DateTime2);
      end; // ctime

      2 : begin
        JObject1:=TJSONObject(Item1.Data);
        JObject2:=TJSONObject(Item2.Data);
        DateTime1:=JObject1.Elements['mtime'].AsString;
        DateTime2:=JObject2.Elements['mtime'].AsString;

        if (DateTime1 <> '') and (DateTime2 <> '') then
          Compare := CompareTextAsDateTime(DateTime1, DateTime2);
      end; // mtime

      3 : begin
        JObject1:=TJSONObject(Item1.Data);
        JObject2:=TJSONObject(Item2.Data);
        DateTime1:=JObject1.Elements['atime'].AsString;
        DateTime2:=JObject2.Elements['atime'].AsString;

        if (DateTime1 <> '') and (DateTime2 <> '') then
          Compare := CompareTextAsDateTime(DateTime1, DateTime2);
      end;
    end; // atime

    if TListView(Sender).SortDirection = sdDescending then
      Compare := -Compare;
  except
    on E: Exception do begin
      msgStr:=E.Message;
      writeln(#13, 'TPLNMV6C_sqlite.AddNote:',msgStr);
//    doOnSQLResultError(EVT_ERROR,msgStr,'TPLNMV6C_sqlite.AddNote');
      raise;
    end;

  end;
end;

procedure TForm1.NoteBrowserMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  NoteObject:TJSONObject;
  Temp_uuid:String;
  ContentStr:String;
  JData:TJSONData;

  TempTabSheet:TNMV6C_TabSheet;
begin
  if Assigned(NoteBrowser.Selected) then begin
    NoteObject:=TJSONObject(NoteBrowser.Selected.Data);
    Temp_uuid:=NoteObject.Elements['uuid'].AsString;


    ContentStr:=NoteManagerV6C.GetContentFromNote(Temp_uuid);

    JData:=NoteObject.Find('content');
    if Assigned(JData) then begin
      JData.AsString:=ContentStr;
    end
    else begin
      NoteObject.Add('content', ContentStr);
    end;

    if (ssDouble in shift) or (ssMiddle in shift) then
      AddOrChangeEditorTabSheet(NoteObject, ssMiddle in Shift);
//    ShowMessage(NoteManagerV6C.GetContentFromNote(Temp_uuid));
  end;
end;

procedure TForm1.OpenNotesChange(Sender: TObject);
var
  EditorTabSheet:TNMV6C_TabSheet;
  NoteUUID:String;
begin
  EditorTabSheet:=OpenNotes.ActivePage as TNMV6C_TabSheet;
  NoteUUID:=EditorTabSheet.NoteObject.Elements['uuid'].AsString;
  UpdateTagCheckList(NoteUUID);
end;

procedure TForm1.OpenNotesCloseTabClicked(Sender: TObject);
var
  PLEditorTab:TNMV6C_TabSheet;
  Reply, BoxStyle: Integer;
begin
  PLEditorTab:=sender as TNMV6C_TabSheet;

  if PLEditorTab.Modified then begin
    BoxStyle := MB_ICONERROR + MB_YESNOCANCEL;
    Reply := Application.MessageBox('Speichern?', 'Noch nicht gespeichert', BoxStyle);
    if Reply = IDYES then begin
      if not NoteSave(PLEditorTab) then
        exit;
    end;
    if Reply = IDCANCEL then
      exit;
  end;
  FreeAndNil(PLEditorTab);

  CheckListBox1.Enabled:=not (OpenNotes.PageCount = 0);
end;

procedure TForm1.SpeedButton1Click(Sender: TObject);
var
  TagObject:TJSONObject;
  TagStr:String;
begin
  TagStr:='';
  if InputQuery('Einen Tag Namen eingeben', 'Tag Name', TagStr) then begin
    TagObject:=TJSONObject.Create();
    TagObject.Add('name',TagStr);

    NoteManagerV6C.AddTag(TagObject, False, False);
  end;
end;

procedure TForm1.SetLastDBFile(AValue: String);
begin
  if fLastDBFile <> AValue then begin
    fLastDBFile:=AValue;
    lbDataBaseName.Caption:=ExtractFileName(AValue);
    lbDataBaseName.Hint:=AValue;
  end;
end; // TForm1.SetLastDBFile

procedure TForm1.InitDB;
begin
  NoteManagerV6C:=TPLNMV6C_sqlite.Create;
  NoteManagerV6C.OnSQLResultAddNote:=@SQLResultAddNotes;
  NoteManagerV6C.OnSQLResultGetNotes:=@SQLResultGetNotes;
  NoteManagerV6C.OnSQLResultUpdateNote:=@SQLResultUpdateNote;
  NoteManagerV6C.OnSQLResultDeleteNote:=@SQLResultDeleteNote;

  NoteManagerV6C.OnSQLResultAddTag:=@SQLResultAddTag;
  NoteManagerV6C.OnSQLResultGetTags:=@SQLResultGetTags;
end; // TForm1.InitDB

procedure TForm1.NoteAddToNoteBrowser(aNoteObject: TJSONObject);
var
  ListItem:TListItem;
  i:Integer;
  TempStr:String;
  TempDateTime:TDateTime;
begin
  ListItem:=TListItem.Create(NoteBrowser.Items);
  ListItem.SubItems.Add(''); // ctime
  ListItem.SubItems.Add(''); // mtime
  ListItem.SubItems.Add(''); // atime
  ListItem.SubItems.Add(''); // acount
  ListItem.SubItems.Add(''); // mcount
  ListItem.Data:=aNoteObject.clone;

  for i:=0 to aNoteObject.Count -1 do begin
    TempStr:=aNoteObject.Names[i];

    case TempStr of
      'title':ListItem.Caption:=aNoteObject.Items[i].AsString;

      'ctime': begin
        TempDateTime:=StrToDateTime(aNoteObject.Items[i].AsString, NoteManagerV6C.myFormatSettings);
        ListItem.SubItems[0]:=FormatDateTime('DDD, DD.MM.YYYY HH:mm', TempDateTime);
      end; // ctime

      'mtime': begin
        TempDateTime:=StrToDateTime(aNoteObject.Items[i].AsString, NoteManagerV6C.myFormatSettings);
        ListItem.SubItems[1]:=FormatDateTime('DDD, DD.MM.YYYY HH:mm', TempDateTime);
      end; // mtime

      'atime': begin
        TempDateTime:=StrToDateTime(aNoteObject.Items[i].AsString, NoteManagerV6C.myFormatSettings);
        ListItem.SubItems[2]:=FormatDateTime('DDD, DD.MM.YYYY HH:mm', TempDateTime);
      end; // atime

      'mcount':ListItem.SubItems[3]:=aNoteObject.Items[i].AsString;
      'acount':ListItem.SubItems[4]:=aNoteObject.Items[i].AsString;
      'AutoOpen': begin
        if aNoteObject.Items[i].AsBoolean then;
          AddOrChangeEditorTabSheet(aNoteObject, true);
      end;
    end; // case of
  end; // for i
  NoteBrowser.Items.AddItem(ListItem);
end; // TForm1.NoteAddToNoteBrowser

procedure TForm1.NotesAddToNoteBrowser(aNoteObject: TJSONObject; const aClear: Boolean);
var
  i:Integer;
  NoteObject:TJSONObject;
  Notes:TJSONArray;
  JData:TJSONData;
  msgStr:String;
begin
  try
    JData:=aNoteObject.Find('Notes');
    if Assigned(JData) then begin
      Notes:=JData as TJSONArray;
      if aClear then NoteBrowser.Items.Clear;
      NoteBrowser.BeginUpdate;
      for i:=0 to Notes.Count -1 do begin
        NoteObject:=Notes[i] as TJSONObject;
        NoteAddToNoteBrowser(NoteObject);
      end; // for i
      NoteBrowser.EndUpdate;
    end
    else begin
      NoteAddToNoteBrowser(aNoteObject);
    end;
    lbNoteCount.Caption:=IntToStr(NoteBrowser.Items.Count);
    NoteBrowser.SortColumn:=1;
    NoteBrowser.SortDirection:=sdDescending;
    NoteBrowser.Sort;
  except
    on E: Exception do begin
      msgStr:=E.Message;
      writeln(#13, 'TForm1.NotesAddToNoteBrowser:',msgStr);
//       doOnSQLResultError(EVT_ERROR,msgStr,'TForm1.FindNoteIDInOpenNotes');
      raise;
    end;
  end;

end; // TForm1.NotesAddToNoteBrowser

function TForm1.FindNoteIDInNoteBrowser(const aUUID: String): TListItem;
var
  i:Integer;
  jData:TJSONData;
  NoteObject:TJSONObject;
begin
  result:=nil;
  for i:=0 to NoteBrowser.Items.Count -1 do begin
    NoteObject:=TJSONObject(NoteBrowser.Items[i].Data);
    jData:=NoteObject.Find('uuid');
    if Assigned(jData) then begin
      if jData.AsString = aUUID then begin
        result:=NoteBrowser.Items[i];
        break;
      end;
    end;
  end; // for i
end; // TForm1.FindNoteIDInNoteBrowser

function TForm1.FindNoteIDInOpenNotes(const aUUID: String): TNMV6C_TabSheet;
var
  i:Integer;
  TabSheet:TNMV6C_TabSheet;
  NoteObject:TJSONObject;
  jData:TJSONData;
  msgStr:string;
begin
  result:=nil;
  try
    try
      for i:=0 to OpenNotes.PageCount - 1 do begin
        TabSheet:=OpenNotes.Page[i] as TNMV6C_TabSheet;
        NoteObject:=TabSheet.NoteObject;
        jData:=NoteObject.Find('uuid');
        if Assigned(jData) then begin
          if jData.AsString = aUUID then begin
            result:=TabSheet;
            break;
          end;
        end;

      end; // for i
    finally
    end;
  except
    on E: Exception do begin
      msgStr:=E.Message;
      writeln(#13, 'TForm1.FindNoteIDInOpenNotes:',msgStr);
//       doOnSQLResultError(EVT_ERROR,msgStr,'TForm1.FindNoteIDInOpenNotes');
      raise;
    end;
  end;
end; // TForm1.FindNoteIDInOpenNotes

function TForm1.NoteSave(aEditorTab: TNMV6C_TabSheet): Boolean;
var
  NoteId:String;
  jData:TJSONData;
  msgStr:String;
begin
  try
    NoteId:='';
    if Assigned(aEditorTab.NoteObject) then begin
      aEditorTab.UpdateNoteObject();
      jData:=aEditorTab.NoteObject.Find('uuid');
      if Assigned(jData) then
        NoteId:=jData.AsString;

      if NoteId <> '' then
        result:=NoteManagerV6C.UpdateNote(aEditorTab.NoteObject)
      else
        result:=NoteManagerV6C.AddNote(aEditorTab.NoteObject);

      aEditorTab.Modified:=False;
    end
    else
      result:=false;
  except
    on E: Exception do begin
      msgStr:=E.Message;
      writeln(#13, 'TForm1.NoteSave:',msgStr);
//       doOnSQLResultError(EVT_ERROR,msgStr,'TForm1.NoteSave');
      raise;
    end;
  end;
end; // TForm1.NoteSave

procedure TForm1.TagAddToTagList(aTagObject: TJSONObject);
var
  jData:TJSONData;
  TagName:String;
begin
  jData:=aTagObject.Find('name');
  if Assigned(jData) then begin
    TagName:=jData.AsString;
    MyHorizontalBar.BarList.Add(TagName, aTagObject);

    jData:=aTagObject.Find('id');
    if Assigned(jData) then begin
      if FindTagInCheckList(jData.AsInteger) = -1 then begin
        CheckListBox1.Items.AddObject(TagName, aTagObject);
      end;
    end;
  end;
end; // TForm1.TagAddToTagList

procedure TForm1.TagsAddToTagList(aTagObject: TJSONObject; const aClear: Boolean);
var
  i:Integer;
  JData:TJSONData;
  TagObject:TJSONObject;
  Tags:TJSONArray;
begin
  JData:=aTagObject.Find('Tags');
  if Assigned(JData) then begin
    if aClear then MyHorizontalBar.Clear();
    MyHorizontalBar.BarList.AutoUpdate:=False;
    Tags:=JData as TJSONArray;
    for i:=0 to Tags.Count -1 do begin
      TagObject:=Tags[i] as TJSONObject;
      TagAddToTagList(TagObject);
    end; // for i
    MyHorizontalBar.BarList.AutoUpdate:=True;
  end
  else begin
    TagAddToTagList(aTagObject);
  end;
end; // TForm1.TagsAddToTagList

function TForm1.FindTagInCheckList(const aID: integer): integer;
var
  i:Integer;

  TagObject:TJSONObject;
  jData:TJSONData;
begin
  result:=-1;
  for i:=0 to CheckListBox1.Items.Count -1 do begin
    TagObject:=CheckListBox1.Items.Objects[i] as TJSONObject;

    jData:=TagObject.Find('id');
    if Assigned(jData) then begin
      if jData.AsInteger = aID then begin
        result:=i;
        break;
      end;
    end;
  end; // for i
end; // TForm1.FindTagInCheckList

procedure TForm1.UpdateTagCheckList(const aNoteUUID: String);
var
  TagObject:TJSONObject;
  i, x:Integer;
  TagID1, TagID2:Integer;

  TagList:TJSONArray;
begin
  CheckListBox1.CheckAll(cbUnchecked);

  TagList:=NoteManagerV6C.GetTagListFromTagID(aNoteUUID);
  if Assigned(TagList) then begin

    for i:=0 to CheckListBox1.Items.Count -1 do begin
      TagObject:=CheckListBox1.Items.Objects[i] as TJSONObject;
      TagID1:=TagObject.Elements['id'].AsInteger;

      for x:=0 to TagList.Count -1 do begin
        TagID2:=TagList[x].AsInteger;
        if TagID1 = TagID2 then begin
          CheckListBox1.Checked[i]:=true;
        end;
      end;
    end; // for i
  end;
end; // TForm1.UpdateTagCheckList

procedure TForm1.AddOrChangeEditorTabSheet(aNoteObject: TJSONObject; aNewTab: Boolean);
var
  EditorTabSheet:TNMV6C_TabSheet;
  jData:TJSONData;

  TitleStr, ContentStr:String;
begin
  TitleStr:=''; ContentStr:='';
  jData:=aNoteObject.Find('title');
  if Assigned(jData) then
    TitleStr:=jData.AsString;

  jData:=aNoteObject.Find('content');
  if Assigned(jData) then
    ContentStr:=jData.AsString;
  if (aNewTab) or (OpenNotes.PageCount = 0) then begin
    EditorTabSheet:=TNMV6C_TabSheet.Create(OpenNotes);
    EditorTabSheet.Parent:=OpenNotes;
  end
  else
    EditorTabSheet:=OpenNotes.ActivePage as TNMV6C_TabSheet;
  EditorTabSheet.NoEvent:=True;
  EditorTabSheet.Caption:=TitleStr;
  EditorTabSheet.Editor_Frame.edTitle.Text:=TitleStr;
  EditorTabSheet.NoteObject:=aNoteObject;

  if ContentStr <> '' then
    EditorTabSheet.Editor_Frame.SEEditor.Lines.Text:=ContentStr;
  EditorTabSheet.NoEvent:=False;
  EditorTabSheet.Modified:=False;

  if aNewTab then begin
    OpenNotes.ActivePage:=EditorTabSheet;
    EditorTabSheet.Editor_Frame.SEEditor.SetFocus;
  end;

  jData:=aNoteObject.Find('uuid');
  if Assigned(jData) then begin
    UpdateTagCheckList(jData.AsString);
  end;
  CheckListBox1.Enabled:=not (OpenNotes.PageCount = 0);
end; // TForm1.AddEditorTabSheet

function TForm1.LoadDataBase(const aFileName: String; const aReloadDB: Boolean): Boolean;
var
  CanOpen:Boolean;
begin
  result:=False;
  if aReloadDB then begin
    CanOpen:=CheckSaveNotes();
    if (CanOpen) and (clear) then begin
      if Assigned(NoteManagerV6C) then FreeAndNil(NoteManagerV6C);
      InitDB();
    end
    else
      exit;
  end;

  lbDataBaseName.Caption:=ExtractFileName(aFileName);
  lbDataBaseName.Hint:=aFileName;

  NoteManagerV6C.DB_Name:=aFileName;
  LastDBFile:=NoteManagerV6C.DB_Name;
  NoteManagerV6C.GetNotes(nil, true);
  NoteManagerV6C.GetTags();

  result:=True;
end; // TForm1.LoadDataBase

function TForm1.Clear: Boolean;
var
  i:Integer;
begin
  result:=False;

  NoteBrowser.Items.Clear;
  MyHorizontalBar.Clear();
  for i:=OpenNotes.PageCount - 1 downto 0 do begin
    OpenNotes.Page[i].Destroy;
  end;
  CheckListBox1.Items.Clear;
  PageControl2.PageIndex:=0;
  lbNoteCount.Caption:='0';
  lbDataBaseName.Caption:='keine';
  NoteManagerV6C.DB_Name:='';

  result:=True;
end; // TForm1.Clear

procedure TForm1.CheckAllTab(var aStringList: TStrings);
var
  i:Integer;
  EditorTab:TNMV6C_TabSheet;
begin
  for i:=0 to OpenNotes.PageCount - 1 do begin
    EditorTab:=OpenNotes.Page[i] as TNMV6C_TabSheet;
    if EditorTab.Modified then begin
      aStringList.AddObject(EditorTab.Caption, EditorTab);
    end;
  end; // for i

end; // TForm1.CheckAllTab

function TForm1.CheckSave(EditorTab: TNMV6C_TabSheet): boolean;
var
  Reply, BoxStyle: Integer;
begin
  result:=False;
  if EditorTab.Modified then begin
    BoxStyle := MB_ICONERROR+ MB_YESNOCANCEL;
    Reply := Application.MessageBox('Speichern?', 'Noch nicht gespeichert', BoxStyle);
    if Reply = IDCANCEL then
      exit
    else begin
      if Reply = IDYES then
        result:=NoteSave(EditorTab)
      else
        result:=True;
    end;
  end
  else
    result:=true;
end; // TForm1.CheckSave

function TForm1.CheckSaveNotes: Boolean;
var
  StrList:TStrings;
  UserInput, i:Integer;
begin
  result:=False;

  Form2.CheckListBox1.Items.Clear;
  StrList:=TStringList.Create;
  CheckAllTab(StrList);

  Form2.CheckListBox1.Items.AddStrings(StrList);
  if StrList.Count > 0 then begin
    UserInput:=Form2.ShowModal;
    case UserInput of
      mrYes: begin
        for i:=0 to Form2.CheckListBox1.Items.Count -1  do begin
          if Form2.CheckListBox1.Checked[i] then begin
            result:=NoteSave(StrList.Objects[i] as TNMV6C_TabSheet);
            if not result then break;
          end;
        end; // for i
      end; // mrOK

      mrNo: begin
        result:=true;
      end;
    end;
  end
  else
    result:=true;
end; // TForm1.CheckSaveNotes

procedure TForm1.SQLResultAddNotes(aNoteObject: TJSONObject);
begin
  writeln('SQLResultAddNotes');
  NotesAddToNoteBrowser(aNoteObject);
end; // TForm1.SQLResultAddNotes

procedure TForm1.SQLResultGetNotes(aNoteObject: TJSONObject);
begin
  writeln('SQLResultGetNote');
  NotesAddToNoteBrowser(aNoteObject, true);
end; // TForm1.SQLResultGetNote

procedure TForm1.SQLResultUpdateNote(aNoteObject: TJSONObject);
var
  jData:TJSONData;

//  mTimeStr, mCount:String;

  TempDateTime:TDateTime;
  ListItem:TListItem;
begin
  writeln('TForm1.SQLResultUpdateNote');
  writeln(aNoteObject.FormatJSON());

  jData:=aNoteObject.Find('uuid');
  if Assigned(jData) then begin
    ListItem:=FindNoteIDInNoteBrowser(jData.AsString);

    jData:=aNoteObject.Find('mtime');
    if Assigned(jData) then begin
      TempDateTime:=StrToDateTime(jData.AsString);
      if Assigned(jData) then begin
        ListItem.SubItems[1]:=FormatDateTime('DDD, DD.MM.YYYY HH:mm', TempDateTime);
      end;
    end;

    jData:=aNoteObject.Find('mcount');
    if Assigned(jData) then ListItem.SubItems[4]:=jData.AsString;

    jData:=aNoteObject.Find('title');
    if Assigned(jData) then ListItem.Caption:=jData.AsString;

  end;

end; // TForm1.SQLResultUpdateNote

procedure TForm1.SQLResultDeleteNote(aNoteIDList: TJSONArray);
var
  NoteTabSheet:TNMV6C_TabSheet;
  NoteObject:TJSONObject;
  uuidStr:String;
  i, x:Integer;
begin
  for i:=aNoteIDList.Count -1 downto 0 do begin

    for x:=NoteBrowser.Items.Count -1 downto 0 do begin
      NoteObject:=TJSONObject(NoteBrowser.Items[x].Data);
      uuidStr:=NoteObject.Elements['uuid'].AsString;
      if uuidStr = aNoteIDList[i].AsString then begin
        NoteBrowser.Items.Delete(x);
      end;
    end; // for x

    for x:=OpenNotes.PageCount -1 downto 0 do begin
      NoteTabSheet:=OpenNotes.Page[x] as TNMV6C_TabSheet;
      NoteObject:=NoteTabSheet.NoteObject;
      uuidStr:=NoteObject.Elements['uuid'].AsString;
      if uuidStr = aNoteIDList[i].AsString then begin
        FreeAndNil(NoteTabSheet);
      end;
    end; // for x

  end;

end; // TForm1.SQLResultDeleteNote

procedure TForm1.SQLResultAddTag(aTagObject: TJSONObject);
begin
  writeln('SQLResultAddTag');
  writeln(aTagObject.FormatJSON());
  TagsAddToTagList(aTagObject);
end; // TForm1.SQLResultAddTag

procedure TForm1.SQLResultGetTags(aTagObject: TJSONObject);
begin
  writeln('SQLResultGetTags');
  writeln(aTagObject.FormatJSON());

  TagsAddToTagList(aTagObject);
end; // TForm1.SQLResultGetTags

procedure TForm1.BarChecked(sender: TObject);
var
  i:Integer;
  BarItem:TPLMyHorizontalBarItem;
  TagList:TJSONArray;
  TagObject:TJSONObject;
  TagID:Integer;
begin
  TagList:=TJSONArray.Create();
  for i:=0 to MyHorizontalBar.BarList.Count -1 do begin
    BarItem:=MyHorizontalBar.BarList[i];
    TagObject:=(BarItem.Data as TJSONObject);

    if BarItem.Checked then begin
      TagID:=TagObject.Elements['id'].AsInteger;
      TagList.Add(TagID);
    end;
  end;
  NoteManagerV6C.GetNotes(TagList);
end; // TForm1.BarChecked

procedure TForm1.LoadConfigFile(const aConfigFile: String);
var
  i:Integer;

  JParser:TJSONParser;
  JColArray:TJSONArray;
  JObject, JObject_Col, JObject_Window, NoteBrowserObject, Notes:TJSONObject;
  JData:TJSONData;
  MS:TMemoryStream;
  msgStr:String;

//  OpenNotes:TJSONArray;
begin
  try
    try
      if FileExists(ConfigFile) then begin
        MS:=TMemoryStream.Create;
        MS.LoadFromFile(ConfigFile);
        MS.Position:=0;

        JParser:=TJSONParser.Create(MS,[]);
        JObject:=JParser.Parse as TJSONObject;

        JData:=JObject.Find('NoteBrowser');
        if Assigned(JData) then begin
          NoteBrowserObject:=JData as TJSONObject;

          JData:=NoteBrowserObject.Find('ColumnsConfig');
          if Assigned(JData) then begin
            JColArray:=JData as TJSONArray;
            for i:=0 to JColArray.Count -1 do begin
              JObject_Col:=JColArray[i] as TJSONObject;

              JData:=JObject_Col.Find('Width');
              if Assigned(JData) then
                NoteBrowser.Column[i].Width:=JData.AsInteger;

              JData:=JObject_Col.Find('Visible');
              if Assigned(JData) then
                NoteBrowser.Column[i].Visible:=JData.AsBoolean;
            end;

            JData:=NoteBrowserObject.Find('SortColum');
            if Assigned(JData) then
              NoteBrowser.SortColumn:=JData.AsInteger;
            JData:=NoteBrowserObject.Find('SortDirection');
            if Assigned(JData) then
              NoteBrowser.SortDirection:=TSortDirection(JData.AsInteger);
            LastSortedColumn:=NoteBrowser.SortColumn;

            if NoteBrowser.Column[NoteBrowser.SortColumn].SortIndicator = siAscending then
              NoteBrowser.Column[NoteBrowser.SortColumn].SortIndicator:=siDescending
            else
              NoteBrowser.Column[NoteBrowser.SortColumn].SortIndicator:=siAscending;
          end;
        end; // NoteBrowser

        JData:=JObject.Find('OpenNotes.Width');
        if Assigned(JData) then
          OpenNotes.Width:=JData.AsInteger;

        JData:=JObject.Find('NoteBrowser.Height');
        if Assigned(JData) then
          NoteBrowser.Height:=JData.AsInteger;

        JData:=JObject.Find('WindowState');
        if Assigned(JData) then
          WindowState:=TWindowState(JData.AsInteger);

{        JData:=JObject.Find('lastDBFile');
        if Assigned(JData) then begin
          LastDBFile:=JData.AsString;
        end;}


      {  JData:=JObject.Find('OpenNotes');
        if Assigned(JData) then begin
          OpenNotes:=JData as TJSONArray;

          Notes:=TJSONObject.Create;
          Notes.Add('NotesOpenByID', OpenNotes);
          writeln(Notes.FormatJSON());

          NoteManager6B_sqlite.GetNotes(Notes);
        end; }
      end;
    finally
      FreeAndNil(JObject); FreeAndNil(JParser);
    end;
  except
    on E: Exception do begin
      msgStr:=E.Message;
      writeln(#13, 'TPLNMV6C_sqlite.LoadConfigFile:',msgStr);
//      doOnSQLResultError(EVT_ERROR,msgStr,'TPLNMV6C_sqlite.CreateDB');
      raise;
    end;
  end;

end; // TForm1.LoadConfigFile

procedure TForm1.SaveConfigFile(const aConfigFile: String);
var
  MS:TMemoryStream;
  EditorTabSheet:TNMV6C_TabSheet;

  JCollArray:TJSONArray;
  OpenPadList:TJSONArray;
  Config:TJSONObject;
  NoteBrowserObject, JObject_Col:TJSONObject;
  Data:TJSONData;

  x:Integer;
  TempContent:String;
  msgStr:string;
begin
  try
    try
      Config:=TJSONObject.Create();

      NoteBrowserObject:=TJSONObject.Create();

      JCollArray:=TJSONArray.Create();
      for x:=0 to NoteBrowser.Columns.Count -1 do begin
        JObject_Col:=TJSONObject.Create();
        JObject_Col.Add('Width', NoteBrowser.Columns[x].Width);
        JObject_Col.Add('Visible', NoteBrowser.Columns[x].Visible);
        JCollArray.Add(JObject_Col);
      end; // for x
      NoteBrowserObject.Add('ColumnsConfig',JCollArray);
      NoteBrowserObject.Add('SortColum', NoteBrowser.SortColumn);
      NoteBrowserObject.Add('SortDirection', Integer(NoteBrowser.SortDirection));
      Config.Add('NoteBrowser',NoteBrowserObject);
      Config.Add('OpenNotes.Width',OpenNotes.Width);
      Config.Add('NoteBrowser.Height',NoteBrowser.Height);
      Config.Add('WindowState',Integer(WindowState));

//      Config.Add('lastDBFile',LastDBFile);

    {  OpenPadList:=TJSONArray.Create();
      for x:=0 to PageControl1.PageCount -1 do begin
        EditorTabSheet:=PageControl1.Pages[x] as TMyEditorTabSheet;
        Data:=EditorTabSheet.NoteObject.Elements['uuid'];
        OpenPadList.Add(Data);
      end; // for x

      Config.Add('OpenNotes',OpenPadList); }

      TempContent:=Config.FormatJSON();

      MS:=TMemoryStream.Create;
      MS.WriteBuffer(Pointer(TempContent)^,Length(TempContent));
      MS.SaveToFile(aConfigFile);
    finally
      FreeAndNil(MS);
      FreeAndNil(Config);
    end;
  except
    on E: Exception do begin
      msgStr:=E.Message;
      writeln(#13, 'TPLNMV6C_sqlite.CreateDB:',msgStr);
//      doOnSQLResultError(EVT_ERROR,msgStr,'TPLNMV6C_sqlite.CreateDB');
      raise;
    end;
  end;
end; // TForm1.SaveConfigFile

end.

