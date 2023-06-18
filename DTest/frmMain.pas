unit frmMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  TimeCode, TimecodeHelper, Vcl.StdCtrls,
  TCEdit;

type
  TMain = class(TForm)
    Edit1: TEdit;
    TCEdit1: TTCEdit;
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    tcEdit: TTCEdit;
  end;

var
  Main: TMain;

implementation

{$R *.dfm}

procedure TMain.FormCreate(Sender: TObject);
begin
//  tcEdit := TTCEdit.Create(self);

end;

end.
