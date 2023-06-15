unit frmMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  TimeCode, TimecodeTypes, TimecodeUtils, Vcl.StdCtrls;

type
  TMain = class(TForm)
    Button1: TButton;
    Label1: TLabel;
    Label2: TLabel;
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Main: TMain;

implementation

{$R *.dfm}

procedure TMain.Button1Click(Sender: TObject);
var
tc1, tc2, tc3: TTimecode;
begin
  tc1.Create(100);  //24fps, 16fpf
  tc2.Create(100);
  tc3.Create(0, 25,20);
  tc3 := tc1;
  tc3 :=  tc1+tc2;
end;

end.
