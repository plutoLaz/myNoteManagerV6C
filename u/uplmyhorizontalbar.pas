{
  Autor: Michael Springwald

  Datum: Mittwoch, 28.07.2023
}
unit uplmyhorizontalbar;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Graphics, Buttons, Controls, Contnrs, LCLType, LCLProc, LCLIntf, Messages, Forms,
  optionsForm, ComCtrls;

type
  TPLMyHorizontalBarItem = class;

  TPLOnItemUpdate = procedure () of Object;
  TPLOnChangeIndex = procedure () of Object;

  TPLOnChecked = procedure (sender: TObject) of Object;

  { TPLMyHorizontalBarItem }
  TPLMyHorizontalBarItem = class
  private
    fChecked: Boolean;
    fcTime: TDateTime;
    fData: TObject;
    fIndex: Integer;
    fLeft: Integer;
    fTitle: String;
    fUserIndex: Integer;
    procedure SetChecked(AValue: Boolean);
    procedure SetTitle(AValue: String);

  protected

  public
    constructor Create;
    destructor Destroy; override;
    property Data:TObject read fData write fData;
  published
    property Title:String read fTitle write SetTitle;
    property Checked:Boolean read fChecked write SetChecked;
    property cTime:TDateTime read fcTime write fcTime;
    property UserIndex:Integer read fUserIndex write fUserIndex;

    property Left:Integer read fLeft write fLeft;
    property Index:Integer read fIndex write fIndex;
  end; // TPLMyHorizontalBarItem

  { TPLMyHorizontalBarList }
  TPLMyHorizontalBarList = class
  private
    fAutoUpdate: Boolean;
    fOnItemUpdate: TPLOnItemUpdate;
    function GetCount: Integer;
    function GetItem(const aItemIndex: Integer): TPLMyHorizontalBarItem;
    procedure SetAutoUpdate(AValue: Boolean);
    procedure setOnItemUpdate(AValue: TPLOnItemUpdate);

  protected
    procedure doItemUpdate();

  public
    Items:TObjectList;
    constructor Create;
    destructor Destroy; override;

    function Add(const aTitle:String; const aData:TObject):TPLMyHorizontalBarItem;
    property Item[const aItemIndex:Integer]:TPLMyHorizontalBarItem read GetItem; default;
    property Count:Integer read GetCount;

    property AutoUpdate:Boolean read fAutoUpdate write SetAutoUpdate;
    property OnItemUpdate:TPLOnItemUpdate read fOnItemUpdate write setOnItemUpdate;
  published
  end; // TPLMyHorizontalBarList

  { TMyHorizontalBar }
  TMyHorizontalBar = class(TCustomControl)
  private
    fMarginRight: Integer;
    fOnChangeIndex: TPLOnChangeIndex;
    fOnChecked: TPLOnChecked;
    fPaddingLeft: Integer;
    fPaddingTop: Integer;
    fSelected: TPLMyHorizontalBarItem;
    procedure SetSelected(AValue: TPLMyHorizontalBarItem);
    procedure OnItemUpdate();

  protected
    procedure DoChangeIndex();
    procedure DoOnChecked(sender:TObject);

  public
    BarList:TPLMyHorizontalBarList;
    Buffer:TBitMap;
    BarHorz: TScrollInfo;
    TempDraqOver:TPLMyHorizontalBarItem;
    OptionsBitBtnButton:TBitBtn;
    OptionFm:TOptionsFm;
    myFormatSettings:TFormatSettings;

    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure Paint; override;
    procedure PaintBarItem(const aBarItem:TPLMyHorizontalBarItem; const aAutoPaint:Boolean = false; const aNotSelectedPaint:Boolean = false);
    procedure ItemUpdate();
    function GetHoriWidth():Integer;
    procedure Resize; override;
    procedure Clear();

    function GetItemByXY(const aX, aY:Integer; var aCheckCheckBox:Boolean):TPLMyHorizontalBarItem;

    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;  published
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;

    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    procedure KeyPress(var Key: char); override;
    procedure KeyUp(var Key: Word; Shift: TShiftState); override;

    procedure DragOver(Source: TObject; X, Y: Integer; State: TDragState; var Accept: Boolean); override;
    procedure DragDrop(Source: TObject; X, Y: Integer); override;

    procedure WMHScroll(var Message: TWMHScroll); message WM_HSCROLL;

    procedure UpdateScrollBars;
    procedure OptionsClick(Sender:TObject);

    property Selected:TPLMyHorizontalBarItem read fSelected write SetSelected;

    property PaddingLeft:Integer read fPaddingLeft write fPaddingLeft;
    property PaddingTop:Integer read fPaddingTop write fPaddingTop;
    property MarginRight:Integer read fMarginRight write fMarginRight;

    property OnChangeIndex:TPLOnChangeIndex read fOnChangeIndex write fOnChangeIndex;

    property OnChecked:TPLOnChecked read fOnChecked write fOnChecked;
  end; // TMyHorizontalBar

