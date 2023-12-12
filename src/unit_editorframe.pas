unit unit_EditorFrame;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, ExtCtrls, StdCtrls, Graphics, EditBtn,
  SynEdit, SynEditMiscClasses, SynEditMarkupSpecialLine;

type

  { TEditorFrame }

  TEditorFrame = class(TFrame)
    ComboBox1: TComboBox;
    DateEdit1: TDateEdit;
    edTitle: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Panel1: TPanel;
    Panel2: TPanel;
    Panel3: TPanel;
    Panel4: TPanel;
    SEEditor: TSynEdit;
    Splitter1: TSplitter;
    Splitter2: TSplitter;
    procedure DateEdit1Change(Sender: TObject);
    procedure SEEditorSpecialLineMarkup(Sender: TObject; Line: integer;
      var Special: boolean; Markup: TSynSelectedColor);
  private

  public

  end;

implementation

{$R *.lfm}

{ TEditorFrame }

procedure TEditorFrame.SEEditorSpecialLineMarkup(Sender: TObject;
  Line: integer; var Special: boolean; Markup: TSynSelectedColor);
var
  FindX:Integer;
begin
  FindX:=pos('[Abschnitt', SEEditor.Lines[Line-1]);
  if FindX > 0 then begin
    Markup.Foreground:=clRed;
    Markup.Style:=[fsBold];
    Special:=True;
  end

end;

procedure TEditorFrame.DateEdit1Change(Sender: TObject);
begin
end;

end.

