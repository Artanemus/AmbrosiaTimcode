// ---------------------------------------------------------------------------
#ifndef TimecodeH
#define TimecodeH
// ---------------------------------------------------------------------------
#include <Classes.hpp>

// ---------------------------------------------------------------------------
class PACKAGE TTimecode : public TComponent {
private:
	struct FPS_TABLE {
		char Caption[25];
		double fps;
		char FPSCaption[25];
	};

	struct FPF_TABLE {
		char Caption[25];
		int fpf;
		double GateWidth;
		int perf;
		int gate;
	};

	struct TC_DISPLAYSTYLE {
		char Caption[25];
		int style;
		char AltCaption[25];
	};
public:
	enum eStyle {
		tcStyle, timeStyle, frameStyle, footageStyle
	};

	enum eStandard {
		ttPAL, ttFILM, ttNTSCDF, ttNTSC, ttCUSTOM
	};

	enum ePerforation {
		mm16, mm16_35_sound, mm35_3perf, mm35_4perf, mm35_8perf, mm65_70_3perf,
		mm65_70_4perf, mm65_70_5perf, mm65_70_6perf, mm65_70_7perf,
		mm65_70_8perf, mm65_70_9perf, mm65_70_10perf, mm65_70_11perf,
		mm65_70_12perf, mm65_70_13perf, mm65_70_14perf, mm65_70_15perf
	};

	enum eOperation {
		oMultiply, oAdd, oSubtract, oDivide, oEquals, oNone
	};

	struct FPS_TABLE *fps_table;
	struct FPF_TABLE *fpf_table;
	struct TC_DISPLAYSTYLE *tc_displaystyle;
	wchar_t *MathsChar;

private:
	eStyle FStyle;
	int FFPFIndex;
	int FFPSIndex;
	int fStyleIndex;
	double FCustomFPS;
	bool FUseGlobal;
	// TTimeStamp fTimeStamp;
	double fFrames;
	bool FUseDropFrame;
	System::Classes::TNotifyEvent FOnChange;
	int fTCFPSCount;
	int fTCFPFCount;
	int fTCDisplayStylesCount;

	void __fastcall SetText(UnicodeString value);
	UnicodeString __fastcall GetText();
	void __fastcall SetFPSIndex(int value);
	int __fastcall GetFPSIndex(void);
	void __fastcall SetFPFIndex(int value);
	int __fastcall GetFPFIndex(void);
	void __fastcall SetStyleIndex(int Value);
	int __fastcall GetStyleIndex(void);
	TTimecode::eStandard __fastcall GetStandard(void);
	void __fastcall SetStandard(TTimecode::eStandard Value);
	TTimecode::ePerforation __fastcall GetPerforation(void);
	void __fastcall SetPerforation(TTimecode::ePerforation Value);
	void __fastcall SetFPS(double value);
	double __fastcall GetCustomFPS(void);
	void __fastcall SetCustomFPS(double value);
	double __fastcall GetFPS(void);
	int __fastcall GetFPF(void);
	UnicodeString __fastcall GetStatus();
	UnicodeString __fastcall GetStatusFPS();
	UnicodeString __fastcall GetShortStatusFPS();
	UnicodeString __fastcall GetStatusFPF();
	UnicodeString __fastcall GetStatusStyle();
	double __fastcall GetGateWidth(void);
	int __fastcall GetPerf(void);
	int __fastcall GetGate(void);
	void __fastcall SetFrames(double value);
	double __fastcall GetFrames(void);
	TTimecode::eStyle __fastcall GetStyle(void);
	void __fastcall SetStyle(TTimecode::eStyle Value);
protected:
	void __fastcall Change(void);

public:
	double __fastcall ConvertFramesNDtoDF(double value);
	double __fastcall ConvertFramesDFtoND(double value);
	__fastcall TTimecode(TComponent* Owner);
	__fastcall ~TTimecode(); // destructor
	const int operator == (const TTimecode* t); // equates
	const int operator != (const TTimecode* t); // not equal
	const int operator < (const TTimecode* t); //
	const int operator > (const TTimecode* t); //
	const int operator >= (const TTimecode* t); //
	const int operator <= (const TTimecode* t); //
	TTimecode* operator -(const TTimecode* t); // subtract
	TTimecode* operator +(const TTimecode* t); // addition
	TTime __fastcall FramesToTime();
	void __fastcall TimeToFrames(TTime dt);
	virtual void __fastcall Assign(Classes::TPersistent* Source);
	void __fastcall ToggleFPS(bool Forward = true);
	void __fastcall ToggleFPF(bool Forward = true);
	void __fastcall ToggleStyle(bool Forward = true);
	// Simple text routine trims any redundant fields.
	// Stringwidth will vary.
	UnicodeString __fastcall GetSimpleText(void);
	wchar_t __fastcall GetOperationChar(TTimecode::eOperation Value);
	// Returns reduced string with 'numbers' (and decimal).
	UnicodeString __fastcall StripDown(void);
	// Special display string ...
	__property UnicodeString Status = {read = GetStatus};
	__property UnicodeString StatusFPS = {read = GetStatusFPS};
	__property UnicodeString ShortStatusFPS = {read = GetShortStatusFPS};
	__property UnicodeString StatusFPF = {read = GetStatusFPF};
	__property UnicodeString StatusStyle = {read = GetStatusStyle};
	// Core parameters ...
	__property double FPS = {read = GetFPS, write = SetFPS, default = 25};
	__property int FPF = {read = GetFPF};
	__property double GateWidth = {read = GetGateWidth};
	__property int Perf = {read = GetPerf};
	__property int Gate = {read = GetGate};
	__property System::Classes::TNotifyEvent OnChange = {read=FOnChange, write=FOnChange};
	__property int TCFPSCount = {read=fTCFPSCount};
	__property int TCFPFCount = {read=fTCFPFCount};
	__property int TCDisplayStylesCount = {read=fTCDisplayStylesCount};

__published:
	__property TTimecode::eStandard Standard = {
		read = GetStandard, write = SetStandard, default = TTimecode::ttPAL};
	__property bool UseGlobal = {
		read = FUseGlobal, write = FUseGlobal, default = true};
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
		read = FUseDropFrame, write = FUseDropFrame, default = true};
	__property TTimecode::ePerforation Perforation = {
		read = GetPerforation, write = SetPerforation};
};

// ---------------------------------------------------------------------------
extern int GlobalFPFIndex;
extern int GlobalFPSIndex;
extern double GlobalCustomFPS;


#pragma region "Gloabal Timecode Preferences"
void __fastcall WriteGlobalTCPrefFile(UnicodeString FileName);
void __fastcall ReadGlobalTCPrefFile(UnicodeString FileName);
bool __fastcall CreateGlobalTCPrefFileName();
UnicodeString __fastcall GetGlobalTCPrefFileName();
void LoadGlobalTCPreferences(void);
void SaveGlobalTCPreferences(void);
#pragma end_region
#endif
