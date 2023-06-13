unit Timecode;

interface

uses
  System.SysUtils, System.Classes, System.DateUtils, Math, TimecodeTypes;

type

  TTimecode = record
  private
    fFrames: Double;
    fFPS: Double;
    fFPF: Double;

    FStyle: eStyle;
    FFPFIndex: Integer;
    FFPSIndex: Integer;
    fStyleIndex: Integer;
    FCustomFPS: Double;
    FUseGlobal: Boolean;
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

    procedure Change;

  public

    constructor Create(frames: Double); overload;
    constructor Create(FPS, FPF, frames: Double); overload;

    class operator Add(a, b: TTimecode): TTimecode; // Binary
    class operator Subtract(a, b: TTimecode): TTimecode; // Binary
    class operator Equal(a, b: TTimecode): Boolean; // Comparison
    class operator NotEqual(a, b: TTimecode): Boolean; // Comparison
    class operator GreaterThan(a, b: TTimecode): Boolean; // Comparison
    class operator LessThan(a, b: TTimecode): Boolean; // Comparison
    class operator GreaterThanOrEqual(a, b: TTimecode): Boolean; // Comparison
    class operator LessThanOrEqual(a, b: TTimecode): Boolean; // Comparison
    class operator Assign(var Dest: TTimecode; const [ref] Src: TTimecode);
    // Binary

    {
      // NOTE: implementation syntax...
      class operator typeName.comparisonOp(a: type; b: type): Boolean;
      class operator typeName.binaryOp(a: type; b: type): resultType;
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

    property Standard: eStandard read GetStandard write SetStandard;
    property UseGlobal: Boolean read FUseGlobal write FUseGlobal;
    property CustomFPS: Double read GetCustomFPS write SetCustomFPS;
    property frames: Double read GetFrames write SetFrames;
    property FPSIndex: Integer read GetFPSIndex write SetFPSIndex;
    property FPFIndex: Integer read GetFPFIndex write SetFPFIndex;
    property StyleIndex: Integer read GetStyleIndex write SetStyleIndex;
    property Text: String read GetText write SetText;
    property style: eStyle read GetStyle write SetStyle;
    property UseDropFrame: Boolean read FUseDropFrame write FUseDropFrame;
    property Perforation: ePerforation read GetPerforation write SetPerforation;

  end;

implementation

{ TTimecode }

procedure TTimecode.Change;
begin

end;

function TTimecode.ConvertFramesDFtoND(value: Double): Double;
var
  frac, f1, f2, sec: Double;
begin
  // convert 29.97 fps to 30 fps - using drop-frame conversion rules.
  // calculate seconds
  sec := value / GetFPS();
  // count the minute intervals x 2
  // extract the integer portion of the double
  f1 := FMod(sec, 60.0);
  // calculate frames
  f1 := f1 * 2;
  // count the number of 10min blocks x 2
  // extract the integer portion of the double
  f2 := FMod(sec, 600.0);
  // calculate frames
  f2 := f2 * 2;
  // wrap it up
  result := (value + f1 - f2);
end;

function TTimecode.ConvertFramesNDtoDF(value: Double): Double;
begin
  // convert ND to seconds then divide by DF.
  // Returns frames count at 29.97.
  result := value / 30.0 * 29.97;
end;

constructor TTimecode.Create(frames: Double);
begin
  fFrames := frames;
  FUseGlobal := false;
  FFPSIndex := GlobalFPSIndex;   //3
  FFPFIndex := GlobalFPFIndex;   //0
  FCustomFPS := GlobalCustomFPS; //12.0
  FStyle := tcStyle;

  fFPS := GetFPS;
  fFPF := GetFPF

end;

constructor TTimecode.Create(FPS, FPF, frames: Double);
begin
  FUseGlobal := true;
  FFPSIndex := GlobalFPSIndex;
  FFPFIndex := GlobalFPFIndex;
  FCustomFPS := GlobalCustomFPS;
  FStyle := tcStyle;

  fFrames := frames;
  fFPS := fps;
  fFPF := fpf;
end;

function TTimecode.FramesToTime: TTime;
var
  dt: TDateTime;
begin
  dt := (fFrames / GetFPS()) / SecsPerDay * 1000.0;
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
var
  str1, str2: String;
  x, y: Integer;
  frames, val: Double;
  fpm: Double;
  fph: Double;

begin
  { TODO :
    Extract feet + frames from Footage Style
    Extract fraction of seconds from Time Style }
  fpm := GetFPS() * 60.0;
  fph := GetFPS() * 3600.0;
  value := value.Trim();
  // remove all non-numerical characters
  // working backwards....
  // no error checking of Hrs, Mins, secs, Frames.....!!
  str1 := '00000000';
  y := 8;

  for x := Length(Value) downto 0 do
  begin
//    while ((x>0) and (value[x] < '0' or value[x] > '9')) do
//      x := x-1;

    { for (x = value.Length(), y = 8; x > 0 && y > 0; x--, y--) begin
      while (x && (value[x] < '0' || value[x] > '9'))
      x--;
      if (x)
      str1[y] = value[x];
      end; }

  end;

  case (FStyle) of

    eStyle.tcStyle: // cheap and nasty way to get frame count
      // HH::MM::SS::FF
      begin
        str2 := str1.SubString(1, 2);
        frames := StrToInt(str2) * fph;
        str2 := str1.SubString(3, 2);
        frames := StrToInt(str2) * fpm + frames;
        str2 := str1.SubString(5, 2);
        frames := StrToInt(str2) * GetFPS() + frames;
        str2 := str1.SubString(7, 2);
        frames := frames + StrToInt(str2);
      end;
    eStyle.tctimeStyle:
      begin
        // hrs::Mins::Secs...
        str2 := str1.SubString(3, 2);
        frames := StrToInt(str2) * fph;
        str2 := str1.SubString(5, 2);
        frames := StrToInt(str2) * fpm + frames;
        str2 := str1.SubString(7, 2);
        frames := StrToInt(str2) * GetFPS() + frames;
      end;

    eStyle.tcframeStyle:
      begin
        frames := StrToIntDef(str1, 0);
      end;
    eStyle.tcfootageStyle:
      begin
        // parameter contains feet only; - no frames...
        frames := StrToInt(str1);
        frames := frames * GetFPF();
      end;

  end;

  // Update fTimeStamp
  SetFrames(frames);

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

class operator TTimecode.Add(a, b: TTimecode): TTimecode;
begin
  result.fFrames := a.fFrames + b.fFrames;
end;

class operator TTimecode.Assign(var Dest: TTimecode;
  const [ref] Src: TTimecode);
begin
  Dest.fFrames := Src.fFrames;
  Dest.fFPF := Src.fFPF;
  Dest.fFPS := Src.fFPS;

  Dest.FStyle := Src.FStyle;
  Dest.FFPFIndex := Src.FFPFIndex;
  Dest.FFPSIndex := Src.FFPSIndex;
  Dest.FCustomFPS := Src.FCustomFPS;
  Dest.FUseGlobal := Src.FUseGlobal;
end;

class operator TTimecode.Equal(a, b: TTimecode): Boolean;
begin
  if (a.fFrames = b.fFrames) then
    result := true
  else
    result := false;
end;

class operator TTimecode.GreaterThan(a, b: TTimecode): Boolean;
begin
  if (a.fFrames > b.fFrames) then
    result := true
  else
    result := false;
end;

class operator TTimecode.GreaterThanOrEqual(a, b: TTimecode): Boolean;
begin
  if (a.fFrames >= b.fFrames) then
    result := true
  else
    result := false;
end;

class operator TTimecode.LessThan(a, b: TTimecode): Boolean;
begin
  if (a.fFrames < b.fFrames) then
    result := true
  else
    result := false;
end;

class operator TTimecode.LessThanOrEqual(a, b: TTimecode): Boolean;
begin
  if (a.fFrames <= b.fFrames) then
    result := true
  else
    result := false;
end;

class operator TTimecode.NotEqual(a, b: TTimecode): Boolean;
begin
  if (a.fFrames <> b.fFrames) then
    result := true
  else
    result := false;
end;

class operator TTimecode.Subtract(a, b: TTimecode): TTimecode;
begin
  result.fFrames := a.fFrames - b.fFrames;
end;

end.
