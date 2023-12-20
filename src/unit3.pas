unit Unit3;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, Buttons,
  ComCtrls, SynEdit, fpjson;

type

  { TForm3 }

  TForm3 = class(TForm)
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    BitBtn3: TBitBtn;
    ListView1: TListView;
    Panel1: TPanel;
    Splitter1: TSplitter;
    SynEdit1: TSynEdit;
    procedure ListView1DblClick(Sender: TObject);
  private

  public

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
    SynEdit1.Lines.Text:=jObject.Elements['content'].AsString;
  end;
end;

end.

