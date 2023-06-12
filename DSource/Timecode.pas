unit Timecode;

interface

uses
  System.SysUtils, System.Classes;

type
  FPS_TABLE = record
    Caption: array [0 .. 24] of Char;
    fps: Double;
    FPSCaption: array [0 .. 24] of Char;
  end;

type
  FPF_TABLE = record
    Caption: array [0 .. 24] of Char;
    fpf: Integer;
    GateWidth: Double;
    perf: Integer;
    gate: Integer;
  end;

type
  TC_DISPLAYSTYLE = record
    Caption: array [0 .. 24] of Char;
    style: Integer;
    AltCaption: array [0 .. 24] of Char;
  end;

type

  TTimecode = class(TComponent)

  public

    type
    eStyle = (tcStyle, tcTimeStyle, tcFrameStyle, tcFootageStyle);

  type
    eStandard = (tcPAL, tcFILM, tcNTSCDF, tcNTSC, tcCUSTOM);

  type
    ePerforation = (mm16, mm16_35_sound, mm35_3perf, mm35_4perf, mm35_8perf,
      mm65_70_3perf, mm65_70_4perf, mm65_70_5perf, mm65_70_6perf, mm65_70_7perf,
      mm65_70_8perf, mm65_70_9perf, mm65_70_10perf, mm65_70_11perf,
      mm65_70_12perf, mm65_70_13perf, mm65_70_14perf, mm65_70_15perf);

  type
    eOperation = (tcMultiply, tcAdd, tcSubtract, tcDivide, tcEquals, tcNone);

  private
    FStyle: eStyle;
    FFPFIndex: Integer;
    FFPSIndex: Integer;
    fStyleIndex: Integer;
    FCustomFPS: Double;
    FUseGlobal: Boolean;
    // TTimeStamp fTimeStamp;
    fFrames: Double;
    FUseDropFrame: Boolean;
    FOnChange: TNotifyEvent;
    fTCFPSCount: Integer;
    fTCFPFCount: Integer;
    fTCDisplayStylesCount: Integer;

    procedure SetText(value: UnicodeString);
    function GetText: UnicodeString;
    procedure SetFPSIndex(value: Integer);
    function GetFPSIndex: Integer;
    procedure SetFPFIndex(value: Integer);
    function GetFPFIndex: Integer;
    procedure SetStyleIndex(value: Integer);
    function GetStyleIndex: Integer;
    function GetStandard: TTimecode.eStandard;
    procedure SetStandard(value: TTimecode.eStandard);
    function GetPerforation: TTimecode.ePerforation;
    procedure SetPerforation(value: TTimecode.ePerforation);
    procedure SetFPS(value: Double);
    function GetCustomFPS: Double;
    procedure SetCustomFPS(value: Double);
    function GetFPS: Double;
    function GetFPF: Integer;
    function GetStatus: UnicodeString;
    function GetStatusFPS: UnicodeString;
    function GetShortStatusFPS: UnicodeString;
    function GetStatusFPF: UnicodeString;
    function GetStatusStyle: UnicodeString;
    function GetGateWidth: Double;
    function GetPerf: Integer;
    function GetGate: Integer;
    procedure SetFrames(value: Double);
    function GetFrames: Double;
    function GetStyle: TTimecode.eStyle;
    procedure SetStyle(value: TTimecode.eStyle);

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
    function GetSimpleText(): UnicodeString;
    function GetOperationChar(value: TTimecode.eOperation): Char;
    // Returns reduced string with 'numbers' (and decimal).
    function StripDown(): UnicodeString;
    function FramesToTime(): TTime;

    procedure TimeToFrames(dt: TTime);
    procedure Assign(Source: TPersistent); override;
    procedure ToggleFPS(Forward: Boolean = true);
    procedure ToggleFPF(Forward: Boolean = true);
    procedure ToggleStyle(Forward: Boolean = true);

    // Special display string ...
    property Status: UnicodeString read GetStatus;
    property StatusFPS: UnicodeString read GetStatusFPS;
    property ShortStatusFPS: UnicodeString read GetShortStatusFPS;
    property StatusFPF: UnicodeString read GetStatusFPF;
    property StatusStyle: UnicodeString read GetStatusStyle;
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
    property Text: UnicodeString read GetText write SetText;
    property style: eStyle read GetStyle write SetStyle default tcStyle;
    property UseDropFrame: Boolean read FUseDropFrame write FUseDropFrame
      default true;
    property Perforation: ePerforation read GetPerforation write SetPerforation;

  end;

type
  TCOperator = record
    class operator Add(a, b: TCOperator): TTimecode; // Binary
    class operator Subtract(a, b: TCOperator): TTimecode; // Binary
    class operator Equal(a, b: TCOperator): Boolean; // Comparison
    class operator NotEqual(a, b: TCOperator): Boolean; // Comparison
    class operator GreaterThan(a, b: TCOperator): Boolean; // Comparison
    class operator LessThan(a, b: TCOperator): Boolean; // Comparison
    class operator GreaterThanOrEqual(a, b: TCOperator): Boolean; // Comparison
    class operator LessThanOrEqual(a, b: TCOperator): Boolean; // Comparison
  end;

  {
    // NOTE: implementation syntax...
    class operator typeName.comparisonOp(a: type; b: type): Boolean;
    class operator typeName.binaryOp(a: type; b: type): resultType;
  }

var
  fpsPtr: ^FPS_TABLE;
  fpfPtr: ^FPF_TABLE;
  tcdisplaystylePtr: ^TC_DISPLAYSTYLE;
  MathsChar: PWideChar;

implementation

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
  inherited;

end;

destructor TTimecode.Destroy;
begin

  inherited;
end;

function TTimecode.FramesToTime: TTime;
begin

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

function TTimecode.GetOperationChar(value: TTimecode.eOperation): Char;
begin

end;

function TTimecode.GetPerf: Integer;
begin

end;

function TTimecode.GetPerforation: TTimecode.ePerforation;
begin

end;

function TTimecode.GetShortStatusFPS: UnicodeString;
begin

end;

function TTimecode.GetSimpleText: UnicodeString;
begin

end;

function TTimecode.GetStandard: TTimecode.eStandard;
begin

end;

function TTimecode.GetStatus: UnicodeString;
begin

end;

function TTimecode.GetStatusFPF: UnicodeString;
begin

end;

function TTimecode.GetStatusFPS: UnicodeString;
begin

end;

function TTimecode.GetStatusStyle: UnicodeString;
begin

end;

function TTimecode.GetStyle: TTimecode.eStyle;
begin

end;

function TTimecode.GetStyleIndex: Integer;
begin

end;

function TTimecode.GetText: UnicodeString;
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

procedure TTimecode.SetPerforation(value: TTimecode.ePerforation);
begin

end;

procedure TTimecode.SetStandard(value: TTimecode.eStandard);
begin

end;

procedure TTimecode.SetStyle(value: TTimecode.eStyle);
begin

end;

procedure TTimecode.SetStyleIndex(value: Integer);
begin

end;

procedure TTimecode.SetText(value: UnicodeString);
begin

end;

function TTimecode.StripDown: UnicodeString;
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

end.
