// ---------------------------------------------------------------------------

#include <fmx.h>

#pragma hdrstop

#include "FmxTCLabel.h"
#pragma package(smart_init)

extern wchar_t MathsChar[];

// ---------------------------------------------------------------------------
// ValidCtrCheck is used to assure that the components created do not have
// any pure virtual functions.
//

static inline void ValidCtrCheck(TFmxTCLabel *) {
	new TFmxTCLabel(NULL);
}

// ---------------------------------------------------------------------------
__fastcall TFmxTCLabel::TFmxTCLabel(TComponent* Owner) : TFmxTCText(Owner) {
	fShowStatus = true;
}

__fastcall TFmxTCLabel::~TFmxTCLabel(void) {
}

// ---------------------------------------------------------------------------
namespace Fmxtclabel {
	void __fastcall PACKAGE Register() {
		TComponentClass classes[1] = {__classid(TFmxTCLabel)};
		RegisterComponents(L"Ambrosia", classes, 0);
	}
}
// ---------------------------------------------------------------------------

void __fastcall TFmxTCLabel::Paint() {
	float txtWidth, txtHeight, padLeft, padRight, padTop;
	TRectF rect;
	UnicodeString s;

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
	if (fShowStatus) {
		// DISPLAY STATUS FPS displayed bottom.right
		s = Timecode->StatusFPS;
		rect = Margins->MarginRect(LocalRect);
		Canvas->FillText(rect, s, false, Opacity, TFillTextFlags(),
			TTextAlign::Trailing, TTextAlign::Trailing);
		// DISPLAY STATUS FPF displayed bottom.left
		s = Timecode->StatusFPF;
		Canvas->FillText(rect, s, false, Opacity, TFillTextFlags(),
			TTextAlign::Leading, TTextAlign::Trailing);
	}
	// go paint the timecode string...
	TFmxTCText::Paint();

}

void __fastcall TFmxTCLabel::SetShowStatus(bool Value) {
	if (fShowStatus != Value) {
		fShowStatus = Value;
		InvalidateRect(LocalRect);
	}
}
