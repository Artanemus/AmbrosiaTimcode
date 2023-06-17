unit frmMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  TimeCode, TimecodeTypes, TimecodeHelper, Vcl.StdCtrls;

type
  TMain = class(TForm)
    Button1: TButton;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
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
  tc1.Frames := 100;
  tc2.Frames := 150;
  tc3 := tc1;
  tc3 :=  (tc1+tc2);
  if tc1>tc2 then
    Label3.Caption := 'tc1 > tc2'
  else
    Label3.Caption := 'tc1 <= tc2';

end;

end.
