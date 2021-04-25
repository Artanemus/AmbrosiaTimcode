// ---------------------------------------------------------------------------
#ifndef TCLabelH
#define TCLabelH
// ---------------------------------------------------------------------------
#include <SysUtils.hpp>
#include <Classes.hpp>
#include <Controls.hpp>
#include <StdCtrls.hpp>
#include "Timecode.h"

// ---------------------------------------------------------------------------
class PACKAGE TTCLabel : public TCustomLabel {
	/*
	 public:
	 enum TTimecode::eOperation {
	 oMultiply, oAdd, oSubtract, oDivide, oEquals, oNone
	 };
	 */

private:
	TTimecode::eOperation fOperation;
	TTimecode * fTC;
	bool fShowStatus;
	int fAutoScaleMaxFontSize;
	UnicodeString fRawText;
	bool fShowRawText;
	TFont * fTCFont;
	bool fShowOperation;
	bool fAutoScale;
	int fLineLead;

	UnicodeString __fastcall GetText(void);
	void __fastcall SetText(UnicodeString Value);
	TTimecode * __fastcall GetTC(void);
	TTimecode::eStyle __fastcall GetStyle(void);
	void __fastcall SetStyle(TTimecode::eStyle Value);
	void __fastcall SetAutoScaleMaxFontSize(int Value);
	void __fastcall SetShowStatus(bool Value);
	void __fastcall SetShowOperation(bool Value);
	TTimecode::eStandard __fastcall GetStandard(void);
	void __fastcall SetStandard(TTimecode::eStandard Value);
	void __fastcall SetShowRawText(bool Value);
	int __fastcall GetFPFIndex(void);
	void __fastcall SetFPFIndex(int Value);
	bool __fastcall GetUseDropFrame(void);
	void __fastcall SetUseDropFrame(bool Value);
	void __fastcall UpdateAutoScaleFontSize(UnicodeString AStr);
	void __fastcall SetOperation(TTimecode::eOperation Value);
	void __fastcall SetAutoScale(bool Value);
protected:
	virtual void __fastcall Paint(void);
//	virtual void __fastcall SetAutoSize(bool Value);
	DYNAMIC void __fastcall AdjustSize(void);
	DYNAMIC void __fastcall Resize(void);
//	DYNAMIC void __fastcall AdjustBounds(void);
public:
	__fastcall TTCLabel(TComponent* Owner);
	__fastcall ~TTCLabel(void);
	__property TTimecode * TC = {read = GetTC};

__published:
	__property Alignment = {default = TAlignment::taCenter};
//	__property Canvas;
	__property FocusControl;
	__property ShowAccelChar;
	__property Transparent;
//	__property Layout;
	__property Font;
//	__property GlowSize;
//	__property AutoSize = {default = false};
	__property Visible;
	__property Enabled;
	__property Width = {default = 145};
	__property Height = {default = 33};
	__property Color;


	__property int AutoSizeMaxFontSize = {
		read = fAutoScaleMaxFontSize, write = SetAutoScaleMaxFontSize,
		default = 32};
	__property bool ShowStatus = {
		read = fShowStatus, write = SetShowStatus, default = true};
	__property bool ShowOperation = {
		read = fShowOperation, write = SetShowOperation, default = true};
	__property bool ShowRawText = {
		read = fShowRawText, write = SetShowRawText, default = false};
	__property bool AutoScale = {
		read = fAutoScale, write = SetAutoScale, default = true};
	__property Caption = {read = GetText, write = SetText};
	__property TTimecode::eStyle Style = {
		read = GetStyle, write = SetStyle, default = 0};
	__property TTimecode::eStandard Standard = {
		read = GetStandard, write = SetStandard, default = TTimecode::ttPAL};
	__property int FPFIndex = {
		read = GetFPFIndex, write = SetFPFIndex, default = 3};
	__property bool UseDropFrame = {
		read = GetUseDropFrame, write = SetUseDropFrame, default = true};
	__property Graphics::TFont *TCFont = {read = fTCFont, write = fTCFont};
	__property TTimecode::eOperation Operation = {
		read = fOperation, write = SetOperation};
};
// ---------------------------------------------------------------------------
#endif
