{
  Autor: Michael Springwald

  Datum: Dienstag, 26.09.2023

  Neue Filter Funktion für, Tags
  SELECT * FROM notes WHERE UUID IN (SELECT note_id FROM note_tags WHERE tag_id in (5,9));

  SELECT * FROM notes WHERE UUID = (SELECT value FROM config WHERE key = 'last_focus_note');

  {859CA510-6A69-11EE-8000-000000000000}
}

unit unmv6c_sqlite;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, clocale, uuid, DB, SQLDB, SQLite3Conn, fpjson, unmv6c_type;

type

  { TPLNMV6C_sqlite }

  TPLNMV6C_sqlite = class
  private
    fAutoCommit: Boolean;
    fDB_Name: String;
    fOnSQlResultAddCity: TOnSQLResultAddCity;
    fOnSQLResultAddNote: TOnSQLResultAddNote;
    fOnSQLResultAddTag: TOnSQLResultAddTag;
    fOnSQlResultDeleteCitys: TOnSQlResultDeleteCitys;
    fOnSQLResultDeleteNote: TOnSQLResultDeleteNote;
    fOnSQLResultDeleteTag: TOnSQLResultDeleteTag;
    fOnSQLResultError: TOnSQLResultError;
    fOnSqlResultGetCity: TOnSQLResultGetCitys;
    fOnSqlResultGetConfig: TOnSqlResultGetConfig;
    fOnSQLResultGetContent: TOnSQLResultGetContent;
    fOnSQLResultGetNotes: TOnSQLResultGetNotes;
    fOnSQLResultGetTagListFromTagID: TOnSQLResultGetTagListFromTagID;
    fOnSQLResultGetTags: TOnSQLResultGetTags;
    fOnSqlResultUpdateCity: TOnSQlResultUpdateCity;
    fOnSqlResultUpdateCitys: TOnSQlResultUpdateCitys;
    fOnSQLResultUpdateNote: TOnSQLResultUpdateNote;
    fOnSQLResultUpdateTag: TOnSQLResultUpdateTag;

    function CreateDB():boolean;
    procedure SetDB_Name(AValue: String);
  protected
    procedure doOnSQLResultAddNote(aNoteObject:TJSONObject);
    procedure doOnSQLResultAddTag(aNoteObject:TJSONObject);
    procedure doOnSQLResultAddCity(aCityObject:TJSONObject);
    procedure doOnSQLResultDeleteNote(aNoteIDList: TJSONArray);
    procedure doOnSQLResultDeleteTag(aTagIdList:TJSONArray);
    procedure doOnSQLResultDeleteCitys(const aDeleteCityList:TJSONArray);
    procedure doOnSQLResultUpdateNote(aNoteObject:TJSONObject);
    procedure doOnSqlResultUpdateCity(const aCityObject:TJSONObject);
    procedure doOnSqlResultUpdateCitys(const aCityObjects:TJSONArray);
    procedure doOnSQLResultGetTagListFromTagID(aNoteObject:TJSONObject);
    procedure doOnSQLResultGetNote(aNoteObject:TJSONObject);
    procedure doOnSQLResultGetTags(aNoteObject:TJSONObject);
    procedure doOnSqlResultGetCitys(aCityArray:TJSONArray);
    procedure doOnSQLResultUpdateTag(aTagObject:TJSONObject);
    procedure doOnSQLResultGetContent(aNoteObject:TJSONObject);
    procedure doOnSQLResultError(const aErrorEventType:TPLOnErrorEventType; aErrorMSG:String; aSender:String);
    procedure doOnSqlResultGetConfig(aConfigObject:TJSONObject);

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

{}  function AddNote(var aNoteObject:TJSONObject; const aExtModus:Boolean = false):Boolean; // TOnSQLResultAddNote
{}  function UpdateNote(var aNoteObject:TJSONObject):Boolean; //  TOnSQLResultUpdateNote
{}  function DeleteNote(const aNoteIDList:TJSONArray):Boolean; //  TOnSQLResultDeleteNote
{}  function GetNotes(const aTagFilterList, aNodeIdList:TJSONArray; const alast_focus_note:String; const aWihtContent:Boolean = False; const aSQLStr:String = ''; aCreateStatistik:boolean = false):Boolean; // TOnGetNote
{}  function GetContentFromNote(const aUUID:String):string; // TOnSQLResultGetContent
    function GetNoteContent(var aNoteObject:TJSONObject):Boolean;

    function GetTagListFromTagID(const aUUID:String):TJSONArray; // TOnSQLResultGetTagListFromTagID

{}  function AddTag(var aTagObject:TJSONObject; const aTagMetaData:Boolean = False; const aExtModus:Boolean = false):Boolean; // TOnSQLResultAddTag
{}  function AddNote_Tags(const aNoteID:String; const aJArray:TJSONArray):Integer;
{}  function NoteLinketToTag(const aNoteID:string; const aTagID:Integer; const aTagAction:TPLNMV6C_TagAction):Boolean;

{}  function UpdateTag(const aTagObject:TJSONObject):Boolean; // TOnSQLResultUpdateTag
{}  function DeleteTag(const aTagIdList:TJSONArray):Boolean; // TOnSQLResultDeleteTag
{}  function GetTags(const aSortetByUserIndex:boolean = False):Boolean; // TOnSQLResultGetTag
{}  function ChangeAllTagUserIndex(const aTagArray:TJSONArray):boolean;

{}  function AddCity(var aCityObject:TJSONObject):Boolean; // TOnSQlResultAddCity
{}  function UpdateCity(const aCityObject:TJSONObject):Boolean; // TOnSqlResultUpdateCity
{}  function UpdateCitys(var aCityObjects:TJSONArray):Boolean;
{}  function GetCitys():Boolean; // TOnSQLResultGetCitys
{}  function GetCitysById(const jIDList:TJSONArray; var aNamedList:TJSONArray):Boolean;

{}  function DeleteCitys(const aDeleteCityList:TJSONArray): Boolean; // TOnSQlResultDeleteCitys

{}  function JObjectToSQLtable(const JConfigObject:TJSONObject; const aSQlTableName:String):boolean;
{}  function SQLtableToJObject(const aSQLTableName:String):Boolean;

{}  function ImportFromOldDataBase(const aFileName:String):Boolean; // TOnSQLResultAddNote, TOnSQLResultAddTag

{}  property OnSQLResultAddNote:TOnSQLResultAddNote read fOnSQLResultAddNote write fOnSQLResultAddNote;
{}  property OnSQLResultUpdateNote:TOnSQLResultUpdateNote read fOnSQLResultUpdateNote write fOnSQLResultUpdateNote;
{}  property OnSQLResultDeleteNote:TOnSQLResultDeleteNote read fOnSQLResultDeleteNote write fOnSQLResultDeleteNote;
{}  property OnSQLResultGetNotes:TOnSQLResultGetNotes read fOnSQLResultGetNotes write fOnSQLResultGetNotes;
{}  property OnSQLResultGetContent:TOnSQLResultGetContent read fOnSQLResultGetContent write fOnSQLResultGetContent;
    property OnSQLResultGetTagListFromTagID:TOnSQLResultGetTagListFromTagID read fOnSQLResultGetTagListFromTagID write fOnSQLResultGetTagListFromTagID;

