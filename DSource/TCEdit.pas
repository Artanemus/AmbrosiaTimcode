unit TCEdit;

interface

uses
  System.SysUtils, System.Classes, System.Types,
  Vcl.Controls, Vcl.Forms, Vcl.StdCtrls, vcl.Graphics,
  Winapi.Messages,
  TimecodeTypes, Timecode;

type

TTCEdit = class(TCustomControl)

	type tcHotSpot = (
		hsStatusFPS, hsStatusFPF, hsStatusStyle, hsClientZone
	);

  private
    { Private declarations }
	fLineLead: integer;

	procedure SetAutoScaleMaxFontSize(Value: integer );
	procedure SetShowRawText(Value: boolean );
	procedure SetShowStatusFPS(Value: boolean );
	procedure SetShowStatusFPF(Value: boolean );
	procedure SetShowStatusStyle(Value: boolean );
	procedure SetStyle(Value: tcStyle);
	function GetStyle(): tcStyle;
	procedure SetStandard(Value: tcStandard);
	function GetStandard(): tcStandard;
	procedure SetPerforation(Value: tcPerforation);
	function GetPerforation(): tcPerforation;
	function GetHotSpot(MousePoint: TPoint):tcHotSpot;
	procedure SetOperation( Value: tcOperation);
	procedure SetShowOperation(Value: boolean );
	procedure SetAutoScale(Value: boolean );
	procedure UpdateAutoScaleFontSize();
	function GetUseDropFrame(): boolean;
	procedure SetUseDropFrame(Value: boolean );
	procedure SetFrames(Value: double );
	function GetFrames(): double;

  protected
    { Protected declarations }
    fOperation: tcOperation;
    fShowOperation: boolean;
    fShowStatusFPS: boolean;
    fShowStatusFPF: boolean;
    fShowStatusStyle: boolean;
    fShowFocused: boolean;
    fTransparent: boolean;
    fAutoScale: boolean;
    fAutoScaleMaxFontSize: integer;
    fTC: TTimecode;
    fRawText: String;
    fShowRawText: boolean;
    fEditing: boolean;
    fModified: boolean;
    fTCFont: TFont;

    FAlignment: TAlignment;
    FOnChange: TNotifyEvent;
    procedure Paint(); virtual;
    function StripOutNonNumerical(TCText: string): String;
    function GetText(): String;
    procedure SetText(Value: string);
    procedure KeyUp(Key: Word; Shift: TShiftState); DYNAMIC;
    procedure Click(); DYNAMIC;
    procedure AdjustSize(); DYNAMIC;
    function CanResize(var NewWidth: integer; var NewHeight: integer)
      : boolean; virtual;
    procedure Changed(); virtual;

    // set transparency parameters
    procedure CreateParams(var Params: TCreateParams); virtual;
    // Paints the parent under this control - use for transparency...
    procedure DrawParentImage(AControl: TControl; Dest: TCanvas);
    procedure SetTransparent(Value: boolean);
    procedure SetAlignment(Value: TAlignment);
    procedure WMKillFocus(var Message: TMessage);

  public
    { Public declarations }
	procedure ClipboardPaste(Sender: TObject);
	procedure ClipboardCopy(Sender: TObject);
	procedure ToggleStyle(AForward: boolean );
	procedure ToggleFPS(AForward: boolean );
	procedure ToggleFPF(AForward: boolean );
	procedure ForceUpdate();
	 procedure SetFocus();virtual;

  constructor Create(AOwner: TComponent); override;
  destructor Destroy();override;

  published
    { Published declarations }
    property Align;
    property Alignment: TAlignment read FAlignment write SetAlignment
      default taLeftJustify;
    // property AutoSize;
    property Cursor;
    property DragCursor;
    property Enabled;
    property Font;
    property Left;
    property ParentFont;
    property Top;
    property Visible;
    property Width default 241;
    property Height default 65;

    // -------------MISC
    property Name;
    property Tag;
    property Touch;
    // ------------LAYOUT
    property Anchors;
    property Constraints;
    property Margins;
    property TabStop;
    // ------------Legacy
    property Ctl3D;
    property ParentCtl3D;
    // ------------Help
    property HelpContext;
    property HelpKeyword;
    property HelpType;
    property Hint;
    property ParentCustomHint;
    property ParentShowHint;
    property ShowHint;
    property BorderWidth;
    property ParentColor;
    property Color;

    // property BevelEdges;
    // property BevelInner;
    // property BevelOuter;
    // property BevelKind;
    // property BevelWidth;

    property OnChange: TNotifyEvent read FOnChange write FOnChange;
    property Text: UnicodeString read GetText write SetText;
    property TC_Font: TFont read fTCFont write fTCFont;
    property AutoSizeMaxFontSize: integer read fAutoScaleMaxFontSize
      write SetAutoScaleMaxFontSize default 64;
    property ShowStatusFPS: boolean read fShowStatusFPS write SetShowStatusFPS
      default True;
    property ShowStatusFPF: boolean read fShowStatusFPF write SetShowStatusFPF
      default True;
    property ShowStatusStyle: boolean read fShowStatusStyle
      write SetShowStatusStyle default True;
    property ShowRawText: boolean read fShowRawText write SetShowRawText
      default True;
    property AutoScale: boolean read fAutoScale write SetAutoScale default True;
     property TC_Style: tcStyle read GetStyle write SetStyle default tcTimecodeStyle;
     property TC_Standard: tcStandard read GetStandard write SetStandard default tcPAL;
    property Perforation: tcPerforation read GetPerforation write SetPerforation
      default tcPerforation.mm35_3perf;
    property MathOperation: tcOperation read fOperation write SetOperation default tcNone;
    property ShowOperation: boolean read fShowOperation write SetShowOperation
      default False;
    property Transparent: boolean read fTransparent write SetTransparent
      default False;
    property UseDropFrame: boolean read GetUseDropFrame write SetUseDropFrame
      default True;
    // TCEdit is a text orientated component... it was never intended to have
    // metamorfic dualality for both string and timecode.
    property Frames: double read GetFrames write SetFrames;
    property Modified: boolean read fModified write fModified default False;
    property ShowFocused: boolean read fShowFocused write fShowFocused
      default False;
  end;

