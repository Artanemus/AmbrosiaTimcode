//---------------------------------------------------------------------------

#include <fmx.h>
#pragma hdrstop

#include "FmxTCPreferencesDlg.h"
//---------------------------------------------------------------------------
#pragma package(smart_init)
#pragma resource "*.fmx"
//TTCPreferencesDlg *TCPreferencesDlg;
//---------------------------------------------------------------------------
__fastcall TTCPreferencesDlg::TTCPreferencesDlg(TComponent* Owner)
	: TForm(Owner)
{
}
void __fastcall TTCPreferencesDlg::FormCreate(TObject *Sender)
{
	tc = new TTimecode(this);
	LoadGlobalTCPreferences();
	int i;
	UnicodeString str;
	// UseGlobal = true;
	cbFPF->Clear();
	for (i = 0; i <= MAXFPFINDEXNUM; i++) {
		cbFPF->Items->Add(fpf_table[i].Caption);
	}
	cbFPS->Clear();
	for (i = 0; i <= MAXFPSINDEXNUM; i++) {
		str = fps_table[i].Caption;
		str = str + Format(" (%2g)", ARRAYOFCONST((fps_table[i].fps)));
		cbFPS->Items->Add(str);
	}
	ebCustomFPS->Enabled = false;
	Label3->Enabled = false;
}

//---------------------------------------------------------------------------
void __fastcall TTCPreferencesDlg::FormActivate(TObject *Sender)
{
	// Long:
	// If no TTimecode is assigned to param 'tc', global params are used.
	double f;
	int ifps, ifpf;
	double customfps;

	// use Local params
	if (!tc->UseGlobal) {
		ifps = tc->FPSIndex;
		ifpf = tc->FPFIndex;
		customfps = tc->CustomFPS;
		// Assert the caption used to display Custom FPS .. for UseGlobal
		// as it may have changed since last call...
		cbFPS->Items->Strings[MAXFPSINDEXNUM] =
			fps_table[MAXFPSINDEXNUM].Caption + Format(" (%2g)",
			ARRAYOFCONST((customfps)));

		if (ifpf < 0 || ifpf > MAXFPFINDEXNUM)
			cbFPF->ItemIndex = -1;
		else
			cbFPF->ItemIndex = ifpf;
		if (ifps < 0 || ifps > MAXFPSINDEXNUM) {
			cbFPS->ItemIndex = -1;
		}
		else {
			cbFPS->ItemIndex = ifps;
		}
		// Custom FPS = last record of fps_table...
		ebCustomFPS->Text = Format("%3.2f", ARRAYOFCONST((customfps)));
	}
	// Use gloabl params.
	else {
		ifps = GlobalFPSIndex;
		ifpf = GlobalFPFIndex;
		customfps = GlobalCustomFPS;
		// Assert the caption used to display Custom FPS .. for UseGlobal
		// as it may have changed since last call...
		cbFPS->Items->Strings[MAXFPSINDEXNUM] =
			fps_table[MAXFPSINDEXNUM].Caption + Format(" (%2g)",
			ARRAYOFCONST((customfps)));

		cbFPF->ItemIndex = ifpf;
		cbFPS->ItemIndex = ifps;
		fps_table[MAXFPSINDEXNUM].fps = customfps;
		// Custom FPS = last record of fps_table...
		ebCustomFPS->Text = Format("%3.2f", ARRAYOFCONST((customfps)));
	}
	// Assert the display of the EditBox.
	ebCustomFPSChange(this);

}
//---------------------------------------------------------------------------
void __fastcall TTCPreferencesDlg::FormClose(TObject *Sender, TCloseAction &Action)
{
	if (ModalResult == mrOk) {
		// Update Local (to this Form) Parmeters
		if (!tc->UseGlobal) {
//			if (cbFPF->ItemIndex != -1) {
//				tc->FPFIndex = cbFPF->ItemIndex;
//			}
//			if (cbFPS->ItemIndex != -1) {
//				tc->FPSIndex = cbFPS->ItemIndex;
//			}
//			 Custom FPS = record 3 of fps_table...
//			if (tc->FPSIndex == MAXFPSINDEXNUM) {
//				tc->CustomFPS = StrToFloatDef(ebCustomFPS->Text, 0);
//			}
		}
		// Update Global Parameters
		else {
			if (cbFPF->ItemIndex != -1) {
				GlobalFPFIndex = cbFPF->ItemIndex;
			}
			if (cbFPS->ItemIndex != -1) {
				GlobalFPSIndex = cbFPS->ItemIndex;
			}
			// Custom FPS = last record of fps_table...
			if (GlobalFPSIndex == MAXFPSINDEXNUM) {
				GlobalCustomFPS = StrToFloatDef(ebCustomFPS->Text, 0);
				fps_table[MAXFPSINDEXNUM].fps = GlobalCustomFPS;
			}
			//save the Global preferences...
			SaveGlobalTCPreferences();
		}
	}
}
//---------------------------------------------------------------------------
void __fastcall TTCPreferencesDlg::ebCustomFPSChange(TObject *Sender)
{
	double f = StrToFloatDef(ebCustomFPS->Text, 0);
	int store = cbFPS->ItemIndex;
	// Assert the caption used to display Custom FPS .. for UseGlobal
	cbFPS->Items->Strings[MAXFPSINDEXNUM] =
		fps_table[MAXFPSINDEXNUM].Caption + Format(" (%2g)", ARRAYOFCONST((f)));
	// if custom FPS is being displayed in combobox2...
	if (store == MAXFPSINDEXNUM) {
		// ..modifying the text will reset ItemIndex to -1
		cbFPS->ItemIndex = MAXFPSINDEXNUM;
	}

}
//---------------------------------------------------------------------------
void __fastcall TTCPreferencesDlg::cbFPSChange(TObject *Sender)
{
	if (cbFPS->ItemIndex == MAXFPSINDEXNUM) {
		// display custom fps
		ebCustomFPS->Enabled = true;
		Label3->Enabled = true;
	}
	else {
		ebCustomFPS->Enabled = false;
		Label3->Enabled = false;
	}
}
//---------------------------------------------------------------------------

