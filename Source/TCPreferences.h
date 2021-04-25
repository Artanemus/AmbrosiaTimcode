//---------------------------------------------------------------------------

#ifndef TCPreferencesH
#define TCPreferencesH
//---------------------------------------------------------------------------
#include <Classes.hpp>
#include <Controls.hpp>
#include <StdCtrls.hpp>
#include <Forms.hpp>
#include <Buttons.hpp>
#include <ExtCtrls.hpp>
//---------------------------------------------------------------------------
#include "Timecode.h"
#include <ActnList.hpp>


class TTCPreferences : public TForm
{
__published:	// IDE-managed Components
	TPanel *Panel2;
	TButton *BtnCancel;
	TButton *BtnOk;
	TComboBox *ComboBox1;
	TLabel *Label2;
	TEdit *Edit1;
	TComboBox *ComboBox2;
	TLabel *Label1;
	TLabel *Label3;
	void __fastcall FormCreate(TObject *Sender);
	void __fastcall FormShow(TObject *Sender);
	void __fastcall FormClose(TObject *Sender, TCloseAction &Action);
	void __fastcall Edit1Change(TObject *Sender);
	void __fastcall ComboBox2Change(TObject *Sender);
private:	// User declarations
public:		// User declarations
	__fastcall TTCPreferences(TComponent* Owner);
	TTimecode * tc;
};
//---------------------------------------------------------------------------
//extern PACKAGE TTCPreferencesDlg *TCPreferencesDlg;
//---------------------------------------------------------------------------
#endif