{}  property OnSQLResultAddTag:TOnSQLResultAddTag read fOnSQLResultAddTag write fOnSQLResultAddTag;
    property OnSQLResultUpdateTag:TOnSQLResultUpdateTag read fOnSQLResultUpdateTag write fOnSQLResultUpdateTag;
    property OnSQLResultDeleteTag:TOnSQLResultDeleteTag read fOnSQLResultDeleteTag write fOnSQLResultDeleteTag;
    property OnSQLResultGetTags:TOnSQLResultGetTags read fOnSQLResultGetTags write fOnSQLResultGetTags;

    property OnSQlResultAddCity:TOnSQLResultAddCity read fOnSQlResultAddCity write fOnSQlResultAddCity;
    property OnSqlResultGetCity:TOnSQLResultGetCitys read fOnSqlResultGetCity write fOnSqlResultGetCity;
    property OnSQlResultDeleteCitys:TOnSQlResultDeleteCitys read fOnSQlResultDeleteCitys write fOnSQlResultDeleteCitys;
    property OnSqlResultUpdateCity:TOnSQlResultUpdateCity read fOnSqlResultUpdateCity write fOnSqlResultUpdateCity;
    property OnSqlResultUpdateCitys:TOnSQlResultUpdateCitys read fOnSqlResultUpdateCitys write fOnSqlResultUpdateCitys;

    property OnSqlResultGetConfig:TOnSqlResultGetConfig read fOnSqlResultGetConfig write fOnSqlResultGetConfig;

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
      SQLScript.Script.Add('userindex INTEGER,');
      SQLScript.Script.Add('location INTEGER');
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

    SQLScript.Script.Add('CREATE TABLE if not exists config (');
      SQLScript.Script.Add('key BLOB NOT NULL UNIQUE,');
      SQLScript.Script.Add('value BLOB NOT NULL');
    SQLScript.Script.Add(');');
    SQLScript.Script.Add('');

    SQLScript.Script.Add('CREATE TABLE if not exists citylist (');
      SQLScript.Script.Add('id INTEGER PRIMARY KEY NOT NULL,');
      SQLScript.Script.Add('name BLOB NOT NULL,');
      SQLScript.Script.Add('ctime DATETIME,');
      SQLScript.Script.Add('content BLOB');
    SQLScript.Script.Add(');');
    SQLScript.Script.Add('');

    SQLScript.ExecuteScript;

    try
      TempQuery:=TSQLQuery.Create(nil);
      TempQuery.DataBase:=SQlConnector;

      TempQuery.SQL.Clear;
      TempQuery.SQL.Add('CREATE TRIGGER IF NOT EXISTS note_update BEFORE UPDATE ON notes');
      TempQuery.SQL.Add('BEGIN');
      TempQuery.SQL.Add('UPDATE notes SET mcount = mcount + 1, mtime = (DATETIME(''now'',''localtime'')) WHERE id = new.id AND (title != new.title OR content != new.content);');
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
    if AValue <> '' then
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

procedure TPLNMV6C_sqlite.doOnSQLResultAddCity(aCityObject: TJSONObject);
begin
  if Assigned(fOnSQlResultAddCity) then fOnSQlResultAddCity(aCityObject);
end; // TPLNMV6C_sqlite.doOnSQLResultAddCity

procedure TPLNMV6C_sqlite.doOnSQLResultDeleteNote(aNoteIDList: TJSONArray);
begin
  if Assigned(fOnSQLResultDeleteNote) then fOnSQLResultDeleteNote(aNoteIDList);
end; // TPLNMV6C_sqlite.doOnSQLResultDeleteNote

procedure TPLNMV6C_sqlite.doOnSQLResultDeleteTag(aTagIdList: TJSONArray);
begin
  if Assigned(fOnSQLResultDeleteTag) then fOnSQLResultDeleteTag(aTagIdList);
end; // TPLNMV6C_sqlite.doOnSQLResultDeleteTag

procedure TPLNMV6C_sqlite.doOnSQLResultDeleteCitys(const aDeleteCityList: TJSONArray);
begin
  if Assigned(fOnSQlResultDeleteCitys) then fOnSQlResultDeleteCitys(aDeleteCityList);
end; // TPLNMV6C_sqlite.doOnSQLResultDeleteCitys

procedure TPLNMV6C_sqlite.doOnSQLResultUpdateNote(aNoteObject: TJSONObject);
begin
  if Assigned(fOnSQLResultUpdateNote) then fOnSQLResultUpdateNote(aNoteObject);
end; // TPLNMV6C_sqlite.doOnSQLResultUpdateNote

procedure TPLNMV6C_sqlite.doOnSqlResultUpdateCity(const aCityObject: TJSONObject);
begin
  if Assigned(fOnSqlResultUpdateCity) then fOnSqlResultUpdateCity(aCityObject);
end; // TPLNMV6C_sqlite.doOnSqlResultUpdateCity

procedure TPLNMV6C_sqlite.doOnSqlResultUpdateCitys(const aCityObjects: TJSONArray);
begin
  if Assigned(fOnSqlResultUpdateCitys) then fOnSqlResultUpdateCitys(aCityObjects);
end;

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

procedure TPLNMV6C_sqlite.doOnSqlResultGetCitys(aCityArray: TJSONArray);
begin
  if Assigned(fOnSqlResultGetCity) then fOnSqlResultGetCity(aCityArray);
end;

procedure TPLNMV6C_sqlite.doOnSQLResultUpdateTag(aTagObject: TJSONObject);
begin
  if Assigned(fOnSQLResultUpdateTag) then fOnSQLResultUpdateTag(aTagObject);
end; // TPLNMV6C_sqlite.doOnSQLResultUpdateTag

procedure TPLNMV6C_sqlite.doOnSQLResultGetContent(aNoteObject: TJSONObject);
begin
  if Assigned(fOnSQLResultGetContent) then fOnSQLResultGetContent(aNoteObject);
end; // TPLNMV6C_sqlite.doOnSQLResultGetContent

procedure TPLNMV6C_sqlite.doOnSQLResultError(const aErrorEventType: TPLOnErrorEventType; aErrorMSG: String; aSender: String);
begin
  if Assigned(fOnSQLResultError) then fOnSQLResultError(aErrorEventType, aErrorMSG, aSender);
end; // TPLNMV6C_sqlite.doOnSQLResultError

procedure TPLNMV6C_sqlite.doOnSqlResultGetConfig(aConfigObject: TJSONObject);
begin
  if Assigned(fOnSqlResultGetConfig) then fOnSqlResultGetConfig(aConfigObject);
end; // TPLNMV6C_sqlite.doOnSqlResultGetConfig

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
  fOnSqlResultGetConfig:=nil;
  fOnSqlResultGetCity:=nil;
  fOnSQlResultDeleteCitys:=nil;
  fOnSqlResultUpdateCity:=nil;
  OnSqlResultUpdateCitys:=nil;

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

function TPLNMV6C_sqlite.AddNote(var aNoteObject: TJSONObject; const aExtModus: Boolean): Boolean;
var
  TempQuery:TSQLQuery;

  Temp_uuid:TParam;
  Temp_title:TParam;
  Temp_content:TParam;
  Temp_ctime:TParam;
  Temp_mtime:TParam;
  Temp_atime:TParam;
  Temp_location:TParam;

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

      Data:=_aNoteObject.Find('uuid');
      if not Assigned(Data) then begin
        _aNoteObject.Add('uuid', TempUuid.ToString);
        Temp_uuid.AsString:=TempUuid.ToString();
      end
      else begin
        Temp_uuid.AsString:=Data.AsString;
      end;

      Data:=_aNoteObject.Find('ctime');
      if not Assigned(Data) then begin
        Temp_ctime.AsDateTime:=now;
        _aNoteObject.Add('ctime', DateTimeToStr(now))
      end
      else begin
        Temp_ctime.AsDateTime:=StrToDateTime(Data.AsString, myFormatSettings);
      end;

       Data:=_aNoteObject.Find('mtime');
       if not Assigned(Data) then begin
         _aNoteObject.Add('mtime', DateTimeToStr(now));
         Temp_mtime.AsDateTime:=now;
       end
       else
         Temp_mtime.AsDateTime:=StrToDateTime(Data.AsString, myFormatSettings);

       Data:=_aNoteObject.Find('atime');
       if not Assigned(Data) then begin
         _aNoteObject.Add('atime', DateTimeToStr(now));
         Temp_atime.AsDateTime:=now;
       end
       else
         Temp_atime.AsDateTime:=StrToDateTime(Data.AsString, myFormatSettings);

       Data:=_aNoteObject.Find('location');
       if Assigned(Data) then
         Temp_location.AsInteger:=Data.AsInteger
       else
         _aNoteObject.Add('location', '');

       Data:=_aNoteObject.Find('acount');
       if not Assigned(Data) then _aNoteObject.Add('acount', 0);

       Data:=_aNoteObject.Find('mcount');
       if not Assigned(Data) then _aNoteObject.Add('mcount', 0);


       Data:=_aNoteObject.Find('id');
       if Assigned(Data) then begin
         _aNoteObject.Add('id', SQlConnector.GetInsertID);
         result:=True;
       end
       else
         result:=False;

       TempQuery.ExecSQL;

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
    TempQuery.DataBase:=SQlConnector;
    try
      // Zuerst prüfen, ob es den Title schon in der Datenbank gibt.
      data:=aNoteObject.Find('Notes');
      if Assigned(Data) then begin
        NoteArray:=data as TJSONArray;
        TempQuery.SQL.Add('SELECT title FROM notes WHERE title=:title;');
        Temp_title:=TempQuery.ParamByName('title');

        for i:=NoteArray.Count -1 downto 0 do begin
          NoteObject:=NoteArray[i] as TJSONObject;

          Temp_title.AsString:=NoteObject.Elements['title'].AsString;
          TempQuery.Open;
          if TempQuery.RecordCount > 0 then begin
            writeln('Gibt es schon: "', Temp_title.AsString);
            NoteArray.Delete(i);
          end;
          TempQuery.Close;
        end;

        TempQuery.SQL.Clear;
      end;

      if not aExtModus then
        TempQuery.SQL.Add('INSERT INTO notes (')
      else
        TempQuery.SQL.Add('INSERT OR IGNORE INTO notes (');

          TempQuery.SQL.Add('title, ');
          TempQuery.SQL.Add('content, ');
          TempQuery.SQL.Add('uuid,');
          TempQuery.SQL.Add('ctime,');
          TempQuery.SQL.Add('mtime,');
          TempQuery.SQL.Add('atime,');
          TempQuery.SQL.Add('location');
        TempQuery.SQL.Add(') ');
        TempQuery.SQL.Add('VALUES (');
          TempQuery.SQL.Add(':title,');
          TempQuery.SQL.Add(':content,');
          TempQuery.SQL.Add(':uuid,');
          TempQuery.SQL.Add(':ctime,');
          TempQuery.SQL.Add(':mtime,');
          TempQuery.SQL.Add(':atime,');
          TempQuery.SQL.Add(':location');
        TempQuery.SQL.Add(');');

      Temp_uuid:=TempQuery.ParamByName('uuid'); // 0
      Temp_title:=TempQuery.ParamByName('title'); // 1
      Temp_content:=TempQuery.ParamByName('content'); // 2
      Temp_ctime:=TempQuery.ParamByName('ctime'); // 3
      Temp_mtime:=TempQuery.ParamByName('mtime'); // 4
      Temp_atime:=TempQuery.ParamByName('atime'); // 5
      Temp_location:=TempQuery.ParamByName('location'); // 6

      data:=aNoteObject.Find('Notes');
      if Assigned(data) then begin
        NoteArray:=data as TJSONArray;
        if NoteArray.Count > 0 then begin
          TempQuery.Prepare; // Spart Zeit, wie Updatebegin z.b.
          for i:=0 to NoteArray.Count -1 do begin
            NoteObject:=NoteArray[i] as TJSONObject;
            result:=_AddNote(NoteObject);
            if not Result then NoteObject.Add('delete',true);
          end; // for i
          TempQuery.UnPrepare;

          for i:=NoteArray.Count -1 downto 0 do begin
            NoteObject:=NoteArray[i] as TJSONObject;
            data:=NoteObject.find('delete');
            if Assigned(data) then begin
         //     NoteArray.Delete(i);
            end;
          end; // for i
        end;
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
  cTime:TDateTime;
  jName:String;
  sqlName:String;
  TempField:TField;
  jData:TJSONData;

  locationTemp:Integer;
