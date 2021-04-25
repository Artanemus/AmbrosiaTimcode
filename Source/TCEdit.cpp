// ---------------------------------------------------------------------------
#include <vcl.h>
#include <Clipbrd.hpp>
#pragma hdrstop
#include <Character.hpp>
#include "TCEdit.h"
#pragma package(smart_init)
// ---------------------------------------------------------------------------
// ValidCtrCheck is used to assure that the components created do not have
// any pure virtual functions.
//

static inline void ValidCtrCheck(TTCEdit *) {
	new TTCEdit(NULL);
}

// ---------------------------------------------------------------------------
// C O N S T R U C T O R   &   D E S T R U C T O R . . . .
// ---------------------------------------------------------------------------
__fastcall TTCEdit::TTCEdit(TComponent* Owner) : TCustomControl(Owner) {
	fTC = new TTimecode(this);
	// This is required to ensure that TTimecode is registered for streaming.
	// If not set, then the Clipboard() will show the exception error
	// EClassNotFound.
	Classes::RegisterClasses(&(__classid(TTimecode)), 0);
	fLineLead = 4;
	FOnChange = NULL;
	AutoSize = false;
	fAutoScale = true;
	fAutoScaleMaxFontSize = 64;
	fShowStatusFPS = true;
	fShowStatusFPF = true;
	fShowStatusStyle = true;
	// user option to force display of raw keyboard input
	fShowRawText = false;
	fShowOperation = false;
	fTC->UseDropFrame = true;
	fRawText = "";
	Width = 241;
	Height = 65;
	fTCFont = new TFont();
	fTCFont->Assign(Font);
	fTCFont->Name = "Courier New";
	fTCFont->Style << fsBold;
	fTCFont->Size = fAutoScaleMaxFontSize;
	fOperation = TTimecode::eOperation::oNone;
	fTransparent = false;
	Caption = "00:00:00:00";
	Text = "00:00:00:00";
	FAlignment = Classes::TAlignment::taCenter;
	fModified = false;
	fShowFocused = false;
	fEditing = false;

	// TCustomControl::OnMouseEnter = OnMouseEnterEvent;
	// TCustomControl::OnMouseLeave = OnMouseLeaveEvent;

}

__fastcall TTCEdit::~TTCEdit() {
	delete fTCFont;
}

// ---------------------------------------------------------------------------
namespace Tcedit {
	void __fastcall PACKAGE Register() {
		TComponentClass classes[1] = {__classid(TTCEdit)};
		RegisterComponents("Ambrosia", classes, 0);
	}
}

void __fastcall TTCEdit::SetTransparent(bool Value) {
	if (fTransparent != Value) {
		fTransparent = Value;
		Invalidate();
	}
}

void __fastcall TTCEdit::CreateParams(TCreateParams &Params) {
	TCustomControl::CreateParams(Params);
	if (fTransparent) {
		Params.ExStyle = Params.ExStyle | WS_EX_TRANSPARENT;
		ControlStyle = ControlStyle >> csOpaque;
		ControlStyle = ControlStyle << csAcceptsControls;
	}
}

/*
 void __fastcall TTCEdit::WMEraseBkGnd(Messages::TMessage &Message) {
 if (fTransparent) {
 DrawParentImage(this, Canvas);
 SetBkMode(HDC(Message.WParam), TRANSPARENT);
 }
 else {
 //		Canvas->Brush->Color = Color;
 //		Canvas->FillRect(ClientRect);
 }
 Message.Result = 1;
 }
 */
void __fastcall TTCEdit::DrawParentImage(TControl *Control, TCanvas *Dest) {
	int SaveIndex;
	HDC DC;
	TPoint Point;
	if (!HasParent())
		return;
	DC = Dest->Handle;
	SaveIndex = SaveDC(DC);
	GetViewportOrgEx(DC, &Point);
	SetViewportOrgEx(DC, Point.X - Control->Left, Point.Y - Control->Top, 0);
	IntersectClipRect(DC, 0, 0, Parent->ClientWidth, Parent->ClientHeight);
	Parent->Perform(WM_ERASEBKGND, int(DC), 0);
	Parent->Perform(WM_PAINT, int(DC), 0);
	RestoreDC(DC, SaveIndex);
}

