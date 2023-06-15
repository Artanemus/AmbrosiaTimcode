unit Timecode;

interface

uses
  System.SysUtils, System.Classes, System.DateUtils, System.Math, TimecodeTypes;

type

  TTimecode = record
  private
    fFrames: Double;  // FRAME COUNT
    fFPS: Double;     // FRAMES PER SECOND
    fFPF: Double;     // FRAMES PER FOOT (FILM)
    FUseDropFrame: Boolean;
    {TODO -oBSA -cGeneral : code OnChange event}
    FOnChange: TNotifyEvent;

  public

    // In Delphi 10.4 'Managed Records' was introduced.
    // variables can now be initialized
    class operator Initialize (out Dest: TTimecode);
    class operator Finalize (var Dest: TTimecode);

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

    { NOTE: implementation syntax...
      class operator typeName.comparisonOp(a: type; b: type): Boolean;
      class operator typeName.binaryOp(a: type; b: type): resultType; }

    function ConvertFramesNDtoDF(value: Double): Double;
    function ConvertFramesDFtoND(value: Double): Double;
    function FramesToTime(): TTime;
    procedure TimeToFrames(dt: TTime);
    // PRIMARY Core parameters ...
    property frames: Double read fFrames write fFrames;
    property FPS: Double read fFPS write fFPS;
    property FPF: Double read fFPF write fFPF;
    property UseDropFrame: Boolean read FUseDropFrame write FUseDropFrame;
    // MISC
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
  end;

var
  DefFramesPerSec: Double = 24.0; // typically used in film
  DefFramesPerFoot: Double = 16;  // 16mm, 35mm 4perf or 70mm 4perf.

implementation

uses System.Character;

{ TTimecode }

function TTimecode.ConvertFramesDFtoND(value: Double): Double;
var
  f1, f2, sec: Double;
begin
  // convert 29.97 fps to 30 fps - using drop-frame conversion rules.
  // calculate seconds
  sec := value / fFPS;
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

class operator TTimecode.Finalize(var Dest: TTimecode);
begin
//  Log('destroyed' + IntToHex (IntPtr(@Dest)))
end;

function TTimecode.FramesToTime: TTime;
var
  ts: TTimeStamp; // required for precision (milliseconds)
begin
  { TODO -oBSA -cGeneral : Re-check ts.Date := 0 exception.
    There are no TTimeStamp.Date values from –1 through 0. (Unlike TDateTime)
    A TTimeStamp.Date value of 0 causes an exception in TimeStampToDateTime. }
  // ts.Date = the number of days since 1/1/0001 plus one.
  ts.Date := 1;
  // requires integer
  ts.Time := Trunc((fFrames / fFPS) * Double(MSecsPerSec));
  // strip date part.
  result := TimeOf(TimeStampToDateTime(ts));
end;

procedure TTimecode.TimeToFrames(dt: TTime);
var
  ts: TTimeStamp;
begin
  ts := DateTimeToTimeStamp(dt);
  fFrames := (Double(ts.Time) / Double(MSecsPerSec)) * fFPS;
end;

{ T C   O p e r a t o r s . }

class operator TTimecode.Add(a, b: TTimecode): TTimecode;
begin
  if a.fFPS = b.fFPS then
    result.fFrames := a.fFrames + b.fFrames
  else
    raise Exception.Create
      ('TTimecode addition was attempted with different FPS.');
end;

class operator TTimecode.Assign(var Dest: TTimecode;
  const [ref] Src: TTimecode);
begin
  Dest.fFrames := Src.fFrames;
  Dest.fFPF := Src.fFPF;
  Dest.fFPS := Src.fFPS;
  Dest.FUseDropFrame := Src.FUseDropFrame;
end;

class operator TTimecode.Equal(a, b: TTimecode): Boolean;
begin
  if a.fFPS = b.fFPS then
  begin
    if (a.fFrames = b.fFrames) then
      result := true
    else
      result := false;
  end
  else
  begin
    if ((a.fFrames / a.fFPS) = (b.fFrames / b.fFPS)) then
      result := true
    else
      result := false;
  end;

end;

class operator TTimecode.GreaterThan(a, b: TTimecode): Boolean;
begin
  if a.fFPS = b.fFPS then
  begin
    if (a.fFrames > b.fFrames) then
      result := true
    else
      result := false;
  end
  else
  begin
    if ((a.fFrames / a.fFPS) > (b.fFrames / b.fFPS)) then
      result := true
    else
      result := false;
  end;
end;

class operator TTimecode.GreaterThanOrEqual(a, b: TTimecode): Boolean;
begin
  if a.fFPS = b.fFPS then
  begin
    if (a.fFrames >= b.fFrames) then
      result := true
    else
      result := false;
  end
  else
  begin
    if ((a.fFrames / a.fFPS) >= (b.fFrames / b.fFPS)) then
      result := true
    else
      result := false;
  end;
end;

class operator TTimecode.Initialize(out Dest: TTimecode);
begin
  Dest.fFrames := 0;
  Dest.fFPS := DefFramesPerSec;
  Dest.fFPF := DefFramesPerFoot;
end;

class operator TTimecode.LessThan(a, b: TTimecode): Boolean;
begin
  if a.fFPS = b.fFPS then
  begin
    if (a.fFrames < b.fFrames) then
      result := true
    else
      result := false;
  end
  else
  begin
    if ((a.fFrames / a.fFPS) < (b.fFrames / b.fFPS)) then
      result := true
    else
      result := false;
  end;
end;

class operator TTimecode.LessThanOrEqual(a, b: TTimecode): Boolean;
begin
  if a.fFPS = b.fFPS then
  begin
    if (a.fFrames <= b.fFrames) then
      result := true
    else
      result := false;
  end
  else
  begin
    if ((a.fFrames / a.fFPS) <= (b.fFrames / b.fFPS)) then
      result := true
    else
      result := false;
  end;
end;

class operator TTimecode.NotEqual(a, b: TTimecode): Boolean;
begin
  if a.fFPS = b.fFPS then
  begin
    if (a.fFrames <> b.fFrames) then
      result := true
    else
      result := false;
  end
  else
  begin
    if ((a.fFrames / a.fFPS) <> (b.fFrames / b.fFPS)) then
      result := true
    else
      result := false;
  end;
end;

class operator TTimecode.Subtract(a, b: TTimecode): TTimecode;
begin
  if a.fFPS = b.fFPS then
    result.fFrames := a.fFrames - b.fFrames
  else
    raise Exception.Create
      ('TTimecode subtraction was attempted with different FPS.');
end;

end.
