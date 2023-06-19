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
    {
      tcvFPS - '%gfps'
      tcvFPF - eg. '35mm 4-perf'
      tcvStanadrd - 'FILM', 'PAL', etc...
      tcvOperation - eg. '*','+', etc...
    }
    tcVisible = (tcvFPS, tcvFPF, tcvStandard, tcvOperation);

    {TODO -oBSA -cGeneral : Intro set of visible elements in TTCEdit;}
    TC_Visible = set of tcVisible;

  private
    { Private declarations }
    fLineLead: integer;

    procedure SetAutoScaleMaxFontSize(Value: integer);
    function GetHotSpot(MousePoint: TPoint): tcHotSpot;
    procedure SetOperation(Value: tcOperation);
    procedure SetAutoScale(Value: boolean);
    procedure UpdateAutoScaleFontSize();
    function GetUseDropFrame(): boolean;
    procedure SetUseDropFrame(Value: boolean);
    procedure SetFrames(Value: double);
    function GetFrames(): double;
    procedure SetShowRawText(Value: boolean);


    procedure ShowStatusFPS(Value: boolean);
    procedure ShowStatusFPF(Value: boolean);
    procedure ShowStatusStandard(Value: boolean);
    procedure ShowOperation(Value: boolean);

  protected
    { Protected declarations }
    fTC: TTimecode; // RECORD AUTO-MANAGED
    fTCFont: TFont; // CLASS CREATE..DESTROY
    fTCText: string;
    fTCRawText: String;

    fOperation: tcOperation;
    fPerforation: tcPerforation;
    fTimecodeStyle: tcDisplayMode;
    fStandard: tcStandard;

    // move to set of visible TC status elements.
    fVisibleFPS: boolean;
    fVisibleFPF: boolean;
    fVisibleStandard: boolean;
    fVisibleOperation: boolean;

    fShowFocused: boolean;
    fShowRawText: boolean;
    fTransparent: boolean;
    fAutoScale: boolean;
    fAutoScaleMaxFontSize: integer;
    fEditing: boolean;
    fModified: boolean;

    FAlignment: TAlignment;
    { TODO -oBSA -cGeneral : code OnChange event }
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

    procedure WMKillFocus(var Message: TMessage); message WM_KILLFOCUS;

  public

    { Public declarations }
    procedure ClipboardPaste(Sender: TObject);
    procedure ClipboardCopy(Sender: TObject);
    procedure ToggleDisplayMode(DoForward: boolean);
    procedure ToggleFPS(DoForward: boolean);
    procedure ToggleFPF(DoForward: boolean);
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

    // O N C H A N G E    E V E N T  .
    property OnChange: TNotifyEvent read FOnChange write FOnChange;

    property Text: String read GetText write SetText;
    property AutoSizeMaxFontSize: integer read fAutoScaleMaxFontSize
      write SetAutoScaleMaxFontSize default 64;
    property VisibleFPS: boolean read fVisibleFPS write ShowStatusFPS
      default True;
    property VisibleFPF: boolean read fVisibleFPF write ShowStatusFPF
      default True;
    property VisisbleStandard: boolean read fVisibleStandard
      write ShowStatusStandard default True;

    property MathOperation: tcOperation read fOperation write SetOperation
      default tcNone;
    property VisibleOperation: boolean read fVisibleOperation write ShowOperation
      default False;
    property AutoScale: boolean read fAutoScale write SetAutoScale default True;
    property Transparent: boolean read fTransparent write SetTransparent
      default False;

    property TC_Font: TFont read fTCFont write fTCFont;
    property TC_Style: tcDisplayMode read fTimecodeStyle write fTimecodeStyle
      default tcTimecode;
    property TC_Standard: tcStandard read fStandard write fStandard
      default tcPAL;
    property TC_Perforation: tcPerforation read fPerforation write fPerforation
      default mm35_3perf;
    property TC_UseDropFrame: boolean read GetUseDropFrame write SetUseDropFrame
      default True;

    // TCEdit is a text orientated component... it was never intended to have
    // metamorfic dualality for both string and timecode.
    property TC_Frames: double read GetFrames write SetFrames;

    property Modified: boolean read fModified write fModified default False;
    property ShowFocused: boolean read fShowFocused write fShowFocused
      default False;
    property ShowRawText: boolean read fShowRawText write SetShowRawText
      default True;

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
        fTC.IterDisplayMode(tcTimecode, GoForwards);
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

end;