// ---------------------------------------------------------------------------
// F U N C T I O N S . . . . . R O U T I N E S . . .
// . . . .
// ---------------------------------------------------------------------------
TTCEdit::eHotSpot __fastcall TTCEdit::GetHotSpot(TPoint MousePoint) {
	int w, h;
	TRect r;
	TPoint p;
	eHotSpot zone = hsClientZone;
	if ((fShowStatusFPS || fShowStatusFPF || fShowStatusStyle) && HasParent()) {
		// TDPoint MousePoint - are the pixel coordinates of the mouse pointer within
		// the client area of the control.
		p = ScreenToClient(MousePoint);
		// Calculate the height of a status line
		Canvas->Font->Assign(Font);
		h = Canvas->TextHeight("0");
		// LOCATE FPF
		if (fShowStatusFPF) {
			r = ClientRect;
			w = Canvas->TextWidth(fTC->StatusFPF);
			r.Bottom = r.Bottom - Margins->Bottom;
			r.Top = r.Bottom - h;
			r.Left = r.left + Margins->Left;
			r.Right = r.left + w;
			if (r.PtInRect(p)) {
				zone = hsStatusFPF;
			}
		}
		// LOCATE FPS
		if (fShowStatusFPS) {
			r = ClientRect;
			w = Canvas->TextWidth(fTC->StatusFPS);
			r.Bottom = r.Bottom - Margins->Bottom;
			r.Top = r.Bottom - h;
			r.Right = ClientRect.Right - Margins->Right;
			r.Left = r.Right - w;
			if (r.PtInRect(p)) {
				zone = hsStatusFPS;
			}
		}
		// LOCATE STYLE
		if (fShowStatusStyle) {
			r = ClientRect;
			w = Canvas->TextWidth(fTC->StatusStyle);
			r.Top = r.Top + Margins->Top;
			r.Bottom = r.Top + h;
			r.Right = ClientRect.Right - Margins->Right;
			r.Left = r.Right - w;
			if (r.PtInRect(p)) {
				zone = hsStatusStyle;
			}
		}
	}
	return zone;
}

void __fastcall TTCEdit::Click(void) {
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
}

void __fastcall TTCEdit::SetAlignment(Classes::TAlignment Value) {
	if (FAlignment != Value) {
		FAlignment = Value;
		Invalidate();
	}
}

void __fastcall TTCEdit::SetAutoScaleMaxFontSize(int Value) {
	if (fAutoScaleMaxFontSize != Value) {
		fAutoScaleMaxFontSize = Value;
		if (fTCFont->Size > fAutoScaleMaxFontSize) {
			AdjustSize();
			Invalidate();
		}
	}
}

void __fastcall TTCEdit::SetStyle(TTimecode::eStyle Value) {
	if (fTC->Style != Value) {
		fTC->Style = Value;
		AdjustSize();
		Invalidate();
	}
}

TTimecode::eStyle __fastcall TTCEdit::GetStyle(void) {
	return fTC->Style;
}

void __fastcall TTCEdit::SetStandard(TTimecode::eStandard Value) {
	if (fTC->Standard != Value) {
		fTC->Standard = Value;
		AdjustSize();
		Invalidate();
	}
}

TTimecode::eStandard __fastcall TTCEdit::GetStandard(void) {
	return fTC->Standard;
}

void __fastcall TTCEdit::SetPerforation(TTimecode::ePerforation Value) {
	if (fTC->Perforation != Value) {
		fTC->Perforation = Value;
		if (fTC->Style == TTimecode::eStyle::footageStyle) {
			AdjustSize();
			Invalidate();
		}
	}
}

TTimecode::ePerforation __fastcall TTCEdit::GetPerforation(void) {
	return fTC->Perforation;
}

void __fastcall TTCEdit::SetShowRawText(bool Value) {
// user option to display raw keyboard input
	if (fShowRawText != Value) {
		fShowRawText = Value;
		Invalidate();
	}
}

void __fastcall TTCEdit::SetShowStatusFPS(bool Value) {
	if (fShowStatusFPS != Value) {
		fShowStatusFPS = Value;
		AdjustSize();
		Invalidate();
	}
}

void __fastcall TTCEdit::SetShowStatusFPF(bool Value) {
	if (fShowStatusFPF != Value) {
		fShowStatusFPF = Value;
		AdjustSize();
		Invalidate();
	}
}

