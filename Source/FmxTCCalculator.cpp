// ---------------------------------------------------------------------------

#include <fmx.h>

#pragma hdrstop

#include "FmxTCCalculator.h"
#pragma link "FmxTCEdit"
#pragma package(smart_init)
// ---------------------------------------------------------------------------
// ValidCtrCheck is used to assure that the components created do not have
// any pure virtual functions.
//

static inline void ValidCtrCheck(TFmxTCCalculator *) {
	new TFmxTCCalculator(NULL);
}

// ---------------------------------------------------------------------------
__fastcall TFmxTCCalculator::TFmxTCCalculator(TComponent* Owner)
	: TFmxTCEdit(Owner) {

}

// ---------------------------------------------------------------------------
namespace Fmxtccalculator {
	void __fastcall PACKAGE Register() {
		TComponentClass classes[1] = {__classid(TFmxTCCalculator)};
		RegisterComponents(L"Ambrosia", classes, 0);
	}
}
// ---------------------------------------------------------------------------
//void __fastcall TFmxTCCalculator::ProcessKey(System::Word &Key,
//	System::WideChar &KeyChar, Classes::TShiftState Shift) {
//
//    }

void __fastcall TFmxTCCalculator::ProcessKey(System::Word &Key,
	System::WideChar &KeyChar,  Classes::TShiftState Shift) {
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
		switch (Key) {
#pragma region "Numerical Keys - VK_DECIMAL, VK_OEM_PERIOD, 0123456789"
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
			// After a maths operation the input string is cleared.
			if (fLastKeyDown == VK_RETURN || fLastKeyDown == '=' ||
				fLastKeyDown == VK_MULTIPLY || fLastKeyDown == VK_ADD ||
				fLastKeyDown == VK_DIVIDE || fLastKeyDown == VK_SUBTRACT) {
				fRawText = "";
				fTC->Frames = 0;
			}
			// After an equates, assume a completely new calculation is being
			// performed.
			if (fLastKeyDown == VK_RETURN || fLastKeyDown == '=') {
				fTCStore->Frames = 0;
				PrevOperation = TFmxTimecode::eOperation::oNone;
				NextOperation = TFmxTimecode::eOperation::oNone;
				fLastKeyDown = Key;
			}
			fLastKeyDown = Key;
			fUseInputStr = true;
			// The period key funcions as '00' when in timecode style.
			if (Key == VK_OEM_PERIOD || Key == '.' || Key == VK_DECIMAL) {
				// the period key is ignore when using frames or footage
				if (fTC->Style == TFmxTimecode::eStyle::tcStyle) {
					fRawText = fRawText + "00";
				}
				else if (fTC->Style == TFmxTimecode::eStyle::footageStyle) {
					// input is toggles between footage and frames...
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
			if (OnChange) OnChange(this);
			break;
#pragma end_region
#pragma region "VK_RETURN"
			// SPECIAL NOTE: when enableing KeyPreview on the main form.
			// ...when a button has focus or when its Default property is true,
			// the Enter key is unaffected by KeyPreview because it does not generate
			// a keyboard events.
			// For KeyPreview to work correctly when the 'keyboard' return key is pressed
			// the 'VK_RETURN' button must have focus.
		case VK_RETURN:
		case '=':
			if (fLastKeyDown == VK_RETURN || fLastKeyDown == '=') {
				fUseInputStr = true;
				break;
			}
			DoOperation();
			PrevOperation = TFmxTimecode::eOperation::oEquals;
			fLastKeyDown = Key;
			fRawText = "";
			fTC->Frames = 0;
			fUseInputStr = false;
			TCustomEdit::SetText(BuildTextStr());
			if (OnChange) OnChange(this);
			break;
#pragma end_region
#pragma region "Operations VK_MULTIPLY, VK_ADD, VK_DIVIDE, VK_SUBTRACT"
		case VK_MULTIPLY:
		case VK_ADD:
		case VK_DIVIDE:
		case VK_SUBTRACT:
			NextOperation = GetOperationEnum(Key, KeyChar);
			if (fLastKeyDown == VK_MULTIPLY || fLastKeyDown == VK_ADD ||
				fLastKeyDown == VK_DIVIDE || fLastKeyDown == VK_SUBTRACT) {
				// the key has been repeated or operation has been changed
				fUseInputStr = true;
				break;
			}
			if (fLastKeyDown != VK_RETURN && fLastKeyDown != '=')
				DoOperation();
			else
				PrevOperation = NextOperation;
			fLastKeyDown = Key;
			fRawText = "";
			fTC->Frames = 0;
			fUseInputStr = false;
			Operation = GetOperationEnum(Key, KeyChar);
			TCustomEdit::SetText(BuildTextStr());
			if (OnChange) OnChange(this);
			break;
#pragma end_region
#pragma region "VK_BACK VK_CLEAR VK_ESCAPE"
		case VK_BACK:
			fRawText = fRawText.Delete(fRawText.Length(), 1);
			fTC->Text = fRawText;
			TCustomEdit::SetText(BuildTextStr());
			if (OnChange) OnChange(this);
			fLastKeyDown = Key;
			fUseInputStr = true;
			break;
			// hex:0x0C  int:12 - clear key - SIGNALS ALL CLEAR
		case VK_CLEAR:
			fTC->Frames = 0;
			fRawText = "";
			TCustomEdit::SetText(BuildTextStr());
			if (OnChange) OnChange(this);
			fTCStore->Frames = 0;
			fTCMemory->Frames = 0;
			Fmx::Platform::Platform->SetClipboard("");
			fLastKeyDown = Key;
			fUseInputStr = true;
			break;
		case VK_ESCAPE:
		case 'C':
			fTC->Frames = 0;
			fRawText = "";
			TCustomEdit::SetText(BuildTextStr());
			if (OnChange) OnChange(this);
			fTCStore->Frames = 0;
			PrevOperation = TFmxTimecode::eOperation::oNone;
			NextOperation = TFmxTimecode::eOperation::oNone;
			fLastKeyDown = Key;
			fUseInputStr = true;
			break;
#pragma end_region
		default:
			break;
		}
	}
	// Suppress any other processing.
	Key = 0;
}


// ---------------------------------------------------------------------------
void __fastcall TFmxTCCalculator::KeyDown(System::Word &Key,
	System::WideChar &KeyChar, System::Classes::TShiftState Shift) {
	ProcessKey(Key, KeyChar, Shift);
}

// ---------------------------------------------------------------------------
void __fastcall TFmxTCCalculator::DoOperation() {
	// frame value will be based on fTCStore->Style.
	fTCTemp->Style = fTCStore->Style;
	fTCTemp->Text = fRawText;
	switch (PrevOperation) {
	case TFmxTimecode::eOperation::oNone:
		fTCStore->Frames = fTCTemp->Frames;
		break;
	case TFmxTimecode::eOperation::oAdd:
		fTCStore->Frames = fTCStore->Frames + fTCTemp->Frames;
		break;
	case TFmxTimecode::eOperation::oMultiply:
		fTCStore->Frames = fTCStore->Frames * fTCTemp->Frames;
		break;
	case TFmxTimecode::eOperation::oDivide:
		if (fTCTemp->Frames != 0)
			fTCStore->Frames = fTCStore->Frames / fTCTemp->Frames;
		break;
	case TFmxTimecode::eOperation::oSubtract:
		fTCStore->Frames = fTCStore->Frames - fTCTemp->Frames;
		break;
	}
	PrevOperation = NextOperation;
}

// ---------------------------------------------------------------------------
TFmxTimecode::eOperation __fastcall TFmxTCCalculator::GetOperationEnum
	(System::Word &Key, System::WideChar &KeyChar) {
	TFmxTimecode::eOperation aOperation;
	switch (Key) {
	case VK_MULTIPLY:
		aOperation = TFmxTimecode::eOperation::oMultiply;
		break;
	case VK_ADD:
		aOperation = TFmxTimecode::eOperation::oAdd;
		break;
	case VK_DIVIDE:
		aOperation = TFmxTimecode::eOperation::oDivide;
		break;
	case VK_SUBTRACT:
		aOperation = TFmxTimecode::eOperation::oSubtract;
		break;
	case VK_RETURN:
	case '=':
		aOperation = TFmxTimecode::eOperation::oEquals;
		break;
	default:
		aOperation = TFmxTimecode::eOperation::oNone;
	}
	return aOperation;
}

System::UnicodeString __fastcall TFmxTCCalculator::BuildTextStr(void)
{
	if (!fUseInputStr) {
		// Doing this ensures Style remains in sync.
		fTC->Frames = fTCStore->Frames;
		fRawText = fTC->StripDown();
	}
	return TFmxTCEdit::BuildTextStr();
}

// ---------------------------------------------------------------------------
/*
void __fastcall TFmxTCCalculator::Paint() {
	UnicodeString s;
	int padLeft, padTop;
	// load the parameter - ready for display.
	fOperation = PrevOperation;
	if (!fUseInputStr) {
		// Doing this ensures Style remains in sync.
		fTC->Frames = fTCStore->Frames;
		fRawText = fTC->StripDown();
	}
	TTCEdit::Paint();
	Canvas->Font->Assign(Font);
	// DISPLAY MEMORY top.left
	if (fShowStatusStyle && fTCMemory->Frames != 0) {
		s = "MEM:" + fTCMemory->Text;
		padLeft = ClientRect.Left + Margins->Right;
		padTop = ClientRect.Top + Margins->Top;
		Canvas->TextOut(padLeft, padTop, s);
	}
}
*/

void __fastcall TFmxTCCalculator::SetShowMemory(bool Value) {
	if (fShowMemory != Value)
		fShowMemory = Value;
}

// ---------------------------------------------------------------------------
void __fastcall TFmxTCCalculator::MemoryRecall(void) {
	UnicodeString txt;
	// Equates was last performed. A new cacluation will begin
	if (fLastKeyDown == VK_RETURN || fLastKeyDown == '=') {
		fTCStore->Frames = fTCMemory->Frames;
		PrevOperation = TFmxTimecode::eOperation::oNone;
		fRawText = "";
		fUseInputStr = false;
	}
	// DoOperation was last performed.
	else if (fLastKeyDown == VK_MULTIPLY || fLastKeyDown == VK_ADD ||
		fLastKeyDown == VK_DIVIDE || fLastKeyDown == VK_SUBTRACT) {
		// re-sync to the current input method.
		fTCMemory->Style = fTCStore->Style;
		// Make raw string.
		txt = StripOutNonNumerical(fTCMemory->Text);
		fRawText = txt;
		// return a pointer to last character
		fLastKeyDown = (WORD) * (txt.LastChar());
		fUseInputStr = true;
	}
	// default ...
	else {
		// re-sync to the current input method.
		fTCMemory->Style = fTCStore->Style;
		// Make raw string.
		txt = StripOutNonNumerical(fTCMemory->Text);
		fRawText = txt;
		// return a pointer to last character
		fLastKeyDown = (WORD) * (txt.LastChar());
		fUseInputStr = true;
	}
	if (OnChange)
		OnChange(this);
	// this will ensure the memory status string is updated.
	TCustomEdit::SetText(BuildTextStr());
}

// ---------------------------------------------------------------------------
void __fastcall TFmxTCCalculator::MemoryClear(void) {
	fTCMemory->Frames = 0;
	// this will ensure the memory status string is updated.
	TCustomEdit::SetText(BuildTextStr());
}

// ---------------------------------------------------------------------------
void __fastcall TFmxTCCalculator::MemoryAdd(void) {
	fTC->Style = fTCStore->Style;
	if (fUseInputStr) {
		fTC->Text = fRawText;
		fTCMemory->Frames = fTCMemory->Frames + fTC->Frames;
	}
	else
		fTCMemory->Frames = fTCMemory->Frames + fTCStore->Frames;
	// Reset state...
	PrevOperation = TFmxTimecode::eOperation::oNone;
	fLastKeyDown = 0;
	// this will ensure the memory status string is updated.
	TCustomEdit::SetText(BuildTextStr());
}

// ---------------------------------------------------------------------------
void __fastcall TFmxTCCalculator::MemorySubtract(void) {
	fTC->Style = fTCStore->Style;
	if (fUseInputStr) {
		fTC->Text = fRawText;
		fTCMemory->Frames = fTCMemory->Frames - fTC->Frames;
	}
	else
		fTCMemory->Frames = fTCMemory->Frames - fTCStore->Frames;
	// Reset state...
	PrevOperation = TFmxTimecode::eOperation::oNone;
	fLastKeyDown = 0;
	// this will ensure the memory status string is updated.
	TCustomEdit::SetText(BuildTextStr());
}

// ---------------------------------------------------------------------------
UnicodeString __fastcall TFmxTCCalculator::GetMemoryText(void) {
	fTCMemory->Style = fTCStore->Style;
	return fTCMemory->Text;
}

// ---------------------------------------------------------------------------