procedure Register;

implementation

uses
  WinApi.Windows, TimecodeHelper;  // for HDC

procedure Register;
begin
  RegisterComponents('Artanemus', [TTCEdit]);
end;

{ TTCEdit }

procedure TTCEdit.AdjustSize;
begin

end;

function TTCEdit.CanResize(var NewWidth, NewHeight: integer): boolean;
begin

end;

procedure TTCEdit.Changed;
begin

end;

procedure TTCEdit.Click;
begin

end;

procedure TTCEdit.ClipboardCopy(Sender: TObject);
begin

end;

procedure TTCEdit.ClipboardPaste(Sender: TObject);
begin

end;

constructor TTCEdit.Create(AOwner: TComponent);
begin
  inherited;
  //	fTC is a RECORD - create isn't required

	// This is required to ensure that TTimecode is registered for streaming.
	// If not set, then the Clipboard() will show the exception error
	// EClassNotFound.
  // Doesn't pertain to RECORD? ...
  //	Classes::RegisterClasses(&(__classid(TTimecode)), 0);

	fLineLead := 4;
	FOnChange := nil;
	AutoSize := false;
	fAutoScale := true;
	fAutoScaleMaxFontSize := 64;
	fShowStatusFPS := true;
	fShowStatusFPF := true;
	fShowStatusStyle := true;
	// user option to force display of raw keyboard input
	fShowRawText := false;
	fShowOperation := false;
	fTC.UseDropFrame := true;
	fRawText := '';
	Width := 241;
	Height := 65;

	fTCFont := TFont.Create();
	fTCFont.Assign(Font);
	fTCFont.Name := 'Courier New';
  fTCFont.Style := fTCFont.Style + [fsBold];
	fTCFont.Size := fAutoScaleMaxFontSize;

	fOperation := tcNone;
	fTransparent := false;
	Caption := '00:00:00:00';
	Text := '00:00:00:00';
	FAlignment := taCenter;
	fModified := false;
	fShowFocused := false;
	fEditing := false;
end;

procedure TTCEdit.CreateParams(var Params: TCreateParams);
begin

end;

destructor TTCEdit.Destroy;
begin
  FreeAndNil(fTCFont);
  inherited;
end;

procedure TTCEdit.DrawParentImage(AControl: TControl; Dest: TCanvas);
var
  SaveIndex: Integer;
  DC: HDC;
  Point: TPoint;
begin
  if not HasParent then
    Exit;
  DC := Dest.Handle;
  SaveIndex := SaveDC(DC);
  GetViewportOrgEx(DC, Point);
  SetViewportOrgEx(DC, Point.X - AControl.Left, Point.Y - AControl.Top, nil);
  IntersectClipRect(DC, 0, 0, Parent.ClientWidth, Parent.ClientHeight);
  Parent.Perform(WM_ERASEBKGND, WPARAM(DC), 0);
  Parent.Perform(WM_PAINT, WPARAM(DC), 0);
  RestoreDC(DC, SaveIndex);
end;


procedure TTCEdit.ForceUpdate;
begin