void __fastcall TTCEdit::SetShowStatusStyle(bool Value) {
	if (fShowStatusStyle != Value) {
		fShowStatusStyle = Value;
		AdjustSize();
		Invalidate();
	}
}

void __fastcall TTCEdit::SetAutoScale(bool Value) {
	if (fAutoScale != Value) {
		fAutoScale = Value;
		Invalidate();
	}
}

bool __fastcall TTCEdit::GetUseDropFrame(void) {
	return fTC->UseDropFrame;
}

void __fastcall TTCEdit::SetUseDropFrame(bool Value) {
	if (fTC->UseDropFrame != Value) {
		fTC->UseDropFrame = Value;
		Invalidate();
	}
}

void __fastcall TTCEdit::ToggleStyle(bool Forward) {
	fEditing = false;
	fTC->ToggleStyle(Forward);
	AdjustSize();
	Invalidate();
}

void __fastcall TTCEdit::ToggleFPS(bool Forward) {
	fTC->ToggleFPS(Forward);
	Invalidate();
}

void __fastcall TTCEdit::ToggleFPF(bool Forward) {
	fTC->ToggleFPF(Forward);
	Invalidate();
}

void __fastcall TTCEdit::WMKillFocus(Messages::TMessage &Message) {
	// removes the red underline
	Paint();
}

// ---------------------------------------------------------------------------
void __fastcall TTCEdit::KeyUp(System::Word &Key, Classes::TShiftState Shift) {

	// NOTE : 'c' and VK_NUMPAD3: are duplicate cases in a switch...
	// COPY TEXT and TC to CLIPBOARD
	if ((Key == 'c' || Key == 'C') && Shift.Contains(ssCtrl)) {
		fEditing = true;
		ClipboardCopy(this);
	}
	// PASTE TC or TEXT to APPLICATION
	else if ((Key == 'v' || Key == 'V') && Shift.Contains(ssCtrl)) {
		fEditing = true;
		ClipboardPaste(this);
	}
	// All other keys are handled by the base routine.
	else {
#pragma region "Numerical Keys - VK_DECIMAL, VK_OEM_PERIOD, 0123456789"
		switch (Key) {
		case VK_DECIMAL:
		case VK_OEM_PERIOD:
		case '0':
		case '1':
		case '2':
		case '3':
		case '4':
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
		case VK_NUMPAD1:
		case VK_NUMPAD2:
		case VK_NUMPAD3:
		case VK_NUMPAD4:
		case VK_NUMPAD5:
		case VK_NUMPAD6:
		case VK_NUMPAD7:
		case VK_NUMPAD8:
		case VK_NUMPAD9:
		case VK_NUMPAD0:
			fEditing = true;
			// The period key funcions as '00' when in timecode style.
			if (Key == VK_OEM_PERIOD || Key == '.' || Key == VK_DECIMAL) {
				// the period key is ignore when using frames or footage
				if (fTC->Style == TTimecode::eStyle::tcStyle) {
					fRawText = fRawText + "00";
				}
				else if (fTC->Style == TTimecode::eStyle::footageStyle) {
					// input is toggles between footage and frames...
					/* TODO : Write routine to allow for VK_OEM_PERIOD when in
					 TTimecode::eStyle:tcStyle */
				}
				else {
					// ignore the period key
				}
			}
			else if (Key > '9') {
				wchar_t c = Key - 0x30;
				fRawText = fRawText + (wchar_t) c;
			}
			else
				fRawText = fRawText + (wchar_t) Key;
			fTC->Text = fRawText;
			fModified = true;
			Invalidate();
			Changed();
			break;
#pragma end_region
#pragma region "VK_BACK VK_CLEAR VK_ESCAPE"
		case VK_BACK:
			fEditing = true;
			fRawText = fRawText.Delete(fRawText.Length(), 1);
			fTC->Text = fRawText;
			fModified = true;
			Invalidate();
			Changed();
			break;
			// hex:0x0C  int:12 - clear key - SIGNALS ALL CLEAR
		case VK_CLEAR:
		case VK_ESCAPE:
			fEditing = true;
			fTC->Frames = 0;
			fRawText = "";
			fModified = true;
			Invalidate();
			Changed();
			break;
#pragma end_region
		default: ;
		}
	}
}

