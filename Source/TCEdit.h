// ---------------------------------------------------------------------------
#ifndef TCEditH
#define TCEditH
// ---------------------------------------------------------------------------
#include <SysUtils.hpp>
#include <Vcl.Controls.hpp>
#include <Classes.hpp>
#include <Forms.hpp>
#include <StdCtrls.hpp>
#include "timecode.h"

// ---------------------------------------------------------------------------
class PACKAGE TTCEdit : public TCustomControl {
private:
	enum eHotSpot {
		hsStatusFPS, hsStatusFPF, hsStatusStyle, hsClientZone
	};

	int fLineLead;

	void __fastcall SetAutoScaleMaxFontSize(int Value);
	void __fastcall SetShowRawText(bool Value);
	void __fastcall SetShowStatusFPS(bool Value);
	void __fastcall SetShowStatusFPF(bool Value);
	void __fastcall SetShowStatusStyle(bool Value);
	void __fastcall SetStyle(TTimecode::eStyle Value);
	TTimecode::eStyle __fastcall GetStyle(void);
	void __fastcall SetStandard(TTimecode::eStandard Value);
	TTimecode::eStandard __fastcall GetStandard(void);
	void __fastcall SetPerforation(TTimecode::ePerforation Value);
	TTimecode::ePerforation __fastcall GetPerforation(void);
	TTCEdit::eHotSpot __fastcall GetHotSpot(TPoint MousePoint);
	void __fastcall SetOperation(TTimecode::eOperation Value);
	void __fastcall SetShowOperation(bool Value);
	void __fastcall SetAutoScale(bool Value);
	void __fastcall UpdateAutoScaleFontSize();
	bool __fastcall GetUseDropFrame(void);
	void __fastcall SetUseDropFrame(bool Value);
	void __fastcall SetFrames(double Value);
	double __fastcall GetFrames(void);

protected:
	TTimecode::eOperation fOperation;

	bool fShowOperation;
	bool fShowStatusFPS;
	bool fShowStatusFPF;
	bool fShowStatusStyle;
	bool fShowFocused;
	bool fTransparent;
	bool fAutoScale;
	int fAutoScaleMaxFontSize;
	TTimecode *fTC;
	UnicodeString fRawText;
	bool fShowRawText;
	bool fEditing;
	bool fModified;
	TFont * fTCFont;

	// void __fastcall OnMouseLeaveEvent(System::TObject* Sender);
	// void __fastcall OnMouseEnterEvent(System::TObject* Sender);

	Classes::TAlignment FAlignment;
	Classes::TNotifyEvent FOnChange;
	virtual void __fastcall Paint(void);
	UnicodeString __fastcall StripOutNonNumerical(UnicodeString TCText);
	UnicodeString __fastcall GetText(void);
	void __fastcall SetText(UnicodeString Value);
	DYNAMIC void __fastcall KeyUp(System::Word &Key,
		Classes::TShiftState Shift);
	DYNAMIC void __fastcall Click(void);
	DYNAMIC void __fastcall AdjustSize(void);
	virtual bool __fastcall CanResize(int &NewWidth, int &NewHeight);
	virtual void __fastcall Changed(void);

	// set transparency parameters
	virtual void __fastcall CreateParams(TCreateParams &Params);
	// Paints the parent under this control - use for transparency...
	void __fastcall DrawParentImage(TControl *Contol, TCanvas *Dest);
	void __fastcall SetTransparent(bool Value);
	void __fastcall SetAlignment(Classes::TAlignment Value);
	void __fastcall WMKillFocus(Messages::TMessage &Message);

#pragma warn -8118
	//
	BEGIN_MESSAGE_MAP
		//
		MESSAGE_HANDLER(WM_KILLFOCUS, TMessage, WMKillFocus)
		//
		END_MESSAGE_MAP(TCustomControl)
#pragma warn .8118

	public : void __fastcall ClipboardPaste(TObject *Sender);
	void __fastcall ClipboardCopy(TObject *Sender);
	void __fastcall ToggleStyle(bool Forward);
	void __fastcall ToggleFPS(bool Forward);
	void __fastcall ToggleFPF(bool Forward);
	void __fastcall ForceUpdate(void);
	virtual void __fastcall SetFocus(void);

	__fastcall TTCEdit(TComponent* Owner);
	__fastcall ~TTCEdit();

__published:
	__property Align;

	__property Classes::TAlignment Alignment = {
		read = FAlignment, write = SetAlignment, default = 1};

	// __property AutoSize;
	__property Cursor;
	__property DragCursor;
	__property Enabled;
	__property Font;
	__property Left;
	__property ParentFont;
	__property Top;
	__property Visible;

	__property Width = { default = 241};
	__property Height = { default = 65};

	// -------------MISC
	__property Name;
	__property Tag;
	__property Touch;
	// ------------LAYOUT
	__property Anchors;
	__property Constraints;
	__property Margins;
	__property TabStop;
	// ------------Legacy
	__property Ctl3D;
	__property ParentCtl3D;
	// ------------Help
	__property HelpContext;
	__property HelpKeyword;
	__property HelpType;
	__property Hint;
	__property ParentCustomHint;
	__property ParentShowHint;
	__property ShowHint;
	__property BorderWidth;
	__property ParentColor;
	__property Color;
	// __property BevelEdges;
	// __property BevelInner;
	// __property BevelOuter;
	// __property BevelKind;
	// __property BevelWidth;

	__property Classes::TNotifyEvent OnChange = {
		read = FOnChange, write = FOnChange};
	__property UnicodeString Text = {read = GetText, write = SetText};
	__property Graphics::TFont *TCFont = {read = fTCFont, write = fTCFont};
	__property int AutoSizeMaxFontSize = {
		read = fAutoScaleMaxFontSize, write = SetAutoScaleMaxFontSize,
		default = 64};
	__property bool ShowStatusFPS = {
		read = fShowStatusFPS, write = SetShowStatusFPS, default = true};
	__property bool ShowStatusFPF = {
		read = fShowStatusFPF, write = SetShowStatusFPF, default = true};
	__property bool ShowStatusStyle = {
		read = fShowStatusStyle, write = SetShowStatusStyle, default = true};
	__property bool ShowRawText = {
		read = fShowRawText, write = SetShowRawText, default = true};
	__property bool AutoScale = {
		read = fAutoScale, write = SetAutoScale, default = true};
	__property TTimecode::eStyle Style = {
		read = GetStyle, write = SetStyle, default = TTimecode::eStyle::tcStyle
	};
	__property TTimecode::eStandard Standard = {
		read = GetStandard, write = SetStandard, default =
			TTimecode::eStandard::ttPAL};
	__property TTimecode::ePerforation Perforation = {
		read = GetPerforation, write = SetPerforation, default =
			TTimecode::ePerforation::mm35_3perf};
	__property TTimecode::eOperation Operation = {
		read = fOperation, write = SetOperation, default =
			TTimecode::eOperation::oNone};
	__property bool ShowOperation = {
		read = fShowOperation, write = SetShowOperation, default = false};
	__property bool Transparent = {
		read = fTransparent, write = SetTransparent, default = false};
	__property bool UseDropFrame = {
		read = GetUseDropFrame, write = SetUseDropFrame, default = true};
	// TCEdit is a text orientated component... it was never intended to have
	// metamorfic dualality for both string and timecode.
	__property double Frames = {read = GetFrames, write = SetFrames, default = 0
	};
	__property bool Modified = {
		read = fModified, write = fModified, default = false};
	__property bool ShowFocused = {
		read = fShowFocused, write = fShowFocused, default = false};

};
// ---------------------------------------------------------------------------
#endif
