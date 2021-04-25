//---------------------------------------------------------------------------

#ifndef FmxTCPreferencesDlgH
#define FmxTCPreferencesDlgH
//---------------------------------------------------------------------------
#include <System.Classes.hpp>
#include <FMX.Controls.hpp>
#include <FMX.Forms.hpp>
#include <FMX.Edit.hpp>
#include <FMX.Layouts.hpp>
#include <FMX.ListBox.hpp>
#include <FMX.Types.hpp>
#include "Timecode.h"
#include <FMX.StdCtrls.hpp>

//---------------------------------------------------------------------------
class TTCPreferencesDlg : public TForm
{
__published:	// IDE-managed Components
	TLayout *Layout1;
	TButton *BtnCancel;
	TButton *BtnOk;
	TComboBox *cbFPS;
	TComboBox *cbFPF;
	TLabel *Label1;
	TLabel *Label2;
	TLabel *Label3;
	TEdit *ebCustomFPS;
	void __fastcall FormCreate(TObject *Sender);
	void __fastcall FormActivate(TObject *Sender);
	void __fastcall FormClose(TObject *Sender, TCloseAction &Action);
	void __fastcall ebCustomFPSChange(TObject *Sender);
	void __fastcall cbFPSChange(TObject *Sender);
private:	// User declarations
	TTimecode * tc;
public:		// User declarations
	__fastcall TTCPreferencesDlg(TComponent* Owner);
};
//---------------------------------------------------------------------------
//extern PACKAGE TTCPreferencesDlg *TCPreferencesDlg;
//---------------------------------------------------------------------------
#endif
