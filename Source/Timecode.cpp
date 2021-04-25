// ---------------------------------------------------------------------------
//#include <vcl.h>
#pragma hdrstop
#include "Timecode.h"
#pragma package(smart_init)
#include <math.h>
#include <Math.hpp>
#include <DateUtils.hpp>
#include <SysUtils.hpp>
#include <Character.hpp>
// ---------------------------------------------------------------------------
// Load & Save Timecode Global Preferences
#include <IniFiles.hpp>

#include "TimecodeDefines.h"

// ---------------------------------------------------------------------------
// CLANG COMPILER .....
// ---------------------------------------------------------------------------
// REPLACE ALL Format calls with System::String().sprintf(L"", ...)
// ANOTHER FIX FOR CLANG ...
// #if defined(__clang__)
// #define VRARRAY(...) (TVarRec[]){__VA_ARGS__}, sizeof((TVarRec[]){__VA_ARGS__})/sizeof(TVarRec)
// #else
// #define VRARRAY(...) System::OpenArray<System::TVarRec>(__VA_ARGS__), sizeof(System::OpenArrayCounter<System::TVarRec>::Count (__VA_ARGS__))-1
// #endif
// ---------------------------------------------------------------------------


// ---------------------------------------------------------------------------

#pragma region "GLOBALS"
int GlobalFPFIndex = 3;
int GlobalFPSIndex = 0;
double GlobalCustomFPS = 12.0;

#pragma end_region
// ---------------------------------------------------------------------------
// ValidCtrCheck is used to assure that the components created do not have
// any pure virtual functions.
//

static inline void ValidCtrCheck(TTimecode *) {
	new TTimecode(NULL);
}

// ---------------------------------------------------------------------------
// C O N S T R U C T O R   &   D E S T R U C T O R . . . .
// ---------------------------------------------------------------------------
__fastcall TTimecode::TTimecode(TComponent* Owner) : TComponent(Owner) {
	FUseGlobal = true;
	FFPSIndex = GlobalFPSIndex;
	FFPFIndex = GlobalFPFIndex;
	FCustomFPS = GlobalCustomFPS;
	FStyle = tcStyle;
	fFrames = 0;

	fps_table = new FPS_TABLE[5];
	fps_table[0] = {"PAL", 25.00, "25fps"};
	fps_table[1] = {"FILM", 24.00, "24fps"};
	fps_table[2] = {"NTSC DF", 29.97, "29.97"};
	// 29.97 but with drop frames
	fps_table[3] = {"NTSC", 30.00, "30fps"};
	fps_table[4] = {"CUSTOM", 12.00, "Custom fps"};
	// Always leave 'CUSTOM' last in table
	// fTCFPSCount = (sizeof(*fps_table) / sizeof(TTimecode::FPS_TABLE));
	fTCFPSCount = 5;
	// NOTE: fTCFPSCount is base 1.  FFPSIndex is base 0

	fpf_table = new FPF_TABLE[18];
	fpf_table[0] = {"16mm", 40, 0.3, 2, 16};
	fpf_table[1] = {"16/35mm sound", 16, 0.75, 2, 16};
	fpf_table[2] = {"35mm 3-perf", 22, 0.5454545454545, 3, 35};
	fpf_table[3] = {"35mm 4-perf", 16, 0.75, 4, 35};
	fpf_table[4] = {"35mm 8-perf", 8, 1.5, 8, 65};
	fpf_table[5] = {"65/70mm 3-perf", 22, 0.5454545454545, 3, 65};
	fpf_table[6] = {"65/70mm 4-perf", 16, 0.75, 4, 65};
	fpf_table[7] = {"65/70mm 5-perf", 13, 0.9230769230769, 5, 65};
	fpf_table[8] = {"65/70mm 6-perf", 11, 1.090909090909, 6, 65};
	fpf_table[9] = {"65/70mm 7-perf", 10, 1.2, 7, 65};
	fpf_table[10] = {"65/70mm 8-perf", 8, 1.5, 8, 65};
	fpf_table[11] = {"65/70mm 9-perf", 8, 1.5, 9, 65};
	fpf_table[12] = {"65/70mm 10-perf", 7, 1.714285714286, 10, 65};
	fpf_table[13] = {"65/70mm 11-perf", 6, 2.0, 11, 65};
	fpf_table[14] = {"65/70mm 12-perf", 6, 2.0, 12, 6};
	fpf_table[15] = {"65/70mm 13-perf", 5, 2.4, 13, 65};
	fpf_table[16] = {"65/70mm 14-perf", 5, 2.4, 14, 65};
	fpf_table[17] = {"65/70mm 15-perf", 5, 2.4, 15, 65};

	// fTCFPFCount = (sizeof(*fpf_table) / sizeof(TTimecode::FPF_TABLE));
	fTCFPFCount = 18;
	// NOTE: fTCFPFCount is base 1.  FFPFIndex is base 0

	tc_displaystyle = new TC_DISPLAYSTYLE[4];
	tc_displaystyle[0] = {"HH:MM:SS:FF", 0, "Timecode"};
	tc_displaystyle[1] = {"Hr.Min.Sec", 1, "Time"};
	tc_displaystyle[2] = {"Frames", 2, "Frames"};
	tc_displaystyle[3] = {"Footage", 3, "Footage"};

	// fTCDisplayStylesCount = (sizeof(*tc_displaystyle) / sizeof(TTimecode::TC_DISPLAYSTYLE));
	fTCDisplayStylesCount = 4;
	// NOTE: fTCDisplayStylesCount is base 1. enum eStyle .. eStyle FStyle are base 0
	// Unless specified otherwise, enums start numbering at 0, and increment by 1 each entry

	MathsChar = new wchar_t[5];
	MathsChar[0] = {'*'};
	MathsChar[1] = {'+'};
	MathsChar[2] = {'-'};
	MathsChar[3] = {'/'};
	MathsChar[4] = {'='};
}

