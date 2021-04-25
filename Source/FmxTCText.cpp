// ---------------------------------------------------------------------------

#include <fmx.h>

#pragma hdrstop

#include "FmxTCText.h"
#pragma package(smart_init)
// ---------------------------------------------------------------------------
// ValidCtrCheck is used to assure that the components created do not have
// any pure virtual functions.
//

static inline void ValidCtrCheck(TFmxTCText *) {
	new TFmxTCText(NULL);
}

// ---------------------------------------------------------------------------
__fastcall TFmxTCText::TFmxTCText(TComponent* Owner) : TText(Owner) {
	fShowRawText = false;
	fShowOperation = false;
	fOperation = TTimecode::eOperation::oNone;
	fTC = new TTimecode(this);
	fTC->Text = "00:00:00:00";
	fRawText = "00:00:00:00";
	TText::Text = "00:00:00:00";
	Width = 80;
	Height = 24;
	fTC->OnChange = OnChangeTimecode;
}

// ---------------------------------------------------------------------------
namespace Fmxtctext {
	void __fastcall PACKAGE Register() {
		TComponentClass classes[1] = {__classid(TFmxTCText)};
		RegisterComponents(L"Ambrosia", classes, 0);
	}
}

void __fastcall TFmxTCText::OnChangeTimecode(System::TObject* Sender){
	// TTimecode->fFrames was changed.. update the text.
	TText::Text = BuildTextStr();
}

// ---------------------------------------------------------------------------
System::UnicodeString __fastcall TFmxTCText::BuildTextStr(void) {
	UnicodeString s;
	if (fTC->Style == TTimecode::tcStyle && fTC->Standard ==
		TTimecode::ttNTSCDF && fTC->UseDropFrame) {
		// always show fully converted text
		s = fTC->Text;
	}
	else if (fTC->Style == TTimecode::tcStyle && fShowRawText) {
		// don't do full syntax checking - just display input string.
		// remove all non-numerical characters - working backwards....
		int x, y;
		UnicodeString raw;
		UnicodeString s2 = "00000000";
		if (fTC->Standard == TTimecode::ttNTSCDF && !fShowRawText)
			raw = "00;00;00;00";
		else
			raw = "00:00:00:00";
		for (x = fRawText.Length(), y = 8; x > 0 && y > 0; x--, y--) {
			while (x && (fRawText[x] < '0' || fRawText[x] > '9'))
				x--;
			if (x)
				s2[y] = fRawText[x];
		}
		// sloppy - but safe way of preparing
		raw[1] = s2[1]; // the string for diplay...
		raw[2] = s2[2]; //
		raw[4] = s2[3];
		raw[5] = s2[4];
		raw[7] = s2[5];
		raw[8] = s2[6];
		raw[10] = s2[7];
		raw[11] = s2[8];
		s = raw;
		s.SetLength(11);
	}
	else
		s = fTC->Text;

	if (fShowOperation)
		s = UnicodeString(fTC->GetOperationChar(fOperation)) + s;
	return s;
}

UnicodeString __fastcall TFmxTCText::GetText(void) {
	return BuildTextStr();
}

void __fastcall TFmxTCText::SetText(UnicodeString Value) {
	if (fTC->Text != Value) {
		fTC->Text = Value;
		fRawText = Value;
		// SetText results in TTimecode->fFrames changeing ... which intern
		// calls  TTimecode->Change() (if assigned)
		// if not assigned - to it manually.
		if (fTC->OnChange == NULL) TText::Text = BuildTextStr();
	}
}

// ---------------------------------------------------------------------------
TTimecode * __fastcall TFmxTCText::GetTimecode(void) {
	return fTC;
}

void __fastcall TFmxTCText::SetTimecode(TTimecode * Value) {
	fTC->Assign(Value);
}

void __fastcall TFmxTCText::SetShowRawText(bool Value) {
	if (fShowRawText != Value) {
		fShowRawText = Value;
		TText::Text = BuildTextStr();
	}
}

void __fastcall TFmxTCText::SetOperation(TTimecode::eOperation Value) {
	if (fOperation != Value) {
		fOperation = Value;
		TText::Text = BuildTextStr();
	}
}

void __fastcall TFmxTCText::SetShowOperation(bool Value) {
	if (fShowOperation != Value) {
		fShowOperation = Value;
		TText::Text = BuildTextStr();
	}
}

void __fastcall TFmxTCText::Paint() {
	TRectF rect;
	float StoreFontSize;
	if (!StyleName.IsEmpty()) {
		TFmxObject * sr = FindStyleResource("text");
		if (sr) {
			Canvas->Fill->Color = reinterpret_cast<TText*>(sr)->Color;
			Canvas->Font->Assign(reinterpret_cast<TText*>(sr)->Font);
		}
	}
	else {
		Canvas->Font->Assign(Font);
		Canvas->Fill->Color = Color;
	}

	rect = Margins->MarginRect(LocalRect);
	if (fAutoFitTC) {
		StoreFontSize = Canvas->Font->Size;
		float w = Canvas->TextWidth(TText::Text);
		Canvas->Font->Size = Canvas->Font->Size * (rect.Width() / w);
	}
	Canvas->FillText(rect, TText::Text, false, Opacity, TFillTextFlags(),
		HorzTextAlign, VertTextAlign);
	// FmxTCLabel inherits ...this.
	// if the font size isn't restored - FmxTCLabel doesn't paint correctly.
	// Why?
	if (fAutoFitTC)
		Canvas->Font->Size = StoreFontSize;

}

//http://docwiki.embarcadero.com/RADStudio/XE3/en/Creating_a_FireMonkey_Primitive_Control
//procedure TEllipse.Paint;
//begin
//  Canvas.FillEllipse(GetShapeRect, AbsoluteOpacity);
//  Canvas.DrawEllipse(GetShapeRect, AbsoluteOpacity);
//end;


