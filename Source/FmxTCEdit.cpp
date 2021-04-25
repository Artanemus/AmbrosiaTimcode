// ---------------------------------------------------------------------------

#include <fmx.h>

#pragma hdrstop

#include "FmxTCEdit.h"
#include <Character.hpp>
#pragma package(smart_init)
// ---------------------------------------------------------------------------
// ValidCtrCheck is used to assure that the components created do not have
// any pure virtual functions.
//

static inline void ValidCtrCheck(TFmxTCEdit *) {
	new TFmxTCEdit(NULL);
}

// ---------------------------------------------------------------------------
__fastcall TFmxTCEdit::TFmxTCEdit(TComponent* Owner) : TCustomEdit(Owner) {
	fTC = new TTimecode(this);
	fTC->Text = "00:00:00:00";
	fRawText = "00:00:00:00";
	TCustomEdit::Text = "00:00:00:00";
	StyleLookup = "editstyle";
	Width = 80;
	Height = 22;
	TextAlign = Fmx::Types::TTextAlign::Center;
//	ShowCaret = false;
	// Same as SelectAll() but doesn't avoids RepaintEdit().
	TCustomEdit::SelStart = 0;
	TCustomEdit::SelLength = TCustomEdit::Text.Length();
	TCustomEdit::CaretPosition = TCustomEdit::Text.Length();
}

// ---------------------------------------------------------------------------
namespace Fmxtcedit {
	void __fastcall PACKAGE Register() {
		TComponentClass classes[1] = {__classid(TFmxTCEdit)};
		RegisterComponents(L"Ambrosia", classes, 0);
	}
}

// ---------------------------------------------------------------------------
System::UnicodeString __fastcall TFmxTCEdit::BuildTextStr(void) {
	UnicodeString s;
	if (fTC->Style == TTimecode::tcStyle && fTC->Standard ==
		TTimecode::ttNTSCDF && fTC->UseDropFrame) {
		// always show fully converted text
		s = fTC->Text;
	}
	else if (fTC->Style == TTimecode::tcStyle && fShowRawText) {
		// don't do full syntax checking - just display input string.
		// remove all non-numerical characters - working backwards....
		int x, y;
		UnicodeString raw;
		UnicodeString s2 = "00000000";
		if (fTC->Standard == TTimecode::ttNTSCDF && !fShowRawText)
			raw = "00;00;00;00";
		else
			raw = "00:00:00:00";
		for (x = fRawText.Length(), y = 8; x > 0 && y > 0; x--, y--) {
			while (x && (fRawText[x] < '0' || fRawText[x] > '9'))
				x--;
			if (x)
				s2[y] = fRawText[x];
		}
		// sloppy - but safe way of preparing
		raw[1] = s2[1]; // the string for diplay...
		raw[2] = s2[2]; //
		raw[4] = s2[3];
		raw[5] = s2[4];
		raw[7] = s2[5];
		raw[8] = s2[6];
		raw[10] = s2[7];
		raw[11] = s2[8];
		s = raw;
		s.SetLength(11);
	}
	else
		s = fTC->Text;

	if (fShowOperation)
		s = UnicodeString(fTC->GetOperationChar(fOperation)) + s;
	return s;
}

// ---------------------------------------------------------------------------

