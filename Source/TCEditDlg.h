//---------------------------------------------------------------------------

#ifndef TCEditDlgH
#define TCEditDlgH
//---------------------------------------------------------------------------
#include <Classes.hpp>
#include <Controls.hpp>
#include <StdCtrls.hpp>
#include <Forms.hpp>
#include "TCEdit.h"
#include <ExtCtrls.hpp>
#include <Mask.hpp>
//---------------------------------------------------------------------------
class TTCEditDlgForm : public TForm
{
__published:	// IDE-managed Components
	TPanel *Panel1;
	TButton *Button1;
	TButton *Button2;
	TPanel *Panel2;
	void __fastcall FormCreate(TObject *Sender);
	void __fastcall FormDestroy(TObject *Sender);
	void __fastcall FormShow(TObject *Sender);
private:	// User declarations
public:		// User declarations
	__fastcall TTCEditDlgForm(TComponent* Owner);
	TTCEdit *tcEdit;
};
//---------------------------------------------------------------------------
//extern PACKAGE TTCEditDlgForm *TCEditDlgForm;
//---------------------------------------------------------------------------
#endif