procedure TTCEdit.ClipboardCopy(Sender: TObject);
begin
  // Copy the timecode text onto the clipboard
  // send to clipboard  Open() and Close() allow us to put multi-items
  // into the clipboard.
  Clipboard.Open;
  Clipboard.AsText := fTC.GetText(tcTimecode);
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
    fTimecodeStyle := tcTimecode;
    // fText := Clipboard.AsText;
    DoCleanUp := True;
  end;

  if (DoCleanUp) then
  begin
    fTCRawText := fTC.GetRawText(fTC.GetText(fTimecodeStyle));
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
  fTimecodeStyle := tcTimecode;
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
  fVisibleFPS := True;
  fVisibleFPF := True;
  fVisibleStandard := True;
  // user option to force display of raw keyboard input
  fShowRawText := False;
  fVisibleOperation := False;
  fTC.UseDropFrame := True;
  fTCRawText := '';
  fTCText := '00:00:00:00';
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
  if (fVisibleFPS or fVisibleFPF or fVisibleStandard) and HasParent then
  begin
    // TDPoint MousePoint - are the pixel coordinates of the mouse pointer within
    // the client area of the control.
    p := ScreenToClient(MousePoint);
    // Calculate the height of a status line
    Canvas.Font.Assign(Font);
    h := Canvas.TextHeight('0');
    // LOCATE FPF
    if fVisibleFPF then
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
    if fVisibleFPS then
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
    if fVisibleStandard then
    begin
      r := ClientRect;
      w := Canvas.TextWidth(fTC.GetTextDisplayMode(fTimecodeStyle));
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
//x,y: integer;
raw,s : string;
begin
	if (fTimecodeStyle = tcTimecode) and (fStandard =
		tcNTSCDF) and  fTC.UseDropFrame then begin
		// always show fully converted text
		result := fTC.GetText(fTimecodeStyle);
	end
	else if (fTimecodeStyle = tcTimecode) and (fShowRawText or fEditing) then begin
		// don't do full syntax checking - just display input string.
		// remove all non-numerical characters - working backwards....
		s := '00000000';
		if (fStandard = tcNTSCDF) then
			raw := '00;00;00;00'
		else
			raw := '00:00:00:00';

    s := fTC.GetRawText(fTCRawText);
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
  // NOTE : 'c' and VK_NUMPAD3: are duplicate cases in a switch...
  // COPY TEXT and TC to CLIPBOARD
  if ((Key = Ord('C')) or (Key = Ord('c'))) and (ssCtrl in Shift) then
  begin
    fEditing := True;
    ClipboardCopy(self);
  end
  // PASTE TC or TEXT to APPLICATION
  else if ((Key = Ord('V')) or (Key = Ord('v'))) and (ssCtrl in Shift) then
  begin
    fEditing := True;
    ClipboardPaste(self);
  end
  // All other keys are handled by the base routine.
  // All other keys are handled by the base routine.
  else
  begin
    case Key of
      VK_DECIMAL, VK_OEM_PERIOD, Ord('0') .. Ord('9'), VK_NUMPAD0 .. VK_NUMPAD9:
        begin
          fEditing := True;
          // The period key funcions as '00' when in timecode style.
          if (Key = VK_OEM_PERIOD) or (Key = Ord('.')) or (Key = VK_DECIMAL)
          then
          begin
            // the period key is ignore when using frames or footage
            if fTimecodeStyle = tcTimecode then
              fTCRawText := fTCRawText + '00'
            else if fTimecodeStyle = tcFootage then
            begin
              // input is toggles between footage and frames...
              { TODO : Write routine to allow for VK_OEM_PERIOD when in TTimecode.eStyle:tcStyle }
            end;
          end
          else if Key > Ord('9') then
            fTCRawText := fTCRawText + Chr(Key - $30)
          else
            fTCRawText := fTCRawText + Chr(Key);
          fTCText := fTCRawText;
          fModified := True;
          Invalidate;
          Changed;
        end;
      VK_BACK:
        begin
          fEditing := True;
          Delete(fTCRawText, Length(fTCRawText), 1);
          fTCText := fTCRawText;
          fModified := True;
          Invalidate;
          Changed;
        end;
      VK_CLEAR, VK_ESCAPE:
        begin
          fEditing := True;
          fTC.Frames := 0;
          fTCRawText := '';
          fModified := True;
          Invalidate;
          Changed;
        end;
    end;
  end;

end;

procedure TTCEdit.Paint;
var
  padTop, padLeft, txtHeight, txtWidth, w: Integer;
  fLine1h, fLine3h, fLine2w, fLine2h: Integer;
  s: String;
