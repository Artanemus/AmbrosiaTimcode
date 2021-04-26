//---------------------------------------------------------------------------

#ifndef TCParamH
#define TCParamH
//---------------------------------------------------------------------------
#include <SysUtils.hpp>
#include <Classes.hpp>
#include "Timecode.h"

 // ---------------------------------------------------------------------------
class PACKAGE TTCParam : public TComponent {
private:
	TTimecode *fTC;
	void __fastcall SetStandard(TTimecode::eStandard Value);
	TTimecode::eStandard __fastcall GetStandard(void);
	void __fastcall SetUseGlobal(bool Value);
	bool __fastcall GetUseGlobal(void);
	double __fastcall GetCustomFPS(void);
	void __fastcall SetCustomFPS(double value);
	void __fastcall SetFrames(double value);
	double __fastcall GetFrames(void);
	void __fastcall SetFPSIndex(int value);
	int __fastcall GetFPSIndex(void);
	void __fastcall SetFPFIndex(int value);
	int __fastcall GetFPFIndex(void);
	void __fastcall SetStyleIndex(int Value);
	int __fastcall GetStyleIndex(void);
	void __fastcall SetText(UnicodeString value);
	UnicodeString __fastcall GetText();
	TTimecode::eStyle __fastcall GetStyle(void);
	void __fastcall SetStyle(TTimecode::eStyle Value);
	void __fastcall SetUseDropFrame(bool Value);
	bool __fastcall GetUseDropFrame(void);
	TTimecode::ePerforation __fastcall GetPerforation(void);
	void __fastcall SetPerforation(TTimecode::ePerforation Value);

public:
	__fastcall TTCParam(TComponent* Owner);
	__fastcall ~TTCParam();


__published:
	// re-published from TTimecode
	__property TTimecode::eStandard Standard = {
		read = GetStandard, write = SetStandard, default = TTimecode::ttPAL};
	__property bool UseGlobal = {
		read = GetUseGlobal, write = SetUseGlobal, default = true};
	__property double CustomFPS = {read = GetCustomFPS, write = SetCustomFPS};
	__property double Frames = {read = GetFrames, write = SetFrames, default = 0
	};
	__property int FPSIndex = {
		read = GetFPSIndex, write = SetFPSIndex, default = 0};
	__property int FPFIndex = {
		read = GetFPFIndex, write = SetFPFIndex, default = 3};
	__property int StyleIndex = {
		read = GetStyleIndex, write = SetStyleIndex, default = 0};
	__property UnicodeString Text = {read = GetText, write = SetText};
	__property TTimecode::eStyle Style = {
		read = GetStyle, write = SetStyle, default = TTimecode::tcStyle};
	__property bool UseDropFrame = {
		read = GetUseDropFrame, write = SetUseDropFrame, default = true};
	__property TTimecode::ePerforation Perforation = {
		read = GetPerforation, write = SetPerforation};


};


#endif