implementation

procedure TPLMyHorizontalBarItem.SetChecked(AValue: Boolean);
begin
  if fChecked <> AValue then
    fChecked:=AValue;
end;

procedure TPLMyHorizontalBarItem.SetTitle(AValue: String);
begin
  if fTitle <> AValue then
    fTitle:=AValue;
end;

{ TPLMyHorizontalBarItem }
constructor TPLMyHorizontalBarItem.Create;
begin
  inherited Create;
  fData:=nil;
  fLeft:=-1;
  fIndex:=-1;
  fUserIndex:=-1;
  fChecked:=False;
end; // TPLMyHorizontalBarItem.Create

destructor TPLMyHorizontalBarItem.Destroy;
begin
  inherited Destroy;
end; // TPLMyHorizontalBarItem.Destroy

function TPLMyHorizontalBarList.GetCount: Integer;
begin
  result:=Items.Count;
end; // TPLMyHorizontalBarList.GetCount

function TPLMyHorizontalBarList.GetItem(const aItemIndex: Integer): TPLMyHorizontalBarItem;
begin
  result:=Items[aItemIndex] as TPLMyHorizontalBarItem
end; // TPLMyHorizontalBarList.GetItem

procedure TPLMyHorizontalBarList.SetAutoUpdate(AValue: Boolean);
begin
  if fAutoUpdate <> AValue then begin
    fAutoUpdate:=AValue;
    doItemUpdate();
  end;
end;

procedure TPLMyHorizontalBarList.setOnItemUpdate(AValue: TPLOnItemUpdate);
begin
  if fOnItemUpdate=AValue then Exit;
  fOnItemUpdate:=AValue;
end;

procedure TPLMyHorizontalBarList.doItemUpdate;
begin
  if Assigned(fOnItemUpdate) then fOnItemUpdate();
end;

{ TPLMyHorizontalBarList }
constructor TPLMyHorizontalBarList.Create;
begin
  inherited Create;
  fOnItemUpdate:=nil;
  fAutoUpdate:=True;
  Items:=TObjectList.Create(False);
  Items.OwnsObjects:=False;
end; // TPLMyHorizontalBarList.Create

destructor TPLMyHorizontalBarList.Destroy;
var
  i:Integer;
begin
  for i:=Count -1 downto 0 do begin
    Item[i].Free;
  end;
  FreeAndNil(Items);
  inherited Destroy;
end; // TPLMyHorizontalBarList.Destroy

function TPLMyHorizontalBarList.Add(const aTitle: String; const aData: TObject): TPLMyHorizontalBarItem;
begin
  result:=item[items.Add(TPLMyHorizontalBarItem.Create)];
  result.Title:=aTitle;
  result.Data:=aData;

  doItemUpdate();
end; // TPLMyHorizontalBarList.Add

procedure TMyHorizontalBar.SetSelected(AValue: TPLMyHorizontalBarItem);
begin
  if Assigned(fSelected) then
    PaintBarItem(fSelected, true, true);

//  if fSelected <> AValue then begin

    fSelected:=AValue;
    PaintBarItem(AValue, true);
//  end;
end;

procedure TMyHorizontalBar.OnItemUpdate;
begin
  if BarList.AutoUpdate then
    ItemUpdate();
end; // TMyHorizontalBar.ItemAdd

procedure TMyHorizontalBar.DoChangeIndex();
begin
  if Assigned(fOnChangeIndex) then fOnChangeIndex();