// ---------------------------------------------------------------------------
__fastcall TTimecode::~TTimecode() {
	delete[] fps_table;
	delete[] fpf_table;
	delete[] tc_displaystyle;
	delete[] MathsChar;
}

// ---------------------------------------------------------------------------
namespace Timecode {
	void __fastcall PACKAGE Register() {
		TComponentClass classes[1] = {__classid(TTimecode)};
		RegisterComponents("Ambrosia", classes, 0);
	}
}

// ---------------------------------------------------------------------------
// O V E R L O A D E D     O P E R A T O R S > > > >
// . . . .
// ---------------------------------------------------------------------------
const int TTimecode:: operator == (const TTimecode* t) {
	return (fFrames == t->fFrames) ? 1 : 0;
}

const int TTimecode:: operator != (const TTimecode* t) {
	/*
	 if (FFrames == t.FFrames
	 && FFPSIndex == t.FFPSIndex
	 && FFPSIndex == MAXFPSINDEXNUM) {
	 if (FCustomFPS != t.FCustomFPS)	return 1;
	 }
	 else if (FFrames != t.FFrames || FFPSIndex != t.FFPSIndex){
	 return 1;
	 }
	 */
	return (fFrames != t->fFrames) ? 1 : 0;
}

const int TTimecode:: operator < (const TTimecode* t) {
	/*
	 double tFPS = const_cast<TTimecode*>(t).GetFPS();
	 if (GetFPS() != tFPS)
	 return(FFrames * GetFPS() < t.FFrames * tFPS);
	 else
	 return(FFrames < t.FFrames);
	 */
	return (fFrames < t->fFrames) ? 1 : 0;
}

const int TTimecode:: operator > (const TTimecode* t) {
	/*
	 double tFPS = const_cast<TTimecode*>(t).GetFPS();
	 if (GetFPS() != tFPS)
	 return(FFrames * GetFPS() < t.FFrames * tFPS);
	 else
	 return(FFrames > t.FFrames);
	 */
	return (fFrames > t->fFrames) ? 1 : 0;
}

const int TTimecode:: operator <= (const TTimecode* t) {
	/*
	 double tFPS = const_cast<TTimecode*>(t).GetFPS();
	 if (GetFPS() != tFPS)
	 return(FFrames * GetFPS() < t.FFrames * tFPS);
	 else
	 return(FFrames <= t.FFrames);
	 */
	return (fFrames <= t->fFrames) ? 1 : 0;
}

const int TTimecode:: operator >= (const TTimecode* t) {
	/*
	 double tFPS = const_cast<TTimecode*>(t).GetFPS();
	 if (GetFPS() != tFPS)
	 return(FFrames * GetFPS() < t.FFrames * tFPS);
	 else
	 return(FFrames >= t.FFrames);
	 */
	return (fFrames >= t->fFrames) ? 1 : 0;
}

