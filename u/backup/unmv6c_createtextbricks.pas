{
  Autor: Michael Springwald

  Datum: Donnerstag, 29.09.2023
}

unit unmv6c_createtextbricks;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, fpjson, jsonparser, FileUtil;

type
  { TNMV6C_CreateTextBricks }
  TNMV6C_CreateTextBricks = class
  private
    fTemplateDir: String;
  protected

  public
    RaumschiffEnterprise:TJSONObject;
    StarTrekNext:TJSONObject;
    StarTrekDeepSpaceNine:TJSONObject;

    constructor Create(const aTemplateDir:String);
    destructor Destroy; override;

    function LoadFromFile(const aFileName:string):TJSONObject;

    function RandomText():String;
    function RandomFromTemplate(const aTemplateObject:TJSONObject):TJSONObject;
    function RandomTemplate():TJSONObject;

    property TemplateDir:String read fTemplateDir write fTemplateDir;
  published
  end; // TNMV6C_CreateTextBricks

implementation

{ TNMV6C_CreateTextBricks }
constructor TNMV6C_CreateTextBricks.Create(const aTemplateDir: String);
begin
  inherited Create;
  TemplateDir:=aTemplateDir;
  RaumschiffEnterprise:=LoadFromFile(aTemplateDir + 'Raumschiff Enterprise.json');

  StarTrekNext:=LoadFromFile(aTemplateDir + 'Star Trek - Das nächste Jahrhundert.json');
  StarTrekDeepSpaceNine:=LoadFromFile(aTemplateDir + 'Star Trek - Deep Space Nine.json');

end; // TNMV6C_CreateTextBricks.Create

destructor TNMV6C_CreateTextBricks.Destroy;
begin
  FreeAndNil(RaumschiffEnterprise);
  FreeAndNil(StarTrekNext);
  FreeAndNil(StarTrekDeepSpaceNine);
  inherited Destroy;
end; // TNMV6C_CreateTextBricks.Destroy

function TNMV6C_CreateTextBricks.LoadFromFile(const aFileName: string): TJSONObject;
var
  ms:TMemoryStream;
  jParser:TJSONParser;
begin
  result:=nil;
  try
    try
      if FileExists(aFileName) then begin
        ms:=TMemoryStream.Create;
        ms.LoadFromFile(aFileName);

        jParser:=TJSONParser.Create(ms,[]);
        result:=jParser.Parse as TJSONObject;
      end;
    finally
      FreeAndNil(ms);
      FreeAndNil(jParser);
    end;
  except
  end;
end; // TNMV6C_CreateTextBricks.LoadFromFile

function TNMV6C_CreateTextBricks.RandomText(): String;
var
  r:Integer;
begin
  result:='';
  r:=Random(5);
  case r of
    0: result:='Ein Sinnloser Text';
    1: result:='Am Himmel steht die Sonne';
    2: result:='Erde, Mond und Sterne';
    3: result:='Morgen, morgen nur nicht Heute';
    4: result:='Nachst ist es kälter als draußen';
    5: result:='Apfel und Birnen';
  end;
end; // TNMV6C_CreateTextBricks.RandomText

function TNMV6C_CreateTextBricks.RandomFromTemplate(const aTemplateObject: TJSONObject): TJSONObject;
var
  r:Integer;
  jArray:TJSONArray;
begin
  jArray:=aTemplateObject.Elements['Items'] as TJSONArray;

  r:=Random(jArray.Count - 1);
  result:=jArray[r] as TJSONObject;
end; // TNMV6C_CreateTextBricks.RandomFromTemplate

function TNMV6C_CreateTextBricks.RandomTemplate(): TJSONObject;
var
  r:Integer;
begin
  r:=random(3);
  case r of
    0:result:=RaumschiffEnterprise;
    1:result:=StarTrekNext;
    2:result:=StarTrekDeepSpaceNine;
  end;
end; // TNMV6C_CreateTextBricks.RandomTemplate

end.