end; // TMyHorizontalBar.DoChangeIndex

procedure TMyHorizontalBar.DoOnChecked(sender: TObject);
begin
  if Assigned(fOnChecked) then fOnChecked(sender);
end;

{ TMyHorizontalBar }
constructor TMyHorizontalBar.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ControlStyle := ControlStyle + [csOpaque, csSetCaption, csTripleClicks, csQuadClicks];

  fOnChangeIndex:=nil;
  fOnChecked:=nil;

  fSelected:=nil;
  TempDraqOver:=nil;
  BarList:=TPLMyHorizontalBarList.Create;
  BarList.OnItemUpdate:=@OnItemUpdate;

  Buffer:=TBitMap.Create;

  BarHorz.cbSize := SizeOf(BarHorz);
  BarHorz.fMask := SIF_ALL;  //FMASK;
  BarHorz.nMin := 0;

  fPaddingLeft:=5;
  fPaddingTop:=5;
  fMarginRight:=30;
  DragMode:=dmManual;

  OptionsBitBtnButton:=TBitBtn.Create(self);
  OptionsBitBtnButton.Parent:=self;
  OptionsBitBtnButton.Align:=alRight;
  OptionsBitBtnButton.Caption:='...';
  OptionsBitBtnButton.Font.Style:=[fsBold];
  OptionsBitBtnButton.AutoSize:=True;

  OptionsBitBtnButton.OnClick:=@OptionsClick;

  OptionFm:=TOptionsFm.Create(nil);
  OptionFm.Parent:=nil;


end; // TMyHorizontalBar.Create

destructor TMyHorizontalBar.Destroy;
begin
  FreeAndNil(OptionFm);
  FreeAndNil(Buffer);
  FreeAndNil(BarList);
  inherited Destroy;
end; // TMyHorizontalBar.Destroy

procedure TMyHorizontalBar.Paint;
var
  i, px, py, pw:integer;
  BarItem:TPLMyHorizontalBarItem;
  r:TRect;
begin

  px:=PaddingLeft;
  py:=PaddingTop;

  Buffer.Width:=ClientWidth;
  Buffer.Height:=ClientHeight;
  Buffer.Canvas.Brush.Style:=bsSolid;
  Buffer.Canvas.Brush.Color:=clWhite;
  Buffer.Canvas.FillRect(0,0,  ClientWidth, ClientHeight);

  Buffer.Canvas.Brush.Style:=bsClear;
  Buffer.Canvas.Font.Name:='Ubuntu';
  Buffer.Canvas.Font.Size:=14;
  Buffer.Canvas.Font.Style:=[fsBold];

  for i:=0 to BarList.Count - 1 do begin
    BarItem:=BarList[i];
    BarItem.Left:=px;
    BarItem.Index:=i;
    PaintBarItem(BarItem);
    pw:=Buffer.Canvas.TextWidth(BarItem.Title) + MarginRight;
    px+=pw;
//    if px - BarHorz.nPos >= (BarHorz.nPage) then
//      break;
  end;

  r:=Rect(0,0, ClientWidth, ClientHeight);
  Canvas.CopyRect(R,Buffer.Canvas, r);
end; // TMyHorizontalBar.Paint

procedure TMyHorizontalBar.PaintBarItem(const aBarItem: TPLMyHorizontalBarItem; const aAutoPaint: Boolean; const aNotSelectedPaint: Boolean);
var
  py, pw, ph:Integer;
  r:TRect;