TTimecode* TTimecode:: operator -(const TTimecode* t) {
	// subtract
	/*
	 double tFPS = const_cast<TTimecode*>(t).GetFPS();
	 if (GetFPS() == tFPS)
	 FFrames = FFrames - t.FFrames;
	 else if (t.FFrames)
	 FFrames = FFrames - (t.FFrames / tFPS * GetFPS());
	 */
	fFrames = fFrames - t->fFrames;
	return this;
}

TTimecode* TTimecode:: operator +(const TTimecode* t) {
	// addition
	/*
	 double tFPS = const_cast<TTimecode*>(t).GetFPS();
	 if (GetFPS() == tFPS)
	 FFrames = FFrames + t.FFrames;
	 else if (t.FFrames)
	 FFrames = FFrames + (t.FFrames / tFPS * GetFPS());
	 */
	fFrames = fFrames + t->fFrames;
	return this;
}

void __fastcall TTimecode::Assign(Classes::TPersistent* Source) {
	if (Source->ClassNameIs("TTimecode")) {
		TTimecode * tc = reinterpret_cast<TTimecode*>(Source);
		FStyle = tc->FStyle;
		FFPFIndex = tc->FFPFIndex;
		FFPSIndex = tc->FFPSIndex;
		FCustomFPS = tc->FCustomFPS;
		FUseGlobal = tc->FUseGlobal;
		fFrames = tc->fFrames;
	}
	else
		TComponent::Assign(Source);
}

// ---------------------------------------------------------------------------
// F U N C T I O N S . . . . . R O U T I N E S . . .
// . . . .
// ---------------------------------------------------------------------------
/*
 Drop-Frame Timecode

 In one hour, a 30FPS system produces 108 frames more than one running at
 29.97FPS. To reconcile this difference, two specific time code frame values
 are dropped each minute (2x60=120), except every 10th minute (2x60-2x6=108).
 The time code values dropped are specified as the first two frames of a minute.

 Thus, the time code label following 01:04:59:29 would be 01:05:00:02, time code
 labels 01:05:00:00 and 01:05:00:01 don't exist.
 */
double __fastcall TTimecode::ConvertFramesDFtoND(double value) {
	// convert 29.97 fps to 30 fps - using drop-frame conversion rules.
	double frac, f1, f2;
	// calculate seconds
	double sec = value / GetFPS();
	// count the minute intervals x 2
	frac = sec / 60.0;
	// extract the integer portion of the double
	modf(frac, &f1);
	// calculate frames
	f1 = f1 * 2;
	// count the number of 10min blocks x 2
	frac = sec / 600.0;
	// extract the integer portion of the double
	modf(frac, &f2);
	// calculate frames
	f2 = f2 * 2;
	// wrap it up
	return (value + f1 - f2);
}

double __fastcall TTimecode::ConvertFramesNDtoDF(double value) {
	// convert ND to seconds then divide by DF.
	// Returns frames count at 29.97.
	double v = value / 30.0 * 29.97;
	return (v);
}

void __fastcall TTimecode::SetText(UnicodeString value) {
	/* TODO :
	 Extract feet + frames from Footage Style
	 Extract fraction of seconds from Time Style */
	UnicodeString str1, str2;
	int x, y;
	double frames, val;
	double fpm = GetFPS() * 60.0;
	double fph = GetFPS() * 3600.0;
	value = value.Trim();
	// remove all non-numerical characters
	// working backwards....
	// no error checking of Hrs, Mins, secs, Frames.....!!
	str1 = "00000000";
	for (x = value.Length(), y = 8; x > 0 && y > 0; x--, y--) {
		while (x && (value[x] < '0' || value[x] > '9'))
			x--;
		if (x)
			str1[y] = value[x];
	}
	switch (FStyle) {
	case eStyle::tcStyle: // cheap and nasty way to get frame count
			// HH::MM::SS::FF
			str2 = str1.SubString(1, 2);
		frames = str2.ToInt() * fph;
		str2 = str1.SubString(3, 2);
		frames = str2.ToInt() * fpm + frames;
		str2 = str1.SubString(5, 2);
		frames = str2.ToInt() * GetFPS() + frames;
		str2 = str1.SubString(7, 2);
		frames = frames + str2.ToInt();
		break;
	case eStyle::timeStyle:
			// hrs::Mins::Secs...
			str2 = str1.SubString(3, 2);
		frames = str2.ToInt() * fph;
		str2 = str1.SubString(5, 2);
		frames = str2.ToInt() * fpm + frames;
		str2 = str1.SubString(7, 2);
		frames = str2.ToInt() * GetFPS() + frames;
		break;
	case eStyle::frameStyle:
		frames = StrToIntDef(str1, 0);
		break;
	case eStyle::footageStyle:
			// parameter contains feet only; - no frames...
			frames = StrToInt(str1);
		frames = frames * GetFPF();
		break;
	}
	// Update fTimeStamp
	SetFrames(frames);
}