begin
  result:=False;
  try
    try
      TempQuery:=TSQLQuery.Create(nil);
      TempQuery.DataBase:=SQlConnector;
      titleStr:=''; contentStr:=''; jName:=''; sqlName:=''; cTime:=0; locationTemp:=-1;
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

        if jname = 'ctime' then begin
          jData:=aNoteObject.Find('ctimeChange');
          if Assigned(jData) then begin
            cTime:=StrToDate(aNoteObject.Items[i].AsString, myFormatSettings);
            sqlName:=AddStr('ctime=:ctime',sqlName);
          end;
        end;

        if jName = 'location' then begin
          locationTemp:=aNoteObject.Items[i].AsInteger;
          sqlName:=AddStr('location=:location',sqlName);
        end; // content

      end; // for i

      if Assigned(aNoteObject.Find('ctimeChange')) then
        aNoteObject.Delete('ctimeChange');

      // SQL Anweisung Zusammenbauen.
      TempQuery.SQL.Clear;
      TempQuery.SQL.Add('UPDATE notes SET ');
      TempQuery.SQL.Add(SQLName);
      TempQuery.SQL.Add(' WHERE uuid=:uuid;');
      TempQuery.ParamByName('uuid').AsString:=NoteID;

      if titleStr <> '' then TempQuery.ParamByName('title').AsString:=titleStr;
      if contentStr <> '' then TempQuery.ParamByName('content').AsString:=contentStr;
      if ctime > 0 then TempQuery.ParamByName('ctime').AsDate:=cTime;
      if locationTemp > 0 then TempQuery.ParamByName('location').AsInteger:=locationTemp;
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
      TempQuery.Close;
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

function TPLNMV6C_sqlite.DeleteNote(const aNoteIDList: TJSONArray): Boolean;
var
  TempQuery:TSQLQuery;
  msgStr:String;
  uuidP:TParam;
  i:Integer;