begin
  py:=PaddingTop;
  Buffer.Canvas.Font.Color:=clBlack;
  if Assigned(aBarItem) then begin
    if not aNotSelectedPaint then begin
      if (Assigned(Selected)) and (aBarItem = Selected) then
        Buffer.Canvas.Font.Color:=clBlue;
    end;
    pw:=Buffer.Canvas.TextWidth(aBarItem.Title);
    ph:=Buffer.Canvas.TextHeight(aBarItem.Title);

    r.Left:=aBarItem.Left-BarHorz.nPos;
    r.Top:=py + 5;
    r.Width:=ph;
    r.Height:=ph;

    Buffer.Canvas.Pen.Width:=1;
    Buffer.Canvas.Frame3D(r,cl3DDkShadow, cl3DFace,1);
    if aBarItem.Checked then begin
      Buffer.Canvas.Pen.Color:=clRed;

      Buffer.Canvas.Pen.Width:=3;
      Buffer.Canvas.MoveTo(r.Left,r.top);
      Buffer.Canvas.LineTo(r.Left + r.Width,r.Top + r.Height);

      Buffer.Canvas.Pen.Width:=3;
      Buffer.Canvas.MoveTo(r.Left + r.Width,r.top);
      Buffer.Canvas.LineTo(r.Left,r.Top + r.Height);
    end;
    Buffer.Canvas.TextOut(aBarItem.Left-BarHorz.nPos+r.Width + 5, py+5, aBarItem.Title);

    if aAutoPaint then begin
      r.Left:=aBarItem.Left-BarHorz.nPos;
      r.Top:=py;
      r.Width:=pw + ph;
      r.Height:=ph;
      Canvas.CopyRect(r, buffer.Canvas,r);
    end;
  end;
end; // TMyHorizontalBar.PaintBarItem

procedure TMyHorizontalBar.ItemUpdate();
begin
  if BarList.AutoUpdate then begin
    UpdateScrollBars;
    Invalidate;
  end;
end; // TMyHorizontalBar.ItemUpdate

function TMyHorizontalBar.GetHoriWidth(): Integer;
var
  i, pw:Integer;
  BarItem:TPLMyHorizontalBarItem;
begin
  Buffer.Canvas.Font.Name:='Ubuntu';
  Buffer.Canvas.Font.Size:=14;
  Buffer.Canvas.Font.Style:=[fsBold];

  pw:=PaddingLeft;
  for i:=0 to BarList.Count -1 do begin
    BarItem:=BarList[i];
    pw+=Buffer.Canvas.TextWidth(BarItem.Title) + MarginRight;
  end;
  result:=pw;
end; // TMyHorizontalBar.GetHoriWidth

procedure TMyHorizontalBar.Resize;
begin
  inherited Resize;
  BarHorz.nMax:=GetHoriWidth() + OptionsBitBtnButton.Width;
  BarHorz.nPage:=ClientWidth - OptionsBitBtnButton.Width;
  UpdateScrollBars();
  Paint;
end; // TMyHorizontalBar.Resize

procedure TMyHorizontalBar.Clear;
begin
  BarList.Items.Clear;
  Invalidate;
end;

function TMyHorizontalBar.GetItemByXY(const aX, aY: Integer;
  var aCheckCheckBox: Boolean): TPLMyHorizontalBarItem;
var
  i, px, py, pw, ph:Integer;
  pt:TPoint;
  r, r2:TRect;
  TempBarItem:TPLMyHorizontalBarItem;
begin
  result:=nil;

  px:=PaddingLeft; py:=PaddingTop;
  Buffer.Canvas.Font.Name:='Ubuntu';
  Buffer.Canvas.Font.Size:=14;
  Buffer.Canvas.Font.Style:=[fsBold];
  pt:=Point(aX, aY);

  for i:=0 to BarList.Count -1 do begin
    TempBarItem:=BarList[i];
    pw:=Buffer.Canvas.TextWidth(TempBarItem.Title);
    ph:=Buffer.Canvas.TextHeight(TempBarItem.Title);

    r.Left:=px-BarHorz.nPos;
    r.Top:=5;
    r.Width:=pw + MarginRight;
    r.Height:=ph;

    r2.Left:=px-BarHorz.nPos;
    r2.Top:=5;
    r2.Width:=ph;
    r2.Height:=ph;
    aCheckCheckBox:=PtInRect(r2, pt);

    if PtInRect(r, pt) then begin
      Result:=TempBarItem;
      break;
    end;
    px+=pw + MarginRight;
  end; // for i
end; // TMyHorizontalBar.GetItemByXY

procedure TMyHorizontalBar.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  TempBarItem:TPLMyHorizontalBarItem;
  isCheckBoxClick:Boolean;
