{
  Autor: Michael Springwald

  Datum: Dienstag, 26.09.2023

  Neue Filter Funktion für, Tags
  SELECT * FROM notes WHERE UUID IN (SELECT note_id FROM note_tags WHERE tag_id in (5,9));
}

unit unmv6c_sqlite;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, uuid, DB, SQLDB, SQLite3Conn, fpjson, unmv6c_type;

type

  { TPLNMV6C_sqlite }

  TPLNMV6C_sqlite = class
  private
    fAutoCommit: Boolean;
    fDB_Name: String;
    fOnSQLResultAddNote: TOnSQLResultAddNote;
    fOnSQLResultAddTag: TOnSQLResultAddTag;
    fOnSQLResultDeleteNote: TOnSQLResultDeleteNote;
    fOnSQLResultDeleteTag: TOnSQLResultDeleteTag;
    fOnSQLResultError: TOnSQLResultError;
    fOnSQLResultGetContent: TOnSQLResultGetContent;
    fOnSQLResultGetNotes: TOnSQLResultGetNotes;
    fOnSQLResultGetTagListFromTagID: TOnSQLResultGetTagListFromTagID;
    fOnSQLResultGetTags: TOnSQLResultGetTags;
    fOnSQLResultUpdateNote: TOnSQLResultUpdateNote;
    fOnSQLResultUpdateTag: TOnSQLResultUpdateTag;

    function CreateDB():boolean;
    procedure SetDB_Name(AValue: String);
  protected
    procedure doOnSQLResultAddNote(aNoteObject:TJSONObject);
    procedure doOnSQLResultAddTag(aNoteObject:TJSONObject);
    procedure doOnSQLResultDeleteNote(aNoteObject:TJSONObject);
    procedure doOnSQLResultDeleteTag(aNoteObject:TJSONObject);
    procedure doOnSQLResultUpdateNote(aNoteObject:TJSONObject);
    procedure doOnSQLResultGetTagListFromTagID(aNoteObject:TJSONObject);
    procedure doOnSQLResultGetNote(aNoteObject:TJSONObject);
    procedure doOnSQLResultGetTags(aNoteObject:TJSONObject);
    procedure doOnSQLResultUpdateTag(aNoteObject:TJSONObject);
    procedure doOnSQLResultGetContent(aNoteObject:TJSONObject);
    procedure doOnSQLResultError(const aErrorEventType:TPLOnErrorEventType; aErrorMSG:String; aSender:String);

    procedure SQLONErrorLog(Sender : TSQLConnection; EventType : TDBEventType; Const Msg : String);
    procedure SQLScriptOnError(Sender: TObject; Statement: TStrings; TheException: Exception; var Continue: boolean);

  public
    myFormatSettings, myFormatSettings2:TFormatSettings;

    SQlConnector:TSQLite3Connection;
    SQLTransaction:TSQLTransaction;
    SQLScript:TSQLScript;

    constructor Create;
    destructor Destroy; override;
    function DBInit():boolean;

{}  function AddNote(var aNoteObject:TJSONObject):Boolean; // TOnSQLResultAddNote
{}  function UpdateNote(var aNoteObject:TJSONObject):Boolean; //  TOnSQLResultUpdateNote
    function DeleteNote(var aJObject:TJSONObject):Boolean; //  TOnSQLResultDeleteNote
{}  function GetNotes(const aTagFilterList:TJSONArray; const aWihtContent:Boolean = False; const aSQLStr:String = ''; aCreateStatistik:boolean = false):Boolean; // TOnGetNote
{}  function GetContentFromNote(const aUUID:String):string; // TOnSQLResultGetContent
    function GetTagListFromTagID(const aUUID:String):Boolean; // TOnSQLResultGetTagListFromTagID

{}  function AddTag(var aTagObject:TJSONObject; const aTagMetaData:Boolean = False):Boolean; // TOnSQLResultAddTag

    function UpdateTag():Boolean; // TOnSQLResultUpdateTag
    function DeleteTag():Boolean; // TOnSQLResultDeleteTag
{}  function GetTags(const aSortetByUserIndex:boolean = False):Boolean; // TOnSQLResultGetTag

    function ImportFromOldDataBase(const aFileName:String):Boolean;

{}  property OnSQLResultAddNote:TOnSQLResultAddNote read fOnSQLResultAddNote write fOnSQLResultAddNote;
    property OnSQLResultUpdateNote:TOnSQLResultUpdateNote read fOnSQLResultUpdateNote write fOnSQLResultUpdateNote;
    property OnSQLResultDeleteNote:TOnSQLResultDeleteNote read fOnSQLResultDeleteNote write fOnSQLResultDeleteNote;
{}  property OnSQLResultGetNotes:TOnSQLResultGetNotes read fOnSQLResultGetNotes write fOnSQLResultGetNotes;
{}  property OnSQLResultGetContent:TOnSQLResultGetContent read fOnSQLResultGetContent write fOnSQLResultGetContent;
    property OnSQLResultGetTagListFromTagID:TOnSQLResultGetTagListFromTagID read fOnSQLResultGetTagListFromTagID write fOnSQLResultGetTagListFromTagID;

