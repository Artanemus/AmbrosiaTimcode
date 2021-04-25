// ---------------------------------------------------------------------------

#include <vcl.h>
#pragma hdrstop

#include "TCEditDlg.h"
// ---------------------------------------------------------------------------
#pragma package(smart_init)
#pragma resource "*.dfm"
//TTCEditDlgForm *TCEditDlgForm;

// ---------------------------------------------------------------------------
__fastcall TTCEditDlgForm::TTCEditDlgForm(TComponent* Owner) : TForm(Owner) {
}

// ---------------------------------------------------------------------------
void __fastcall TTCEditDlgForm::FormCreate(TObject *Sender) {
	tcEdit = new TTCEdit(this);
	tcEdit->Parent = Panel2->Parent;
	tcEdit->Align = alClient;
	tcEdit->ShowStatusFPF = false;
	tcEdit->ShowStatusFPS = false;
	tcEdit->ShowFocused = true;
	SetFocusedControl(tcEdit);
}

// ---------------------------------------------------------------------------
void __fastcall TTCEditDlgForm::FormDestroy(TObject *Sender) {
	;
}
// ---------------------------------------------------------------------------
void __fastcall TTCEditDlgForm::FormShow(TObject *Sender)
{
	// force a repaint...
	tcEdit->ForceUpdate();
}
//---------------------------------------------------------------------------

