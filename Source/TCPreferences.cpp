// ---------------------------------------------------------------------------

#include <vcl.h>
#pragma hdrstop

#include "TCPreferences.h"
// ---------------------------------------------------------------------------
#pragma package(smart_init)
#pragma resource "*.dfm"

// TTCPreferencesDlg *TCPreferencesDlg;

extern FPF_TABLE fpf_table[];

// ---------------------------------------------------------------------------
__fastcall TTCPreferences::TTCPreferences(TComponent* Owner)
	: TForm(Owner) {
}

// ---------------------------------------------------------------------------
void __fastcall TTCPreferences::FormCreate(TObject *Sender) {
	LoadGlobalTCPreferences();
	int i;
	UnicodeString str;
	// UseGlobal = true;
	for (i = 0; i <= MAXFPFINDEXNUM; i++) {
		ComboBox1->Items->Add(fpf_table[i].Caption);
	}
	for (i = 0; i <= MAXFPSINDEXNUM; i++) {
		str = fps_table[i].Caption;
		str = str + Format(" (%2g)", ARRAYOFCONST((fps_table[i].fps)));
		ComboBox2->Items->Add(str);
	}
	tc = NULL;
	Edit1->Enabled = false;
	Label2->Enabled = false;
}

// ---------------------------------------------------------------------------
void __fastcall TTCPreferences::FormShow(TObject *Sender) {
	// Long:
	// If no TTimecode is assigned to param 'tc', global params are used.
	double f;
	int ifps, ifpf;
	double customfps;

	// use Local params
	if (tc && !tc->UseGlobal) {
		ifps = tc->FPSIndex;
		ifpf = tc->FPFIndex;
		customfps = tc->CustomFPS;
		// Assert the caption used to display Custom FPS .. for UseGlobal
		// as it may have changed since last call...
		ComboBox2->Items->Strings[MAXFPSINDEXNUM] =
			fps_table[MAXFPSINDEXNUM].Caption + Format(" (%2g)",
			ARRAYOFCONST((customfps)));

		if (ifpf < 0 || ifpf > MAXFPFINDEXNUM)
			ComboBox1->ItemIndex = -1;
		else
			ComboBox1->ItemIndex = ifpf;
		if (ifps < 0 || ifps > MAXFPSINDEXNUM) {
			ComboBox2->ItemIndex = -1;
		}
		else {
			ComboBox2->ItemIndex = ifps;
		}
		// Custom FPS = last record of fps_table...
		Edit1->Text = Format("%3.2f", ARRAYOFCONST((customfps)));
	}
	// Use gloabl params.
	else {
		ifps = GlobalFPSIndex;
		ifpf = GlobalFPFIndex;
		customfps = GlobalCustomFPS;
		// Assert the caption used to display Custom FPS .. for UseGlobal
		// as it may have changed since last call...
		ComboBox2->Items->Strings[MAXFPSINDEXNUM] =
			fps_table[MAXFPSINDEXNUM].Caption + Format(" (%2g)",
			ARRAYOFCONST((customfps)));

		ComboBox1->ItemIndex = ifpf;
		ComboBox2->ItemIndex = ifps;
		fps_table[MAXFPSINDEXNUM].fps = customfps;
		// Custom FPS = last record of fps_table...
		Edit1->Text = Format("%3.2f", ARRAYOFCONST((customfps)));
	}
	// Assert the display of the EditBox.
	ComboBox2Change(this);
}
// ---------------------------------------------------------------------------

void __fastcall TTCPreferences::FormClose(TObject *Sender,
	TCloseAction &Action)

{
	if (ModalResult == mrOk) {
		// Update Local (to this Form) Parmeters
		if (tc && !tc->UseGlobal) {
			if (ComboBox1->ItemIndex != -1) {
				tc->FPFIndex = ComboBox1->ItemIndex;
			}
			if (ComboBox2->ItemIndex != -1) {
				tc->FPSIndex = ComboBox2->ItemIndex;
			}
			// Custom FPS = record 3 of fps_table...
			if (tc->FPSIndex == MAXFPSINDEXNUM) {
				tc->CustomFPS = StrToFloatDef(Edit1->Text, 0);
			}
		}
		// Update Global Parameters
		else {
			if (ComboBox1->ItemIndex != -1) {
				GlobalFPFIndex = ComboBox1->ItemIndex;
			}
			if (ComboBox2->ItemIndex != -1) {
				GlobalFPSIndex = ComboBox2->ItemIndex;
			}
			// Custom FPS = last record of fps_table...
			if (GlobalFPSIndex == MAXFPSINDEXNUM) {
				GlobalCustomFPS = StrToFloatDef(Edit1->Text, 0);
				fps_table[MAXFPSINDEXNUM].fps = GlobalCustomFPS;
			}
			//save the Global preferences...
			SaveGlobalTCPreferences();
		}
	}
	// Assert internal tc state.
	tc = NULL;
}
// ---------------------------------------------------------------------------

void __fastcall TTCPreferences::Edit1Change(TObject *Sender) {
	double f = StrToFloatDef(Edit1->Text, 0);
	int store = ComboBox2->ItemIndex;
	// Assert the caption used to display Custom FPS .. for UseGlobal
	ComboBox2->Items->Strings[MAXFPSINDEXNUM] =
		fps_table[MAXFPSINDEXNUM].Caption + Format(" (%2g)", ARRAYOFCONST((f)));
	// if custom FPS is being displayed in combobox2...
	if (store == MAXFPSINDEXNUM) {
		// ..modifying the text will reset ItemIndex to -1
		ComboBox2->ItemIndex = MAXFPSINDEXNUM;
	}
}
// ---------------------------------------------------------------------------

void __fastcall TTCPreferences::ComboBox2Change(TObject *Sender) {
	if (ComboBox2->ItemIndex == MAXFPSINDEXNUM) {
		// display custom fps
		Edit1->Enabled = true;
		Label2->Enabled = true;
	}
	else {
		Edit1->Enabled = false;
		Label2->Enabled = false;
	}
}
// ---------------------------------------------------------------------------