begin
  inherited MouseDown(Button, Shift, X, Y);
  isCheckBoxClick:=true;
  DragMode:=dmManual;

  if mbLeft = Button then begin
    TempBarItem:=GetItemByXY(x,y, isCheckBoxClick);

    Selected:=TempBarItem;

    if Assigned(TempBarItem) then begin
      writeln('Gefunden: ', TempBarItem.Title);
      if isCheckBoxClick then begin
        Selected.Checked:=not Selected.Checked;
        DoOnChecked(Selected);
      end
      else
        DragMode:=dmAutomatic;
      Invalidate;
    end
    else
      writeln('TMyHorizontalBar.MouseDown: Kein Eintrag an der Stelle gefunden !' );
  end;

end; // TMyHorizontalBar.MouseDown

procedure TMyHorizontalBar.MouseMove(Shift: TShiftState; X, Y: Integer);
begin
  inherited MouseMove(Shift, X, Y);
end; // TMyHorizontalBar.MouseMove

procedure TMyHorizontalBar.MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  inherited MouseUp(Button, Shift, X, Y);
end; // TMyHorizontalBar.MouseUp

procedure TMyHorizontalBar.KeyDown(var Key: Word; Shift: TShiftState);
var
  TempItemIndex:Integer;
  TempWidht:Integer;
begin
  inherited KeyDown(Key, Shift);
  case Key of
    VK_LEFT: begin
      if Assigned(Selected) then
        TempItemIndex:=Selected.Index
      else
        TempItemIndex:=BarList.Count -1;

      if TempItemIndex - 1 >= 0 then begin
        Selected:=BarList[TempItemIndex - 1];
        TempWidht:=Buffer.Canvas.TextWidth(Selected.Title);
        if (Selected.Left - TempWidht-MarginRight) < BarHorz.nPos then begin

          if BarHorz.nPos - TempWidht > MarginRight then
            BarHorz.nPos-=(TempWidht+MarginRight)
          else begin
            BarHorz.nPos:=0;
          end;
        end
        else begin
          if Selected.Left - TempWidht <= MarginRight then
            BarHorz.nPos:=0;
        end;

        SetScrollInfo(Handle, SB_Horz, BarHorz, true);
        Invalidate;
      end
      else begin
        if BarHorz.nPos > 0 then begin
          BarHorz.nPos:=0;
          SetScrollInfo(Handle, SB_Horz, BarHorz, true);
          Invalidate;
        end;
      end;

    end; // VK_LEFT;

    VK_RIGHT: begin
      if Assigned(Selected) then
        TempItemIndex:=Selected.Index
      else
        TempItemIndex:=0;

      if TempItemIndex + 1 <= BarList.Count -1 then begin
        Selected:=BarList[TempItemIndex + 1];

        TempWidht:=Buffer.Canvas.TextWidth(Selected.Title);
        if Selected.Left+TempWidht + 10 > (BarHorz.nPos + ClientWidth)- OptionsBitBtnButton.Width then
          BarHorz.nPos+=(TempWidht + MarginRight);

        SetScrollInfo(Handle, SB_Horz, BarHorz, true);
        Invalidate;
      end
      else begin
        BarHorz.nPos:=BarHorz.nMax - ClientWidth;
        SetScrollInfo(Handle, SB_Horz, BarHorz, true);
        Invalidate;
      end;
    end; // VK_RIGHT;
  end;
end; // TMyHorizontalBar.KeyDown

procedure TMyHorizontalBar.KeyPress(var Key: char);
begin
  inherited KeyPress(Key);
end; // TMyHorizontalBar.KeyPress

procedure TMyHorizontalBar.KeyUp(var Key: Word; Shift: TShiftState);
begin
  inherited KeyUp(Key, Shift);
end; // TMyHorizontalBar.KeyUp

procedure TMyHorizontalBar.DragOver(Source: TObject; X, Y: Integer; State: TDragState; var Accept: Boolean);
var
  isCheckboxClick:Boolean;
  DraqOverObject:TPLMyHorizontalBarItem;
begin
  inherited DragOver(Source, X, Y, State, Accept);
  isCheckboxClick:=true;
  DraqOverObject:=GetItemByXY(x,y, isCheckboxClick);
  if not isCheckboxClick then begin
    Accept:=True;
    TempDraqOver:=DraqOverObject;
  end
  else
    Accept:=False;
end; // TMyHorizontalBar.DragOver

