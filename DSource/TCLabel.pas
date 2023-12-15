unit TCLabel;

interface

uses
  System.SysUtils, System.Classes, Vcl.Controls, Vcl.StdCtrls,
  Vcl.Graphics,
  Timecode, TimecodeHelper;

type
  TTCLabel = class(TCustomLabel)
  private
    { Private declarations }
    fTC: TTimecode; // RECORD AUTO-MANAGED
    fTCFont: TFont; // CLASS CREATE..DESTROY
    fTCText: string;
    fTCRawText: String;

    fOperation: tcOperation;
    fPerforation: tcPerforation;
    fDisplayMode: tcDisplayMode;
    fStandard: tcStandard;

    fShowStatus: boolean;
    fAutoScaleMaxFontSize: integer;
    fShowRawText: boolean;
    fShowOperation: boolean;
    fAutoScale: boolean;
    fLineLead: integer;

    function GetText(): string;
    procedure SetText(Value: string);
    function GetTC(): TTimecode;
    function GetDisplayMode(): tcDisplayMode;
    procedure SetDisplayMode(Value: tcDisplayMode);
    procedure SetAutoScaleMaxFontSize(Value: integer);
    procedure SetShowStatus(Value: boolean);
    procedure SetShowOperation(Value: boolean);
    function GetStandard(): tcStandard;
    procedure SetStandard(Value: tcStandard);
    procedure SetShowRawText(Value: boolean);
    function GetPerforation(): tcPerforation;
    procedure SetPerforation(Value: tcPerforation);
    function GetUseDropFrame(): boolean;
    procedure SetUseDropFrame(Value: boolean);
    procedure UpdateAutoScaleFontSize(AString: string);
    procedure SetOperation(Value: tcOperation);
    procedure SetAutoScale(Value: boolean);

  protected
    { Protected declarations }
    procedure Paint(); reintroduce; virtual;
    procedure AdjustSize(); reintroduce; DYNAMIC;
    procedure Resize(); reintroduce; DYNAMIC;
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
    destructor Destroy(); override;

    property TC: TTimecode read fTC;

  published
    { Published declarations }
    property Alignment default taCenter;
    property FocusControl;
    property ShowAccelChar;
    property Transparent;
    property Font;
    property Visible;
    property Enabled;
    property Width default 145;
    property Height default 33;
    property Color;

    property AutoSizeMaxFontSize: integer read fAutoScaleMaxFontSize
      write SetAutoScaleMaxFontSize default 32;
    property ShowStatus: boolean read fShowStatus write SetShowStatus
      default true;
    property ShowOperation: boolean read fShowOperation write SetShowOperation
      default true;
    property ShowRawText: boolean read fShowRawText write SetShowRawText
      default false;
    property AutoScale: boolean read fAutoScale write SetAutoScale default true;
    property Caption: string read GetText write SetText;
    property DisplayMode: tcDisplayMode read GetDisplayMode write SetDisplayMode
      default tcTimecode;
    property Standard: tcStandard read GetStandard write SetStandard
      default tcPAL;
    property FPFIndex: tcPerforation read GetPerforation write SetPerforation default mm35_4perf;
    property UseDropFrame: boolean read GetUseDropFrame write SetUseDropFrame
      default true;
    property TCFont: TFont read fTCFont write fTCFont;
    property Operation: tcOperation read fOperation write SetOperation;
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('Artanemus', [TTCLabel]);
end;

{ TTCLabel }

procedure TTCLabel.AdjustSize;
begin
	inherited AdjustSize;
	if (HasParent()) then
		UpdateAutoScaleFontSize(fTCText);
end;

constructor TTCLabel.Create(AOwner: TComponent);
begin
  inherited;

  // fTC = new TTimecode(this);  -- RECORD
  // T T I M E C O D E  I N I T -----------------
  fTC.UseDropFrame := true;
  // --------------------------------------------

  AutoSize := false;
  WordWrap := false;
  Alignment := taCenter;
  fAutoScaleMaxFontSize := 32;
  fShowStatus := true;
  fShowRawText := false;
  fShowOperation := false;

  // F O N T ------------------------------------
  fTCFont := TFont.Create;
  fTCFont.Assign(Font); // syncronize derived class
  fTCFont.Name := 'Courier New'; // proportional font?
  fTCFont.Style := fTCFont.Style + [fsBold];
  // --------------------------------------------

  fOperation := tcNone;
  fPerforation := mm35_4perf;
  fDisplayMode := tcTimecode;
  fStandard := tcPAL;
  Width := 145;
  Height := 33;
  Caption := '00:00:00:00';
  fAutoScale := true;
  fLineLead := 4;
