program DelphiTest_RTL;

uses
  Vcl.Forms,
  frmMain in 'frmMain.pas' {Main},
  Timecode in '..\DSource\Timecode.pas',
  TimecodeHelper in '..\DSource\TimecodeHelper.pas',
  TCEdit in '..\DSource\TCEdit.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TMain, Main);
  Application.Run;
end.