end;

function TTCEdit.GetFrames: double;
begin

end;

function TTCEdit.GetHotSpot(MousePoint: TPoint): tcHotSpot;
var
  w, h: Integer;
  r: TRect;
  p: TPoint;
  zone: tcHotSpot;
begin
  zone := hsClientZone;
  if (fShowStatusFPS or fShowStatusFPF or fShowStatusStyle) and HasParent then
  begin
    // TDPoint MousePoint - are the pixel coordinates of the mouse pointer within
    // the client area of the control.
    p := ScreenToClient(MousePoint);
    // Calculate the height of a status line
    Canvas.Font.Assign(Font);
    h := Canvas.TextHeight('0');
    // LOCATE FPF
    if fShowStatusFPF then
    begin
      r := ClientRect;
      w := Canvas.TextWidth(fTC.GetStatusFPF(APerforation: tcPerforation));
      r.Bottom := r.Bottom - Margins.Bottom;
      r.Top := r.Bottom - h;
      r.Left := r.Left + Margins.Left;
      r.Right := r.Left + w;
      if System.Types.PtInRect(r,p) then
        zone := hsStatusFPF;
    end;
    // LOCATE FPS
    if fShowStatusFPS then
    begin
      r := ClientRect;
      w := Canvas.TextWidth(fTC.GetStatusFPS(ATimecodeStyle: tcStyle));
      r.Bottom := r.Bottom - Margins.Bottom;
      r.Top := r.Bottom - h;
      r.Right := ClientRect.Right - Margins.Right;
      r.Left := r.Right - w;
      if System.Types.PtInRect(r,p) then
        zone := hsStatusFPS;
    end;
    // LOCATE STYLE
    if fShowStatusStyle then
    begin
      r := ClientRect;
      w := Canvas.TextWidth(fTC.GetTimecodeStyle(ATimecodeStyle: tcStyle));
      r.Top := r.Top + Margins.Top;
      r.Bottom := r.Top + h;
      r.Right := ClientRect.Right - Margins.Right;
      r.Left := r.Right - w;
      if System.Types.PtInRect(r,p) then
        zone := hsStatusStyle;
    end;
  end;
  Result := zone;
end;


function TTCEdit.GetPerforation: tcPerforation;
begin

end;

function TTCEdit.GetStandard: tcStandard;
begin

end;

function TTCEdit.GetStyle: tcStyle;
begin

end;

function TTCEdit.GetText: String;
begin

end;

function TTCEdit.GetUseDropFrame: boolean;
begin

end;

procedure TTCEdit.KeyUp(Key: Word; Shift: TShiftState);
begin

end;

procedure TTCEdit.Paint;
begin

end;

procedure TTCEdit.SetAlignment(Value: TAlignment);
begin

end;

procedure TTCEdit.SetAutoScale(Value: boolean);
begin

end;

procedure TTCEdit.SetAutoScaleMaxFontSize(Value: integer);
begin

end;

procedure TTCEdit.SetFocus;
begin

end;

procedure TTCEdit.SetFrames(Value: double);
begin

end;

procedure TTCEdit.SetOperation(Value: tcOperation);
begin

end;

procedure TTCEdit.SetPerforation(Value: tcPerforation);
begin

end;

procedure TTCEdit.SetShowOperation(Value: boolean);
begin

end;

procedure TTCEdit.SetShowRawText(Value: boolean);
begin

end;

procedure TTCEdit.SetShowStatusFPF(Value: boolean);
begin

end;

procedure TTCEdit.SetShowStatusFPS(Value: boolean);
begin

end;

procedure TTCEdit.SetShowStatusStyle(Value: boolean);
begin

end;

procedure TTCEdit.SetStandard(Value: tcStandard);
begin

end;

procedure TTCEdit.SetStyle(Value: tcStyle);
begin

end;

procedure TTCEdit.SetText(Value: string);
begin

end;

procedure TTCEdit.SetTransparent(Value: boolean);
begin
	if (fTransparent <> Value) then begin
		fTransparent := Value;
		Invalidate;
	end;
end;

procedure TTCEdit.SetUseDropFrame(Value: boolean);
begin

end;

function TTCEdit.StripOutNonNumerical(TCText: string): String;
begin

end;

procedure TTCEdit.ToggleFPF(AForward: boolean);
begin

end;

procedure TTCEdit.ToggleFPS(AForward: boolean);
begin

end;

procedure TTCEdit.ToggleStyle(AForward: boolean);
begin

end;

procedure TTCEdit.UpdateAutoScaleFontSize;
begin

end;

procedure TTCEdit.WMKillFocus(var Message: TMessage);
begin

end;

end.
