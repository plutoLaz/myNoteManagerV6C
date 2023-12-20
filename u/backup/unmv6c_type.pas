{
  Autor: Michael Springwald

  Datum: Dienstag, 26.09.2023
}

unit unmv6c_type;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, fpjson;

type
  TPLOnErrorEventType = (
                         EVT_ERROR   = 0,
                         EVT_WARNING = 1,
                         EVT_INFO    = 2
                       ); // TPLOnErrorEvent

  TPLNMV6C_TagAction = (
                         TA_REMOVE = 0,
                         TA_ADD    = 1
                       ); // TPLNMV6C_TagAction

  TOnSQLResultAddNote = procedure(aNoteObject:TJSONObject) of object;
  TOnSQLResultUpdateNote = procedure(aNoteObject:TJSONObject) of object;
  TOnSQLResultDeleteNote = procedure(aNoteIDList: TJSONArray) of object;
  TOnSQLResultGetNotes = procedure(aNoteObject:TJSONObject) of object;
  TOnSQLResultGetContent = procedure(aNoteObject:TJSONObject) of object;
  TOnSQLResultGetTagListFromTagID = procedure(aNoteObject:TJSONObject) of object;
  TOnSqlResultGetConfig = procedure(aConfigObject:TJSONObject) of object;

  TOnSQLResultAddTag = procedure(aTagObject:TJSONObject) of object;
  TOnSQLResultUpdateTag = procedure(aTagObject:TJSONObject) of object;
  TOnSQLResultDeleteTag = procedure(aTagIdList:TJSONArray) of object;
  TOnSQLResultGetTags = procedure(aTagObject:TJSONObject) of object;

  TOnSQLResultAddCity = procedure(aCityObject:TJSONObject) of object;
  TOnSQLResultGetCitys = procedure (aCityObject:TJSONObject) of object;

  TOnSQLResultError = procedure(const aErrorEventType:TPLOnErrorEventType; aErrorMSG:String; aSender:String) of Object;


implementation

end.