void __fastcall TFmxTCEdit::KeyDown(System::Word &Key,
	System::WideChar &KeyChar, System::Classes::TShiftState Shift) {
	// NOTE : 'c' and VK_NUMPAD3: are duplicate cases in a switch...
	// COPY TEXT and TC to CLIPBOARD
	if ((Key == 'c' || Key == 'C') && Shift.Contains(ssCtrl)) {
		SelectAll();
		CopyToClipboard();
	}
	// PASTE TC or TEXT to APPLICATION
	else if ((Key == 'v' || Key == 'V') && Shift.Contains(ssCtrl)) {
		PasteFromClipboard();
		fRawText = TCustomEdit::Text;
		fTC->Text = fRawText;
		TCustomEdit::SetText(BuildTextStr());
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
			// The period key funcions as '00' when in timecode style.
			if (Key == VK_OEM_PERIOD || Key == '.' || Key == VK_DECIMAL) {
				// the period key is ignore when using frames or footage
				if (fTC->Style == TTimecode::eStyle::tcStyle) {
					fRawText = fRawText + "00";
				}
				else if (fTC->Style == TTimecode::eStyle::footageStyle) {
					// input is toggles between footage and frames...
					// TODO : Write routine to allow for VK_OEM_PERIOD when in
					// TTimecode::eStyle:tcStyle
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
			TCustomEdit::SetText(BuildTextStr());
			// Routine then calls TCustomEdit::RepaintEdit()...
			break;
#pragma end_region
#pragma region "VK_BACK VK_CLEAR VK_ESCAPE"
		case VK_BACK:
			fRawText = fRawText.Delete(fRawText.Length(), 1);
			fTC->Text = fRawText;
			TCustomEdit::SetText(BuildTextStr());
			break;
			// hex:0x0C  int:12 - clear key - SIGNALS ALL CLEAR
		case VK_CLEAR:
		case VK_ESCAPE:
			fTC->Frames = 0;
			fRawText = "";
			TCustomEdit::SetText(BuildTextStr());
			break;
#pragma end_region
		default: ;
		}
	}
}

// ---------------------------------------------------------------------------
UnicodeString __fastcall TFmxTCEdit::StripOutNonNumerical(UnicodeString TCText)
{
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

void __fastcall TFmxTCEdit::SetShowRawText(bool Value) {
	if (fShowRawText != Value) {
		fShowRawText = Value;
		TCustomEdit::SetText(BuildTextStr());
	}
}

void __fastcall TFmxTCEdit::SetOperation(TTimecode::eOperation Value) {
	if (fOperation != Value) {
		fOperation = Value;
		TCustomEdit::SetText(BuildTextStr());
	}
}

System::UnicodeString __fastcall TFmxTCEdit::GetText(void) {
	return BuildTextStr();
}

void __fastcall TFmxTCEdit::SetText(const System::UnicodeString Value) {
	if (fTC->Text != Value) {
		fTC->Text = Value;
		fRawText = Value;
		TCustomEdit::SetText(BuildTextStr());
	}
}

TTimecode * __fastcall TFmxTCEdit::GetTimecode(void) {
	return fTC;
}

void __fastcall TFmxTCEdit::SetTimecode(TTimecode * Value) {
	fTC->Assign(Value);
}

void __fastcall TFmxTCEdit::SetShowOperation(bool Value) {
	if (fShowOperation != Value) {
		fShowOperation = Value;
		TCustomEdit::SetText(BuildTextStr());
	}
}

/*
TTimecode::eStyle __fastcall TFmxTCEdit::GetStyle(void) {
	return fTC->Style;
}

void __fastcall TFmxTCEdit::SetStyle(TTimecode::eStyle Value) {
	if (fTC->Style != Value) {
		fTC->Style = Value;
		TCustomEdit::SetText(BuildTextStr());
	}
}

TTimecode::eStandard __fastcall TFmxTCEdit::GetStandard(void) {
	return fTC->Standard;
}

void __fastcall TFmxTCEdit::SetStandard(TTimecode::eStandard Value) {
	if (fTC->Standard != Value) {
		fTC->Standard = Value;
		TCustomEdit::SetText(BuildTextStr());
	}
}

int __fastcall TFmxTCEdit::GetFPFIndex(void) {
	return fTC->FPFIndex;
}

void __fastcall TFmxTCEdit::SetFPFIndex(int Value) {
	if (fTC->FPFIndex != Value) {
		fTC->FPFIndex = Value;
		TCustomEdit::SetText(BuildTextStr());
	}
}

bool __fastcall TFmxTCEdit::GetUseDropFrame(void) {
	return fTC->UseDropFrame;
}

void __fastcall TFmxTCEdit::SetUseDropFrame(bool Value) {
	if (fTC->UseDropFrame != Value) {
		fTC->UseDropFrame = Value;
		TCustomEdit::SetText(BuildTextStr());
	}
}

bool __fastcall TFmxTCEdit::GetUseGlobal(void) {
	return fTC->UseGlobal;
}

void __fastcall TFmxTCEdit::SetUseGlobal(bool Value) {
	if (fTC->UseGlobal != Value) {
		fTC->UseGlobal = Value;
		TCustomEdit::SetText(BuildTextStr());
	}
}

*/
