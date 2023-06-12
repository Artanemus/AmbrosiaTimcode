unit Timecode;

interface

uses
  System.SysUtils, System.Classes, System.DateUtils;

type

  eStyle = (tcStyle, tcTimeStyle, tcFrameStyle, tcFootageStyle);

  eStandard = (tcPAL, tcFILM, tcNTSCDF, tcNTSC, tcCUSTOM);

  ePerforation = (mm16, mm16_35_sound, mm35_3perf, mm35_4perf, mm35_8perf,
    mm65_70_3perf, mm65_70_4perf, mm65_70_5perf, mm65_70_6perf, mm65_70_7perf,
    mm65_70_8perf, mm65_70_9perf, mm65_70_10perf, mm65_70_11perf,
    mm65_70_12perf, mm65_70_13perf, mm65_70_14perf, mm65_70_15perf);

  eOperation = (tcMultiply, tcAdd, tcSubtract, tcDivide, tcEquals, tcNone);

  TTimecode = class(TComponent)
  private
    FStyle: eStyle;
    FFPFIndex: Integer;
    FFPSIndex: Integer;
    fStyleIndex: Integer;
    FCustomFPS: Double;
    FUseGlobal: Boolean;
    fFrames: Double;
    FUseDropFrame: Boolean;
    FOnChange: TNotifyEvent;
    fTCFPSCount: Integer;
    fTCFPFCount: Integer;
    fTCDisplayStylesCount: Integer;

    procedure SetText(value: String);
    function GetText: String;
    procedure SetFPSIndex(value: Integer);
    function GetFPSIndex: Integer;
    procedure SetFPFIndex(value: Integer);
    function GetFPFIndex: Integer;
    procedure SetStyleIndex(value: Integer);
    function GetStyleIndex: Integer;
    function GetStandard: eStandard;
    procedure SetStandard(value: eStandard);
    function GetPerforation: ePerforation;
    procedure SetPerforation(value: ePerforation);
    procedure SetFPS(value: Double);
    function GetCustomFPS: Double;
    procedure SetCustomFPS(value: Double);
    function GetFPS: Double;
    function GetFPF: Integer;
    function GetStatus: String;
    function GetStatusFPS: String;
    function GetShortStatusFPS: String;
    function GetStatusFPF: String;
    function GetStatusStyle: String;
    function GetGateWidth: Double;
    function GetPerf: Integer;
    function GetGate: Integer;
    procedure SetFrames(value: Double);
    function GetFrames: Double;
    function GetStyle: eStyle;
    procedure SetStyle(value: eStyle);

  protected
    procedure Change; virtual;

  public

    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    {
      const operator = (const t : TTimecode) : integer; // equates
      const operator <> (const t : TTimecode) : integer; // not equal
      const operator < (const t : TTimecode) : integer; //
      const operator > (const t : TTimecode) : integer; //
      const operator >= (const t : TTimecode) : integer; //
      const operator <= (const t : TTimecode) : integer; //
      operator - (const t : TTimecode) : TTimecode; // subtract
      operator + (const t : TTimecode) : TTimecode; // addition
    }

    function ConvertFramesNDtoDF(value: Double): Double;
    function ConvertFramesDFtoND(value: Double): Double;
    // Simple text routine trims any redundant fields.
    // Stringwidth will vary.
    function GetSimpleText(): String;
    function GetOperationChar(value: eOperation): Char;
    // Returns reduced string with 'numbers' (and decimal).
    function StripDown(): String;
    function FramesToTime(): TTime;

    procedure TimeToFrames(dt: TTime);
    procedure Assign(Source: TPersistent); override;
    procedure ToggleFPS(Forward: Boolean = true);
    procedure ToggleFPF(Forward: Boolean = true);
    procedure ToggleStyle(Forward: Boolean = true);

    // Special display string ...
    property Status: String read GetStatus;
    property StatusFPS: String read GetStatusFPS;
    property ShortStatusFPS: String read GetShortStatusFPS;
    property StatusFPF: String read GetStatusFPF;
    property StatusStyle: String read GetStatusStyle;
    // Core parameters ...
    property fps: Double read GetFPS write SetFPS;
    property fpf: Integer read GetFPF;
    property GateWidth: Double read GetGateWidth;
    property perf: Integer read GetPerf;
    property gate: Integer read GetGate;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
    property TCFPSCount: Integer read fTCFPSCount;
    property TCFPFCount: Integer read fTCFPFCount;
    property TCDisplayStylesCount: Integer read fTCDisplayStylesCount;

  published
    property Standard: eStandard read GetStandard write SetStandard
      default tcPAL;
    property UseGlobal: Boolean read FUseGlobal write FUseGlobal default true;
    property CustomFPS: Double read GetCustomFPS write SetCustomFPS;
    property Frames: Double read GetFrames write SetFrames;
    property FPSIndex: Integer read GetFPSIndex write SetFPSIndex default 0;
    property FPFIndex: Integer read GetFPFIndex write SetFPFIndex default 3;
    property StyleIndex: Integer read GetStyleIndex write SetStyleIndex
      default 0;
    property Text: String read GetText write SetText;
    property style: eStyle read GetStyle write SetStyle default tcStyle;
    property UseDropFrame: Boolean read FUseDropFrame write FUseDropFrame
      default true;
    property Perforation: ePerforation read GetPerforation write SetPerforation;

  end;

