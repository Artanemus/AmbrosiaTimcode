// ---------------------------------------------------------------------------

#ifndef FmxTCTextH
#define FmxTCTextH
// ---------------------------------------------------------------------------
#include <SysUtils.hpp>
#include <Classes.hpp>
#include <FMX.Objects.hpp>
#include <FMX.Types.hpp>
#include "Timecode.h"
// ---------------------------------------------------------------------------
// forward declaration
// class TFmxTCLabel;

class PACKAGE TFmxTCText : public TText {
	// friend TFmxTCLabel;

private:
	UnicodeString fRawText;
	bool fShowRawText;
	bool fShowOperation;
	bool fAutoFitTC;
	TTimecode * fTC;
	TTimecode::eOperation fOperation;

	System::UnicodeString __fastcall GetText(void);
	void __fastcall SetText(const System::UnicodeString Value);
	System::UnicodeString __fastcall BuildTextStr(void);
	TTimecode * __fastcall GetTimecode(void);
	void __fastcall SetTimecode(TTimecode * Value);
	void __fastcall SetShowOperation(bool Value);
	void __fastcall SetShowRawText(bool Value);
	void __fastcall SetOperation(TTimecode::eOperation Value);
	void __fastcall OnChangeTimecode(System::TObject* Sender);

protected:
	virtual void __fastcall Paint(void);

public:
	__fastcall TFmxTCText(TComponent* Owner);
	__property Width = { default = 80};
	__property Height = { default = 24};

__published:
	__property System::UnicodeString Text = {read = GetText, write = SetText};
	__property bool ShowOperation = {
		read = fShowOperation, write = SetShowOperation, default = true};
	__property bool ShowRawText = {
		read = fShowRawText, write = SetShowRawText, default = false};
	__property bool AutoFitTC = {read = fAutoFitTC, write = fAutoFitTC};
	__property TTimecode * Timecode = { read=GetTimecode, write=SetTimecode};

};
// ---------------------------------------------------------------------------
#endif
