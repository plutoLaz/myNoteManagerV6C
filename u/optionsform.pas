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
    CheckListBox1: TCheckListBox;
    Panel1: TPanel;
    Panel2: TPanel;
    Panel3: TPanel;
    ListView1:TListView;
    PageControl1:TPageControl;
    TabSheet1: TTabSheet;
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
var
  TempTitle:String;
begin

  if CheckListBox1.ItemIndex > -1 then begin
    TempTitle:=CheckListBox1.Items[CheckListBox1.ItemIndex];
    if InputQuery('Title vom Tag ändern', 'Neuer Title', TempTitle) then begin
      CheckListBox1.Items[CheckListBox1.ItemIndex]:=TempTitle;
    end;
  end;
end;


procedure TOptionsFm.CheckListBox1DragDrop(Sender, Source: TObject; X, Y: Integer);
var ItemUnderMouse:integer;
begin
  ItemUnderMouse := CheckListBox1.ItemAtPos(Point(X,Y), true);
  if (ItemUnderMouse>-1) and (ItemUnderMouse<CheckListBox1.Count) and (DraggingItemNumber>-1) then
    CheckListBox1.Items.Move(DraggingItemNumber,ItemUnderMouse);
end;

procedure TOptionsFm.CheckListBox1DragOver(Sender, Source: TObject; X, Y: Integer;
  State: TDragState; var Accept: Boolean);
var ItemUnderMouse:integer;
begin
  if Sender=Source then
    begin
      ItemUnderMouse := CheckListBox1.ItemAtPos(Point(X,Y), true);
      Accept:=(ItemUnderMouse>-1) and (ItemUnderMouse<CheckListBox1.Count);
    end
  else
    Accept:=false;
end;

procedure TOptionsFm.CheckListBox1MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  DraggingItemNumber := CheckListBox1.ItemAtPos(Point(X,Y), true);
  if (DraggingItemNumber>-1) and (DraggingItemNumber<CheckListBox1.Count) then
    CheckListBox1.BeginDrag(true)
  else begin
    CheckListBox1.BeginDrag(False);
    DraggingItemNumber:=-1;
  end;
end;

procedure TOptionsFm.FormCreate(Sender: TObject);
begin
  ListView1.MultiSelect:=true;
end;

procedure TOptionsFm.ListView1DragDrop(Sender, Source: TObject; X, Y: Integer);
begin

end;

procedure TOptionsFm.ListView1DragOver(Sender, Source: TObject; X, Y: Integer;
  State: TDragState; var Accept: Boolean);
begin
  Accept:=True;
end;

procedure TOptionsFm.PageControl1Change(Sender: TObject);
begin

end;

procedure TOptionsFm.TabSheet1ContextPopup(Sender: TObject; MousePos: TPoint;
  var Handled: Boolean);
begin

end;

end.

