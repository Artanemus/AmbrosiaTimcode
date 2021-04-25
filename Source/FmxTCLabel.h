//---------------------------------------------------------------------------

#ifndef FmxTCLabelH
#define FmxTCLabelH
//---------------------------------------------------------------------------
#include <SysUtils.hpp>
#include <Classes.hpp>
#include <FMX.Controls.hpp>
#include <FMX.Types.hpp>

#include "FmxTCText.h"

//---------------------------------------------------------------------------
class PACKAGE TFmxTCLabel : public TFmxTCText
{
private:
	bool fShowStatus;
	void __fastcall SetShowStatus(bool Value);

protected:
	virtual void __fastcall Paint(void);

public:
	__fastcall TFmxTCLabel(TComponent* Owner);
	__fastcall ~TFmxTCLabel(void);

__published:
	__property bool ShowStatus = {read=fShowStatus, write=SetShowStatus};



};
//---------------------------------------------------------------------------
#endif
