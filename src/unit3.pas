unit Unit3;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, Buttons,
  ComCtrls, SynEdit, fpjson, LCLType, StdCtrls, EditBtn;

type

  { TForm3 }

  TForm3 = class(TForm)
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    BitBtn3: TBitBtn;
    DateEdit1: TDateEdit;
    Edit1: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    ListView1: TListView;
    Panel1: TPanel;
    Panel2: TPanel;
    Panel3: TPanel;
    Panel4: TPanel;
    Panel5: TPanel;
    Panel6: TPanel;
    spCityAdd: TSpeedButton;
    spCityDelete: TSpeedButton;
    Splitter1: TSplitter;
    Splitter2: TSplitter;
    SynEdit1: TSynEdit;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure ListView1DblClick(Sender: TObject);
    procedure spCityAddClick(Sender: TObject);
    procedure spCityDeleteClick(Sender: TObject);
    procedure SynEdit1Exit(Sender: TObject);
  private

  public
    jSelectObject:TJSONObject;
    jDeleteArray:TJSONArray;
    procedure ProcessData(var aAddArray:TJSONArray; var aChangeArray:TJSONArray);
  end;

var
  Form3: TForm3;

implementation

{$R *.lfm}

{ TForm3 }

procedure TForm3.ListView1DblClick(Sender: TObject);
var
  jObject:TJSONObject;
begin
  if Assigned(ListView1.Selected) then begin
    jObject:=TJSONObject(ListView1.Selected.Data);
    jSelectObject:=jObject;

    Edit1.Text:=jObject.Elements['name'].AsString;
    DateEdit1.Date:=StrToDateTime(jObject.Elements['ctime'].AsString);
    SynEdit1.Lines.Text:=jObject.Elements['content'].AsString;
  end;
end;

procedure TForm3.FormCreate(Sender: TObject);
begin
  jSelectObject:=nil;
  jDeleteArray:=TJSONArray.Create();
end;

procedure TForm3.FormDestroy(Sender: TObject);
begin
  FreeAndNil(jDeleteArray);
end;

procedure TForm3.spCityAddClick(Sender: TObject);
var
  cityName:string;
  ListItem:TListItem;

  cityObject:TJSONObject;
begin
  cityName:='';
  if InputQuery('Stadt Name eingeben', 'Name', cityName) then begin
    cityObject:=TJSONObject.Create();
    cityObject.Add('status','add');
    cityObject.Add('name', cityName);
    cityObject.Add('ctime', DateTimeToStr(now));
    cityObject.Add('content', '');

    ListItem:=ListView1.Items.add;
    ListItem.Caption:=cityName;
    ListItem.SubItems.Add('');
    ListItem.Data:=cityObject;
  end;
end;

procedure TForm3.spCityDeleteClick(Sender: TObject);
var
  Reply, BoxStyle: Integer;
  i:Integer;

  jData:TJSONData;
  jObject:TJSONObject;
begin
  BoxStyle := MB_ICONERROR+ MB_YESNOCANCEL;
  Reply := Application.MessageBox('Wirklich löschen ?', 'Löschen?', BoxStyle);
  if Reply = IDYES then begin
    for i:=ListView1.Items.Count -1 downto 0 do begin
      if ListView1.Items[i].Selected then begin
        jObject:=TJSONObject(ListView1.Items[i].Data);
        jData:=jObject.Find('id');
        if Assigned(jData) then begin
          jDeleteArray.Add(jData.AsInteger);
        end;
        ListView1.Items.Delete(i);
      end;
    end; // for x
  end;
end;

procedure TForm3.SynEdit1Exit(Sender: TObject);
var
  jData:TJSONData;
begin
  if Assigned(jSelectObject) then begin
    jData:=jSelectObject.Find('status');
    if not Assigned(jData) then begin
      jSelectObject.Add('status', 'change');
    end;

    jData:=jSelectObject.Find('name');
    if (Assigned(jData)) and (Edit1.Modified) then begin
      Edit1.Modified:=False;
      jData.AsString:=Edit1.Text;
    end;

    jData:=jSelectObject.Find('content');
    if (Assigned(jData)) and (SynEdit1.Modified) then begin
      SynEdit1.Modified:=False;
      jData.AsString:=SynEdit1.Lines.Text;
    end;

    jData:=jSelectObject.Find('ctime');
    if (Assigned(jData)) and (DateEdit1.Modified) then begin
      DateEdit1.Modified:=False;
      jData.AsString:=DateToStr(DateEdit1.Date);
    end;
  end;
end;

procedure TForm3.ProcessData(var aAddArray: TJSONArray; var aChangeArray: TJSONArray);
var
  i:Integer;
  jObject:TJSONObject;
  jData:TJSONData;
  StatusStr:String;
begin
  for i:=0 to ListView1.Items.Count - 1 do begin
    jObject:=TJSONObject(ListView1.Items[i].Data);

    jData:=jObject.Find('status');
    if Assigned(jData) then begin
      StatusStr:=LowerCase(jData.AsString);
      case StatusStr of
        'add': aAddArray.Add(jObject);
        'change': aChangeArray.Add(jObject);
      end; // case
    end;
  end;
end; // TForm3.ProcessData

end.