UnicodeString __fastcall TTimecode::GetSimpleText() {
	// Short:
	// Simple text routine trims any redundant fields.
	// Remarks:
	// String width will vary.
	UnicodeString FText, temp;
	TTime dt;
	Word Hour, Min, Sec, MSec;
	switch (FStyle) {
	case timeStyle:
		dt = FramesToTime();
		// the time value is empty.
		if (!Hour && !Min && !Sec) {
			FText = "...";
		}
		DecodeTime(dt, Hour, Min, Sec, MSec);
		FText = "";
		// only show hours if we have them
		if (Hour) {
			FText = FText + IntToStr(Hour);
			if (Min && Sec) {
				FText = FText + ":";
			}
			else if (Min && !Sec)
				FText = FText + "h";
			else if (!Min && Sec)
				FText = FText + "h...";
			else {
				// We only have hours.
				FText = FText + "hrs.";
			}
		}
		// if we have no minutes....
		// if we have hours || (hour && secs) we must show minutes
		if (Min || (Hour && Sec)) {
			// CLANG FAILS
			// temp = FText + Format("%2.2d", ARRAYOFCONST((Variant(Min))));
			temp = FText + System::String().sprintf(L"%2.2d", Min);
			if (Hour && Sec && Min)
				FText = temp + ":";
			else if (Min && ((Hour && !Sec) || (!Hour && Sec)))
				FText = temp + "m";
			else if (Min && !Hour && !Sec)
				// We only have mins.
					FText = temp + "mins.";
		}
		// always show seconds.
		if (Sec) {
			// CLANG FAILS
			// FText = FText + Format("%2.2d", ARRAYOFCONST((Variant(Sec))));
			FText = FText + System::String().sprintf(L"%2.2d", Sec);
			if (!Hour && !Min)
				FText = FText + "secs.";
			else if ((Hour && !Min) || (!Hour && Min))
				FText = FText + "s";
		}
		break;
	default:
		FText = GetText();
	}
	return FText;
}

UnicodeString __fastcall TTimecode::GetText() {
	UnicodeString FText;
	UnicodeString Buf;
	if (GetStandard() == ttNTSCDF && FUseDropFrame)
		FText = "00;00;00;00";
	else
		FText = "00:00:00:00";
	double fraction, hours, minutes, seconds, remainder, frames, feet;
	UnicodeString format = "00.00";
	ldiv_t dd;
	double val, frameRate;
	frames = GetFrames();
	switch (FStyle) {
	case tcStyle:
	case timeStyle:
		frameRate = GetFPS();
		if (frameRate == 0) {
			FText = "ER:R_:FP:S_";
			break;
		}
		if (fFrames == 0 && FStyle == tcStyle)
			break;
		if (frames < 0) // sort out negative amounts
		{
			frames = -frames;
			frames = (frameRate * 3600.0 * frameRate) - frames;
		}
		if ((GetStandard() == ttNTSCDF) && FUseDropFrame) {
			// take 29.97 and convert for display as 30fps
			// using the drop frame conversion rules...
			frames = ConvertFramesDFtoND(frames);
			// frame rate is now 30fps
			// frameRate = 30.0;
		}
		// step one: find the number of seconds.... and the number of frames...
		seconds = frames / frameRate; //
		fraction = modf(seconds, &seconds); //
		frames = frameRate * fraction; // find frames
		hours = seconds / 3600.0; // find hours
		modf(hours, &hours); //
		if (hours)
			seconds = seconds - (3600.0 * hours);
		minutes = seconds / 60.0; // find minutes
		modf(minutes, &minutes); //
		if (minutes)
			seconds = seconds - (60.0 * minutes);
		fraction = modf(frames, &frames); // resolve rounding problems
		if (fraction >= .5)
			frames++; // round up or down - by hand...
		if (frames >= frameRate) { // frames may exceed the
			frames = 0; // current timebase. Make the
			seconds++; // appropriate adjustment...
		}
		if (seconds >= 60) {
			seconds = 0;
			minutes++;
		}
		if (minutes >= 60) {
			minutes = 0;
			hours++;
		}
		if (FStyle == tcStyle) {
			Buf = Buf.FormatFloat(format, hours);
			// sloppy - but safe way of preparing
			FText[1] = Buf[1]; // the string for diplay...
			FText[2] = Buf[2]; //
			Buf = Buf.FormatFloat(format, minutes);
			FText[4] = Buf[1];
			FText[5] = Buf[2];
			Buf = Buf.FormatFloat(format, seconds); // find seconds
			FText[7] = Buf[1];
			FText[8] = Buf[2];
			Buf = Buf.FormatFloat(format, frames);
			FText[10] = Buf[1];
			FText[11] = Buf[2];
		}
		else {
			// to make all padding zero's (not blanks) FormatFloat was used.
			FText = FormatFloat("00", hours) + "h" + FormatFloat("00", minutes)
				+ "m" + FormatFloat("00", seconds) + "s";
		}
		break;
	case frameStyle:
		// CLANG FAILS
		// FText = Format("%dfr", Args, 0);
		FText = System::String().sprintf(L"%dfr", frames);
		break;
	case footageStyle:
		if (FFPFIndex > (fTCFPFCount-1)) {
			// error - illegal index....
			break;
		}
		// dd.quot portion has feet...
		dd = ldiv(static_cast<long double>(frames),
			static_cast<long double>(GetFPF()));
		remainder = fmod(static_cast<long double>(frames),
			static_cast<long double>(GetFPF()));
		// CLANG FAILS
		// FText = Format("%0.0fFt.%2.0ffr", Args, 1);
		FText = System::String().sprintf(L"%0.0fFt.%2.0ffr", dd.quot, remainder);
		break;
	default: ;
	}
	return FText;
}

