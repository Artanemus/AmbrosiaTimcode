unit TCCalculator;

interface

uses
  System.SysUtils, System.Classes, Vcl.Controls, Vcl.StdCtrls,
  Vcl.Graphics, Timecode, TimecodeHelper, TCEdit;

type
  TTCCalculator = class(TTCEdit)
  private
    CurrOperation: tcOperation;
    NextOperation: tcOperation;
    PrevOperation: tcOperation;

    // TC Storage for calculations
    fTCStore: TTimecode;
    // Memory store feature (MS M+ M- MC)
    fTCMemory: TTimecode;
    // Tempory timecode value
    fTCTemp: TTimecode;

    fLastKeyDown: WORD;
    // replaces fTC->Text for input storage.
    // As fTC->ShowRawText can change - it isn't a stable storage space.
    fInputStr: string;
    { TODO -oBSA -cGeneral : Change the methanology to remove fUseInputString && fInputStr }
    fUseInputStr: boolean;
    fShowMemory: boolean;
    fShowOperation: boolean;

    procedure ChangeOperation();
    function GetOperation(Key: char): tcOperation;
    function GetMemoryText(): string;

  protected
    procedure KeyUp(var Key: char; Shift: TShiftState); dynamic;
    procedure Paint; override;

    property TCRawText;
    property Operation;
    property Perforation;
    property DisplayMode;
    property Standard;


  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy(); override;

    procedure ProcessKey(var Key: char; Shift: TShiftState);
    procedure MemoryRecall();
    procedure MemoryClear();
    procedure MemoryAdd();
    procedure MemorySubtract();

  published
    property MemoryText: string read GetMemoryText;
    property ShowMemory: boolean read fShowMemory write fShowMemory
      default true;

    property OnKeyDown;
    property OnKeyUp;
    property OnKeyPress;

  end;

implementation

{ TTCCalculator }

constructor TTCCalculator.Create(AOwner: TComponent);
begin
  inherited;

  //	fTCStore; fTCMemory;	fTCTemp; RECORD

	TCRawText := '';  // Ancestor field value
	fShowRawText := true;
	PrevOperation := tcOperation.tcNone;
	fLastKeyDown := 0;
	fUseInputStr := true;
  fShowOperation := true;
	fShowMemory := true;
end;

destructor TTCCalculator.Destroy;
begin
  // TODO?
  inherited;
end;

function TTCCalculator.GetMemoryText: string;
begin
  result := fTCMemory.GetTextDisplayMode(DisplayMode);
end;

function TTCCalculator.GetOperation(Key: char): tcOperation;
begin
  result := Operation;
end;

procedure TTCCalculator.KeyUp(var Key: char; Shift: TShiftState);
begin

end;

procedure TTCCalculator.MemoryAdd;
begin

end;

procedure TTCCalculator.MemoryClear;
begin

end;

procedure TTCCalculator.MemoryRecall;
begin

end;

procedure TTCCalculator.MemorySubtract;
begin

end;

procedure TTCCalculator.ChangeOperation;
begin
	fTCTemp.FPS := TC_Frames;

  case PrevOperation of
    tcMultiply: ;
    tcAdd: ;
    tcSubtract: ;
    tcDivide: ;
    tcEquals: ;
    tcNone: ;
  end;

end;

procedure TTCCalculator.Paint;
begin
  inherited;

end;

procedure TTCCalculator.ProcessKey(var Key: char; Shift: TShiftState);
begin

end;

end.