type
  TCOperator = record
    tc: TTimecode;
    class operator Add(a, b: TCOperator): TCOperator; // Binary
    class operator Subtract(a, b: TCOperator): TCOperator; // Binary
    class operator Equal(a, b: TCOperator): Boolean; // Comparison
    class operator NotEqual(a, b: TCOperator): Boolean; // Comparison
    class operator GreaterThan(a, b: TCOperator): Boolean; // Comparison
    class operator LessThan(a, b: TCOperator): Boolean; // Comparison
    class operator GreaterThanOrEqual(a, b: TCOperator): Boolean; // Comparison
    class operator LessThanOrEqual(a, b: TCOperator): Boolean; // Comparison
    // Assign(var Dest: type; const [ref] Src: type);
    class operator Assign(var Dest: TCOperator; const [ref] Src: TCOperator); // Binary
  end;

  {
    // NOTE: implementation syntax...
    class operator typeName.comparisonOp(a: type; b: type): Boolean;
    class operator typeName.binaryOp(a: type; b: type): resultType;
  }

var
//  fpsPtr: ^FPS_TABLE;
//  fpfPtr: ^FPF_TABLE;
//  tcdisplaystylePtr: ^TC_DISPLAYSTYLE;

  MathsChar: PWideChar;

implementation

procedure ValidCtrCheck(TTimecode: TTimecode);
begin
  TTimecode.Create(nil);
end;


procedure Register;
begin
  RegisterComponents('Artanemus', [TTimecode]);
end;

{ TTimecode }

procedure TTimecode.Assign(Source: TPersistent);
begin
  inherited;

end;

procedure TTimecode.Change;
begin

end;

function TTimecode.ConvertFramesDFtoND(value: Double): Double;
begin

end;

function TTimecode.ConvertFramesNDtoDF(value: Double): Double;
begin

end;

constructor TTimecode.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FUseGlobal := True;
//  FFPSIndex := GlobalFPSIndex;
//  FFPFIndex := GlobalFPFIndex;
//  FCustomFPS := GlobalCustomFPS;
  FStyle := tcStyle;
  fFrames := 0;

  {

  SetLength(fps_table, 5);

  fps_table[0] := ('PAL', 25.00, '25fps');
  fps_table[1] := ('FILM', 24.00, '24fps');
  fps_table[2] := ('NTSC DF', 29.97, '29.97');
  fps_table[3] := ('NTSC', 30.00, '30fps');
  fps_table[4] := ('CUSTOM', 12.00, 'Custom fps');

  fTCFPSCount := Length(fps_table);

  SetLength(fpf_table, 18);

	fpf_table[0] := ('16mm', 40, 0.3, 2, 16);
	fpf_table[1] := ('16/35mm sound', 16, 0.75, 2, 16);
	fpf_table[2] := ('35mm 3-perf', 22, 0.5454545454545, 3, 35);
	fpf_table[3] := ('35mm 4-perf', 16, 0.75, 4, 35);
	fpf_table[4] := ('35mm 8-perf', 8, 1.5, 8, 65);
	fpf_table[5] := ('65/70mm 3-perf', 22, 0.5454545454545, 3, 65);
	fpf_table[6] := ('65/70mm 4-perf', 16, 0.75, 4, 65);
	fpf_table[7] := ('65/70mm 5-perf', 13, 0.9230769230769, 5, 65);
	fpf_table[8] := ('65/70mm 6-perf', 11, 1.090909090909, 6, 65);
	fpf_table[9] := ('65/70mm 7-perf', 10, 1.2, 7, 65);
	fpf_table[10] := ('65/70mm 8-perf', 8, 1.5, 8, 65);
	fpf_table[11] := ('65/70mm 9-perf', 8, 1.5, 9, 65);
	fpf_table[12] := ('65/70mm 10-perf', 7, 1.714285714286, 10, 65);
	fpf_table[13] := ('65/70mm 11-perf', 6, 2.0, 11, 65);
	fpf_table[14] := ('65/70mm 12-perf', 6, 2.0, 12, 6);
	fpf_table[15] := ('65/70mm 13-perf', 5, 2.4, 13, 65);
	fpf_table[16] := ('65/70mm 14-perf', 5, 2.4, 14, 65);
	fpf_table[17] := ('65/70mm 15-perf', 5, 2.4, 15, 65);


fTCFPFCount := Length(fpf_table);

SetLength(tc_displaystyle,4);
tc_displaystyle[0] := ('HH:MM:SS:FF',0,'Timecode');
tc_displaystyle[1] := ('Hr.Min.Sec',1,'Time');
tc_displaystyle[2] := ('Frames',2,'Frames');
tc_displaystyle[3] := ('Footage',3,'Footage');

fTCDisplayStylesCount := Length(tc_displaystyle);

SetLength(MathsChar,5);
MathsChar[0] := '*';
MathsChar[1] := '+';
MathsChar[2] := '-';
MathsChar[3] := '/';
MathsChar[4] := '=';

}