begin
  if fTransparent then
    DrawParentImage(Self, Canvas);
  // fShowRawText - user has forced display of raw text
  // FEditing - user is entering keyboard data and has entered edit mode
  if fEditing or fShowRawText then
    s := GetText
  else
    s := fTC.GetText(fTimecodeStyle);
  if fVisibleOperation then
    s := String(fTC.GetTextOperation(fOperation)) + s;
  // calculate the heights for status lines 1 and 3.
  Canvas.Font.Assign(Font);
  // Units subtracted to keep display 'tight'
  fLine1h := (Canvas.TextHeight(s) - fLineLead);
  fLine3h := fLine1h;
  // Calculate the actual display co-ordinates (minus margins) ...
  w := ClientRect.Width - (Margins.Left + Margins.Right);
  padTop := 0;
  padLeft := padTop;
  txtWidth := 0;
  txtHeight := 0;
  // DISPLAY TIMECODE ...
  if not s.IsEmpty then
  begin
    if fAutoScale and (fTCFont.Size <> 0) then
      Canvas.Font.Assign(fTCFont)
    else
      Canvas.Font.Assign(Font);
    // if canvas font is so small - it's unreadable - don't paint...
    if -(Canvas.Font.Height) >= 1 then
    begin
      // Calculate height and width parameters for paint().
      fLine2w := Canvas.TextWidth(s);
      Canvas.Brush.Style := bsClear;
      Canvas.Pen.Style := psSolid;
      if AutoScale then
      begin
        // (Alignment: taRightJustify)
        if (fTimecodeStyle = tcFrames) or (fTimecodeStyle = tcFootage) then
          padLeft := ClientRect.Left + (w - fLine2w)
        // (Alignment: taCenter)
        else
          padLeft := ClientRect.Left + ((w - fLine2w) div 2);
      end
      else
      begin
        if Alignment = taLeftJustify then
          padLeft := ClientRect.Left + Margins.Left
        else if Alignment = taRightJustify then
          padLeft := ClientRect.Left + (w - fLine2w)
        // (Alignment: taCenter)
        else
          padLeft := ClientRect.Left + ((w - fLine2w) div 2);
      end;
      padTop := ClientRect.Top + Margins.Top;
      if fVisibleStandard then
        Inc(padTop, fLine1h);
      Canvas.TextOut(padLeft, padTop, s);

      // ISFOCUSED?? draw a line under the text
      fLine2h := Canvas.TextHeight(s);
      Canvas.Brush.Style := bsClear;
      Canvas.Pen.Style := psSolid;
      Canvas.Pen.Width := 1;
      if Focused and ShowFocused then
        Canvas.Pen.Color := clRed
      else
        Canvas.Pen.Color := Color;
      // Subtract # pixel to raise the 'focused' line into the text ascending seriff zone.
      // Makes for a better display when using only numbers.
      Canvas.MoveTo(padLeft, padTop + fLine2h - 2);
      Canvas.LineTo(padLeft + fLine2w, padTop + fLine2h - 2);
    end;
  end;
  // -----------------------------------
  Canvas.Font.Assign(Font);
  // DISPLAY STATUS FPS displayed bottom.right.
  if fVisibleFPS then
  begin
    s := fTC.GetTextFPS;
    txtWidth := Canvas.TextWidth(s);
    padLeft := ClientRect.Right - Margins.Right - txtWidth;
    padTop := ClientRect.Bottom - Margins.Bottom - fLine3h - fLineLead;
    Canvas.TextOut(padLeft, padTop, s);
  end;
  // DISPLAY STATUS FPF displayed bottom.left.
  if fVisibleFPF then
  begin
    s := fTC.GetTextPerforation(fPerforation);
    padLeft := ClientRect.Left + Margins.Left;
    padTop := ClientRect.Bottom - Margins.Bottom - fLine3h - fLineLead;
    Canvas.TextOut(padLeft, padTop, s);
  end;
  // DISPLAY STATUS STYLE top.right.
  if fVisibleStandard then
  begin
    s := fTC.GetTextDisplayMode(fTimecodeStyle);
    txtWidth := Canvas.TextWidth(s);
    padLeft := ClientRect.Right - Margins.Right - txtWidth;
    padTop := ClientRect.Top + Margins.Top;
    Canvas.TextOut(padLeft, padTop, s);
  end;
  if BorderWidth > 0 then
  begin
    Canvas.Brush.Style := bsSolid;
    Canvas.Pen.Style := psClear;
    if Focused and ShowFocused then
      Canvas.Brush.Color := clHighlight
    else
      Canvas.Brush.Color := clBackground;
    // Note : 1xpixel frame width.
    Canvas.FrameRect(ClientRect);
  end;
end;

procedure TTCEdit.SetAlignment(Value: TAlignment);
begin
	if (FAlignment <> Value) then begin
		FAlignment := Value;
		Invalidate;
	end;
end;

procedure TTCEdit.SetAutoScale(Value: boolean);
begin
	if (fAutoScale <> Value) then begin
		fAutoScale := Value;
		Invalidate;
	end