begin
  result:=false;
  try
    TempQuery:=TSQLQuery.Create(nil);
    TempQuery.DataBase:=SQlConnector;
    try
      TempQuery.SQL.Add('DELETE FROM notes WHERE uuid=:uuid');
      uuidP:=TempQuery.ParamByName('uuid');
      for i:=0 to aNoteIDList.Count - 1 do begin
        uuidP.AsString:=aNoteIDList[i].AsString;
        TempQuery.ExecSQL;
      end; // for i
      result:=True;
    finally
      TempQuery.Close;
      FreeAndNil(TempQuery);
      if AutoCommit then SQLTransaction.Commit;
      doOnSQLResultDeleteNote(aNoteIDList);
    end;

  except
    on E: Exception do begin
      msgStr:=E.Message;
      writeln(#13, 'TPLNMV6C_sqlite.DeleteNote:',msgStr);
      doOnSQLResultError(EVT_ERROR,msgStr,'TPLNMV6C_sqlite.DeleteNote');
      raise;
    end;
  end;

end; // TPLNMV6C_sqlite.DeleteNote

function TPLNMV6C_sqlite.GetNotes(const aTagFilterList,
  aNodeIdList: TJSONArray; const alast_focus_note: String;
  const aWihtContent: Boolean; const aSQLStr: String; aCreateStatistik: boolean
  ): Boolean;
var
  TempQuery:TSQLQuery;

  Notes:TJSONArray;
  NoteObject, GetNoteObject:TJSONObject;
  Fild:TField;
  FildName:String;
  msgStr:String;
  TagIDListStr:String;
  NodeIdListStr:String;
  x:Integer;
  AutoOpen:boolean;

  jCityIDList, jCityNameList:TJSONArray;
begin
  result:=False; AutoOpen:=False;

  jCityIDList:=TJSONArray.Create();
  jCityNameList:=TJSONArray.Create();
  try
    try
      TagIDListStr:='';
      TempQuery:=TSQLQuery.Create(nil);
      TempQuery.DataBase:=SQlConnector;
      if aSQLStr = '' then begin
        // SELECT * FROM notes WHERE UUID IN (SELECT note_id FROM note_tags WHERE tag_id in (5,9));
        if (Assigned(aTagFilterList)) and (aTagFilterList.Count > 0) then begin
          for x:=0 to aTagFilterList.Count -1 do begin
            TagIDListStr+=aTagFilterList[x].AsString;
            if x < aTagFilterList.Count -1 then
              TagIDListStr+=',';
          end; // for x
          TempQuery.SQL.Add(format('SELECT * FROM notes WHERE UUID IN (SELECT note_id FROM note_tags WHERE tag_id in (%s))',[TagIDListStr]));
        end
        else begin
          if Assigned(aNodeIdList) then begin
            NodeIdListStr:='';
            AutoOpen:=true;
            for x:=0 to aNodeIdList.Count -1 do begin
              NodeIdListStr+='"' + aNodeIdList[x].AsString + '"';
              if x < aNodeIdList.Count -1 then
                NodeIdListStr+=',';
            end;
            TempQuery.SQL.Add(format('SELECT * FROM notes WHERE uuid in (%s)',[NodeIdListStr]));
          end
          else begin
            TempQuery.SQL.Add('select id, uuid, title, ');
            if aWihtContent then
              TempQuery.SQL.Add('content, ');
            TempQuery.SQL.Add('ctime, mtime, atime, mcount, acount, location from notes;')
          end;
        end;
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
              'uuid': NoteObject.Add('uuid', Fild.AsString);
              'title': NoteObject.Add('title',trim(Fild.AsString));
              'content':NoteObject.Add('content',trim(Fild.AsString));
              'ctime': begin
                 if not Fild.IsNull then
                   NoteObject.Add('ctime',Fild.AsString);
               end;

              'mtime': begin
                 if not Fild.IsNull then
                   NoteObject.Add('mtime',Fild.AsString);
               end;

              'atime': begin
                 if not Fild.IsNull then
                   NoteObject.Add('atime',Fild.AsString);
               end;

              'mcount': NoteObject.Add('mcount',Fild.AsInteger);
              'acount': NoteObject.Add('acount',Fild.AsInteger);
              'location': begin
                NoteObject.Add('location',Fild.AsInteger);
                jCityIDList.Add(Fild.AsInteger);
              end;
            end;
          end; // for x

          if AutoOpen then begin
            NoteObject.Add('AutoOpen', True);
            NoteObject.Add('NotAddToNoteBrowser', True);
          end;
          Notes.Add(NoteObject);
          TempQuery.Next;
        end;
        TempQuery.Close;
        GetCitysById(jCityIDList, jCityNameList);

        GetNoteObject:=TJSONObject.Create();
        if alast_focus_note <> '' then begin
          GetNoteObject.Add('NoClear', true);
          GetNoteObject.Add('LastFocusNote', alast_focus_note);
        end;

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

function TPLNMV6C_sqlite.GetNoteContent(var aNoteObject: TJSONObject): Boolean;
var
  TempQuery, TempQuery2:TSQLQuery;
  TempField:TField;
  msgStr, idStr:String;
  x:Integer;

  sqlName:String;
  titleStr, contentStr:String;
  acountInt:Integer;
  aTime:TDateTime;
  jData:TJSONData;
  NotMetaDataUpdate:Boolean;
begin
  result:=False;

  sqlName:='';
  try
    try
      NotMetaDataUpdate:=False;
      jData:=aNoteObject.Find('NotMetaDataUpdate');
      if Assigned(jData) then
        NotMetaDataUpdate:=True
      else
        aNoteObject.Add('NotMetaDataUpdate', true);

      idStr:=aNoteObject.Elements['uuid'].AsString;

      TempQuery:=TSQLQuery.Create(nil);
      TempQuery.DataBase:=SQlConnector;

      // acount und atime updaten
      TempQuery.SQL.Add('SELECT title, content, acount, atime FROM notes WHERE uuid =:uuid');
      TempQuery.ParamByName('uuid').AsString:=idStr;
      TempQuery.Open;

      if TempQuery.RecordCount > 0 then begin
        for x:=0 to TempQuery.Fields.Count - 1 do begin
          TempField:=TempQuery.Fields[x];
          case TempField.FieldName of
            'title': begin
              titleStr:=TempField.AsString;
              aNoteObject.Elements['title'].AsString:=titleStr;
              sqlName:=AddStr('title=:title',sqlName);
            end;

            'content': begin
              contentStr:=TempField.AsString;
              jData:=aNoteObject.Find('content');
              if Assigned(jData) then
                jData.AsString:=contentStr
              else
                aNoteObject.Add('content', contentStr);

              sqlName:=AddStr('content=:content',sqlName);
            end;

            'acount': begin
              if not NotMetaDataUpdate then begin
                acountInt:=TempField.AsInteger + 1;
                aNoteObject.Elements['acount'].AsInteger:=acountInt;
                sqlName:=AddStr('acount=:acount',sqlName);
              end;
            end;

            'atime': begin
              if not NotMetaDataUpdate then begin
                aTime:=Now();
                aNoteObject.Elements['atime'].AsString:=DateTimeToStr(aTime , myFormatSettings);
                sqlName:=AddStr('atime=:atime',sqlName);
              end;
            end;
          end;
        end; // for x
        TempQuery.Close();
        // Werte hinzufügen / erstezen im NoteObject

        if not NotMetaDataUpdate then begin
          // Triger in der neuen Datenbank löschen, wenn vorhanden
          TempQuery2:=TSQLQuery.Create(nil);
          TempQuery2.DataBase:=SQlConnector;
          TempQuery2.SQL.Add('DROP TRIGGER if exists note_update;');
          TempQuery2.ExecSQL;
          SQLTransaction.Commit;


          TempQuery.SQL.Clear;
          TempQuery.SQL.Add('UPDATE notes SET ');
          TempQuery.SQL.Add(SQLName);
          TempQuery.SQL.Add(' WHERE uuid=:uuid;');
          TempQuery.ParamByName('uuid').AsString:=idStr;

          TempQuery.ParamByName('title').AsString:=titleStr;
          TempQuery.ParamByName('content').AsString:=contentStr;
          TempQuery.ParamByName('acount').AsInteger:=acountInt;
          TempQuery.ParamByName('atime').AsTime:=aTime;
          TempQuery.ExecSQL;


          // Triger wieder hinzufügen
          TempQuery2.SQL.Clear;
          TempQuery2.SQL.Add('CREATE TRIGGER note_update BEFORE UPDATE ON notes');
          TempQuery2.SQL.Add('BEGIN');
          TempQuery2.SQL.Add('    UPDATE notes SET mcount = mcount + 1, mtime = (DATETIME(''now'')) WHERE id = new.id AND (title != new.title OR content != new.content);');
          TempQuery2.SQL.Add('END;');
          TempQuery2.ExecSQL;
          SQLTransaction.Commit;

          TempQuery2.Close;
          doOnSQLResultUpdateNote(aNoteObject);
        end;
      end;
    finally
      FreeAndNil(TempQuery);
      result:=True;
    end;
  except
    on E: Exception do begin
      msgStr:=e.ClassName;
      writeln('TPLNoteManager6B_sqlite.GetNoteContent :', e.ClassName);
      doOnSQLResultError(EVT_ERROR,msgStr,'TPLNoteManager6B_sqlite.GetNoteContent');
    end;
  end;

end; // TPLNMV6C_sqlite.GetNoteContent

function TPLNMV6C_sqlite.GetTagListFromTagID(const aUUID: String): TJSONArray;
var
  TempQuery:TSQLQuery;
  FildName, msgStr:String;
  Fild:TField;
  x:Integer;
begin
  result:=nil;
  msgStr:='';
  try
    try
      TempQuery:=TSQLQuery.Create(nil);
      TempQuery.DataBase:=SQlConnector;
      TempQuery.SQL.Text:='SELECT * FROM note_tags WHERE note_id =:note_id';
      TempQuery.ParamByName('note_id').AsString:=aUUID;
      TempQuery.Open;

      if TempQuery.RecordCount > 0 then begin
        TempQuery.First;
        Result:=TJSONArray.Create();
        while not TempQuery.Eof do begin
          Fild:=TempQuery.FindField('tag_id');
          if Assigned(Fild) then begin
            Result.Add(Fild.AsInteger);
          end;
          TempQuery.Next;
        end;
        writeln('GetTagListFromTagID', Result.FormatJSON());
      end;
    finally
      FreeAndNil(TempQuery);
    end;
  except
    on E: Exception do begin
      msgStr:=e.ClassName;
      writeln('TPLNoteManager6B_sqlite.GetTagListFromTagID :', e.ClassName);
      doOnSQLResultError(EVT_ERROR,msgStr,'TPLNoteManager6B_sqlite.GetTagListFromTagID');
      //DoErrorEvent(EVT_ERROR,E.Message,'TPLNoteManager6B_sqlite.GetTagListFromTagID');
    end;
  end;
end; // TPLNMV6C_sqlite.GetTagListFromTagID

function TPLNMV6C_sqlite.AddTag(var aTagObject: TJSONObject;
  const aTagMetaData: Boolean; const aExtModus: Boolean): Boolean;
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
        jData.AsString:=DateTimeToStr(Temp_ctime.AsDateTime, myFormatSettings)
      else
        _aTagObject.Add('ctime', DateTimeToStr(Temp_ctime.AsDateTime, myFormatSettings));

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

      // Zuerst prüfen, ob es den Title tags in der Datenbank gibt.
      TempQuery.SQL.Add('SELECT name FROM tags WHERE name=:name;');
      Temp_name:=TempQuery.ParamByName('name');

      jData:=aTagObject.Find('Tags');
      if Assigned(jData) then begin
        TagArray:=jData as TJSONArray;

        for i:=TagArray.Count -1 downto 0 do begin
          TagObject:=TagArray[i] as TJSONObject;

          Temp_name.AsString:=TagObject.Elements['name'].AsString;
          TempQuery.Open;
          if TempQuery.RecordCount > 0 then begin
            writeln('Gibt es schon: "', Temp_name.AsString);
            TagArray.Delete(i);
          end;
          TempQuery.Close;
        end;
      end;
      TempQuery.SQL.Clear;

      if not aExtModus then
        TempQuery.SQL.Add('INSERT INTO tags (')
      else
        TempQuery.SQL.Add('INSERT OR IGNORE INTO tags (');

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

        jData:=aTagObject.Find('Tags');
        if Assigned(jData) then begin
          TagArray:=jData as TJSONArray;
          if TagArray.Count > 0 then begin
            for i:=0 to TagArray.Count -1 do begin
              TagObject:=TagArray[i] as TJSONObject;
              _AddTag(TagObject);
            end;
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

function TPLNMV6C_sqlite.AddNote_Tags(const aNoteID: String; const aJArray: TJSONArray): Integer;
var
  TempQuery:TSQLQuery;
  x:Integer;
  TagID:String;

  TempNote_id:TParam;
  TempTag_id:TParam;
begin
  result:=0;
  try
    try
      TempQuery:=TSQLQuery.Create(nil);
      TempQuery.DataBase:=SQlConnector;

      TempQuery.SQL.Add('INSERT OR IGNORE INTO note_tags (');
        TempQuery.SQL.Add('note_id, ');
        TempQuery.SQL.Add('tag_id');
      TempQuery.SQL.Add(') VALUES (');
        TempQuery.SQL.Add(':note_id, ');
        TempQuery.SQL.Add(':tag_id');
      TempQuery.SQL.Add(');');

      TempNote_id:=TempQuery.ParamByName('note_id'); // 0
      TempTag_id:=TempQuery.ParamByName('tag_id'); // 1

      for x:=0 to aJArray.Count -1 do begin
        TagID:=aJArray[x].AsString;

        TempTag_id.AsString:=TagID;
        TempNote_id.AsString:=aNoteID;
        TempQuery.ExecSQL;
      end; // for x
    finally
      FreeAndNil(TempQuery);
    end;

  except
    on E: Exception do begin
      writeln(#13, 'AddNote_Tags.AddNote_Tags:',E.Message);
      doOnSQLResultError(EVT_ERROR,E.Message,'TPLNMV6C_sqlite.AddNote_Tags');

      //DoErrorEvent(EVT_ERROR,E.Message,'AddNote_Tags.AddNote_Tags');
    end;
  end;
end; // TPLNMV6C_sqlite.AddNote_Tags

function TPLNMV6C_sqlite.NoteLinketToTag(const aNoteID: string; const aTagID: Integer; const aTagAction: TPLNMV6C_TagAction): Boolean;
var
  TempQuery:TSQLQuery;
  msgStr:string;
begin
  result:=false;
  try
    TempQuery:=TSQLQuery.Create(nil);
    TempQuery.DataBase:=SQlConnector;
    try
      case aTagAction of
        TA_ADD: begin
          TempQuery.SQL.Add('INSERT OR IGNORE INTO note_tags (');
            TempQuery.SQL.Add('note_id,');
            TempQuery.SQL.Add('tag_id');
          TempQuery.SQL.Add(') VALUES (');
            TempQuery.SQL.Add(':note_id,');
            TempQuery.SQL.Add(':tag_id');
          TempQuery.SQL.Add(');');

          TempQuery.ParamByName('note_id').AsString:=aNoteID;
          TempQuery.ParamByName('tag_id').AsInteger:=aTagID;
        end; // TA_ADD

        TA_REMOVE: begin
          TempQuery.SQL.Add('DELETE FROM note_tags WHERE note_id = ' + IntToStr(aTagID) + ';');
        end; // TA_REMOVE
      end; // case

      TempQuery.ExecSQL;

      if AutoCommit then SQLTransaction.Commit;
      result:=True;
    finally
      TempQuery.Close;
      FreeAndNil(TempQuery);
    end;
  except
    on E: Exception do begin
      msgStr:=E.Message;
      writeln(#13, 'TPLNMV6C_sqlite.NoteLinketToTag: ',msgStr);
      doOnSQLResultError(EVT_ERROR,msgStr,'TPLNMV6C_sqlite.NoteLinketToTag');
      raise;
    end;
  end;
end; // TPLNMV6C_sqlite.NoteLinketToTag

function TPLNMV6C_sqlite.UpdateTag(const aTagObject: TJSONObject): Boolean;
var
  TempQuery:TSQLQuery;
  msgStr:String;

  TagName:String;
  TagId:Integer;

begin
  msgStr:=''; result:=False;
  try
    try
      TagName:=aTagObject.Elements['name'].AsString;
      TagId:=aTagObject.Elements['id'].AsInteger;

      TempQuery:=TSQLQuery.Create(nil);
      TempQuery.DataBase:=SQlConnector;

      TempQuery.SQL.Add('UPDATE tags SET ');
      TempQuery.SQL.Add('name=:name');
      TempQuery.SQL.Add(' WHERE id=:id');
      TempQuery.SQL.Add(';');

      TempQuery.ParamByName('name').AsString:=TagName;
      TempQuery.ParamByName('id').AsInteger:=TagID;

      TempQuery.ExecSQL;
      if AutoCommit then SQLTransaction.Commit;
      doOnSQLResultUpdateTag(aTagObject);
      result:=True;
    finally
      FreeAndNil(TempQuery);
    end;
  except
    on E: Exception do begin
      msgStr:=E.Message;
      writeln(#13, 'TPLNMV6C_sqlite.UpdateTag:',msgStr);
      doOnSQLResultError(EVT_ERROR,msgStr,'TPLNMV6C_sqlite.UpdateTag');
      raise;
    end;
  end;

end; // TPLNMV6C_sqlite.UpdateTag

function TPLNMV6C_sqlite.DeleteTag(const aTagIdList: TJSONArray): Boolean;
var
  TempQuery:TSQLQuery;
  msgStr:String;
  tagIdP:TParam;
  i:Integer;
begin
  result:=False;
  msgStr:='';
  try
    try
      TempQuery:=TSQLQuery.Create(nil);
      TempQuery.DataBase:=SQlConnector;

      TempQuery.SQL.Add('DELETE FROM tags WHERE id=:id');
      tagIdP:=TempQuery.ParamByName('id');
      for i:=0 to aTagIdList.Count - 1 do begin
        tagIdP.AsString:=aTagIdList[i].AsString;
        TempQuery.ExecSQL;
      end; // for i

      if AutoCommit then SQLTransaction.Commit;
      writeln(aTagIdList.FormatJSON());
      doOnSQLResultDeleteTag(aTagIdList);
      result:=True;
    finally
      FreeAndNil(TempQuery);
    end;
  except
    on E: Exception do begin
      msgStr:=E.Message;
      writeln(#13, 'TPLNMV6C_sqlite.DeleteTag:',msgStr);
      doOnSQLResultError(EVT_ERROR,msgStr,'TPLNMV6C_sqlite.DeleteTag');
      raise;
    end;
  end;
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
      Tags:=TJSONArray.Create();
      if TempQuery.RecordCount > 0 then begin
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
      writeln(Tags.Count);
      if Tags.Count > 0 then begin
        EventObject:=TJSONObject.Create();
        EventObject.Add('Tags',Tags);
        doOnSQLResultGetTags(EventObject);
      end;
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

function TPLNMV6C_sqlite.ChangeAllTagUserIndex(const aTagArray: TJSONArray): boolean;
var
  TempQuery:TSQLQuery;
  msgStr:string;
  PUserIndex, Pid:TParam;
  i:Integer;
  TagObject:TJSONObject;
begin
  result:=False;
  try
    TempQuery:=TSQLQuery.Create(nil);
    TempQuery.DataBase:=SQlConnector;
    try
      TempQuery.SQL.Add('UPDATE tags SET userindex=:userindex WHERE id=:id;');

      PUserIndex:=TempQuery.ParamByName('userindex');
      Pid:=TempQuery.ParamByName('id');

      for i:=0 to aTagArray.Count -1 do begin
        TagObject:=aTagArray[i] as TJSONObject;

        PUserIndex.AsInteger:=TagObject.Elements['userindex'].AsInteger;
        Pid.AsInteger:=TagObject.Elements['id'].AsInteger;

        TempQuery.ExecSQL;
      end;
      if AutoCommit then SQLTransaction.Commit;

      result:=true;
    finally
      FreeAndNil(TempQuery);
    end;

  except
    on E: Exception do begin
      msgStr:=E.Message;
      writeln(#13, 'TPLNMV6C_sqlite.ChangeAllTagUserIndex :',msgStr);
      doOnSQLResultError(EVT_ERROR,msgStr,'TPLNMV6C_sqlite.ChangeAllTagUserIndex');
    end;
  end;

end; // TPLNMV6C_sqlite.ChangeAllTagUserIndex

function TPLNMV6C_sqlite.AddCity(var aCityObject: TJSONObject): Boolean;
var
  TempQuery:TSQLQuery;
  Temp_name, Temp_ctime, Temp_content:TParam;
  msgStr:string;


  function _AddCity(var _aCityObject: TJSONObject):Boolean;
  var
    NameStr, ContentStr:String;
    TempCTime:TDateTime;
    jData:TJSONData;
  begin
    try
      ContentStr:=''; NameStr:=''; TempCTime:=0;
      result:=False;
      jData:=_aCityObject.Find('name');
      if Assigned(jData) then begin
        NameStr:=jData.AsString;

        jData:=_aCityObject.Find('content');
        if Assigned(jData) then
          ContentStr:=jData.AsString;

        jData:=_aCityObject.Find('ctime');
        if Assigned(jData) then begin
          if jData.AsString <> '' then
            TempCTime:=StrToDateTime(jData.AsString, myFormatSettings)
          else begin
            TempCTime:=now;
            jData.AsString:=DateTimeToStr(TempCTime, myFormatSettings);
          end;
        end;

        Temp_name.AsString:=NameStr;
        Temp_ctime.AsDateTime:=TempCTime;
        Temp_content.AsString:=ContentStr;

        TempQuery.ExecSQL;

        jData:=_aCityObject.Find('id');
        if not Assigned(jData) then
          _aCityObject.Add('id', SQlConnector.GetInsertID);
        result:=True;
      end // _AddCity
      else begin
        msgStr:='Name nicht vorhanden';
        writeln(#13, 'TPLNMV6C_sqlite._AddCity :',msgStr);
        doOnSQLResultError(EVT_ERROR,msgStr,'TPLNMV6C_sqlite._AddCity');
      end;
    except
      on E: Exception do begin
        msgStr:=E.Message;
        writeln(#13, 'TPLNMV6C_sqlite._AddCity :',msgStr);
        doOnSQLResultError(EVT_ERROR,msgStr,'TPLNMV6C_sqlite._AddCity');
      end;
    end;
  end;

var
  jData:TJSONData;
  cityObject:TJSONObject;
  citys:TJSONArray;
  i:Integer;
begin
  msgStr:='';

  result:=False;
  try
    TempQuery:=TSQLQuery.Create(nil);
    TempQuery.DataBase:=SQlConnector;
    try
      TempQuery.SQL.Add('INSERT INTO citylist (');
        TempQuery.SQL.Add('name,');
        TempQuery.SQL.Add('ctime,');
        TempQuery.SQL.Add('content');
      TempQuery.SQL.Add(') ');
      TempQuery.SQL.Add('VALUES (');
        TempQuery.SQL.Add(':name,');
        TempQuery.SQL.Add(':ctime,');
        TempQuery.SQL.Add(':content');
      TempQuery.SQL.Add(');');

      Temp_name:=TempQuery.ParamByName('name'); // 0
      Temp_ctime:=TempQuery.ParamByName('ctime'); // 1
      Temp_content:=TempQuery.ParamByName('content'); // 2
      jData:=aCityObject.Find('citys');
      if Assigned(jData) then begin
        citys:=jData as TJSONArray;
        for i:=0 to citys.Count - 1 do begin
          cityObject:=citys[i] as TJSONObject;
          result:=_AddCity(cityObject);
        end; // for i
      end
      else
        result:=_AddCity(aCityObject);

      if AutoCommit then SQLTransaction.Commit;
      doOnSQLResultAddCity(aCityObject);
    finally
      FreeAndNil(TempQuery);
    end;
  except
    on E: Exception do begin
      msgStr:=E.Message;
      writeln(#13, 'TPLNMV6C_sqlite.AddCity :',msgStr);
      doOnSQLResultError(EVT_ERROR,msgStr,'TPLNMV6C_sqlite.AddCity');
    end;
  end;

end; // TPLNMV6C_sqlite.AddCity

function TPLNMV6C_sqlite.UpdateCity(const aCityObject: TJSONObject): Boolean;
var
  nameStr, contentStr, sqlName, jName:String;
  msgStr:String;
  CityID:Integer;

  TempQuery:TSQLQuery;
  i:Integer;

  jData:TJSONData;
  cTime:TDateTime;
begin
  result:=False;
  try
    try
      TempQuery:=TSQLQuery.Create(nil);
      TempQuery.DataBase:=SQlConnector;

      CityID:=0; nameStr:=''; contentStr:=''; sqlName:=''; cTime:=0;
      for i:=0 to aCityObject.Count -1 do begin
        jName:=aCityObject.Names[i];
        if jName = 'id' then CityID:=aCityObject.Items[i].AsInteger;

        if jName = 'name' then begin
          nameStr:=aCityObject.Items[i].AsString;
          sqlName:=AddStr('name=:name',sqlName);
        end; // title

        if jName = 'content' then begin
          contentStr:=aCityObject.Items[i].AsString;
          sqlName:=AddStr('content=:content',sqlName);
        end; // content

        if jname = 'ctime' then begin
          jData:=aCityObject.Find('ctimeChange');
          if Assigned(jData) then begin
            cTime:=StrToDate(aCityObject.Items[i].AsString, myFormatSettings);
            sqlName:=AddStr('ctime=:ctime',sqlName);
          end;
        end;
      end; // for i

      if Assigned(aCityObject.Find('ctimeChange')) then
        aCityObject.Delete('ctimeChange');

      TempQuery.SQL.Add('UPDATE citylist SET ');
      TempQuery.SQL.Add(SQLName);
      TempQuery.SQL.Add(' WHERE id=:id;');
      TempQuery.ParamByName('id').AsInteger:=CityID;

      if nameStr <> '' then TempQuery.ParamByName('title').AsString:=nameStr;
      if contentStr <> '' then TempQuery.ParamByName('content').AsString:=contentStr;
      if ctime > 0 then TempQuery.ParamByName('ctime').AsDate:=cTime;

      TempQuery.ExecSQL;
      if AutoCommit then SQLTransaction.Commit;

      doOnSqlResultUpdateCity(aCityObject);
      Result:=True;
    finally
      TempQuery.Close;
      FreeAndNil(TempQuery);
    end;
  except
    on E: Exception do begin
      msgStr:=E.Message;
      writeln(#13, 'TPLNMV6C_sqlite.UpdateCity :',msgStr);
      doOnSQLResultError(EVT_ERROR,msgStr,'TPLNMV6C_sqlite.UpdateCity');
    end;
  end;
end; // TPLNMV6C_sqlite.UpdateCity

function TPLNMV6C_sqlite.UpdateCitys(var aCityObjects: TJSONArray): Boolean;
var
  TempQuery:TSQLQuery;
  jName:String;
  cTime:TDateTime;
  msgStr:String;
  CityID:Integer;

  CityObject:TJSONObject;
  jData:TJSONData;
  i, y:Integer;
begin
  result:=False;
  try
    TempQuery:=TSQLQuery.Create(nil);
    TempQuery.DataBase:=SQlConnector;

    TempQuery.SQL.Add('UPDATE citylist SET ');
    TempQuery.SQL.Add('name=:name, content=:content, ctime=:ctime');
    TempQuery.SQL.Add(' WHERE id=:id;');

    for y:=0 to aCityObjects.Count - 1 do begin
      CityObject:=aCityObjects.Items[y] as TJSONObject;

      CityID:=0; cTime:=0;
      for i:=0 to CityObject.Count -1 do begin
        jName:=CityObject.Names[i];
        if jName = 'id' then begin
          CityID:=CityObject.Items[i].AsInteger;
          TempQuery.ParamByName('id').AsInteger:=CityID;
        end;

        if jName = 'name' then begin
          TempQuery.ParamByName('name').AsString:=CityObject.Items[i].AsString;
        end; // title

        if jName = 'content' then begin
          TempQuery.ParamByName('content').AsString:=CityObject.Items[i].AsString;
        end; // content

        if jname = 'ctime' then begin
          jData:=CityObject.Find('ctimeChange');
          if Assigned(jData) then begin
            cTime:=StrToDate(CityObject.Items[i].AsString, myFormatSettings);
            TempQuery.ParamByName('ctime').AsDate:=cTime;
          end;
        end;
      end; // for i
      TempQuery.ExecSQL;

      if Assigned(CityObject.Find('ctimeChange')) then
        CityObject.Delete('ctimeChange');
    end; // for y

    if AutoCommit then SQLTransaction.Commit;
    result:=True;
    doOnSqlResultUpdateCitys(aCityObjects);
  except
    on E: Exception do begin
      msgStr:=E.Message;
      writeln(#13, 'TPLNMV6C_sqlite.UpdateCitys :',msgStr);
      doOnSQLResultError(EVT_ERROR,msgStr,'TPLNMV6C_sqlite.UpdateCitys');
    end;
  end;
end; // TPLNMV6C_sqlite.UpdateCitys

function TPLNMV6C_sqlite.GetCitys: Boolean;
var
  msgStr:String;
  TempQuery:TSQLQuery;

  Fild:TField;
  FildName:String;

  CityArray:TJSONArray;
  CityObject:TJSONObject;
  x:Integer;
begin
  result:=False;
  try
    try
      TempQuery:=TSQLQuery.Create(nil);
      TempQuery.DataBase:=SQlConnector;
      TempQuery.SQL.Text:='SELECT * FROM citylist;';
      TempQuery.Open;

      if TempQuery.RecordCount > 0 then begin
        CityArray:=TJSONArray.Create();

        TempQuery.First;
        while not TempQuery.Eof do begin
          CityObject:=TJSONObject.Create();
          for x:=0 to TempQuery.Fields.Count -1 do begin
            Fild:=TempQuery.Fields[x];
            FildName:=Fild.FieldName;
            case FildName of
              'id': CityObject.Add('id', Fild.AsInteger);
              'name': CityObject.Add('name', Fild.AsString);
              'ctime': CityObject.Add('ctime', DateTimeToStr(Fild.AsDateTime, myFormatSettings));
              'content': CityObject.Add('content', Fild.AsString);
            end;
          end; // for x
          CityArray.Add(CityObject);
          TempQuery.Next;
        end;
        TempQuery.Close;
        Result:=True;
        doOnSqlResultGetCitys(CityArray);
      end;
    finally
      FreeAndNil(TempQuery);
    end;
  except
    on E: Exception do begin
      msgStr:=E.Message;
      writeln(#13, 'TPLNMV6C_sqlite.GetCitys :',msgStr);
      doOnSQLResultError(EVT_ERROR,msgStr,'TPLNMV6C_sqlite.GetCitys');
    end;
  end;
end; // TPLNMV6C_sqlite.GetCitys

function TPLNMV6C_sqlite.GetCitysById(const jIDList: TJSONArray; var aNamedList: TJSONArray): Boolean;
var
  msgStr:String;
  TempQuery:TSQLQuery;
  i:Integer;
  valueStr:String;
begin
  result:=False;
  valueStr:='';
  try
    try
      for i:=0 to jIDList.Count -1 do begin
        valueStr+=IntToStr(jIDList[i].AsInteger);
        if i < jIDList.Count -1 then
          valueStr+=',';
      end;
      TempQuery:=TSQLQuery.Create(nil);
      TempQuery.DataBase:=SQlConnector;
      TempQuery.SQL.Add(format('SELECT name FROM citylist WHERE id in ( %s );',[valueStr]));
      TempQuery.Open;

      if TempQuery.RecordCount > 0 then begin
        TempQuery.First;
        while not TempQuery.Eof do begin
          aNamedList.Add( TempQuery.FieldByName('name').AsString );
//          writeln(TempQuery.FieldByName('name').AsString );
          TempQuery.Next;
        end;
      end;

      result:=True;
    finally
      FreeAndNil(TempQuery);
    end;
  except
    on E: Exception do begin
      msgStr:=E.Message;
      writeln(#13, 'TPLNMV6C_sqlite.GetCitysById :',msgStr);
      doOnSQLResultError(EVT_ERROR,msgStr,'TPLNMV6C_sqlite.GetCitysById');
    end;
  end;
end; // TPLNMV6C_sqlite.GetCitysById

function TPLNMV6C_sqlite.DeleteCitys(const aDeleteCityList: TJSONArray): Boolean;
var
  msgStr:String;
  TempQuery:TSQLQuery;
  citydP:TParam;
  i:Integer;
begin
  result:=False;
  try
    try
      TempQuery:=TSQLQuery.Create(nil);
      TempQuery.DataBase:=SQlConnector;

      TempQuery.SQL.Add('DELETE FROM citylist WHERE id=:id');
      citydP:=TempQuery.ParamByName('id');
      for i:=0 to aDeleteCityList.Count - 1 do begin
        citydP.AsString:=aDeleteCityList[i].AsString;
        TempQuery.ExecSQL;
      end; // for i

      if AutoCommit then SQLTransaction.Commit;
      doOnSQLResultDeleteCitys(aDeleteCityList);
      result:=True;

    finally
      FreeAndNil(TempQuery);
    end;
  except
    on E: Exception do begin
      msgStr:=E.Message;
      writeln(#13, 'TPLNMV6C_sqlite.DeleteCitys :',msgStr);
      doOnSQLResultError(EVT_ERROR,msgStr,'TPLNMV6C_sqlite.DeleteCitys');
    end;
  end;
end; // TPLNMV6C_sqlite.DeleteCitys

function TPLNMV6C_sqlite.JObjectToSQLtable(const JConfigObject: TJSONObject; const aSQlTableName: String): boolean;
var
  msgStr:String;
  TempQuery:TSQLQuery;

  Temp_key, Temp_value:TParam;
  i:Integer;

  jName:String;
  jData:TJSONData;
begin
  result:=False;
  try
    try
      TempQuery:=TSQLQuery.Create(nil);
      TempQuery.DataBase:=SQlConnector;

      TempQuery.SQL.Add('INSERT OR REPLACE INTO config ( ');
        TempQuery.SQL.Add('key, ');
        TempQuery.SQL.Add('value');
      TempQuery.SQL.Add(')');
      TempQuery.SQL.Add('VALUES (');
        TempQuery.SQL.Add(':key, ');
        TempQuery.SQL.Add(':value');
      TempQuery.SQL.Add(');');

      Temp_key:=TempQuery.ParamByName('key');
      Temp_value:=TempQuery.ParamByName('value');

      for i:=0 to JConfigObject.Count - 1 do begin
        jName:=LowerCase(JConfigObject.Names[i]);
        jData:=JConfigObject.Items[i];
        Temp_key.AsString:=jName;
        case jName of
          'last_open_notes': begin
             Temp_value.AsString:=jData.FormatJSON();
             TempQuery.ExecSQL;
           end;

           'select_tags': begin
             Temp_value.AsString:=jData.FormatJSON();
             TempQuery.ExecSQL;
           end;

           'last_focus_note': begin
             Temp_value.AsString:=jData.AsString;
             TempQuery.ExecSQL;
           end;
        end; // case
      end; // for i
      result:=True;
      if AutoCommit then SQLTransaction.Commit;
    finally
      FreeAndNil(TempQuery);
    end;

  except
    on E: Exception do begin
      msgStr:=E.Message;
      writeln(#13, 'TPLNMV6C_sqlite.JObjectToSQLtable :',msgStr);
      doOnSQLResultError(EVT_ERROR,msgStr,'TPLNMV6C_sqlite.JObjectToSQLtable');
    end;
  end;

end; // TPLNMV6C_sqlite.JObjectToSQLtable

function TPLNMV6C_sqlite.SQLtableToJObject(const aSQLTableName: String): Boolean;
var
  msgStr:String;
  TempQuery:TSQLQuery;

  Fild:TField;
  FildName:String;
  jObject:TJSONObject;
begin
  result:=False;
  try
    try
      TempQuery:=TSQLQuery.Create(nil);
      TempQuery.DataBase:=SQlConnector;

      TempQuery.SQL.Add('SELECT * FROM ' + aSQLTableName + ';');
      TempQuery.Open;
      jObject:=TJSONObject.Create();

      if TempQuery.RecordCount > 0 then begin
        TempQuery.First;
        while not TempQuery.Eof do begin
          case TempQuery.Fields[0].AsString of
            'last_open_notes':
             jObject.Add(TempQuery.Fields[0].AsString, GetJSON(TempQuery.Fields[1].AsString));

            'last_focus_note':
              jObject.Add(TempQuery.Fields[0].AsString, TempQuery.Fields[1].AsString);

            'select_tags':
              jObject.Add(TempQuery.Fields[0].AsString, GetJSON(TempQuery.Fields[1].AsString));

          end;
          TempQuery.Next;
        end;
      end;
    finally
      TempQuery.Close;
      FreeAndNil(TempQuery);
      result:=True;
      doOnSqlResultGetConfig(jObject);
    end;
  except
    on E: Exception do begin
      msgStr:=E.Message;
      writeln(#13, 'TPLNMV6C_sqlite.SQLtableToJObject :',msgStr);
      doOnSQLResultError(EVT_ERROR,msgStr,'TPLNMV6C_sqlite.SQLtableToJObject');
    end;
  end;
end; // TPLNMV6C_sqlite.SQLtableToJObject

function TPLNMV6C_sqlite.ImportFromOldDataBase(const aFileName: String): Boolean;
  procedure ConvertOldTagIdToNewTagID(const aTagJArray:TJSONArray; var aOldTagArray:TJSONArray);
  var
    i, x:Integer;
    TagObject:TJSONObject;
    NewTagID, OldTagID:Integer;
    TagJArray:TJSONArray;
    jData:TJSONData;
  begin
    for x:=0 to aOldTagArray.Count - 1 do begin
      for i:=0 to aTagJArray.Count -1 do begin
        TagObject:=aTagJArray[i] as TJSONObject;
        jData:=TagObject.Find('id');
        if Assigned(jData) then
          NewTagID:=jData.AsInteger
        else
          break;
        OldTagID:=TagObject['oldID'].AsInteger;

        if aOldTagArray[x].AsInteger = OldTagID then begin
          aOldTagArray[x].AsInteger:=NewTagID;
          break;
        end;
      end; // for i
    end; // for x
  end; // ConvertOldTagIdToNewTagID

var
  TempConn:TSQLConnection;
  TempTrans:TSQLTransaction;
  TempQuery, TempQuery2:TSQLQuery;
  FildName, TempDateTimeStr:String;
  TempUuid: uuid_t;

  Fild:TField;
  NoteID:String;
  TagList:TJSONArray;
  Data:TJSONData;
  x:Integer;

  JObj:TJSONObject;
  NoteJArray, TagJArray:TJSONArray;
  EventObject:TJSONObject;
  TagObject, NoteObject:TJSONObject;
  msgStr:String;

begin
  result:=False;
  if FileExists(aFileName) then begin
    try
      try
        TempConn:=TSQLite3Connection.Create(nil);
        TempConn.HostName:='localhost';
        TempConn.OnLog:=@SQLONErrorLog;

        TempTrans:=TSQLTransaction.Create(nil);
        TempConn.Transaction:=TempTrans;

        TempConn.DatabaseName:=aFileName;
        TempConn.Connected:=True;
        TempTrans.Active:=True;

        TempQuery:=TSQLQuery.Create(nil);
        TempQuery.DataBase:=TempConn;

        // Triger in der neuen Datenbank löschen, wenn vorhanden
        TempQuery2:=TSQLQuery.Create(nil);
        TempQuery2.DataBase:=SQlConnector;
        TempQuery2.SQL.Add('DROP TRIGGER if exists note_update;');
        TempQuery2.ExecSQL;
        SQLTransaction.Commit;

        // Die alten Tags, in der neuen Datenbank hinzufügen
        TempQuery.Close;
        TempQuery.SQL.Text:='select id, Title, CreateDateTime, LastReadDateTime, LastWriteDateTime from TagTable order BY Title;';
        TempQuery.Open;
        if TempQuery.RecordCount > 0 then begin
          TempQuery.First;
          TagJArray:=TJSONArray.Create();
          while not TempQuery.Eof do begin
            JObj:=TJSONObject.Create();

            for x:=0 to TempQuery.Fields.Count -1 do begin
              Fild:=TempQuery.Fields[x];
              FildName:=Fild.FieldName;
              if FildName = 'id' then  JObj.Add('oldID', Fild.AsInteger);

              if FildName = 'Title' then  JObj.Add('name', Fild.AsAnsiString);

              if not Fild.IsNull then begin
                if FildName = 'CreateDateTime' then begin
                  TempDateTimeStr:=DateTimeToStr(StrToDateTime(Fild.AsString, DefaultFormatSettings), myFormatSettings);
                  writeln(TempDateTimeStr);
                  JObj.Add('ctime', TempDateTimeStr);
                end;
                if FildName = 'LastWriteDateTime' then begin
                  TempDateTimeStr:=DateTimeToStr(StrToDateTime(Fild.AsString, DefaultFormatSettings), myFormatSettings);
                  JObj.Add('mtime', TempDateTimeStr);
                end;

                if FildName = 'LastReadDateTime' then begin
                  TempDateTimeStr:=DateTimeToStr(StrToDateTime(Fild.AsString, DefaultFormatSettings), myFormatSettings);
                  JObj.Add('atime', TempDateTimeStr);
                end;
              end;
            end; // for x
            TagJArray.Add(JObj);
            TempQuery.Next;
          end; // while
        end;
        TempQuery.Close;
        TagObject:=TJSONObject.Create();
        TagObject.Add('Tags', TagJArray);
        AddTag(TagObject, True, true);

        // Notizen von der alten Datenbank in eine JSON Array hinzufügen
        TempQuery.SQL.Text:='select Title, NoteText, CreateDateTime, LastWriteDateTime, LastReadDateTime, ReadCount, WriteCount, NoteID, TagList from NoteTable order BY Title';
        TempQuery.Open;

        if TempQuery.RecordCount > 0 then begin
          TempQuery.First;
          NoteJArray:=TJSONArray.Create();
          while not TempQuery.Eof do begin
            JObj:=TJSONObject.Create();
            for x:=0 to TempQuery.Fields.Count -1 do begin
              Fild:=TempQuery.Fields[x];
              FildName:=Fild.FieldName;
              if FildName = 'Title' then  JObj.Add('title', Fild.AsAnsiString);
              if FildName = 'NoteText' then  JObj.Add('content', Fild.AsAnsiString);
              if not Fild.IsNull then begin
                if FildName = 'CreateDateTime' then begin
                  TempDateTimeStr:=DateTimeToStr(StrToDateTime(Fild.AsString, DefaultFormatSettings), myFormatSettings);
                  JObj.Add('ctime', TempDateTimeStr);
                end;
                if FildName = 'LastWriteDateTime' then begin
                  TempDateTimeStr:=DateTimeToStr(StrToDateTime(Fild.AsString, DefaultFormatSettings), myFormatSettings);
                  JObj.Add('mtime', TempDateTimeStr);
                end;

                if FildName = 'LastReadDateTime' then begin
                  TempDateTimeStr:=DateTimeToStr(StrToDateTime(Fild.AsString, DefaultFormatSettings), myFormatSettings);
                  JObj.Add('atime', TempDateTimeStr);
                end;
              end;

              if FildName = 'ReadCount' then JObj.Add('mcount', Fild.AsInteger);
              if FildName = 'WriteCount' then JObj.Add('acount', Fild.AsInteger);
              if FildName = 'NoteID' then JObj.Add('uuid', Fild.AsAnsiString);

              if FildName = 'TagList' then begin
                JObj.Add('TagList', '[' + Fild.AsAnsiString + ']');
                Data:=GetJSON(JObj.Elements['TagList'].AsString);
                if Assigned(Data) then begin
                  TagList:=Data as TJSONArray;
                  ConvertOldTagIdToNewTagID(TagJArray, TagList);
                end;
              end;
            end; // for x
           // JObj.Add('id',-1);
            NoteJArray.Add(JObj);
            NoteID:=JObj.Elements['uuid'].AsString;
            AddNote_Tags(NoteID,TagList);
            TempQuery.Next;
          end; // while
          NoteObject:=TJSONObject.Create();
          NoteObject.Add('Notes', NoteJArray);
          AddNote(NoteObject, true);
//          NoteAddCount:=AddNotes(NoteJArray);
//          writeln(Format('Es wurden "%d" Notizen  hinzugefügt.',[NoteAddCount]));
        end;

        // Triger wieder hinzufügen
        TempQuery2.SQL.Clear;
        TempQuery2.SQL.Add('CREATE TRIGGER note_update BEFORE UPDATE ON notes');
        TempQuery2.SQL.Add('BEGIN');
        TempQuery2.SQL.Add('    UPDATE notes SET mcount = mcount + 1, mtime = (DATETIME(''now'')) WHERE id = new.id AND (title != new.title OR content != new.content);');
        TempQuery2.SQL.Add('END;');
        TempQuery2.ExecSQL;
        SQLTransaction.Commit;

      finally
        FreeAndNil(NoteJArray);
        FreeAndNil(TempQuery); FreeAndNil(TempTrans); FreeAndNil(TempConn); FreeAndNil(TempQuery2);
      end;
    except
      on E: Exception do begin
        msgStr:=E.Message;
        writeln(#13, 'TPLNMV6C_sqlite.ImportFromOldDataBase :',msgStr);
        doOnSQLResultError(EVT_ERROR,msgStr,'TPLNMV6C_sqlite.GetTags');
      end;
    end;
  end;
end; // TPLNMV6C_sqlite.ImportFromOldDataBase

end.

