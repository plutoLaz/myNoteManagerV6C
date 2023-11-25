unit unit_EditorFrame;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, ExtCtrls, StdCtrls, Graphics,
  SynEdit, SynEditMiscClasses, SynEditMarkupSpecialLine;

type

  { TEditorFrame }

  TEditorFrame = class(TFrame)
    edTitle: TEdit;
    Label1: TLabel;
    Panel1: TPanel;
    SEEditor: TSynEdit;
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

end.