end;

procedure TTCEdit.SetAutoScaleMaxFontSize(Value: integer);
begin
	if (fAutoScaleMaxFontSize <> Value) then begin
		fAutoScaleMaxFontSize := Value;
		if (fTCFont.Size > fAutoScaleMaxFontSize) then begin
			AdjustSize;
			Invalidate;
		end;
	end;
end;

procedure TTCEdit.SetFocus;
begin
	inherited SetFocus;
	Invalidate;
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
	if (fOperation <> Value) then begin
		fOperation := Value;
		Invalidate;
	end;
end;

procedure TTCEdit.ShowOperation(Value: boolean);
begin
	if (fVisibleOperation <> Value) then begin
		fVisibleOperation := Value;
		AdjustSize;
		Invalidate;
	end;
end;

procedure TTCEdit.SetShowRawText(Value: boolean);
begin
// user option to display raw keyboard input
	if (fShowRawText <> Value) then begin
		fShowRawText := Value;
		Invalidate;
	end;
end;

procedure TTCEdit.ShowStatusFPF(Value: boolean);
begin
	if (fVisibleFPF <> Value) then begin
		fVisibleFPF := Value;
		AdjustSize;
		Invalidate;
	end;
end;

procedure TTCEdit.ShowStatusFPS(Value: boolean);
begin
	if (fVisibleFPS <> Value) then begin
		fVisibleFPS := Value;
		AdjustSize;
		Invalidate;
	end;
end;

procedure TTCEdit.ShowStatusStandard(Value: boolean);
begin
	if (fVisibleStandard <> Value) then begin
		fVisibleStandard := Value;
		AdjustSize;
		Invalidate;
	end;
end;

procedure TTCEdit.SetText(Value: string);
begin
	if (fTCText <> Value) then begin
		fTCText := Value;
		fTCRawText := Value;
		// Indicates whether the user edited the text of the edit control.
		// Use Modified to determine whether the user changed the Text property
		// of the edit control. Modified is only reset to False when you assign
		// a value to the Text property. In particular, it is not reset when
		// the control receives focus.
		fModified := false;
		Invalidate;
		Changed;
	end;
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
	if (fTC.UseDropFrame <> Value) then begin
		fTC.UseDropFrame := Value;
		Invalidate;
	end;
end;

function TTCEdit.StripOutNonNumerical(TCText: string): String;
begin
	// Strip out any formatting, leaving only numbers.
  result := fTC.GetRawText(TCText)
end;

procedure TTCEdit.ToggleFPF(DoForward: boolean);
begin
	fTC.IterPerforation(fPerforation, DoForward);
	Invalidate;
end;

procedure TTCEdit.ToggleFPS(DoForward: boolean);
begin
	fTC.IterStandard(fStandard, DoForward);
	Invalidate;
end;

procedure TTCEdit.ToggleDisplayMode(DoForward: boolean);
begin
	fTC.IterDisplayMode(tcTimecode, DoForward);
	Invalidate;
end;

procedure TTCEdit.UpdateAutoScaleFontSize;
var
  fLine1h, fLine3h: Integer;
  s: String;
  h2, w, h: Integer;
begin
  if HasParent then
  begin
    s := fTCText;
    if fVisibleOperation then
      s := String(fTC.GetTextOperation(fOperation)) + s;
    // calculate the heights for status lines 1 and 3.
    Canvas.Font.Assign(Font);
    // Units subtracted to keep display 'tight'
    fLine1h := (Canvas.TextHeight(s) - fLineLead);
    fLine3h := fLine1h;
    // get the actual available height for line 2
    h2 := ClientRect.Height - Margins.Top - Margins.Bottom;
    if fVisibleFPS or fVisibleFPF then
      Dec(h2, fLine3h);
    if fVisibleStandard then
      Dec(h2, fLine1h);
    // make line 2 fit.
    Canvas.Font.Assign(fTCFont);
    Canvas.Font.Size := fAutoScaleMaxFontSize;
    w := Canvas.TextWidth(s);
    h := Canvas.TextHeight(s);
    if (w > ClientWidth) or (h > h2) then
    begin
      // reduce the font size to fit the width
      repeat
        Canvas.Font.Size := Canvas.Font.Size - 1;
        w := Canvas.TextWidth(s);
        h := Canvas.TextHeight(s);
      until ((w <= ClientWidth) and (h <= h2)) or (Canvas.Font.Size <= 0);
    end;
    // if the results are null - restore to default.
    if Canvas.Font.Size <> 0 then
      fTCFont.Size := Canvas.Font.Size;
  end;
end;


procedure TTCEdit.WMKillFocus(var Message: TMessage);
begin

end;

end.