{}  property OnSQLResultAddTag:TOnSQLResultAddTag read fOnSQLResultAddTag write fOnSQLResultAddTag;
    property OnSQLResultUpdateTag:TOnSQLResultUpdateTag read fOnSQLResultUpdateTag write fOnSQLResultUpdateTag;
    property OnSQLResultDeleteTag:TOnSQLResultDeleteTag read fOnSQLResultDeleteTag write fOnSQLResultDeleteTag;
    property OnSQLResultGetTags:TOnSQLResultGetTags read fOnSQLResultGetTags write fOnSQLResultGetTags;

    property OnSQLResultError:TOnSQLResultError read fOnSQLResultError write fOnSQLResultError;

    property DB_Name:String read fDB_Name write SetDB_Name;
    property AutoCommit:Boolean read fAutoCommit write fAutoCommit;
  published
  end;


implementation

function AddStr(const aName, aValue:String):String;
begin
  if aValue <> '' then
    result:=aValue + ',' +  aName
  else
    result:=aName;
end; // AddStr

function TPLNMV6C_sqlite.CreateDB(): boolean;
var
  msgStr:String;
  TempQuery:TSQLQuery;
begin
  result:=False;
  try
    SQLScript.Script.Add('PRAGMA foreign_keys = ON;');
    SQLScript.Script.Add('');

    SQLScript.Script.Add('CREATE TABLE if not exists notes');
    SQLScript.Script.Add('(');
      SQLScript.Script.Add('id INTEGER PRIMARY KEY NOT NULL,');
      SQLScript.Script.Add('uuid BLOB UNIQUE,');
      SQLScript.Script.Add('title TEXT NOT NULL,');
      SQLScript.Script.Add('content TEXT,');
      SQLScript.Script.Add('ctime DATETIME,');
      SQLScript.Script.Add('mtime DATETIME,');
      SQLScript.Script.Add('atime DATETIME,');
      SQLScript.Script.Add('mcount INTEGER NOT NULL DEFAULT 1,');
      SQLScript.Script.Add('acount INTEGER NOT NULL DEFAULT 1,');
      SQLScript.Script.Add('userindex INTEGER');

    SQLScript.Script.Add(');');
    SQLScript.Script.Add('');

    SQLScript.Script.Add('CREATE INDEX IF NOT EXISTS idx_notes_uuid ON notes(uuid);');
    SQLScript.Script.Add('CREATE INDEX IF NOT EXISTS idx_notes_title ON notes(title);');
    SQLScript.Script.Add('CREATE INDEX IF NOT EXISTS idx_notes_ctime ON notes(ctime);');
    SQLScript.Script.Add('CREATE INDEX IF NOT EXISTS idx_notes_mtime ON notes(mtime);');
    SQLScript.Script.Add('CREATE INDEX IF NOT EXISTS idx_notes_atime ON notes(atime);');
    SQLScript.Script.Add('CREATE INDEX IF NOT EXISTS idx_notes_mcount ON notes(mcount);');
    SQLScript.Script.Add('CREATE INDEX IF NOT EXISTS idx_notes_acount ON notes(acount);');

    SQLScript.Script.Add('CREATE TABLE if not exists tags (');
      SQLScript.Script.Add('id INTEGER PRIMARY KEY NOT NULL,');
      SQLScript.Script.Add('name TEXT NOT NULL UNIQUE COLLATE NOCASE,');
      SQLScript.Script.Add('ctime DATETIME,');
      SQLScript.Script.Add('mtime DATETIME,');
      SQLScript.Script.Add('atime DATETIME,');
      SQLScript.Script.Add('userindex INTEGER');

    SQLScript.Script.Add(');');
    SQLScript.Script.Add('');
    SQLScript.Script.Add('CREATE INDEX IF NOT EXISTS idx_tags_name ON tags(name);');
    SQLScript.Script.Add('');

    SQLScript.Script.Add('CREATE TABLE if not exists note_tags (');
      SQLScript.Script.Add('note_id INTEGER NOT NULL,');
      SQLScript.Script.Add('tag_id INTEGER NOT NULL,');
      SQLScript.Script.Add('UNIQUE(note_id, tag_id),');
      SQLScript.Script.Add('FOREIGN KEY (note_id) REFERENCES notes(id) ON DELETE CASCADE,');
      SQLScript.Script.Add('FOREIGN KEY (tag_id) REFERENCES tags(id) ON DELETE CASCADE');
    SQLScript.Script.Add(');');
    SQLScript.Script.Add('');
    SQLScript.ExecuteScript;

    try
      TempQuery:=TSQLQuery.Create(nil);
      TempQuery.DataBase:=SQlConnector;

      TempQuery.SQL.Clear;
      TempQuery.SQL.Add('CREATE TRIGGER IF NOT EXISTS note_update BEFORE UPDATE ON notes');
      TempQuery.SQL.Add('BEGIN');
      TempQuery.SQL.Add('UPDATE notes SET mcount = mcount + 1, mtime = (DATETIME(''now'')) WHERE id = new.id AND (title != new.title OR content != new.content);');
      TempQuery.SQL.Add('END;');
      TempQuery.ExecSQL;
      TempQuery.SQL.Clear;

      TempQuery.SQL.Add('CREATE VIEW IF NOT EXISTS FilterByTag AS');
        TempQuery.SQL.Add('SELECT');
          TempQuery.SQL.Add('note_id, ');
          TempQuery.SQL.Add('tag_id, ');
          TempQuery.SQL.Add('title, ');
          TempQuery.SQL.Add('ctime, ');
          TempQuery.SQL.Add('atime, ');
          TempQuery.SQL.Add('mtime, ');
          TempQuery.SQL.Add('mcount, ');
          TempQuery.SQL.Add('acount');
        TempQuery.SQL.Add('FROM');
          TempQuery.SQL.Add('note_tags');
        TempQuery.SQL.Add('LEFT JOIN notes ON');
          TempQuery.SQL.Add('notes.uuid = note_tags.note_id');
      TempQuery.ExecSQL;

      SQLTransaction.Commit;
    finally
      FreeAndNil(TempQuery);
    end;
  except
    on E: Exception do begin
      msgStr:=E.Message;
      writeln(#13, 'TPLNMV6C_sqlite.CreateDB:',msgStr);
      doOnSQLResultError(EVT_ERROR,msgStr,'TPLNMV6C_sqlite.CreateDB');
      raise;
    end;

  end;
end; /// TPLNMV6C_sqlite.CreateDB

procedure TPLNMV6C_sqlite.SetDB_Name(AValue: String);
begin
  SQlConnector.Connected:=False;
  SQlConnector.DatabaseName:=AValue;
  SQlConnector.Connected:=AValue <> '';
  SQLTransaction.Active:=AValue <> '';

  if fDB_Name <> AValue then begin
    fDB_Name:=AValue;
    CreateDB();
  end;
end; // TPLNMV6C_sqlite.SetDB_Name

{ TPLNMV6C_sqlite }
procedure TPLNMV6C_sqlite.doOnSQLResultAddNote(aNoteObject: TJSONObject);
begin
  if Assigned(fOnSQLResultAddNote) then fOnSQLResultAddNote(aNoteObject);
end; // TPLNMV6C_sqlite.doOnSQLResultAddNote

procedure TPLNMV6C_sqlite.doOnSQLResultAddTag(aNoteObject: TJSONObject);
begin
  if Assigned(fOnSQLResultAddTag) then fOnSQLResultAddTag(aNoteObject);
end; // TPLNMV6C_sqlite.doOnSQLResultAddTag

procedure TPLNMV6C_sqlite.doOnSQLResultDeleteNote(aNoteObject: TJSONObject);
begin
  if Assigned(fOnSQLResultDeleteNote) then fOnSQLResultDeleteNote(aNoteObject);
end; // TPLNMV6C_sqlite.doOnSQLResultDeleteNote

procedure TPLNMV6C_sqlite.doOnSQLResultDeleteTag(aNoteObject: TJSONObject);
begin
  if Assigned(fOnSQLResultDeleteTag) then fOnSQLResultDeleteTag(aNoteObject);
end; // TPLNMV6C_sqlite.doOnSQLResultDeleteTag

procedure TPLNMV6C_sqlite.doOnSQLResultUpdateNote(aNoteObject: TJSONObject);
begin
  if Assigned(fOnSQLResultUpdateNote) then fOnSQLResultUpdateNote(aNoteObject);
end; // TPLNMV6C_sqlite.doOnSQLResultUpdateNote

procedure TPLNMV6C_sqlite.doOnSQLResultGetTagListFromTagID(aNoteObject: TJSONObject);
begin
  if Assigned(fOnSQLResultGetTagListFromTagID) then fOnSQLResultGetTagListFromTagID(aNoteObject);
end; // TPLNMV6C_sqlite.doOnSQLResultGetTagListFromTagID

procedure TPLNMV6C_sqlite.doOnSQLResultGetNote(aNoteObject: TJSONObject);
begin
  if Assigned(fOnSQLResultGetNotes) then fOnSQLResultGetNotes(aNoteObject);
end; // TPLNMV6C_sqlite.doOnSQLResultGetNote

procedure TPLNMV6C_sqlite.doOnSQLResultGetTags(aNoteObject: TJSONObject);
begin
  if Assigned(fOnSQLResultGetTags) then fOnSQLResultGetTags(aNoteObject);
end; // TPLNMV6C_sqlite.doOnSQLResultGetTags

procedure TPLNMV6C_sqlite.doOnSQLResultUpdateTag(aNoteObject: TJSONObject);
begin
  if Assigned(fOnSQLResultUpdateTag) then fOnSQLResultUpdateTag(aNoteObject);
end; // TPLNMV6C_sqlite.doOnSQLResultUpdateTag

procedure TPLNMV6C_sqlite.doOnSQLResultGetContent(aNoteObject: TJSONObject);
begin
  if Assigned(fOnSQLResultGetContent) then fOnSQLResultGetContent(aNoteObject);
end; // TPLNMV6C_sqlite.doOnSQLResultGetContent

procedure TPLNMV6C_sqlite.doOnSQLResultError(const aErrorEventType: TPLOnErrorEventType; aErrorMSG: String; aSender: String);
begin
  if Assigned(fOnSQLResultError) then fOnSQLResultError(aErrorEventType, aErrorMSG, aSender);
end; // TPLNMV6C_sqlite.doOnSQLResultError

procedure TPLNMV6C_sqlite.SQLONErrorLog(Sender: TSQLConnection; EventType: TDBEventType; const Msg: String);
begin
//  writeln(Msg);
end; // TPLNMV6C_sqlite.SQLONErrorLog

procedure TPLNMV6C_sqlite.SQLScriptOnError(Sender: TObject; Statement: TStrings; TheException: Exception; var Continue: boolean);
begin
  writeln(Statement.Text);
  writeln(TheException.ClassName);
end; // TPLNMV6C_sqlite.SQLScriptOnError

constructor TPLNMV6C_sqlite.Create;
begin
  inherited Create;
  fAutoCommit:=True;

  DefaultFormatSettings.DateSeparator:='.';
  DefaultFormatSettings.LongDateFormat:='DD.MM.YYYY';
  DefaultFormatSettings.LongTimeFormat:='HH:mm:ss';

  myFormatSettings.ShortTimeFormat:='HH:MM:SS';
  myFormatSettings.LongTimeFormat:='HH:MM:SS';
  myFormatSettings.TimeSeparator:=':';

  myFormatSettings.ShortDateFormat:='DD.MM.YYYY';
  myFormatSettings.LongDateFormat:='DD.MM.YYYY';
  myFormatSettings.DateSeparator:='.';

  fOnSQLResultAddNote:=nil;
  fOnSQLResultAddTag:=nil;
  fOnSQLResultDeleteNote:=nil;
  fOnSQLResultDeleteTag:=nil;
  fOnSQLResultError:=nil;
  fOnSQLResultGetContent:=nil;
  fOnSQLResultGetNotes:=nil;
  fOnSQLResultGetTagListFromTagID:=nil;
  fOnSQLResultUpdateNote:=nil;
  fOnSQLResultUpdateTag:=nil;
  fOnSQLResultGetTags:=nil;

  SQlConnector:=nil;
  SQLTransaction:=nil;
  SQLScript:=nil;

  DBInit();
end; // TPLNMV6C_sqlite.Create

destructor TPLNMV6C_sqlite.Destroy;
begin
  FreeAndNil(SQlConnector); FreeAndNil(SQLTransaction); FreeAndNil(SQLScript);
  inherited Destroy;
end; // TPLNMV6C_sqlite.Destroy

function TPLNMV6C_sqlite.DBInit(): boolean;
var
  msgStr:String;
begin
  result:=False;
  try
    SQlConnector:=TSQLite3Connection.Create(nil);
    SQlConnector.HostName:='localhost';
    SQlConnector.OnLog:=@SQLONErrorLog;

    SQLTransaction:=TSQLTransaction.Create(nil);

    SQlConnector.Transaction:=SQLTransaction;

    SQLScript:=TSQLScript.Create(nil);
    SQLScript.DataBase:=SQlConnector;
    SQLScript.Transaction:=SQLTransaction;
    SQLScript.OnException:=@SQLScriptOnError;

    result:=True;
  except
    on E: Exception do begin
      msgStr:=E.Message;
      writeln(#13, 'TPLNMV6C_sqlite.DBInit:',msgStr);
      doOnSQLResultError(EVT_ERROR,msgStr,'TPLNMV6C_sqlite.DBInit');

      if Assigned(SQlConnector) then
        FreeAndNil(SQlConnector);

      if Assigned(SQLTransaction) then
        FreeAndNil(SQLTransaction);

      if Assigned(SQLScript) then
        FreeAndNil(SQLScript);
      raise;
    end;
  end;
end; // TPLNMV6C_sqlite.DBInit

function TPLNMV6C_sqlite.AddNote(var aNoteObject: TJSONObject): Boolean;
var
  TempQuery:TSQLQuery;

  Temp_uuid:TParam;
  Temp_title:TParam;
  Temp_content:TParam;
  Temp_ctime:TParam;
  Temp_mtime:TParam;
  Temp_atime:TParam;

  msgStr:string;

  function _AddNote(var _aNoteObject:TJSONObject):boolean;
  var
    Data:TJSONData;
    NoteTitle, NoteContent:String;
    TempUuid: uuid_t;
  begin
    result:=False;
    NoteTitle:=''; NoteContent:='';
    try
      Data:=_aNoteObject.Find('title');
      if Assigned(Data) then
        NoteTitle:=Data.AsString;

      Data:=_aNoteObject.Find('content');
      if Assigned(Data) then
        NoteContent:=Data.AsString;

      uuid_create(TempUuid);

      Temp_title.AsString:=NoteTitle;
      Temp_content.AsString:=NoteContent;
      Temp_uuid.AsString:=TempUuid.ToString();
      Temp_ctime.AsDateTime:=now;
      Temp_mtime.AsDateTime:=now;
      Temp_atime.AsDateTime:=now;
      TempQuery.ExecSQL;

      _aNoteObject.Add('uuid', TempUuid.ToString);
      _aNoteObject.Add('ctime', DateTimeToStr(now));
      _aNoteObject.Add('mtime', DateTimeToStr(now));
      _aNoteObject.Add('atime', DateTimeToStr(now));
      _aNoteObject.Add('acount', 0);
      _aNoteObject.Add('mcount', 0);
      _aNoteObject.Add('id', SQlConnector.GetInsertID);

      result:=True;
    except
      on E: Exception do begin
        msgStr:=E.Message;
        writeln(#13, 'TPLNMV6C_sqlite.AddNote _AddNote:',msgStr);
        doOnSQLResultError(EVT_ERROR,msgStr,'TPLNMV6C_sqlite.AddNote _AddNote');
        raise;
      end;
    end;

  end; // _AddNote

var
  data:TJSONData;
  NoteArray:TJSONArray;
  NoteObject:TJSONObject;

  i:Integer;
begin
  NoteObject:=nil;
  result:=False;
  try
    TempQuery:=TSQLQuery.Create(nil);
    try
      TempQuery.DataBase:=SQlConnector;

      TempQuery.SQL.Add('INSERT INTO notes (');
          TempQuery.SQL.Add('title, ');
          TempQuery.SQL.Add('content, ');
          TempQuery.SQL.Add('uuid,');
          TempQuery.SQL.Add('ctime,');
          TempQuery.SQL.Add('mtime,');
          TempQuery.SQL.Add('atime');
        TempQuery.SQL.Add(') ');
        TempQuery.SQL.Add('VALUES (');
          TempQuery.SQL.Add(':title,');
          TempQuery.SQL.Add(':content,');
          TempQuery.SQL.Add(':uuid,');
          TempQuery.SQL.Add(':ctime,');
          TempQuery.SQL.Add(':mtime,');
          TempQuery.SQL.Add(':atime');
        TempQuery.SQL.Add(');');

      Temp_uuid:=TempQuery.ParamByName('uuid'); // 0
      Temp_title:=TempQuery.ParamByName('title'); // 1
      Temp_content:=TempQuery.ParamByName('content'); // 2
      Temp_ctime:=TempQuery.ParamByName('ctime'); // 3
      Temp_mtime:=TempQuery.ParamByName('mtime'); // 4
      Temp_atime:=TempQuery.ParamByName('atime'); // 5

      data:=aNoteObject.Find('Notes');
      if Assigned(data) then begin
        NoteArray:=data as TJSONArray;
        TempQuery.Prepare; // Spart Zeit, wie Updatebegin z.b.
        for i:=0 to NoteArray.Count -1 do begin
          NoteObject:=NoteArray[i] as TJSONObject;
          result:=_AddNote(NoteObject);
        end; // for i
        TempQuery.UnPrepare;
      end
      else begin
       result:=_AddNote(aNoteObject);
      end;
    finally
      if AutoCommit then SQLTransaction.Commit;
      doOnSQLResultAddNote(aNoteObject);

      TempQuery.Close;
      FreeAndNil(TempQuery);
    end;
  except
    on E: Exception do begin
      msgStr:=E.Message;
      writeln(#13, 'TPLNMV6C_sqlite.AddNote:',msgStr);
      doOnSQLResultError(EVT_ERROR,msgStr,'TPLNMV6C_sqlite.AddNote');
      raise;
    end;
  end;
end; // TPLNMV6C_sqlite.AddNote

function TPLNMV6C_sqlite.UpdateNote(var aNoteObject: TJSONObject): Boolean;
var
  TempQuery:TSQLQuery;
  msgStr:String;

  i:Integer;

  titleStr, contentStr, NoteID:String;
  jName:String;
  sqlName:String;
  TempField:TField;
begin
  result:=False;
  try
    try
      TempQuery:=TSQLQuery.Create(nil);
      TempQuery.DataBase:=SQlConnector;
      titleStr:=''; contentStr:=''; jName:=''; sqlName:='';
      for i:=0 to aNoteObject.Count -1 do begin
        jName:=aNoteObject.Names[i];
        if jName = 'uuid' then NoteID:=aNoteObject.Items[i].AsString;

        if jName = 'title' then begin
          titleStr:=aNoteObject.Items[i].AsString;
          sqlName:=AddStr('title=:title',sqlName);
        end; // title

        if jName = 'content' then begin
          contentStr:=aNoteObject.Items[i].AsString;
          sqlName:=AddStr('content=:content',sqlName);
        end; // content
      end; // for i

      // SQL Anweisung Zusammenbauen.
      TempQuery.SQL.Clear;
      TempQuery.SQL.Add('UPDATE notes SET ');
      TempQuery.SQL.Add(SQLName);
      TempQuery.SQL.Add(' WHERE uuid=:uuid;');
      TempQuery.ParamByName('uuid').AsString:=NoteID;

      if titleStr <> '' then TempQuery.ParamByName('title').AsString:=titleStr;
      if contentStr <> '' then TempQuery.ParamByName('content').AsString:=contentStr;
      TempQuery.ExecSQL;

      if AutoCommit then SQLTransaction.Commit;

      // Daten im aNoteObject Aktuallisieren
      TempQuery.SQL.Clear;
      TempQuery.SQL.Add('SELECT mtime, mcount FROM notes WHERE uuid=:uuid;');
      TempQuery.ParamByName('uuid').AsString:=NoteID;
      TempQuery.Open;

      TempField:=TempQuery.Fields.FieldByName('mcount');
      if Assigned(TempField) then
        aNoteObject.Elements['mcount'].AsInteger:=TempField.AsInteger;

      TempField:=TempQuery.Fields.FieldByName('mtime');
      if Assigned(TempField) then
        aNoteObject.Elements['mtime'].AsString:=DateTimeToStr(TempField.AsDateTime, myFormatSettings);

      result:=True;

      doOnSQLResultUpdateNote(aNoteObject);
    finally
      FreeAndNil(TempQuery);
    end;
  except
    on E: Exception do begin
      msgStr:=E.Message;
      writeln(#13, 'TPLNMV6C_sqlite.UpdateNote:',msgStr);
      doOnSQLResultError(EVT_ERROR,msgStr,'TPLNMV6C_sqlite.UpdateNote');
      raise;
    end;
  end;
end; // TPLNMV6C_sqlite.UpdateNote

function TPLNMV6C_sqlite.DeleteNote(var aJObject: TJSONObject): Boolean;
begin
  result:=False;
end; // TPLNMV6C_sqlite.DeleteNote

function TPLNMV6C_sqlite.GetNotes(const aTagFilterList: TJSONArray; const aWihtContent: Boolean; const aSQLStr: String; aCreateStatistik: boolean): Boolean;
var
  TempQuery:TSQLQuery;

  Notes:TJSONArray;
  NoteObject, GetNoteObject:TJSONObject;
  Fild:TField;
  FildName:String;
  msgStr:String;

  x:Integer;
begin
  result:=False;
  try
    try
      TempQuery:=TSQLQuery.Create(nil);
      TempQuery.DataBase:=SQlConnector;
      if aSQLStr = '' then begin
        TempQuery.SQL.Add('select id, uuid, title, ');
        if aWihtContent then
          TempQuery.SQL.Add('content, ');
        TempQuery.SQL.Add('ctime, mtime, atime, mcount,acount from notes;')
      end
      else
        TempQuery.SQL.Add(aSQLStr);
      TempQuery.Open;

      if TempQuery.RecordCount > 0 then begin
        Notes:=TJSONArray.Create();
        TempQuery.First;
        while not TempQuery.Eof do begin
          NoteObject:=TJSONObject.Create();
          for x:=0 to TempQuery.Fields.Count -1 do begin
            Fild:=TempQuery.Fields[x];
            FildName:=Fild.FieldName;
            case FildName of
              'id': NoteObject.Add('id', Fild.AsInteger);
              'uuid':NoteObject.Add('uuid', Fild.AsString);
              'title':NoteObject.Add('title',trim(Fild.AsString));
              'content':NoteObject.Add('content',trim(Fild.AsString));
              'ctime':NoteObject.Add('ctime',Fild.AsString);
              'mtime':NoteObject.Add('mtime',Fild.AsString);
              'atime':NoteObject.Add('atime',Fild.AsString);
              'mcount':NoteObject.Add('mcount',Fild.AsInteger);
              'acount':NoteObject.Add('acount',Fild.AsInteger);
            end;
          end; // for x
          Notes.Add(NoteObject);
          TempQuery.Next;
        end;
        TempQuery.Close;

        GetNoteObject:=TJSONObject.Create();
        GetNoteObject.Add('Notes', Notes);
        doOnSQLResultGetNote(GetNoteObject);
        result:=True;
      end;
    finally
      FreeAndNil(TempQuery);
    end;
  except
    on E: Exception do begin
      msgStr:=E.Message;
      writeln(#13, 'TPLNMV6C_sqlite.GetNote:',msgStr);
      doOnSQLResultError(EVT_ERROR,msgStr,'TPLNMV6C_sqlite.GetNotes');
      raise;
    end;
  end;

end; // TPLNMV6C_sqlite.GetNotes

function TPLNMV6C_sqlite.GetContentFromNote(const aUUID: String): string;
var
  TempQuery:TSQLQuery;
  msgStr:String;
  TempField:TField;
begin
  result:='';
  try
    try
      TempQuery:=TSQLQuery.Create(nil);
      TempQuery.DataBase:=SQlConnector;
      TempQuery.SQL.Add('SELECT content FROM notes WHERE uuid=:uuid');
      TempQuery.ParamByName('uuid').AsString:=aUUID;
      TempQuery.Open;

      if TempQuery.RecordCount >= 0 then begin
        TempField:=TempQuery.Fields.FieldByName('content');
        if Assigned(TempField) then begin
          result:=TempField.AsString
        end;
      end;


    finally
      FreeAndNil(TempQuery);
    end;

  except
    on E: Exception do begin
      msgStr:=E.Message;
      writeln(#13, 'TPLNMV6C_sqlite.GetContentFromNote:',msgStr);
      doOnSQLResultError(EVT_ERROR,msgStr,'TPLNMV6C_sqlite.GetContentFromNote');
      raise;
    end;
  end;
end; // TPLNMV6C_sqlite.GetContentFromNote

function TPLNMV6C_sqlite.GetTagListFromTagID(const aUUID: String): Boolean;
begin
  result:=False;
end; // TPLNMV6C_sqlite.GetTagListFromTagID

function TPLNMV6C_sqlite.AddTag(var aTagObject: TJSONObject;
  const aTagMetaData: Boolean): Boolean;
var
  Temp_id:TParam;
  Temp_name:TParam;
  Temp_ctime:TParam;
  Temp_mtime:TParam;
  Temp_atime:TParam;
  TempQuery:TSQLQuery;

  function _AddTag(var _aTagObject:TJSONObject): Boolean;
  var
    FildData:TJSONData;
    FildName:String;
    i:Integer;
    msgStr:String;
    jData:TJSONData;
  begin
    result:=False;
    try
      for i:=0 to _aTagObject.Count -1 do begin
        FildName:=_aTagObject.Names[i];
        FildData:=_aTagObject.Items[i];
        if (FildData.AsString <> '') then begin
          if FildName = 'id' then Temp_id.AsInteger:=FildData.AsInteger;
          if FildName = 'name' then Temp_name.AsString:=FildData.AsString;

          if aTagMetaData then begin
            if FildName = 'ctime' then Temp_ctime.AsDateTime:=StrToDateTime(FildData.AsString, myFormatSettings);
            if FildName = 'mtime' then Temp_mtime.AsDateTime:=StrToDateTime(FildData.AsString, myFormatSettings);
            if FildName = 'atime' then Temp_atime.AsDateTime:=StrToDateTime(FildData.AsString, myFormatSettings);
          end;
        end;
      end; // for i

      if not aTagMetaData then begin
        Temp_ctime.AsDateTime:=now;
        Temp_mtime.AsDateTime:=now;
        Temp_atime.AsDateTime:=now;
      end;
      TempQuery.ExecSQL;

      jData:=_aTagObject.Find('ctime');
      if Assigned(jData) then
        jData.AsString:=DateTimeToStr(Temp_ctime.AsDateTime)
      else
        _aTagObject.Add('ctime', DateTimeToStr(Temp_ctime.AsDateTime));

      jData:=_aTagObject.Find('mtime');
      if Assigned(jData) then
        jData.AsString:=DateTimeToStr(Temp_mtime.AsDateTime)
      else
        _aTagObject.Add('mtime', DateTimeToStr(Temp_mtime.AsDateTime));

      jData:=_aTagObject.Find('atime');
      if Assigned(jData) then
        jData.AsString:=DateTimeToStr(Temp_atime.AsDateTime)
      else
        _aTagObject.Add('atime', DateTimeToStr(Temp_atime.AsDateTime));

      if SQlConnector.GetInsertID > 0 then begin
        _aTagObject.Add('id',SQlConnector.GetInsertID);
      end;
    except
      on E: Exception do begin
        msgStr:=E.Message;
        writeln(#13, 'TPLNMV6C_sqlite.AddTag _AddTag:',msgStr);
        doOnSQLResultError(EVT_ERROR,msgStr,'TPLNMV6C_sqlite.AddTag _AddTag');
        raise;
      end;
    end;
  end; // _AddTag

var
  msgStr:String;
  i:Integer;

  jData:TJSONData;
  TagObject:TJSONObject;
  TagArray:TJSONArray;
begin
  result:=False;
  try
    try
      TempQuery:=TSQLQuery.Create(nil);
      TempQuery.DataBase:=SQlConnector;

      TempQuery.SQL.Add('INSERT INTO tags (');
          TempQuery.SQL.Add('id, ');
          TempQuery.SQL.Add('name, ');
          TempQuery.SQL.Add('ctime, ');
          TempQuery.SQL.Add('mtime, ');
          TempQuery.SQL.Add('atime');
        TempQuery.SQL.Add(') VALUES (');
          TempQuery.SQL.Add(':id, ');
          TempQuery.SQL.Add(':name, ');
          TempQuery.SQL.Add(':ctime, ');
          TempQuery.SQL.Add(':mtime, ');
          TempQuery.SQL.Add(':atime ');
        TempQuery.SQL.Add(');');

        Temp_id:=TempQuery.ParamByName('id'); // 0
        Temp_name:=TempQuery.ParamByName('name'); // 1
        Temp_ctime:=TempQuery.ParamByName('ctime'); // 2
        Temp_mtime:=TempQuery.ParamByName('mtime'); // 3
        Temp_atime:=TempQuery.ParamByName('atime'); // 4

        jData:=aTagObject.Find('Items');
        if Assigned(jData) then begin
          TagArray:=jData as TJSONArray;
          for i:=0 to TagArray.Count -1 do begin
            TagObject:=TagArray[i] as TJSONObject;
            _AddTag(TagObject);
          end;

        end
        else begin
          _AddTag(aTagObject);
        end;

    finally
      if AutoCommit then SQLTransaction.Commit;
      doOnSQLResultAddTag(aTagObject);
      TempQuery.Close;
      FreeAndNil(TempQuery);
    end;

  except
    on E: Exception do begin
      msgStr:=E.Message;
      writeln(#13, 'TPLNMV6C_sqlite.AddTag:',msgStr);
      doOnSQLResultError(EVT_ERROR,msgStr,'TPLNMV6C_sqlite.AddTag');
      raise;
    end;
  end;
end; // TPLNMV6C_sqlite.AddTag

function TPLNMV6C_sqlite.UpdateTag: Boolean;
begin
  result:=False;
end; // TPLNMV6C_sqlite.UpdateTag

function TPLNMV6C_sqlite.DeleteTag: Boolean;
begin
  result:=False;
end;

function TPLNMV6C_sqlite.GetTags(const aSortetByUserIndex: boolean): Boolean;
var
  TempQuery:TSQLQuery;
  FildName:String;

  Fild:TField;
  Tags:TJSONArray;
  TagObject:TJSONObject;
  msgStr:String;
  x:Integer;
  EventObject:TJSONObject;
begin
  result:=False;
  try
    try
      TempQuery:=TSQLQuery.Create(nil);
      TempQuery.DataBase:=SQlConnector;
      if not aSortetByUserIndex then
        TempQuery.SQL.Add('select id, name, ctime, mtime, atime from tags;')
      else begin
        //  DESC ASC
        TempQuery.SQL.Add('select id, name, ctime, mtime, atime, userindex from tags order by userindex ASC;');
      end;

      TempQuery.Open;
      if TempQuery.RecordCount > 0 then begin
        Tags:=TJSONArray.Create();
        TempQuery.First;
        while not TempQuery.Eof do begin
          TagObject:=TJSONObject.Create();
          for x:=0 to TempQuery.Fields.Count -1 do begin
            Fild:=TempQuery.Fields[x];
            FildName:=Fild.FieldName;

            if FildName = 'id' then TagObject.Add('id', Fild.AsInteger);
            if FildName = 'name' then TagObject.Add('name', Fild.AsString);
            if FildName = 'ctime' then TagObject.Add('ctime',Fild.AsString);
            if FildName = 'mtime' then TagObject.Add('mtime',Fild.AsString);
            if FildName = 'atime' then TagObject.Add('atime',Fild.AsString);
            if FildName = 'userindex' then TagObject.Add('userindex',Fild.AsInteger);
          end; // for x
          Tags.Add(TagObject);
          TempQuery.Next;
        end;
        TempQuery.Close;
      end;
    finally
      EventObject:=TJSONObject.Create();
      EventObject.Add('Tags',Tags);
      doOnSQLResultGetTags(EventObject);
      FreeAndNil(TempQuery);
    end;
  except
    on E: Exception do begin
      msgStr:=E.Message;
      writeln(#13, 'TPLNMV6C_sqlite.GetTags:',msgStr);
      doOnSQLResultError(EVT_ERROR,msgStr,'TPLNMV6C_sqlite.GetTags');
      raise;
    end;
  end;
end; // TPLNMV6C_sqlite.GetTags

function TPLNMV6C_sqlite.ImportFromOldDataBase(const aFileName: String): Boolean;
begin
  result:=False;
end; // TPLNMV6C_sqlite.ImportFromOldDataBase

end.