end;

destructor TTCLabel.Destroy;
begin
  fTCFont.Free;
  inherited;
end;

function TTCLabel.GetDisplayMode: tcDisplayMode;
begin
  result := fDisplayMode;
end;

function TTCLabel.GetPerforation: tcPerforation;
begin
  result := fPerforation;
end;

function TTCLabel.GetStandard: tcStandard;
begin
	result := fStandard;
end;

function TTCLabel.GetTC: TTimecode;
begin
  result := fTC;
end;

function TTCLabel.GetText: string;
begin
	if (fDisplayMode = tcTimecode) and (fStandard =
		tcNTSCDF) and  fTC.UseDropFrame then
		// always show fully converted text
		result := fTC.GetText(fDisplayMode)
	else if (fDisplayMode = tcTimecode) and fShowRawText then
		// don't do full syntax checking - just display input string.
		// remove all non-numerical characters - working backwards....
		result := fTC.GetRawTextLEN8(fTCText)
	else
		result := fTCText;
end;

function TTCLabel.GetUseDropFrame: boolean;
begin
  result := fTC.UseDropFrame;
end;

procedure TTCLabel.Paint;
var
padTop, padLeft, txtHeight, txtWidth, StatusHeight, w, h, fLine3h, fLine2w: integer;
s: string;
begin

	if (fShowRawText) then
		s := GetText
	else
		s := fTCText;

	if (ShowOperation) then
		s := fTC.GetTextOperation(fOperation) + s;

	// calculate the heights for status lines 1 and 3.
	Canvas.Font.Assign(Font);
	// Units subtracted to keep display 'tight'
	fLine3h := (Canvas.TextHeight(s) - fLineLead);
	// Calculate the actual display co-ordinates (minus margins) ...
	w := ClientRect.Width - (Margins.Left + Margins.Right);
	// DISPLAY TIMECODE ...
	if  not s.IsEmpty() then begin
		if fAutoScale and (fTCFont.Size > 0) then
			Canvas.Font.Assign(fTCFont)
		else
			Canvas.Font.Assign(Font);
		// if canvas font is so small - it's unreadable - don't paint...
		if (-(Canvas.Font.Height) >= 1) then
    begin
			// Calculate height and width parameters for paint().
			fLine2w := Canvas.TextWidth(s);
			Canvas.Brush.Style := bsClear;
			Canvas.Pen.Style := psSolid;
			if (AutoScale) then
      begin
				// (Alignment == taRightJustify)
				if (fDisplayMode = tcFrames) or	(fDisplayMode= tcFootage) then
					padLeft := ClientRect.Left + (w - fLine2w)
				// (Alignment == taCenter)
				else
					padLeft := ClientRect.Left + Round(((w - fLine2w) / 2));
			end
			else
      begin
				if (Alignment = taLeftJustify) then
					padLeft := ClientRect.Left + Margins.Left
				else if (Alignment = taRightJustify) then
					padLeft := ClientRect.Left + (w - fLine2w)
				// (Alignment == taCenter)
				else
					padLeft := ClientRect.Left + Round(((w - fLine2w) / 2));
			end;
			padTop := ClientRect.top + Margins.Top;
			Canvas.TextOut(padLeft, padTop, s);
		end;
	end;

	// -----------------------------------
	Canvas.Font.Assign(Font);
	// DISPLAY STATUS FPS displayed bottom.right
	if (fShowStatus) then begin
		s := fTC.GetTextFPS;
		txtWidth := Canvas.TextWidth(s);
		{		 txtHeight := Canvas->TextHeight(s); 		 }
    padLeft := ClientRect.Right - Margins.Right - txtWidth;
		padTop := ClientRect.Bottom - Margins.Bottom - fLine3h - fLineLead;
		Canvas.TextOut(padLeft, padTop, s);
		// DISPLAY STATUS FPF displayed bottom.left
		s := fTC.GetTextPerforation(fPerforation);
		padLeft := ClientRect.Left + Margins.Left;
		padTop := ClientRect.Bottom - Margins.Bottom - fLine3h - fLineLead;
		Canvas.TextOut(padLeft, padTop, s);
	end;

