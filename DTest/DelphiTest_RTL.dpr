program DelphiTest_RTL;

uses
  Vcl.Forms,
  frmMain in 'frmMain.pas' {Main},
  Timecode in '..\DSource\Timecode.pas',
  TimecodeTypes in '..\DSource\TimecodeTypes.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TMain, Main);
  Application.Run;
end.
