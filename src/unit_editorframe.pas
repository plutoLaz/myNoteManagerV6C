unit unit_EditorFrame;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, ExtCtrls, StdCtrls, SynEdit;

type

  { TEditorFrame }

  TEditorFrame = class(TFrame)
    edTitle: TEdit;
    Label1: TLabel;
    Panel1: TPanel;
    SEEditor: TSynEdit;
  private

  public

  end;

implementation

{$R *.lfm}

end.

