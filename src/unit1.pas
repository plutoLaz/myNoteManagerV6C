unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, ComCtrls,
  Buttons, StdCtrls, fpjson, StrUtils, DateUtils,
  unit_EditorFrame, unmv6c_sqlite, unmv6c_createtextbricks;

type

  { TNMV6C_TabSheet }
  TNMV6C_TabSheet = class(TTabSheet)
  private

  protected

  public
    NoteObject:TJSONObject;
    Editor_Frame:TEditorFrame;

    constructor Create(TheOwner: TComponent); override;
    destructor Destroy; override;
  published
  end; // TNMV6C_TabSheet

  { TForm1 }
  TForm1 = class(TForm)
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    BitBtn3: TBitBtn;
    BitBtn4: TBitBtn;
    BitBtn5: TBitBtn;
    BitBtn6: TBitBtn;
    BitBtn7: TBitBtn;
    btNewDB: TBitBtn;
    btOpenDB: TBitBtn;
    btSaveDB: TBitBtn;
    btSaveAsDB: TBitBtn;
    btImportOldDB: TBitBtn;
    CheckBox1: TCheckBox;
    NoteBrowser: TListView;
    PageControl1: TPageControl;
    OpenNotes: TPageControl;
    Panel1: TPanel;
    Splitter1: TSplitter;
    TabSheet1: TTabSheet;
    tsDataBase: TTabSheet;
    tsTags: TTabSheet;
    tsFilter1: TTabSheet;
    tsFilter2: TTabSheet;
    procedure BitBtn1Click(Sender: TObject);
    procedure BitBtn2Click(Sender: TObject);
    procedure BitBtn3Click(Sender: TObject);
    procedure BitBtn4Click(Sender: TObject);
    procedure BitBtn5Click(Sender: TObject);
    procedure BitBtn6Click(Sender: TObject);
    procedure BitBtn7Click(Sender: TObject);
    procedure CheckBox1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure NoteBrowserColumnClick(Sender: TObject; Column: TListColumn);
    procedure NoteBrowserCompare(Sender: TObject; Item1, Item2: TListItem;
      Data: Integer; var Compare: Integer);
    procedure NoteBrowserDblClick(Sender: TObject);
  private

  public
    NoteManagerV6C:TPLNMV6C_sqlite;
    CreateTextBricks:TNMV6C_CreateTextBricks;

    AppDir:String;
    LastSortedColumn:Integer;
    procedure NoteAddToNoteBrowser(aNoteObject:TJSONObject);
    procedure NotesAddToNoteBrowser(aNoteObject:TJSONObject; const aClear:Boolean = False);

    procedure AddOrChangeEditorTabSheet(aNoteObject:TJSONObject; aNewTab:Boolean);

    procedure SQLResultAddNotes(aNoteObject:TJSONObject);
    procedure SQLResultGetNotes(aNoteObject:TJSONObject);

    procedure SQLResultAddTag(aNoteObject:TJSONObject);
    procedure SQLResultGetTags(aNoteObject:TJSONObject);
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

constructor TNMV6C_TabSheet.Create(TheOwner: TComponent);
begin
  inherited Create(TheOwner);
  NoteObject:=nil;
  Editor_Frame:=TEditorFrame.Create(self);
  Editor_Frame.Parent:=self;
  Editor_Frame.Align:=alClient;
end; // TNMV6C_TabSheet.Create

destructor TNMV6C_TabSheet.Destroy;
begin
  FreeAndNil(Editor_Frame);
  inherited Destroy;
end; // TNMV6C_TabSheet.Destroy


{ TForm1 }
procedure TForm1.BitBtn1Click(Sender: TObject);
begin

end; // TForm1.BitBtn1Click

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

procedure TForm1.CheckBox1Click(Sender: TObject);
begin
  NoteManagerV6C.AutoCommit:=CheckBox1.Checked;
  if CheckBox1.Checked then NoteManagerV6C.SQLTransaction.Commit;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  Randomize;
  AppDir:=ExtractFileDir(ParamStr(0)) + DirectorySeparator;
  CreateTextBricks:=TNMV6C_CreateTextBricks.Create(AppDir + 'template' + DirectorySeparator);

  NoteManagerV6C:=TPLNMV6C_sqlite.Create;
  NoteManagerV6C.OnSQLResultAddNote:=@SQLResultAddNotes;
  NoteManagerV6C.OnSQLResultGetNotes:=@SQLResultGetNotes;

  NoteManagerV6C.OnSQLResultAddTag:=@SQLResultAddTag;
  NoteManagerV6C.OnSQLResultGetTags:=@SQLResultGetTags;

  NoteManagerV6C.DB_Name:=AppDir + 'test01.db';

  CheckBox1.Checked:=NoteManagerV6C.AutoCommit;

end; // TForm1.FormCreate

procedure TForm1.FormDestroy(Sender: TObject);
begin
  FreeAndNil(NoteManagerV6C); FreeAndNil(CreateTextBricks);
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
begin
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
end;

procedure TForm1.NoteBrowserDblClick(Sender: TObject);
var
  NoteObject:TJSONObject;
  Temp_uuid:String;
  ContentStr:String;
  JData:TJSONData;
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

    AddOrChangeEditorTabSheet(NoteObject, False);
//    ShowMessage(NoteManagerV6C.GetContentFromNote(Temp_uuid));
  end;
end;

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
  ListItem.Data:=aNoteObject;

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
begin
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
  end;
end; // TForm1.NotesAddToNoteBrowser

procedure TForm1.AddOrChangeEditorTabSheet(aNoteObject: TJSONObject; aNewTab: Boolean);
var
  EditorTabSheet:TNMV6C_TabSheet;
  jData:TJSONData;

  TitleStr, ContentStr, uuidStr:String;
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
  else begin

    {jData:=aNoteObject.Find('uuid');
    if Assigned(jData) then begin
      uuidStr:=jData.AsString;
    end;}
    EditorTabSheet:=OpenNotes.ActivePage as TNMV6C_TabSheet;
  end;

  EditorTabSheet.Caption:=TitleStr;
  EditorTabSheet.NoteObject:=aNoteObject;

  if ContentStr <> '' then begin
    EditorTabSheet.Editor_Frame.SynEdit1.Lines.Text:=ContentStr;
  end;
end; // TForm1.AddEditorTabSheet

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

procedure TForm1.SQLResultAddTag(aNoteObject: TJSONObject);
begin
  writeln('SQLResultAddTag');
  writeln(aNoteObject.FormatJSON());
end; // TForm1.SQLResultAddTag

procedure TForm1.SQLResultGetTags(aNoteObject: TJSONObject);
begin
  writeln('SQLResultGetTags');
  writeln(aNoteObject.FormatJSON());
end; // TForm1.SQLResultGetTags

end.