UnicodeString __fastcall TTimecode::GetStatusFPF() {
	UnicodeString str;
	int i = GetFPFIndex();
	str = fpf_table[i].Caption;
	return str;
}

UnicodeString __fastcall TTimecode::GetShortStatusFPS()
	// Remarks:
	// By using GetFPS() we sort out wether we are using Global or Local.
{
	UnicodeString str;
	Variant var(GetFPS());
	// CLANG FAILS
	// str = Format("%gfps", ARRAYOFCONST((var)));
	str = System::String().sprintf(L"%gfps", GetFPS());
	return str;
}

UnicodeString __fastcall TTimecode::GetStatusFPS()
	// Remarks:
	// By using GetFPS() we sort out wether we are using Global or Local.
{
	UnicodeString str;
	// CLANG FAILS
	// str = str2 + Format("%3.2ffps", VRARRAY((var)));
	str = fps_table[GetFPSIndex()].Caption + System::String().sprintf
		(L" %3.2ffps", GetFPS());
	return str;
}

UnicodeString __fastcall TTimecode::GetStatus() {
	UnicodeString str;
	str = GetStatusFPS();
	str = str + " " + GetStatusFPF();
	return str;
}

void __fastcall TTimecode::SetFrames(double value) {
	if (fFrames != value) {
		fFrames = value;
	}
}

double __fastcall TTimecode::GetFrames(void) {
	return fFrames;
}

TTimecode::eStandard __fastcall TTimecode::GetStandard(void)
	// Doc-O-Matic
	// Short:
	// Get the current FPS stated as an enumerator.
	// Long :
	// Using the FPSIndex value... lookup the correct eStandard enumerator.
	// <p>By calling GetFPSIndex() it sorts out if we are using the GLOBAL index
	// or the Local FFPSIndex param.
	// Returns:
	// eStandard - A TTimecode enumerator ttPAL, ttFILM, ttNTSCDF, ttNTSC, ttCUSTOM.
{
	TTimecode::eStandard value;
	int i;
	i = GetFPSIndex();
	switch (i) {
	case 0:
		value = TTimecode::eStandard::ttPAL;
		break;
	case 1:
		value = TTimecode::eStandard::ttFILM;
		break;
	case 2:
		value = TTimecode::eStandard::ttNTSCDF;
		break;
	case 3:
		value = TTimecode::eStandard::ttNTSC;
		break;
	case 4:
	default:
		value = TTimecode::eStandard::ttCUSTOM;
		break;
	}
	return value;
}

TTimecode::ePerforation __fastcall TTimecode::GetPerforation(void) {
	return (static_cast<TTimecode::ePerforation>(GetFPFIndex()));
}

void __fastcall TTimecode::SetPerforation(TTimecode::ePerforation Value) {
	int i = GetFPFIndex();
	if (i != static_cast<int>(Value)) {
		SetFPFIndex(static_cast<int>(Value));
	}
}

