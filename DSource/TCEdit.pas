unit TCEdit;

interface

uses
  System.SysUtils, System.Classes, System.Types, System.UITypes,
  Vcl.Controls, Vcl.Forms, Vcl.StdCtrls, Vcl.Graphics, Vcl.Clipbrd,
  Winapi.Messages, Timecode, TimecodeHelper;

type

  TTCEdit = class(TCustomControl)

  type
    tcHotSpot = (hsStatusFPS, hsStatusFPF, hsStatusStyle, hsClientZone);

  private
    { Private declarations }
    fLineLead: integer;

    procedure SetAutoScaleMaxFontSize(Value: integer);
    procedure SetShowRawText(Value: boolean);
    procedure SetShowStatusFPS(Value: boolean);
    procedure SetShowStatusFPF(Value: boolean);
    procedure SetShowStatusStyle(Value: boolean);
    function GetHotSpot(MousePoint: TPoint): tcHotSpot;
    procedure SetOperation(Value: tcOperation);
    procedure SetShowOperation(Value: boolean);
    procedure SetAutoScale(Value: boolean);
    procedure UpdateAutoScaleFontSize();
    function GetUseDropFrame(): boolean;
    procedure SetUseDropFrame(Value: boolean);
    procedure SetFrames(Value: double);
    function GetFrames(): double;

  protected
    { Protected declarations }
    fTC: TTimecode; // RECORD
    fTCFont: TFont; // CLASS

    fOperation: tcOperation;
    fPerforation: tcPerforation;
    fTimecodeStyle: tcStyle;
    fStandard: tcStandard;

    fShowOperation: boolean;
    fShowStatusFPS: boolean;
    fShowStatusFPF: boolean;
    fShowStatusStyle: boolean;
    fShowFocused: boolean;
    fTransparent: boolean;
    fAutoScale: boolean;
    fAutoScaleMaxFontSize: integer;
    fRawText: String;
    fShowRawText: boolean;
    fEditing: boolean;
    fModified: boolean;

    FAlignment: TAlignment;
    FOnChange: TNotifyEvent;
    procedure Paint(); reintroduce; virtual;
    function StripOutNonNumerical(TCText: string): String;
    function GetText(): String;
    procedure SetText(Value: string);
    procedure KeyUp(Key: Word; Shift: TShiftState); reintroduce; DYNAMIC;
    procedure Click(); reintroduce; DYNAMIC;
    procedure AdjustSize(); reintroduce; DYNAMIC;
    function CanResize(var NewWidth: integer; var NewHeight: integer): boolean;
      reintroduce; virtual;
    procedure Changed(); virtual;

    // set transparency parameters
    procedure CreateParams(var Params: TCreateParams); reintroduce; virtual;
    // Paints the parent under this control - use for transparency...
    procedure DrawParentImage(AControl: TControl; Dest: TCanvas);
    procedure SetTransparent(Value: boolean);
    procedure SetAlignment(Value: TAlignment);
    procedure WMKillFocus(var Message: TMessage);

  public
    { Public declarations }
    procedure ClipboardPaste(Sender: TObject);
    procedure ClipboardCopy(Sender: TObject);
    procedure ToggleStyle(AForward: boolean);
    procedure ToggleFPS(AForward: boolean);
    procedure ToggleFPF(AForward: boolean);
    procedure ForceUpdate();
    procedure SetFocus(); reintroduce; virtual;

    constructor Create(AOwner: TComponent); override;
    destructor Destroy(); override;

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
    property TC_Style: tcStyle read fTimecodeStyle write fTimecodeStyle
      default tcTimecodeStyle;
    property TC_Standard: tcStandard read fStandard write fStandard
      default tcPAL;
    property Perforation: tcPerforation read fPerforation write fPerforation
      default mm35_3perf;
    property MathOperation: tcOperation read fOperation write SetOperation
      default tcNone;
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
  Winapi.Windows; // for HDC

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
  UpdateAutoScaleFontSize;
  result := True;
end;

procedure TTCEdit.Changed;
begin
  inherited Changed();
  if Assigned(FOnChange) then
    FOnChange(self);
end;

procedure TTCEdit.Click;
var
  hs: tcHotSpot;
  GoForwards: boolean;
