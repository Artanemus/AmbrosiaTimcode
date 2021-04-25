// ---------------------------------------------------------------------------
#include <vcl.h>
#pragma hdrstop
#include "TCCalculator.h"
#include <Clipbrd.hpp>
#pragma package(smart_init)

extern wchar_t MathsChar[];
// ---------------------------------------------------------------------------
// ValidCtrCheck is used to assure that the components created do not have
// any pure virtual functions.
//

static inline void ValidCtrCheck(TTCCalculator *) {
	new TTCCalculator(NULL);
}

// ---------------------------------------------------------------------------
__fastcall TTCCalculator::TTCCalculator(TComponent* Owner) : TTCEdit(Owner) {
	fTCStore = new TTimecode(this);
	fTCMemory = new TTimecode(this);
	fTCTemp = new TTimecode(this);
	fRawText = "";
	fShowRawText = true;
	PrevOperation = TTimecode::eOperation::oNone;
	fLastKeyDown = 0;
	fUseInputStr = true;
	fShowOperation = true;
	fShowMemory = true;
}

__fastcall TTCCalculator::~TTCCalculator() {
}

// ---------------------------------------------------------------------------
namespace Tccalculator {
	void __fastcall PACKAGE Register() {
		TComponentClass classes[1] = {__classid(TTCCalculator)};
		RegisterComponents(L"Ambrosia", classes, 0);
	}
}