void __fastcall TTimecode::SetStandard(TTimecode::eStandard eFPSvalue)
	// Doc-O-Matic
	// Short:
	// Set the FPS index value based on the given enumerator.
	// Long :
	// Modify the FFPSIndex based on the TTimecode::eStandard given.
	// <p> Calling SetFPSIndex ensures that the correct parma is updates. ie. either
	// GLOBAL or the Local FFPSIndex value.
	// Inputs:
	// eFPSvalue - A timecode enumerator.
{
	int i;
	switch (eFPSvalue) {
	case eStandard::ttPAL:
		i = 0;
		break;
	case eStandard::ttFILM:
		i = 1;
		break;
	case eStandard::ttNTSCDF:
		i = 2;
		break;
	case eStandard::ttNTSC:
		i = 3;
		break;
	case eStandard::ttCUSTOM:
		i = 4;
		break;
	default: ;
	}
	SetFPSIndex(i);
}

int __fastcall TTimecode::GetFPF(void) {
	int AFPF;
	if (FUseGlobal) {
		AFPF = fpf_table[GlobalFPFIndex].fpf;
	}
	else {
		AFPF = fpf_table[FFPFIndex].fpf;
	}
	return AFPF;
}

double __fastcall TTimecode::GetGateWidth(void) {
	double GateWidth;
	if (FUseGlobal) {
		GateWidth = fpf_table[GlobalFPFIndex].GateWidth;
	}
	else {
		GateWidth = fpf_table[FFPFIndex].GateWidth;
	}
	return GateWidth;
}

int __fastcall TTimecode::GetPerf(void) {
	int perf;
	if (FUseGlobal) {
		perf = fpf_table[GlobalFPFIndex].perf;
	}
	else {
		perf = fpf_table[FFPFIndex].perf;
	}
	return perf;
}

int __fastcall TTimecode::GetGate(void) {
	int gate;
	if (FUseGlobal) {
		gate = fpf_table[GlobalFPFIndex].gate;
	}
	else {
		gate = fpf_table[FFPFIndex].gate;
	}
	return gate;
}

double __fastcall TTimecode::GetFPS(void) {
	double AFPS;
	if (FUseGlobal) {
		if (FFPSIndex == (fTCFPSCount-1)) {
			AFPS = GlobalCustomFPS;
		}
		else {
			AFPS = fps_table[GlobalFPSIndex].fps;
		}
	}
	else {
		if (FFPSIndex == (fTCFPSCount-1)) {
			AFPS = FCustomFPS;
		}
		else {
			AFPS = fps_table[FFPSIndex].fps;
		}
	}
	return AFPS;
}

double __fastcall TTimecode::GetCustomFPS(void) {
	double f;
	if (FUseGlobal) {
		f = GlobalCustomFPS;
	}
	else {
		f = FCustomFPS;
	}
	return f;
}

void __fastcall TTimecode::ToggleFPS(bool Forward) {
	if (FUseGlobal) {
		if (Forward)
			GlobalFPSIndex++;
		else
			GlobalFPSIndex--;
		if (GlobalFPSIndex > (fTCFPSCount-1))
			GlobalFPSIndex = 0;
		if (GlobalFPSIndex < 0)
			GlobalFPSIndex = (fTCFPSCount-1);
	}
	else {
		if (Forward)
			FFPSIndex++;
		else
			FFPSIndex--;
		if (FFPSIndex > (fTCFPSCount-1))
			FFPSIndex = 0;
		if (FFPSIndex < 0)
			FFPSIndex = (fTCFPSCount-1);
	}
}

void __fastcall TTimecode::ToggleFPF(bool Forward) {
	if (FUseGlobal) {
		if (Forward)
			GlobalFPFIndex++;
		else
			GlobalFPFIndex--;
		if (GlobalFPFIndex > (fTCFPFCount-1))
			GlobalFPFIndex = 0;
		if (GlobalFPFIndex < 0)
			GlobalFPFIndex = (fTCFPFCount-1);
	}
	else {
		if (Forward)
			FFPFIndex++;
		else
			FFPFIndex--;
		if (FFPFIndex > (fTCFPFCount-1))
			FFPFIndex = 0;
		if (FFPFIndex < 0)
			FFPFIndex = (fTCFPFCount-1);
	}
}

void __fastcall TTimecode::ToggleStyle(bool Forward) {
	int i = static_cast<int>(FStyle);
	if (Forward)
		i++;
	else
		i--;
	if (i > (fTCDisplayStylesCount-1))
		i = 0;
	if (i < 0)
		i = (fTCDisplayStylesCount-1);
	FStyle = static_cast<eStyle>(i);
}