begin
  // the Ctrl Key is pressed.
  if (GetKeyState(VK_CONTROL) < 0) then
    GoForwards := True
  else
    GoForwards := False;
  hs := GetHotSpot(Mouse.CursorPos);
  case hs of
    hsStatusFPS:
      fTC.IterStandard(fStandard, GoForwards);
    hsStatusFPF:
      fTC.IterPerforation(fPerforation, GoForwards);
    hsStatusStyle:
      begin
        fEditing := False;
        fTC.IterTimecodeStyle(fTimecodeStyle, GoForwards);
      end;
    hsClientZone:
      ;
    // default;
  end;

  if (hs = hsStatusFPF) or (hs = hsStatusFPS) then
    Invalidate();
  if (hs = hsStatusStyle) then
  begin
    AdjustSize();
    Invalidate();
  end;
  if (CanFocus()) then
    SetFocus();

  (*
    int nVirtKey; // virtual-key code
    eHotSpot hs;
    bool Forwards;
    nVirtKey = GetKeyState(VK_CONTROL);
    /*
    If the high-order bit is 1, the key is down; otherwise, it is up.
    If the low-order bit is 1, the key is toggled. A key, such as the
    CAPS LOCK key, is toggled if it is turned on. The key is off and
    untoggled if the low-order bit is 0. A toggle key's indicator light
    (if any) on the keyboard will be on when the key is toggled, and off
    when the key is untoggled.
    */
    // True idicates the Ctrl Key is pressed... need to 'not'
    Forwards = !((nVirtKey & 0x80) ? true : false);
    hs = GetHotSpot(Mouse->CursorPos);
    switch (hs) {
    case hsStatusFPS:
    fTC->ToggleFPS(Forwards);
    break;
    case hsStatusFPF:
    fTC->ToggleFPF(Forwards);
    break;
    case hsStatusStyle:
    fEditing = false;
    fTC->ToggleStyle(Forwards);
    break;
    case hsClientZone:
    default: ;
    }
    if (hs == hsStatusFPF || hs == hsStatusFPS) {
    Invalidate();
    }
    if (hs == hsStatusStyle) {
    AdjustSize();
    Invalidate();
    }
    if (CanFocus())
    SetFocus();

  *)
end;

procedure TTCEdit.ClipboardCopy(Sender: TObject);
begin
  // Copy the timecode text onto the clipboard
  // send to clipboard  Open() and Close() allow us to put multi-items
  // into the clipboard.
  Clipboard.Open;
  Clipboard.AsText := fTC.GetText(tcTimecodeStyle);
  // For VCL Components ... TTtimecode isn't a component, it's RECORD.
  // Component passed to Clipboard is dependant on fUseInputStr.
  // Clipboard.SetComponent(TComponent(fTC));
  Clipboard.Close;
end;

procedure TTCEdit.ClipboardPaste(Sender: TObject);
var
  DoCleanUp: boolean;
  comp: TComponent;
begin
  DoCleanUp := False;
  // Before a class is read from the clipboard, it must be registered by a
  // call to RegisterClasses. If you try to read an unregistered class,
  // you'll get an EClassNotFound exception.
  if (Clipboard.HasFormat(CF_COMPONENT)) then
  begin
    try
      begin
        // Reminder that the TTimecode stream must be registered.
        // Classes::RegisterClasses(&(__classid(TTimecode)), 0);
        // else an exception error occurs
        // registration was done in creation routine.
        comp := Clipboard.GetComponent(self, self);
        if Assigned(comp) and comp.ClassNameIs('TTimecode') then
        begin
          // fTC.Assign(TTimecode(comp));
          DoCleanUp := True;
        end;
        // As we have become the new owner of thie component
        // we'll clean it up here.
        comp.Free;
      end;
    except
      on E: Exception do;
    end;
  end;

  if Clipboard.HasFormat(CF_TEXT) and (not Clipboard.AsText.IsEmpty) then
  begin
    // paste text into the caclulator. Text must be SMPTE string
    fTimecodeStyle := tcTimecodeStyle;
    // fText := Clipboard.AsText;
    DoCleanUp := True;
  end;

  if (DoCleanUp) then
  begin
    fRawText := fTC.GetRawText(fTC.GetText(fTimecodeStyle));
    Invalidate;
    Changed;
  end;
end;

constructor TTCEdit.Create(AOwner: TComponent);
begin
  inherited;

  // fTC is a RECORD - create isn't required

  fOperation := tcNone;
  fPerforation := mm35_4perf;
  fTimecodeStyle := tcTimecodeStyle;
  fStandard := tcFILM;

  // This is required to ensure that TTimecode is registered for streaming.
  // If not set, then the Clipboard() will show the exception error
  // EClassNotFound.
  // Doesn't pertain to RECORD? ...
  // Classes::RegisterClasses(&(__classid(TTimecode)), 0);

  fLineLead := 4;
  FOnChange := nil;
  AutoSize := False;
  fAutoScale := True;
  fAutoScaleMaxFontSize := 64;
  fShowStatusFPS := True;
  fShowStatusFPF := True;
  fShowStatusStyle := True;
  // user option to force display of raw keyboard input
  fShowRawText := False;
  fShowOperation := False;
  fTC.UseDropFrame := True;
  fRawText := '';
  Width := 241;
  Height := 65;

  fTCFont := TFont.Create();
  fTCFont.Assign(Font);
  fTCFont.Name := 'Courier New';
  fTCFont.Style := fTCFont.Style + [fsBold];
  fTCFont.Size := fAutoScaleMaxFontSize;

  fTransparent := False;
  Caption := '00:00:00:00';
  Text := '00:00:00:00';
  FAlignment := taCenter;
  fModified := False;
  fShowFocused := False;
  fEditing := False;
