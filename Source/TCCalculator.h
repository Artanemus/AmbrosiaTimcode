// ---------------------------------------------------------------------------
#ifndef TCCalculatorH
#define TCCalculatorH
// ---------------------------------------------------------------------------
#include <SysUtils.hpp>
#include <Classes.hpp>
#include <Controls.hpp>
#include <StdCtrls.hpp>
#include "TCEdit.h"

// ---------------------------------------------------------------------------
class PACKAGE TTCCalculator : public TTCEdit {
private:
	TTimecode::eOperation CurrOperation;
	TTimecode::eOperation NextOperation;
	TTimecode::eOperation PrevOperation;

	// TC Storage for calculations
	TTimecode * fTCStore;
	// Memory store feature (MS M+ M- MC)
	TTimecode * fTCMemory;
	// Tempory timecode value
	TTimecode *fTCTemp;
	WORD fLastKeyDown;
	// replaces fTC->Text for input storage.
	// As fTC->ShowRawText can change - it isn't a stable storage space.
	UnicodeString fInputStr;
	/* TODO : Change the methanology to remove fUseInputString && fInputStr */
	bool fUseInputStr;
	bool fShowMemory;

	void __fastcall Operation();
	TTimecode::eOperation __fastcall GetOperationEnum(wchar_t Key);
	UnicodeString __fastcall GetMemoryText(void);
	void __fastcall SetShowMemory(bool Value);
protected:
	DYNAMIC void __fastcall KeyUp(System::Word &Key,
		Classes::TShiftState Shift);
	virtual void __fastcall Paint(void);
public:
	__fastcall TTCCalculator(TComponent* Owner);
	__fastcall ~TTCCalculator(void);
	void __fastcall ProcessKey(System::Word &Key, Classes::TShiftState Shift);
	void __fastcall MemoryRecall(void);
	void __fastcall MemoryClear(void);
	void __fastcall MemoryAdd(void);
	void __fastcall MemorySubtract(void);

__published:
	__property UnicodeString MemoryText = {read = GetMemoryText};
	__property bool ShowMemory = {
		read = fShowMemory, write = SetShowMemory, default = true};

	__property OnKeyDown;
	__property OnKeyUp;
	__property OnKeyPress;
};
// ---------------------------------------------------------------------------
#endif