void __fastcall TTimecode::SetCustomFPS(double value) {
	if (FUseGlobal) {
		if (GlobalCustomFPS != value)
			GlobalCustomFPS = value;
	}
	else {
		if (FCustomFPS != value)
			FCustomFPS = value;
	}
}

void __fastcall TTimecode::SetFPS(double Value) {
	int i;
	for (i = 0; i < 4; i++) {
		if (Value == fps_table[i].fps) {
			if (FUseGlobal) {
				GlobalFPSIndex = i;
			}
			else {
				FFPSIndex = i;
			}
			break;
		}
	}
	if (i == (fTCFPSCount-1)) { // Use Custom FPS
		if (FUseGlobal) {
			GlobalFPSIndex = (fTCFPSCount-1);
			GlobalCustomFPS = Value;
		}
		else {
			FPSIndex = (fTCFPSCount-1);
			FCustomFPS = Value;
		}
	}
}

void __fastcall TTimecode::SetFPSIndex(int value) {
	if (FUseGlobal) {
		if (GlobalFPSIndex != value && value >= 0 && value <= (fTCFPSCount-1))
			GlobalFPSIndex = value;
	}
	else {
		if (FFPSIndex != value && value >= 0 && value <= (fTCFPSCount-1))
			FFPSIndex = value;
	}
}

int __fastcall TTimecode::GetFPSIndex(void) {
	if (FUseGlobal) {
		return GlobalFPSIndex;
	}
	else {
		return FFPSIndex;
	}
}

void __fastcall TTimecode::SetFPFIndex(int value) {
	if (FUseGlobal) {
		if (GlobalFPFIndex != value && value >= 0 && value <= (fTCFPFCount-1))
			GlobalFPFIndex = value;
	}
	else {
		if (FFPFIndex != value && value >= 0 && value <= (fTCFPFCount-1))
			FFPFIndex = value;
	}
}

int __fastcall TTimecode::GetFPFIndex(void) {
	if (FUseGlobal) {
		return GlobalFPFIndex;
	}
	else {
		return FFPFIndex;
	}
}

TTime __fastcall TTimecode::FramesToTime() {
	TTimeStamp ts;
	// There are no TDateTime values from –1 through 0.
	// A TDateTime value of 0.0 causes an exception.
	// ts.Date = the number of days since 1/1/0001 plus one.
	ts.Date = 1;
	ts.Time = (fFrames / GetFPS()) * (double)MSecsPerSec;
	return TimeStampToDateTime(ts);
}

void __fastcall TTimecode::TimeToFrames(TTime dt) {
	TTimeStamp ts;
	ts = DateTimeToTimeStamp(dt);
	fFrames = ((double)ts.Time / (double)MSecsPerSec) * GetFPS();
}

TTimecode::eStyle __fastcall TTimecode::GetStyle(void) {
	return FStyle;
}

void __fastcall TTimecode::SetStyle(eStyle Value) {
	if (FStyle != Value) {
		FStyle = Value;
	}
}

void __fastcall TTimecode::SetStyleIndex(int Value) {
	if (Value >= 0 && Value <= (fTCDisplayStylesCount-1)) {
		if (FStyle != static_cast<eStyle>(Value)) {
			FStyle = static_cast<eStyle>(Value);
		}
	}
}

int __fastcall TTimecode::GetStyleIndex(void) {
	return static_cast<int>(FStyle);
}

UnicodeString __fastcall TTimecode::GetStatusStyle() {
	return tc_displaystyle[static_cast<int>(FStyle)].AltCaption;
}

UnicodeString __fastcall TTimecode::StripDown(void) {
	int x, y, i = 0;
	UnicodeString s = "";
	UnicodeString s2 = GetText();
	// Strip out non-numbers
	for (x = 1; x <= s2.Length(); x++) {
#pragma warn -8111
		if (IsNumber(s2[x]) || s2[x] == '.') {
			s = s + s2[x];
		}
	}
#pragma warn .8111
	// strip out leading zeros
	if (!s.IsEmpty()) {
		for (x = 1; x <= s.Length(); x++) {
			if (s[x] != '0') {
				i = x;
				break;
			}
		}
		s = s.SubString(i, s.Length());
	}
	return s;
}