UnicodeString __fastcall TTCEdit::GetText(void) {
	if (fTC->Style == TTimecode::tcStyle && fTC->Standard ==
		TTimecode::ttNTSCDF && fTC->UseDropFrame) {
		// always show fully converted text
		return fTC->Text;
	}
	else if (fTC->Style == TTimecode::tcStyle && (fShowRawText || fEditing)) {
		// don't do full syntax checking - just display input string.
		// remove all non-numerical characters - working backwards....
		int x, y;
		UnicodeString raw;
		UnicodeString s = "00000000";
		if (fTC->Standard == TTimecode::ttNTSCDF)
			raw = "00;00;00;00";
		else
			raw = "00:00:00:00";
		for (x = fRawText.Length(), y = 8; x > 0 && y > 0; x--, y--) {
			while (x && (fRawText[x] < '0' || fRawText[x] > '9'))
				x--;
			if (x)
				s[y] = fRawText[x];
		}
		// sloppy - but safe way of preparing
		raw[1] = s[1]; // the string for diplay...
		raw[2] = s[2]; //
		raw[4] = s[3];
		raw[5] = s[4];
		raw[7] = s[5];
		raw[8] = s[6];
		raw[10] = s[7];
		raw[11] = s[8];
		return raw;
	}
	else
		return fTC->Text;
}

void __fastcall TTCEdit::SetText(UnicodeString Value) {
	if (fTC->Text != Value) {
		fTC->Text = Value;
		fRawText = Value;
		// Indicates whether the user edited the text of the edit control.
		// Use Modified to determine whether the user changed the Text property
		// of the edit control. Modified is only reset to False when you assign
		// a value to the Text property. In particular, it is not reset when
		// the control receives focus.

		fModified = false;
		Invalidate();
		Changed();
	}
}

void __fastcall TTCEdit::SetFocus(void) {
	TCustomControl::SetFocus();
	Invalidate();
}

void __fastcall TTCEdit::SetFrames(double Value) {
	// Note SetFrames uses SetText as it's core routine
	// Create a tempory TTimecode object ... don't use the internal value!
	TTimecode *tempTC = new TTimecode(this);
	// Assures style, fps, fpf, etc are in sync
	tempTC->Assign(fTC);
	tempTC->Frames = Value;
	SetText(tempTC->Text);
	delete tempTC;
}

double __fastcall TTCEdit::GetFrames(void) {
	// Assume fTC is currently in-sync with the text that is on display?
	return fTC->Frames;
}

void __fastcall TTCEdit::UpdateAutoScaleFontSize() {
	int fLine1h, fLine3h;
	if (HasParent()) {
		UnicodeString s = fTC->Text;
		if (ShowOperation)
			s = UnicodeString(fTC->GetOperationChar(fOperation)) + s;
		// calculate the heights for status lines 1 and 3.
		Canvas->Font->Assign(Font);
		// Units subtracted to keep display 'tight'
		fLine1h = fLine3h = (Canvas->TextHeight(s) - fLineLead);
		// get the actual available height for line 2
		int h2 = ClientRect.Height() - Margins->Top - Margins->Bottom;
		if (fShowStatusFPS || fShowStatusFPF) {
			h2 = h2 - fLine3h;
		}
		if (fShowStatusStyle) {
			h2 = h2 - fLine1h;
		}
		// make line 2 fit.
		Canvas->Font->Assign(fTCFont);
		Canvas->Font->Size = fAutoScaleMaxFontSize;
		int w = Canvas->TextWidth(s);
		int h = Canvas->TextHeight(s);
		if (w > ClientWidth || h > h2) {
			// reducce the font size to fit   the width
			do {
				Canvas->Font->Size = Canvas->Font->Size - 1;
				w = Canvas->TextWidth(s);
				h = Canvas->TextHeight(s);
			}
			while ((w > ClientWidth || h > h2) && Canvas->Font->Size > 0);
		}
		// if the results are null - restore to default.
		if (Canvas->Font->Size)
			fTCFont->Size = Canvas->Font->Size;
	}
}

void __fastcall TTCEdit::ForceUpdate(void) {
	AdjustSize();
}

void __fastcall TTCEdit::AdjustSize(void) {
	TCustomControl::AdjustSize();
	UpdateAutoScaleFontSize();
}