end;

procedure TTCLabel.Resize;
begin
	inherited Resize;
	if (HasParent) then
		UpdateAutoScaleFontSize(fTCText);
end;

procedure TTCLabel.SetAutoScale(Value: boolean);
begin
	if (fAutoScale <> Value) then begin
		fAutoScale := Value;
		Invalidate;
	end;
end;

procedure TTCLabel.SetAutoScaleMaxFontSize(Value: integer);
begin
	if (fAutoScaleMaxFontSize <> Value) then begin
		fAutoScaleMaxFontSize := Value;
		Invalidate;
	end;
end;

procedure TTCLabel.SetDisplayMode(Value: tcDisplayMode);
begin
	if (fDisplayMode <> Value) then begin
		fDisplayMode := Value;
		Invalidate;
	end;
end;

procedure TTCLabel.SetPerforation(Value: tcPerforation);
begin
	if (fPerforation <> Value) then begin
		fPerforation := Value;
		Invalidate;
	end;
end;

procedure TTCLabel.SetOperation(Value: tcOperation);
begin
	if (fOperation <> Value) then begin
		fOperation := Value;
		Invalidate;
	end;
end;

procedure TTCLabel.SetShowOperation(Value: boolean);
begin
	if (fShowOperation <> Value) then begin
		fShowOperation := Value;
		AdjustSize;
		Invalidate;
	end;
end;

procedure TTCLabel.SetShowRawText(Value: boolean);
begin
	if (fShowRawText <> Value) then begin
		fShowRawText := Value;
		Invalidate;
	end;
end;

procedure TTCLabel.SetShowStatus(Value: boolean);
begin
	if (fShowStatus <> Value) then begin
		fShowStatus := Value;
		AdjustSize;
		Invalidate;
	end;
end;

procedure TTCLabel.SetStandard(Value: tcStandard);
begin
	if (fStandard <> Value) then begin
		fStandard := Value;
		Invalidate;
	end;
end;

procedure TTCLabel.SetText(Value: string);
begin
	if (fTCText <> Value) then begin
		fTCText := Value;
		fTCRawText := Value;
		Invalidate;
	end;
end;

procedure TTCLabel.SetUseDropFrame(Value: boolean);
begin
	if (fTC.UseDropFrame <> Value) then begin
		fTC.UseDropFrame := Value;
		Invalidate;
	end;
end;

procedure TTCLabel.UpdateAutoScaleFontSize(AString: string);
var
s: string;
h2, w, h, fLine3h: integer;
begin
	if (HasParent()) then begin
		s := fTCText;
		if (ShowOperation) then
			s := String(fTC.GetTextOperation(fOperation)) + s;
		// calculate the heights for status lines 1 and 3.
		Canvas.Font.Assign(Font);
		// Units subtracted to keep display 'tight'
		fLine3h := (Canvas.TextHeight(s) - fLineLead);
		// get the actual available height for line 2
		h2 := ClientRect.Height - Margins.Top - Margins.Bottom;
		if (fShowStatus) then
			h2 := h2 - fLine3h;

		// make line 2 fit.
		Canvas.Font.Assign(fTCFont);
		Canvas.Font.Size := fAutoScaleMaxFontSize;
		w := Canvas.TextWidth(s);
		h := Canvas.TextHeight(s);
		if (w > ClientWidth) or (h > h2) then begin
			// reduce the font size to fit the width
			repeat
				Canvas.Font.Size := Canvas.Font.Size - 1;
				w := Canvas.TextWidth(s);
				h := Canvas.TextHeight(s);
			until ((w > ClientWidth) or (h > h2)) and (Canvas.Font.Size > 0);
		end;
		// if the results are null - restore to default.
		if (Canvas.Font.Size = 0) then
			fTCFont.Size := Canvas.Font.Size;
	end;
end;

end.