wchar_t __fastcall TTimecode::GetOperationChar(TTimecode::eOperation Value) {
	wchar_t c;
	switch (Value) {
	case TTimecode::eOperation::oMultiply:
		c = MathsChar[0];
		break;
	case TTimecode::eOperation::oAdd:
		c = MathsChar[1];
		break;
	case TTimecode::eOperation::oSubtract:
		c = MathsChar[2];
		break;
	case TTimecode::eOperation::oDivide:
		c = MathsChar[3];
		break;
	case TTimecode::eOperation::oEquals:
		c = MathsChar[4];
		break;
	case TTimecode::eOperation::oNone:
	default:
		c = '.';
	}
	return c;
}
#pragma region "TTimecode Global Timecode Preferences"

// ---------------------------------------------------------------------------
// GLOBAL - PREFERENCES
// Timecode.ini - FPF and FPS parameters...
// ---------------------------------------------------------------------------
// By default all new VCL TTimcode's are set to 'UseGlobal = true'.
//
// ---------------------------------------------------------------------------
void LoadGlobalTCPreferences(void) {
	// ---------------------------------------------------------------------------
	// LOAD GLOBAL TIMECODE PREFERENCES....
	// ---------------------------------------------------------------------------
	// "$CURRENTUSER$\\APPDATA\\Ambrosia\\GlobalPrefs\\Timecode.ini"
	// NOTE: for the current user...
	// If the file 'Timecode.ini' doesn't exists, then stay with default values
	// given during the creation of the TTimecode VCL.
	// ---------------------------------------------------------------------------
	UnicodeString PrefFile;
	PrefFile = GetGlobalTCPrefFileName();
	if (!PrefFile.IsEmpty()) {
		ReadGlobalTCPrefFile(PrefFile);
	}
}

void SaveGlobalTCPreferences(void) {
	// ---------------------------------------------------------------------------
	// LOAD THE GLOBAL TIMECODE PREFERNCES
	// CONSIDERATION : First check that your TTimcode VCL is using
	// Global Preferences....
	// ---------------------------------------------------------------------------
	UnicodeString PrefFile;
	PrefFile = GetGlobalTCPrefFileName();
	if (PrefFile.IsEmpty()) {
		if (CreateGlobalTCPrefFileName()) {
			// go get the PrefFile again check for it's existance
			PrefFile = GetGlobalTCPrefFileName();
		}
	}
	// assert PrefFile ...
	if (!PrefFile.IsEmpty() && FileExists(PrefFile)) {
		WriteGlobalTCPrefFile(PrefFile);
	}
}

UnicodeString __fastcall GetGlobalTCPrefFileName() {
	UnicodeString str;
	str = GetEnvironmentVariable("APPDATA");
	str = str + "\\Ambrosia\\GlobalPrefs\\Timecode.ini";
	if (!FileExists(str)) {
		str = "";
	}
	return str;
}

// ---------------------------------------------------------------------------
bool __fastcall CreateGlobalTCPrefFileName() {
	UnicodeString str;
	str = GetEnvironmentVariable("APPDATA");
	str = str + "\\Ambrosia\\GlobalPrefs";
	// Assert directory exists!
	if (!DirectoryExists(str)) {
		if (!CreateDir(str))
			return false; // FAILED!
	}
	str = str + "\\Timecode.ini";
	if (!FileExists(str)) {
		int filehandle = FileCreate(str);
		if (filehandle != -1) {
			FileClose(filehandle);
		}
	}
	// Last & final check for file...
	return (FileExists(str));
}

// ---------------------------------------------------------------------------
void __fastcall ReadGlobalTCPrefFile(UnicodeString FileName) {
	TIniFile *PrefFile = new TIniFile(FileName);
	GlobalFPSIndex = PrefFile->ReadInteger("Pref", "FPSIndex", 0);
	GlobalFPFIndex = PrefFile->ReadInteger("Pref", "FPFIndex", 3);
	GlobalCustomFPS = PrefFile->ReadFloat("Pref", "CustomFPS", 25.0);
	delete PrefFile;
}

// ---------------------------------------------------------------------------
void __fastcall WriteGlobalTCPrefFile(UnicodeString FileName) {
	TIniFile *PrefFile = new TIniFile(FileName);
	PrefFile->WriteInteger("Pref", "FPSIndex", GlobalFPSIndex);
	PrefFile->WriteInteger("Pref", "FPFIndex", GlobalFPFIndex);
	PrefFile->WriteFloat("Pref", "CustomFPS", GlobalCustomFPS);
	delete PrefFile;
}
#pragma end_region
