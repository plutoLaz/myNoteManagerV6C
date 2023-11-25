unit optionsForm;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, Buttons,
  StdCtrls, CheckLst, ComCtrls, Types;

type

  { TOptionsFm }

  TOptionsFm = class(TForm)
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    Panel1: TPanel;
    Panel2: TPanel;
    Panel3: TPanel;
    ListView1:TListView;
    PageControl1:TPageControl;
    TabSheet2: TTabSheet;

    procedure CheckListBox1DblClick(Sender: TObject);
    procedure CheckListBox1DragDrop(Sender, Source: TObject; X, Y: Integer);
    procedure CheckListBox1DragOver(Sender, Source: TObject; X, Y: Integer;
      State: TDragState; var Accept: Boolean);
    procedure CheckListBox1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormCreate(Sender: TObject);
    procedure ListView1DragDrop(Sender, Source: TObject; X, Y: Integer);
    procedure ListView1DragOver(Sender, Source: TObject; X, Y: Integer;
      State: TDragState; var Accept: Boolean);
    procedure PageControl1Change(Sender: TObject);
    procedure TabSheet1ContextPopup(Sender: TObject; MousePos: TPoint;
      var Handled: Boolean);
  private

  public
    DraggingItemNumber:Integer;
  end;

var
  OptionsFm: TOptionsFm;

implementation

{$R *.lfm}

{ TOptionsFm }

procedure TOptionsFm.CheckListBox1DblClick(Sender: TObject);
begin
end;


procedure TOptionsFm.CheckListBox1DragDrop(Sender, Source: TObject; X, Y: Integer);
begin
end;

procedure TOptionsFm.CheckListBox1DragOver(Sender, Source: TObject; X, Y: Integer;
  State: TDragState; var Accept: Boolean);
begin
end;

procedure TOptionsFm.CheckListBox1MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
end;

procedure TOptionsFm.FormCreate(Sender: TObject);
begin
  ListView1.MultiSelect:=true;
end;

// Quelle 1: https://forum.lazarus.freepascal.org/index.php?topic=18734.0
// Quelle 2: https://help.market.com.br/delphi/listview_-_drag_n_drop_multipl.htm
procedure TOptionsFm.ListView1DragDrop(Sender, Source: TObject; X, Y: Integer);
var
  DragItem, DropItem, CurrentItem, NextItem: TListItem;
begin
  if Sender = Source then
    with TListView(Sender) do begin
      DropItem    := GetItemAt(X, Y);
      CurrentItem := Selected;
      while CurrentItem <> nil do begin
        NextItem := GetNextItem(CurrentItem, SdAll, [lisSelected]);
        if DropItem = nil then
          DragItem := Items.Add
        else
          DragItem := Items.Insert(DropItem.Index);

        DragItem.Assign(CurrentItem);
        CurrentItem.Free;
        CurrentItem := NextItem;
      end;
    end;
end;

procedure TOptionsFm.ListView1DragOver(Sender, Source: TObject; X, Y: Integer;
  State: TDragState; var Accept: Boolean);
begin
  Accept := Sender = TListView(Sender);
end;

procedure TOptionsFm.PageControl1Change(Sender: TObject);
begin

end;

procedure TOptionsFm.TabSheet1ContextPopup(Sender: TObject; MousePos: TPoint;
  var Handled: Boolean);
begin

end;

end.

