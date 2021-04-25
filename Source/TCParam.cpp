// ---------------------------------------------------------------------------

#pragma hdrstop

#include "TCParam.h"
// ---------------------------------------------------------------------------
#pragma package(smart_init)

// ---------------------------------------------------------------------------
// ValidCtrCheck is used to assure that the components created do not have
// any pure virtual functions.
//

static inline void ValidCtrCheck(TTCParam *) {
	new TTCParam(NULL);
}

// ---------------------------------------------------------------------------
// C O N S T R U C T O R   &   D E S T R U C T O R . . . .
// ---------------------------------------------------------------------------
__fastcall TTCParam::TTCParam(TComponent* Owner) : TComponent(Owner) {
	fTC = new TTimecode(this);
	// This is required to ensure that TTimecode is registered for streaming.
	// If not set, then the Clipboard() will show the exception error
	// EClassNotFound.
	Classes::RegisterClasses(&(__classid(TTCParam)), 0);
}

__fastcall TTCParam::~TTCParam() {
}

// ---------------------------------------------------------------------------
namespace Tcparam {
	void __fastcall PACKAGE Register() {
		TComponentClass classes[1] = {__classid(TTCParam)};
		RegisterComponents("Ambrosia", classes, 0);
	}
}

TTimecode::eStandard __fastcall TTCParam::GetStandard(void) {
	return fTC->Standard;
}

void __fastcall TTCParam::SetStandard(TTimecode::eStandard Value) {
	fTC->Standard = Value;
}

void __fastcall TTCParam::SetUseGlobal(bool Value) {
	fTC->UseGlobal = Value;
}

bool __fastcall TTCParam::GetUseGlobal(void) {
	return fTC->UseGlobal;
}

void __fastcall TTCParam::SetCustomFPS(double Value) {
	fTC->CustomFPS = Value;
}

double __fastcall TTCParam::GetCustomFPS(void) {
	return fTC->CustomFPS;
}

void __fastcall TTCParam::SetFrames(double Value) {
	fTC->Frames = Value;
}

double __fastcall TTCParam::GetFrames(void) {
	return fTC->Frames;
}

void __fastcall TTCParam::SetFPSIndex(int Value) {
	fTC->FPSIndex = Value;
}

int __fastcall TTCParam::GetFPSIndex(void) {
	return fTC->FPSIndex;
}

void __fastcall TTCParam::SetFPFIndex(int Value) {
	fTC->FPFIndex = Value;
}

int __fastcall TTCParam::GetFPFIndex(void) {
	return fTC->FPFIndex;
}

void __fastcall TTCParam::SetStyleIndex(int Value) {
	fTC->StyleIndex = Value;
}

int __fastcall TTCParam::GetStyleIndex(void) {
	return fTC->StyleIndex;
}

void __fastcall TTCParam::SetText(UnicodeString Value) {
	fTC->Text = Value;
}

UnicodeString __fastcall TTCParam::GetText() {
	return fTC->Text;
}

void __fastcall TTCParam::SetStyle(TTimecode::eStyle Value) {
	fTC->Style = Value;
}

TTimecode::eStyle __fastcall TTCParam::GetStyle(void) {
	return fTC->Style;
}

void __fastcall TTCParam::SetUseDropFrame(bool Value) {
	fTC->UseDropFrame = Value;
}

bool __fastcall TTCParam::GetUseDropFrame(void) {
	return fTC->UseDropFrame;
}

void __fastcall TTCParam::SetPerforation(TTimecode::ePerforation Value) {
	fTC->Perforation = Value;
}

TTimecode::ePerforation __fastcall TTCParam::GetPerforation(void) {
	return fTC->Perforation;
}