bool __fastcall TTCEdit::CanResize(int &NewWidth, int &NewHeight) {
	UpdateAutoScaleFontSize();
	return true;
}

void __fastcall TTCEdit::Changed(void)
{
	TCustomControl::Changed();
	if (FOnChange != NULL) {
		FOnChange(this);
	}
}


/*
 void __fastcall TTCEdit::OnMouseLeaveEvent(System::TObject* Sender) {
 }

 void __fastcall TTCEdit::OnMouseEnterEvent(System::TObject* Sender) {
 }
 */

// ---------------------------------------------------------------------------
void __fastcall TTCEdit::Paint() {
	int padTop, padLeft, txtHeight, txtWidth, StatusHeight, w, h;
	int fLine1h, fLine3h, fLine2w, fLine2h;
	if (fTransparent)
		DrawParentImage(this, Canvas);
	UnicodeString s;
	// fShowRawText - user has forced display of raw text
	// FEditing - user is entering keyboard data and has entered edit mode
	if (fEditing || fShowRawText)
		s = GetText();
	else
		s = fTC->Text;
	if (ShowOperation)
		s = UnicodeString(fTC->GetOperationChar(fOperation)) + s;
	// calculate the heights for status lines 1 and 3.
	Canvas->Font->Assign(Font);
	// Units subtracted to keep display 'tight'
	fLine1h = fLine3h = (Canvas->TextHeight(s) - fLineLead);
	// Calculate the actual display co-ordinates (minus margins) ...
	w = ClientRect.Width() - (Margins->Left + Margins->Right);
	padTop = padLeft = 0;
	// DISPLAY TIMECODE ...
	if (!s.IsEmpty()) {
		if (fAutoScale && fTCFont->Size)
			Canvas->Font->Assign(fTCFont);
		else
			Canvas->Font->Assign(Font);
		// if canvas font is so small - it's unreadable - don't paint...
		if (-(Canvas->Font->Height) >= 1) {
			// Calculate height and width parameters for paint().
			int fLine2w = Canvas->TextWidth(s);
			Canvas->Brush->Style = Graphics::bsClear;
			Canvas->Pen->Style = psSolid;
			if (AutoScale) {
				// (Alignment == taRightJustify)
				if (fTC->Style == TTimecode::frameStyle ||
					fTC->Style == TTimecode::footageStyle) {
					padLeft = ClientRect.Left + (w - fLine2w);
				}
				// (Alignment == taCenter)
				else {
					padLeft = ClientRect.Left + ((w - fLine2w) / 2);
				}
			}
			else {
				if (Alignment == taLeftJustify) {
					padLeft = ClientRect.Left + Margins->Left;
				}
				else if (Alignment == taRightJustify) {
					padLeft = ClientRect.Left + (w - fLine2w);
				}
				// (Alignment == taCenter)
				else {
					padLeft = ClientRect.Left + ((w - fLine2w) / 2);
				}
			}
			padTop = ClientRect.top + Margins->Top;
			if (fShowStatusStyle)
				padTop = padTop + fLine1h;
			Canvas->TextOut(padLeft, padTop, s);

			// ISFOCUSED?? draw a line under the text
			fLine2h = Canvas->TextHeight(s);
			Canvas->Brush->Style = bsClear;
			Canvas->Pen->Style = psSolid;
			Canvas->Pen->Width = 1;
			if (Focused() && ShowFocused) {
				Canvas->Pen->Color = clRed;
			}
			else {
				Canvas->Pen->Color = Color;
			}
			// Subtract # pixel to raise the 'focused' line into the text
			// ascending seriff zone. Makes for a better display when using
			// only numbers
			Canvas->MoveTo(padLeft, padTop + fLine2h-2);
			Canvas->LineTo(padLeft + fLine2w, padTop + fLine2h-2);
		}
	}
	// -----------------------------------
	Canvas->Font->Assign(Font);
	// DISPLAY STATUS FPS displayed bottom.right
	if (fShowStatusFPS) {
		s = fTC->StatusFPS;
		txtWidth = Canvas->TextWidth(s);
		/*
		 txtHeight = Canvas->TextHeight(s);
		 */ padLeft = ClientRect.Right - Margins->Right - txtWidth;
		padTop = ClientRect.Bottom - Margins->Bottom - fLine3h - fLineLead;
		Canvas->TextOut(padLeft, padTop, s);
	}
	// DISPLAY STATUS FPF displayed bottom.left
	if (fShowStatusFPF) {
		s = fTC->StatusFPF;
		padLeft = ClientRect.Left + Margins->Left;
		padTop = ClientRect.Bottom - Margins->Bottom - fLine3h - fLineLead;
		Canvas->TextOut(padLeft, padTop, s);
	}
	// DISPLAY STATUS STYLE top.right
	if (fShowStatusStyle) {
		s = fTC->StatusStyle;
		txtWidth = Canvas->TextWidth(s);
		padLeft = ClientRect.Right - Margins->Right - txtWidth;
		padTop = ClientRect.Top + Margins->Top;
		Canvas->TextOut(padLeft, padTop, s);
	}
	if (BorderWidth > 0) {
		Canvas->Brush->Style = bsSolid;
		Canvas->Pen->Style = psClear;
		if (isFocused && ShowFocused)
			Canvas->Brush->Color = clHighlight;
		else
			Canvas->Brush->Color = clBackground;
		// Note : 1xpixel frame width.
		Canvas->FrameRect(ClientRect);
	}
}