end;

procedure TTCEdit.CreateParams(var Params: TCreateParams);
begin
	inherited CreateParams(Params);
	if (fTransparent) then
  begin
		Params.ExStyle := Params.ExStyle or WS_EX_TRANSPARENT;
		ControlStyle := ControlStyle - [csOpaque];
		ControlStyle := ControlStyle + [csAcceptsControls];
	end
end;

destructor TTCEdit.Destroy;
begin
  FreeAndNil(fTCFont);
  inherited;
end;

procedure TTCEdit.DrawParentImage(AControl: TControl; Dest: TCanvas);
var
  SaveIndex: integer;
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
	AdjustSize;
end;

function TTCEdit.GetFrames: double;
begin
  result := fTC.Frames;
end;

function TTCEdit.GetHotSpot(MousePoint: TPoint): tcHotSpot;
var
  w, h: integer;
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
      w := Canvas.TextWidth(fTC.GetTextPerforation(fPerforation));
      r.Bottom := r.Bottom - Margins.Bottom;
      r.Top := r.Bottom - h;
      r.Left := r.Left + Margins.Left;
      r.Right := r.Left + w;
      if System.Types.PtInRect(r, p) then
        zone := hsStatusFPF;
    end;
    // LOCATE FPS
    if fShowStatusFPS then
    begin
      r := ClientRect;
      w := Canvas.TextWidth(fTC.GetTextFPS());
      r.Bottom := r.Bottom - Margins.Bottom;
      r.Top := r.Bottom - h;
      r.Right := ClientRect.Right - Margins.Right;
      r.Left := r.Right - w;
      if System.Types.PtInRect(r, p) then
        zone := hsStatusFPS;
    end;
    // LOCATE STYLE
    if fShowStatusStyle then
    begin
      r := ClientRect;
      w := Canvas.TextWidth(fTC.GetTextTimecodeStyle(fTimecodeStyle));
      r.Top := r.Top + Margins.Top;
      r.Bottom := r.Top + h;
      r.Right := ClientRect.Right - Margins.Right;
      r.Left := r.Right - w;
      if System.Types.PtInRect(r, p) then
        zone := hsStatusStyle;
    end;
  end;
  result := zone;
end;

function TTCEdit.GetText: String;
var
x,y: integer;
raw,s : string;
begin
	if (fTimecodeStyle = tcTimecodeStyle) and (fStandard =
		tcNTSCDF) and  fTC.UseDropFrame then begin
		// always show fully converted text
		result := fTC.GetText(fTimecodeStyle);
	end
	else if (fTimecodeStyle = tcTimecodeStyle) and (fShowRawText or fEditing) then begin
		// don't do full syntax checking - just display input string.
		// remove all non-numerical characters - working backwards....
		s := '00000000';
		if (fStandard = tcNTSCDF) then
			raw := '00;00;00;00'
		else
			raw := '00:00:00:00';

    s := fTC.GetRawText(fRawText);
    // Pad with LEADING '0' - if undersized
    while Length(s) < 8 do
      s := '0' + s;

    (*
      for (x = fRawText.Length(), y = 8; x > 0 && y > 0; x--, y--) {
      while (x && (fRawText[x] < '0' || fRawText[x] > '9'))
      x--;
      if (x)
      s[y] = fRawText[x];
      }
    *)

		// sloppy - but safe way of preparing
		raw[1] := s[1]; // the string for diplay...
		raw[2] := s[2]; //
		raw[4] := s[3];
		raw[5] := s[4];
		raw[7] := s[5];
		raw[8] := s[6];
		raw[10] := s[7];
		raw[11] := s[8];

		result := raw;
	end
	else
		result := fTC.GetText(fTimecodeStyle);
end;

function TTCEdit.GetUseDropFrame: boolean;
begin
  result := fTC.UseDropFrame;
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
var
  s: string;
begin
  fTC.Frames := Value;
  s := fTC.GetText(fTimecodeStyle);
  SetText(s);
end;

procedure TTCEdit.SetOperation(Value: tcOperation);
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

procedure TTCEdit.SetText(Value: string);
begin

end;

procedure TTCEdit.SetTransparent(Value: boolean);
begin
  if (fTransparent <> Value) then
  begin
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
