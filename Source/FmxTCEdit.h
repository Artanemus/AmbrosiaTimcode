// ---------------------------------------------------------------------------

#ifndef FmxTCEditH
#define FmxTCEditH
// ---------------------------------------------------------------------------
#include <SysUtils.hpp>
#include <Classes.hpp>
#include <FMX.Edit.hpp>
#include <FMX.Types.hpp>
#include "Timecode.h"

// ---------------------------------------------------------------------------
class PACKAGE TFmxTCEdit : public TCustomEdit {
private:
	bool fShowRawText;
	bool fShowOperation;
	TTimecode::eOperation fOperation;

	System::UnicodeString __fastcall GetText(void);
	void __fastcall SetText(const System::UnicodeString Value);
	void __fastcall SetTimecode(TTimecode * Value);
	TTimecode * __fastcall GetTimecode(void);
	void __fastcall SetShowRawText(bool Value);
	void __fastcall SetOperation(TTimecode::eOperation Value);
	void __fastcall SetShowOperation(bool Value);

protected:
	TTimecode *fTC;
	UnicodeString fRawText;
	virtual void __fastcall KeyDown(System::Word &Key, System::WideChar &KeyChar,
		System::Classes::TShiftState Shift);
	UnicodeString __fastcall StripOutNonNumerical(UnicodeString TCText);
	System::UnicodeString __fastcall BuildTextStr(void);

public:
	__fastcall TFmxTCEdit(TComponent* Owner);

__published:
	__property bool ShowRawText = {
		read = fShowRawText, write = SetShowRawText, default = false};
	__property TTimecode::eOperation Operation = {
		read = fOperation, write = SetOperation, default =
			TTimecode::eOperation::oNone};
	__property System::UnicodeString Text = {read = GetText, write = SetText};
	__property TTimecode * Timecode = { read=GetTimecode, write=SetTimecode};

};
// ---------------------------------------------------------------------------
#endif
