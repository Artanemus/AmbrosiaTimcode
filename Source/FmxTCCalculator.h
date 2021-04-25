// ---------------------------------------------------------------------------

#ifndef FmxTCCalculatorH
#define FmxTCCalculatorH
// ---------------------------------------------------------------------------
#include <SysUtils.hpp>
#include <Classes.hpp>
#include "FmxTCEdit.h"
#include <FMX.Edit.hpp>
#include <FMX.Types.hpp>

// ---------------------------------------------------------------------------
class PACKAGE TFmxTCCalculator : public TFmxTCEdit {
private:
	TFmxTimecode::eOperation CurrOperation;
	TFmxTimecode::eOperation NextOperation;
	TFmxTimecode::eOperation PrevOperation;

	// TC Storage for calculations
	TFmxTimecode * fTCStore;
	// Memory store feature (MS M+ M- MC)
	TFmxTimecode * fTCMemory;
	// Tempory timecode value
	TFmxTimecode *fTCTemp;
	WORD fLastKeyDown;
	// replaces fTC->Text for input storage.
	// As fTC->ShowRawText can change - it isn't a stable storage space.
	UnicodeString fInputStr;
	/* TODO : Change the methanology to remove fUseInputString && fInputStr */
	bool fUseInputStr;
	bool fShowMemory;

	void __fastcall DoOperation();

	TFmxTimecode::eOperation __fastcall GetOperationEnum(System::Word &Key,
		System::WideChar &KeyChar);
	UnicodeString __fastcall GetMemoryText(void);
	void __fastcall SetShowMemory(bool Value);

protected:
	virtual void __fastcall KeyDown(System::Word &Key, System::WideChar &KeyChar,
		System::Classes::TShiftState Shift);
	virtual System::UnicodeString __fastcall BuildTextStr(void);

public:
	__fastcall TFmxTCCalculator(TComponent* Owner);
	void __fastcall ProcessKey(System::Word &Key, System::WideChar &KeyChar,
		Classes::TShiftState Shift);
	void __fastcall MemoryRecall(void);
	void __fastcall MemoryClear(void);
	void __fastcall MemoryAdd(void);
	void __fastcall MemorySubtract(void);

__published:
	__property UnicodeString MemoryText = {read = GetMemoryText};
	__property bool ShowMemory = {
		read = fShowMemory, write = SetShowMemory, default = true};

__published:
};
// ---------------------------------------------------------------------------
#endif