procedure TMyHorizontalBar.DragDrop(Source: TObject; X, Y: Integer);
var
  TempSelect:TPLMyHorizontalBarItem;
  isCheckboxClick:Boolean;
begin
  inherited DragDrop(Source, X, Y);
  isCheckboxClick:=False;
  TempSelect:=GetItemByXY(x,y, isCheckboxClick);
  isCheckboxClick:=True;
  if Assigned(TempSelect) then begin
//    writeln('DraqDrop: ', TempSelect.Title);
    if Assigned(Selected) then begin
//      writeln('Quelle: ', Selected.Title);
//      writeln(TempSelect.Index, ' ', TempDraqOver.Index);

      BarList.Items.Move(Selected.Index, TempDraqOver.Index);

      DoChangeIndex();
      Invalidate;
    end;
  end;
end; // TMyHorizontalBar.DragDrop

procedure TMyHorizontalBar.WMHScroll(var Message: TWMHScroll);
var
  NewPaint:Boolean;
const
  PIXEL_TO_SCROLL = 17;
begin
  case Message.ScrollCode of
    SB_LINELEFT: begin

    end; // SB_LINELEFT

    SB_RIGHT: begin

    end; // SB_RIGHT

    SB_THUMBPOSITION, SB_THUMBTRACK: begin
      BarHorz.nPos:=Message.Pos;
    end;
  end;
  SetScrollInfo(Handle, SB_Horz, BarHorz, true);
  Invalidate();
end; // TMyHorizontalBar.WMHScroll

procedure TMyHorizontalBar.UpdateScrollBars;
begin
  BarHorz.nPos := Left;

  ShowScrollBar(Handle, SB_HORZ, False);
  SetScrollInfo(Handle, SB_HORZ, BarHorz, True);

  BarHorz.nMax:=GetHoriWidth() + OptionsBitBtnButton.Width;
  if BarHorz.nMax > ClientWidth then begin
    BarHorz.nPage:=ClientWidth;

    ShowScrollBar(Handle, SB_HORZ, BarHorz.nMax > Width);
    SetScrollInfo(Handle, SB_HORZ, BarHorz, true);
  end;
end; // TMyHorizontalBar.UpdateScrollBars

procedure TMyHorizontalBar.OptionsClick(Sender: TObject);
var
  TempModal, i, TempIndex:Integer;

  BarItem:TPLMyHorizontalBarItem;
  ListItem:TListitem;
  FormatetDateTime, TempItemTitle:String;
begin
  OptionFm.CheckListBox1.Items.Clear;
  OptionFm.ListView1.Items.Clear;

  for i:=0 to BarList.Count -1 do begin
    BarItem:=BarList[i];
    TempIndex:=OptionFm.CheckListBox1.Items.AddObject(BarItem.Title, BarItem);
    OptionFm.CheckListBox1.Checked[TempIndex]:=BarItem.Checked;

    FormatetDateTime:=FormatDateTime('DDD, DD.MM.YYYY HH:MM',BarItem.cTime);
    ListItem:=TListItem.Create(OptionFm.ListView1.Items);
    ListItem.Caption:=BarItem.Title;
    ListItem.Checked:=BarItem.Checked;
    ListItem.Data:=BarItem.Data;

    ListItem.SubItems.Add(FormatetDateTime);

    OptionFm.ListView1.Items.AddItem(ListItem);
  end;

  TempModal:=OptionFm.ShowModal;
  if TempModal = mrOK then begin
    BarList.AutoUpdate:=False;
    BarList.Items.Clear;
    for i:=0 to OptionFm.CheckListBox1.Items.Count -1 do begin
      BarItem:=OptionFm.CheckListBox1.Items.Objects[i] as TPLMyHorizontalBarItem;
      BarItem.Title:=OptionFm.CheckListBox1.Items[i];
      BarItem.Checked:=OptionFm.CheckListBox1.Checked[i];

      BarItem.Data:=(OptionFm.CheckListBox1.Items.Objects[i] as TPLMyHorizontalBarItem).Data;
      BarList.Items.Add(BarItem);
    end;
    BarHorz.nMax:=GetHoriWidth() + OptionsBitBtnButton.Width;
    BarHorz.nPos:=0;

    BarList.AutoUpdate:=True;
    DoChangeIndex();
  end;
end;

end.