// ---------------------------------------------------------------------------
// COPY AND PAST INTO CLIPBOARD
// ---------------------------------------------------------------------------
void __fastcall TTCEdit::ClipboardPaste(TObject * Sender) {
	bool DoCleanUp = false;
	// Before a class is read from the clipboard, it must be registered by a
	// call to RegisterClasses. If you try to read an unregistered class,
	// you'll get an EClassNotFound exception.
	if (Clipboard()->HasFormat(CF_COMPONENT)) {
		try {
			// Reminder that the TTimecode stream must be registered.
			// Classes::RegisterClasses(&(__classid(TTimecode)), 0);
			// else an exception error occurs
			// registration was done in creation routine.
			TComponent * comp = Clipboard()->GetComponent(this, this);
			if (comp && comp->ClassNameIs("TTimecode")) {
				fTC->Assign(reinterpret_cast<TTimecode*>(comp));
				DoCleanUp = true;
			}
			// As we have become the new owner of thie component
			// we'll clean it up here.
			delete comp;
		}
		catch (...) {
		}
	}
	else if (Clipboard()->HasFormat(CF_TEXT) && !Clipboard()->AsText.IsEmpty())
	{
		// paste text into the caclulator. Text must be SMPTE string
		fTC->Style = TTimecode::tcStyle;
		fTC->Text = Clipboard()->AsText;
		DoCleanUp = true;
	}
	if (DoCleanUp) {
		fRawText = StripOutNonNumerical(fTC->Text);
		Invalidate();
		Changed();
	}
}

// ---------------------------------------------------------------------------
void __fastcall TTCEdit::ClipboardCopy(TObject * Sender) {
	// Copy the timecode text onto the clipboard
	// send to clipboard  Open() and Close() allow us to put multi-items
	// into the clipboard.
	Clipboard()->Open();
	Clipboard()->AsText = fTC->Text;
	// For TTimecode aware VCL Components ... they will be able to read the
	// an actual TTimecode component.
	// Component passed to Clipboard is dependant on fUseInputStr.
	Clipboard()->SetComponent(reinterpret_cast<TComponent*>(fTC));
	Clipboard()->Close();
}

// ---------------------------------------------------------------------------
UnicodeString __fastcall TTCEdit::StripOutNonNumerical(UnicodeString TCText) {
	// Strip out any formatting, leaving only numbers.
	int i;
	UnicodeString txt = "";
	if (TCText == NULL || TCText.IsEmpty())
		return txt;
	for (i = 1; i <= TCText.Length(); i++) {
#pragma warn -8111
		if (IsNumber(TCText[i])) {
			txt = txt + TCText[i];
		}
#pragma warn .8111
	}
	return txt;
}

void __fastcall TTCEdit::SetOperation(TTimecode::eOperation Value) {
	if (fOperation != Value) {
		fOperation = Value;
		Invalidate();
	}
}

void __fastcall TTCEdit::SetShowOperation(bool Value) {
	if (fShowOperation != Value) {
		fShowOperation = Value;
		AdjustSize();
		Invalidate();
	}
}