end;


destructor TTimecode.Destroy;
begin
//  fps_table := nil;
//  fpf_table := nil;
//  tc_displaystyle := nil;
  MathsChar := nil;
  inherited;
end;

function TTimecode.FramesToTime: TTime;
var
dt: TDateTime;
begin
  dt :=  (fFrames / GetFPS()) / SecsPerDay * 1000.0;
	result := TimeOf(dt);
end;

function TTimecode.GetCustomFPS: Double;
begin

end;

function TTimecode.GetFPF: Integer;
begin

end;

function TTimecode.GetFPFIndex: Integer;
begin

end;

function TTimecode.GetFPS: Double;
begin

end;

function TTimecode.GetFPSIndex: Integer;
begin

end;

function TTimecode.GetFrames: Double;
begin

end;

function TTimecode.GetGate: Integer;
begin

end;

function TTimecode.GetGateWidth: Double;
begin

end;

function TTimecode.GetOperationChar(value: eOperation): Char;
begin

end;

function TTimecode.GetPerf: Integer;
begin

end;

function TTimecode.GetPerforation: ePerforation;
begin

end;

function TTimecode.GetShortStatusFPS: String;
begin

end;

function TTimecode.GetSimpleText: String;
begin

end;

function TTimecode.GetStandard: eStandard;
begin

end;

function TTimecode.GetStatus: String;
begin

end;

function TTimecode.GetStatusFPF: String;
begin

end;

function TTimecode.GetStatusFPS: String;
begin

end;

function TTimecode.GetStatusStyle: String;
begin

end;

function TTimecode.GetStyle: eStyle;
begin

end;

function TTimecode.GetStyleIndex: Integer;
begin

end;

function TTimecode.GetText: String;
begin

end;

procedure TTimecode.SetCustomFPS(value: Double);
begin

end;

procedure TTimecode.SetFPFIndex(value: Integer);
begin

end;

procedure TTimecode.SetFPS(value: Double);
begin

end;

procedure TTimecode.SetFPSIndex(value: Integer);
begin

end;

procedure TTimecode.SetFrames(value: Double);
begin

end;

procedure TTimecode.SetPerforation(value: ePerforation);
begin

end;

procedure TTimecode.SetStandard(value: eStandard);
begin

end;

procedure TTimecode.SetStyle(value: eStyle);
begin

end;

procedure TTimecode.SetStyleIndex(value: Integer);
begin

end;

procedure TTimecode.SetText(value: String);
begin

end;

function TTimecode.StripDown: String;
begin

end;

procedure TTimecode.TimeToFrames(dt: TTime);
begin

end;

procedure TTimecode.ToggleFPF(Forward: Boolean);
begin

end;

procedure TTimecode.ToggleFPS(Forward: Boolean);
begin

end;

procedure TTimecode.ToggleStyle(Forward: Boolean);
begin

end;

{ TCOperator }

class operator TCOperator.Add(a, b: TCOperator): TCOperator;
begin

end;

class operator TCOperator.Assign(var Dest: TCOperator; const [ref] Src: TCOperator);
begin

end;

class operator TCOperator.Equal(a, b: TCOperator): Boolean;
begin

end;

class operator TCOperator.GreaterThan(a, b: TCOperator): Boolean;
begin

end;

class operator TCOperator.GreaterThanOrEqual(a, b: TCOperator): Boolean;
begin

end;

class operator TCOperator.LessThan(a, b: TCOperator): Boolean;
begin

end;

class operator TCOperator.LessThanOrEqual(a, b: TCOperator): Boolean;
begin

end;

class operator TCOperator.NotEqual(a, b: TCOperator): Boolean;
begin

end;

class operator TCOperator.Subtract(a, b: TCOperator): TCOperator;
begin

end;

end.