void __fastcall TTCCalculator::ProcessKey(System::Word &Key,
	Classes::TShiftState Shift) {
	// NOTE : 'c' and VK_NUMPAD3: are duplicate cases in a switch...
	// COPY TEXT and TC to CLIPBOARD
	if ((Key == 'c' || Key == 'C') && Shift.Contains(ssCtrl)) {
		ClipboardCopy(this);
	}
	// PASTE TC or TEXT to APPLICATION
	else if ((Key == 'v' || Key == 'V') && Shift.Contains(ssCtrl)) {
		ClipboardPaste(this);
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
				PrevOperation = TTimecode::eOperation::oNone;
				NextOperation = TTimecode::eOperation::oNone;
				fLastKeyDown = Key;
			}
			fLastKeyDown = Key;
			fUseInputStr = true;
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
			Invalidate();
			Changed();
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
			Operation();
			PrevOperation = TTimecode::eOperation::oEquals;
			fLastKeyDown = Key;
			fRawText = "";
			fTC->Frames = 0;
			fUseInputStr = false;
			Invalidate();
			Changed();
			break;
#pragma end_region
#pragma region "Operations VK_MULTIPLY, VK_ADD, VK_DIVIDE, VK_SUBTRACT"
		case VK_MULTIPLY:
		case VK_ADD:
		case VK_DIVIDE:
		case VK_SUBTRACT:
			NextOperation = GetOperationEnum(Key);
			if (fLastKeyDown == VK_MULTIPLY || fLastKeyDown == VK_ADD ||
				fLastKeyDown == VK_DIVIDE || fLastKeyDown == VK_SUBTRACT) {
				// the key has been repeated or operation has been changed
				fUseInputStr = true;
				break;
			}
			if (fLastKeyDown != VK_RETURN && fLastKeyDown != '=')
				Operation();
			else
				PrevOperation = NextOperation;
			fLastKeyDown = Key;
			fRawText = "";
			fTC->Frames = 0;
			fUseInputStr = false;
			fOperation = GetOperationEnum(Key);
			Invalidate();
			Changed();
			break;
#pragma end_region
#pragma region "VK_BACK VK_CLEAR VK_ESCAPE"
		case VK_BACK:
			fRawText = fRawText.Delete(fRawText.Length(), 1);
			fTC->Text = fRawText;
			Invalidate();
			Changed();
			fLastKeyDown = Key;
			fUseInputStr = true;
			break;
			// hex:0x0C  int:12 - clear key - SIGNALS ALL CLEAR
		case VK_CLEAR:
			fTC->Frames = 0;
			fRawText = "";
			Invalidate();
			Changed();
			fTCStore->Frames = 0;
			fTCMemory->Frames = 0;
			Clipboard()->Clear();
			fLastKeyDown = Key;
			fUseInputStr = true;
			break;
		case VK_ESCAPE:
		case 'C':
			fTC->Frames = 0;
			fRawText = "";
			Invalidate();
			Changed();
			fTCStore->Frames = 0;
			PrevOperation = TTimecode::eOperation::oNone;
			NextOperation = TTimecode::eOperation::oNone;
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
void __fastcall TTCCalculator::KeyUp(System::Word &Key,
	Classes::TShiftState Shift) {
	ProcessKey(Key, Shift);
}

// ---------------------------------------------------------------------------
void __fastcall TTCCalculator::Operation() {
	// frame value will be based on fTCStore->Style.
	fTCTemp->Style = fTCStore->Style;
	fTCTemp->Text = fRawText;
	switch (PrevOperation) {
	case TTimecode::eOperation::oNone:
		fTCStore->Frames = fTCTemp->Frames;
		break;
	case TTimecode::eOperation::oAdd:
		fTCStore->Frames = fTCStore->Frames + fTCTemp->Frames;
		break;
	case TTimecode::eOperation::oMultiply:
		fTCStore->Frames = fTCStore->Frames * fTCTemp->Frames;
		break;
	case TTimecode::eOperation::oDivide:
		if (fTCTemp->Frames != 0)
			fTCStore->Frames = fTCStore->Frames / fTCTemp->Frames;
		break;
	case TTimecode::eOperation::oSubtract:
		fTCStore->Frames = fTCStore->Frames - fTCTemp->Frames;
		break;
	}
	PrevOperation = NextOperation;
}

// ---------------------------------------------------------------------------
TTimecode::eOperation __fastcall TTCCalculator::GetOperationEnum(wchar_t Key) {
	TTimecode::eOperation aOperation;
	switch (Key) {
	case VK_MULTIPLY:
		aOperation = TTimecode::eOperation::oMultiply;
		break;
	case VK_ADD:
		aOperation = TTimecode::eOperation::oAdd;
		break;
	case VK_DIVIDE:
		aOperation = TTimecode::eOperation::oDivide;
		break;
	case VK_SUBTRACT:
		aOperation = TTimecode::eOperation::oSubtract;
		break;
	case VK_RETURN:
	case '=':
		aOperation = TTimecode::eOperation::oEquals;
		break;
	default:
		aOperation = TTimecode::eOperation::oNone;
	}
	return aOperation;
}

// ---------------------------------------------------------------------------
void __fastcall TTCCalculator::Paint() {
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

void __fastcall TTCCalculator::SetShowMemory(bool Value) {
	if (fShowMemory != Value)
		fShowMemory = Value;
}

// ---------------------------------------------------------------------------
void __fastcall TTCCalculator::MemoryRecall(void) {
	UnicodeString txt;
	// Equates was last performed. A new cacluation will begin
	if (fLastKeyDown == VK_RETURN || fLastKeyDown == '=') {
		fTCStore->Frames = fTCMemory->Frames;
		PrevOperation = TTimecode::eOperation::oNone;
		fRawText = "";
		fUseInputStr = false;
	}
	// Operation was last performed.
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
	if (FOnChange)
		FOnChange(this);
	// this will ensure the memory status string is updated.
	Invalidate();
}

// ---------------------------------------------------------------------------
void __fastcall TTCCalculator::MemoryClear(void) {
	fTCMemory->Frames = 0;
	// this will ensure the memory status string is updated.
	Invalidate();
}

// ---------------------------------------------------------------------------
void __fastcall TTCCalculator::MemoryAdd(void) {
	fTC->Style = fTCStore->Style;
	if (fUseInputStr) {
		fTC->Text = fRawText;
		fTCMemory->Frames = fTCMemory->Frames + fTC->Frames;
	}
	else
		fTCMemory->Frames = fTCMemory->Frames + fTCStore->Frames;
	// Reset state...
	PrevOperation = TTimecode::eOperation::oNone;
	fLastKeyDown = 0;
	// this will ensure the memory status string is updated.
	Invalidate();
}

// ---------------------------------------------------------------------------
void __fastcall TTCCalculator::MemorySubtract(void) {
	fTC->Style = fTCStore->Style;
	if (fUseInputStr) {
		fTC->Text = fRawText;
		fTCMemory->Frames = fTCMemory->Frames - fTC->Frames;
	}
	else
		fTCMemory->Frames = fTCMemory->Frames - fTCStore->Frames;
	// Reset state...
	PrevOperation = TTimecode::eOperation::oNone;
	fLastKeyDown = 0;
	// this will ensure the memory status string is updated.
	Invalidate();
}

// ---------------------------------------------------------------------------
UnicodeString __fastcall TTCCalculator::GetMemoryText(void) {
	fTCMemory->Style = fTCStore->Style;
	return fTCMemory->Text;
}
