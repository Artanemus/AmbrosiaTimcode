// ---------------------------------------------------------------------------
#include <vcl.h>
#pragma hdrstop
#include "TCLabel.h"
#pragma package(smart_init)
extern wchar_t MathsChar[];
// ---------------------------------------------------------------------------
// ValidCtrCheck is used to assure that the components created do not have
// any pure virtual functions.
//

static inline void ValidCtrCheck(TTCLabel *) {
	new TTCLabel(NULL);
}

// ---------------------------------------------------------------------------
__fastcall TTCLabel::TTCLabel(TComponent* Owner) : TCustomLabel(Owner) {
	fTC = new TTimecode(this);
	AutoSize = false;
	WordWrap = false;
	Alignment = taCenter;
	fAutoScaleMaxFontSize = 32;
	fShowStatus = true;
	fShowRawText = false;
	fTC->UseDropFrame = true;
	fTCFont = new TFont();
	fTCFont->Assign(Font);
	fTCFont->Name = "Courier New";
	fTCFont->Style << fsBold;
	fOperation = TTimecode::eOperation::oNone;
	fShowOperation = false;
	Width = 145;
	Height = 33;
	Caption = "00:00:00:00";
	fAutoScale = true;
	fLineLead = 4;
}

__fastcall TTCLabel::~TTCLabel(void) {
	delete fTCFont;
}

// ---------------------------------------------------------------------------
namespace Tclabel {
	void __fastcall PACKAGE Register() {
		TComponentClass classes[1] = {__classid(TTCLabel)};
		RegisterComponents(L"Ambrosia", classes, 0);
	}
}

// ---------------------------------------------------------------------------
TTimecode::eStyle __fastcall TTCLabel::GetStyle(void) {
	return fTC->Style;
}

void __fastcall TTCLabel::SetStyle(TTimecode::eStyle Value) {
	if (fTC->Style != Value) {
		fTC->Style = Value;
		Invalidate();
	}
}

TTimecode * __fastcall TTCLabel::GetTC(void) {
	return fTC;
}

UnicodeString __fastcall TTCLabel::GetText(void) {
	if (fTC->Style == TTimecode::tcStyle && fTC->Standard ==
		TTimecode::ttNTSCDF && fTC->UseDropFrame) {
		// always show fully converted text
		return fTC->Text;
	}
	else if (fTC->Style == TTimecode::tcStyle && fShowRawText) {
		// don't do full syntax checking - just display input string.
		// remove all non-numerical characters - working backwards....
		int x, y;
		UnicodeString raw;
		UnicodeString s = "00000000";
		if (fTC->Standard == TTimecode::ttNTSCDF && !fShowRawText)
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

void __fastcall TTCLabel::SetText(UnicodeString Value) {
	if (fTC->Text != Value) {
		fTC->Text = Value;
		fRawText = Value;
		Invalidate();
	}
}

void __fastcall TTCLabel::SetAutoScaleMaxFontSize(int Value) {
	if (fAutoScaleMaxFontSize != Value) {
		fAutoScaleMaxFontSize = Value;
		Invalidate();
	}
}

void __fastcall TTCLabel::SetShowStatus(bool Value) {
	if (fShowStatus != Value) {
		fShowStatus = Value;
		AdjustSize();
		Invalidate();
	}
}

void __fastcall TTCLabel::SetShowRawText(bool Value) {
	if (fShowRawText != Value) {
		fShowRawText = Value;
		Invalidate();
	}
}

TTimecode::eStandard __fastcall TTCLabel::GetStandard(void) {
	return fTC->Standard;
}

void __fastcall TTCLabel::SetStandard(TTimecode::eStandard Value) {
	if (fTC->Standard != Value) {
		fTC->Standard = Value;
		Invalidate();
	}
}

int __fastcall TTCLabel::GetFPFIndex(void) {
	return fTC->FPFIndex;
}

void __fastcall TTCLabel::SetFPFIndex(int Value) {
	if (fTC->FPFIndex != Value) {
		fTC->FPFIndex = Value;
		Invalidate();
	}
}

bool __fastcall TTCLabel::GetUseDropFrame(void) {
	return fTC->UseDropFrame;
}

void __fastcall TTCLabel::SetUseDropFrame(bool Value) {
	if (fTC->UseDropFrame != Value) {
		fTC->UseDropFrame = Value;
		Invalidate();
	}
}

void __fastcall TTCLabel::UpdateAutoScaleFontSize(UnicodeString AStr) {
	int fLine3h;
	if (HasParent()) {
		UnicodeString s = fTC->Text;
		if (ShowOperation)
			s = UnicodeString(fTC->GetOperationChar(fOperation)) + s;
		// calculate the heights for status lines 1 and 3.
		Canvas->Font->Assign(Font);
		// Units subtracted to keep display 'tight'
		fLine3h = (Canvas->TextHeight(s) - fLineLead);
		// get the actual available height for line 2
		int h2 = ClientRect.Height() - Margins->Top - Margins->Bottom;
		if (fShowStatus) {
			h2 = h2 - fLine3h;
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


void __fastcall TTCLabel::SetAutoScale(bool Value) {
	if (fAutoScale != Value) {
		fAutoScale = Value;
		Invalidate();
	}
}

void __fastcall TTCLabel::Resize(void) {
	TCustomLabel::Resize();
	if (HasParent()) {
		UpdateAutoScaleFontSize(fTC->Text);
	}
}

void __fastcall TTCLabel::AdjustSize(void) {
	TCustomLabel::AdjustSize();
	if (HasParent()) {
		UpdateAutoScaleFontSize(fTC->Text);
	}
}

void __fastcall TTCLabel::Paint() {
	int padTop, padLeft, txtHeight, txtWidth, StatusHeight, w, h;
	int fLine3h, fLine2w;
	UnicodeString s;
	if (fShowRawText)
		s = GetText();
	else
		s = fTC->Text;
	if (ShowOperation)
		s = UnicodeString(fTC->GetOperationChar(fOperation)) + s;
	// calculate the heights for status lines 1 and 3.
	Canvas->Font->Assign(Font);
	// Units subtracted to keep display 'tight'
	fLine3h = (Canvas->TextHeight(s) - fLineLead);
	// Calculate the actual display co-ordinates (minus margins) ...
	w = ClientRect.Width() - (Margins->Left + Margins->Right);
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
			Canvas->TextOut(padLeft, padTop, s);
		}
	}
	// -----------------------------------
	Canvas->Font->Assign(Font);
	// DISPLAY STATUS FPS displayed bottom.right
	if (fShowStatus) {
		s = fTC->StatusFPS;
		txtWidth = Canvas->TextWidth(s);
		/*
		 txtHeight = Canvas->TextHeight(s);
		 */ padLeft = ClientRect.Right - Margins->Right - txtWidth;
		padTop = ClientRect.Bottom - Margins->Bottom - fLine3h - fLineLead;
		Canvas->TextOut(padLeft, padTop, s);
		// DISPLAY STATUS FPF displayed bottom.left
		s = fTC->StatusFPF;
		padLeft = ClientRect.Left + Margins->Left;
		padTop = ClientRect.Bottom - Margins->Bottom - fLine3h - fLineLead;
		Canvas->TextOut(padLeft, padTop, s);
	}
}

void __fastcall TTCLabel::SetOperation(TTimecode::eOperation Value) {
	if (fOperation != Value) {
		fOperation = Value;
		Invalidate();
	}
}

void __fastcall TTCLabel::SetShowOperation(bool Value) {
	if (fShowOperation != Value) {
		fShowOperation = Value;
		AdjustSize();
		Invalidate();
	}
}
