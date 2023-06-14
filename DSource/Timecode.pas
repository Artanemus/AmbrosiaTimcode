unit Timecode;

interface

uses
  System.SysUtils, System.Classes, System.DateUtils, System.Math, TimecodeTypes;

  type eStyle = (tcStyle, tcTimeStyle, tcFrameStyle, tcFootageStyle);

  type eStandard = (tcPAL, tcFILM, tcNTSCDF, tcNTSC, tcCUSTOM);

  type ePerforation = (mm16, mm16_35_sound, mm35_3perf, mm35_4perf, mm35_8perf,
  mm65_70_3perf, mm65_70_4perf, mm65_70_5perf, mm65_70_6perf, mm65_70_7perf,
  mm65_70_8perf, mm65_70_9perf, mm65_70_10perf, mm65_70_11perf,
  mm65_70_12perf, mm65_70_13perf, mm65_70_14perf, mm65_70_15perf);


type

  TTimecode = record
  private
    fFrames: Double;
    fFPS: Double;
    fFPF: Double;
    fStyle: eStyle;
    fStandard: eStandard;
    fPerforation: ePerforation;

    FUseDropFrame: Boolean;
    FOnChange: TNotifyEvent;

    // FFPFIndex: Integer;
    // FFPSIndex: Integer;
    // fStyleIndex: Integer;
    // FCustomFPS: Double;
    // FUseGlobal: Boolean;
    // fTCFPSCount: Integer;
    // fTCFPFCount: Integer;
    // fTCDisplayStylesCount: Integer;

    procedure SetText(value: String);
    function GetText: String;
    // function GetStandard: eStandard;
    // procedure SetStandard(value: eStandard);
    // function GetPerforation: ePerforation;
    // procedure SetPerforation(value: ePerforation);
    // procedure SetFPS(value: Double);
    // function GetFPS: Double;
    // function GetFPF: Integer;
    // function GetStatus: String;
    // function GetStatusFPS: String;
    // function GetShortStatusFPS: String;
    // function GetStatusFPF: String;
    // function GetStatusStyle: String;
    // function GetGateWidth: Double;
    // function GetPerf: Integer;
    // function GetGate: Integer;
    // procedure SetFrames(value: Double);
    // function GetFrames: Double;

    // procedure SetFPSIndex(value: Integer);
    // function GetFPSIndex: Integer;
    // procedure SetFPFIndex(value: Integer);
    // function GetFPFIndex: Integer;
    // procedure SetStyleIndex(value: Integer);
    // function GetStyleIndex: Integer;
    // function GetCustomFPS: Double;
    // procedure SetCustomFPS(value: Double);


  public

    constructor Create(frames: Double); overload;
    constructor Create(frames, FPS, FPF: Double); overload;

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
    // function GetOperationChar(value: eOperation): Char;
    // Returns reduced string with 'numbers' (and decimal).
    function StripDown(): String;
    function FramesToTime(): TTime;
    procedure TimeToFrames(dt: TTime);
    // procedure ToggleFPS(Forward: Boolean = true);
    // procedure ToggleFPF(Forward: Boolean = true);
    // procedure ToggleStyle(Forward: Boolean = true);
    // PRIMARY Core parameters ...
    property frames: Double read fFrames write fFrames;
    property FPS: Double read fFPS write fFPS;
    property FPF: Double read fFPF write fFPF;
    property style: eStyle read fStyle write fStyle;
    // SECONDARY Core parameters ...
    // property perf: Integer read GetPerf;
    // property gate: Integer read GetGate;
    property UseDropFrame: Boolean read FUseDropFrame write FUseDropFrame;
    // property Perforation: ePerforation read GetPerforation write SetPerforation;
    // property GateWidth: Double read GetGateWidth;
    // MISC
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
    // property Standard: eStandard read GetStandard write SetStandard;
    property Text: String read GetText write SetText;

    // Special display string ...  --- remove from TTimecode
    // property Status: String read GetStatus;
    // property StatusFPS: String read GetStatusFPS;
    // property ShortStatusFPS: String read GetShortStatusFPS;
    // property StatusFPF: String read GetStatusFPF;
    // property StatusStyle: String read GetStatusStyle;

    // property TCFPSCount: Integer read fTCFPSCount;
    // property TCFPFCount: Integer read fTCFPFCount;
    // property TCDisplayStylesCount: Integer read fTCDisplayStylesCount;
    // property UseGlobal: Boolean read FUseGlobal write FUseGlobal;
    // property CustomFPS: Double read GetCustomFPS write SetCustomFPS;
    // property FPSIndex: Integer read GetFPSIndex write SetFPSIndex;
    // property FPFIndex: Integer read GetFPFIndex write SetFPFIndex;
    // property StyleIndex: Integer read GetStyleIndex write SetStyleIndex;

  end;

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

constructor TTimecode.Create(frames: Double);
begin
  fFrames := frames;
  fStyle := eStyle.tcStyle;
  fFPS := 24.0;
  fFPF := 16;
  // FUseGlobal := false;
  // FFPSIndex := GlobalFPSIndex; // 3
  // FFPFIndex := GlobalFPFIndex; // 0
  // FCustomFPS := GlobalCustomFPS; // 12.0

end;

constructor TTimecode.Create(frames, FPS, FPF: Double);
begin
  fFrames := frames;
  fStyle := tcStyle;
  fFPS := FPS;
  fFPF := FPF;
  // FUseGlobal := true;
  // FFPSIndex := GlobalFPSIndex;
  // FFPFIndex := GlobalFPFIndex;
  // FCustomFPS := GlobalCustomFPS;
end;

function TTimecode.FramesToTime: TTime;
var
  ts: TTimeStamp; // required for precision (milliseconds)
begin
  { TODO -oBSA -cGeneral : Re-check ts.Date := 0 exception. }
  {
    There are no TTimeStamp.Date values from –1 through 0. (Unlike TDateTime)
    A TTimeStamp.Date value of 0 causes an exception in TimeStampToDateTime.
  }
  // ts.Date = the number of days since 1/1/0001 plus one.
  ts.Date := 1;
  // requires integer
  ts.Time := Trunc((fFrames / fFPS) * Double(MSecsPerSec));
  // strip date part.
  result := TimeOf(TimeStampToDateTime(ts));
end;

function TTimecode.GetSimpleText: String;
var
  FText, temp: String;
  dt: TTime;
  Hour, Min, sec, MSec: Word;
begin
  // Short:
  // Simple text routine trims any redundant fields.
  // Remarks:
  // String width will vary.
  case fStyle of
    tcTimeStyle:
      begin
        dt := FramesToTime;
        // the time value is empty.
        if (Hour = 0) and (Min = 0) and (sec = 0) then
          FText := '...'
        else
        begin
          DecodeTime(dt, Hour, Min, sec, MSec);
          FText := '';
          // only show hours if we have them
          if Hour > 0 then
          begin
            FText := FText + IntToStr(Hour);
            if (Min > 0) and (sec > 0) then
              FText := FText + ':'
            else if (Min > 0) and (sec = 0) then
              FText := FText + 'h'
            else if (Min = 0) and (sec > 0) then
              FText := FText + 'h...'
            else
              // We only have hours.
              FText := FText + 'hrs.';
          end;
          // if we have no minutes....
          // if we have hours || (hour && secs) we must show minutes
          if (Min > 0) or ((Hour > 0) and (sec > 0)) then
          begin
            temp := FText + Format('%2.2d', [Min]);
            if (Hour > 0) and (sec > 0) and (Min > 0) then
              FText := temp + ':'
            else if (Min > 0) and
              (((Hour > 0) and (sec = 0)) or ((Hour = 0) and (sec > 0))) then
              FText := temp + 'm'
            else if (Min > 0) and (Hour = 0) and (sec = 0) then
              // We only have mins.
              FText := temp + 'mins.';
          end;
          // always show seconds.
          if sec > 0 then
          begin
            FText := FText + Format('%2.2d', [sec]);
            if (Hour = 0) and (Min = 0) then
              FText := FText + 'secs.'
            else if ((Hour > 0) and (Min = 0)) or ((Hour = 0) and (Min > 0))
            then
              FText := FText + 's';
          end;
        end;
      end;
  else
    FText := GetText;
  end;
  result := FText;
end;

function TTimecode.GetText: String;
var
  FText, Buf: String;
  fraction, hours, minutes, seconds, frames: Double;
  Quotient, Remainder: single;
  Format: UnicodeString;
  frameRate: Double;
begin

  if FUseDropFrame then
    FText := '00;00;00;00'
  else
    FText := '00:00:00:00';

  Format := '00.00';
  frames := fFrames;
  case fStyle of
    tcStyle, tcTimeStyle:
      begin
        frameRate := fFPS;
        if frameRate = 0 then
        begin
          FText := 'ER:R_:FP:S_';
          Exit;
        end;
        if (fFrames = 0) and (fStyle = tcStyle) then
          Exit;
        if frames < 0 then // sort out negative amounts
        begin
          frames := -frames;
          frames := (frameRate * 3600.0 * frameRate) - frames;
        end;
        if FUseDropFrame then
        begin
          // take 29.97 and convert for display as 30fps
          // using the drop frame conversion rules...
          frames := ConvertFramesDFtoND(frames);
          // frame rate is now 30fps
          // frameRate = 30.0;
        end;
        // step one: find the number of seconds.... and the number of frames...
        seconds := frames / frameRate; //
        fraction := frac(seconds); //
        frames := frameRate * fraction; // find frames
        hours := seconds / 3600.0; // find hours
        hours := Int(hours); //
        if hours > 0 then
          seconds := seconds - (3600.0 * hours);
        minutes := seconds / 60.0; // find minutes
        minutes := Int(minutes); //
        if minutes > 0 then
          seconds := seconds - (60.0 * minutes);
        fraction := frac(frames); // resolve rounding problems
        if fraction >= 0.5 then
          frames := frames + 1; // round up or down - by hand...
        if frames >= frameRate then
        // frames may exceed the current timebase. Make the appropriate adjustment...
        begin
          frames := 0; //
          seconds := seconds + 1; //
        end;
        if seconds >= 60 then
        begin
          seconds := 0;
          minutes := minutes + 1;
        end;
        if minutes >= 60 then
        begin
          minutes := 0;
          hours := hours + 1;
        end;
        if fStyle = tcStyle then
        begin
          Buf := FormatFloat(Format, hours);
          // sloppy - but safe way of preparing the string for diplay...
          FText[1] := Buf[1]; //
          FText[2] := Buf[2]; //
          Buf := FormatFloat(Format, minutes);
          FText[4] := Buf[1];
          FText[5] := Buf[2];
          Buf := FormatFloat(Format, seconds); // find seconds
          FText[7] := Buf[1];
          FText[8] := Buf[2];
          Buf := FormatFloat(Format, frames);
          FText[10] := Buf[1];
          FText[11] := Buf[2];
        end
        else
        begin // to make all padding zero's (not blanks) FormatFloat was used.
          FText := FormatFloat('00', hours) + 'h' + FormatFloat('00', minutes) +
            'm' + FormatFloat('00', seconds) + 's';
        end;
      end;
    tcframeStyle:
      FText := String.Format('%dfr', [frames]);
    tcfootageStyle:
      begin
        Quotient := FMod(Trunc(frames), Trunc(fFPF));
        Remainder := Frac(frames / fFPF) * fFPF;
        FText := String.Format('%0.0fFt.%2.0ffr', [Quotient, Remainder]);
      end;

  else
    ;
  end;

  result := FText;

end;

procedure TTimecode.SetText(value: String);
var
  str1, str2: String;
  I: Integer;
  frames,fpm,fph: Double;
begin
  frames := 0;

  if Length(value) = 0 then
  begin
    fFrames := 0;
    Exit;
  end;

  { TODO :
    Extract feet + frames from Footage Style
    Extract fraction of seconds from Time Style
    no error checking of Hrs, Mins, secs, Frames.....!!
  }

  fpm := fFPS * 60.0;
  fph := fFPS * 3600.0;

  // TEMPLATE REQUIRED '00000000' - MAX LENGTH = 8
  str1 := value;
  // Remove all non-numerical characters
  for I := Length(str1) downto 1 do
    if not str1[I].IsDigit then
      Delete(str1, I, 1);
  // Trim the HEAD - if oversized
  if Length(str1) > 8 then
    str1 := Copy(str1, Length(str1) - 8 + 1, 8);
  // Pad with LEADING '0' - if undersized
  while Length(str1) < 8 do
    str1 := '0' + str1;

  case (fStyle) of

    eStyle.tcStyle: // cheap and nasty way to extract HH:MM:SS:FF
      begin
        str2 := str1.SubString(1, 2);
        frames := StrToInt(str2) * fph;
        str2 := str1.SubString(3, 2);
        frames := StrToInt(str2) * fpm + frames;
        str2 := str1.SubString(5, 2);
        frames := StrToInt(str2) * fFPS + frames;
        str2 := str1.SubString(7, 2);
        frames := frames + StrToInt(str2);
      end;
    eStyle.tcTimeStyle:
      begin
        // extract hrs::Mins::Secs...
        str2 := str1.SubString(3, 2);
        frames := StrToInt(str2) * fph;
        str2 := str1.SubString(5, 2);
        frames := StrToInt(str2) * fpm + frames;
        str2 := str1.SubString(7, 2);
        frames := StrToInt(str2) * fFPS + frames;
      end;

    eStyle.tcframeStyle:
      begin
        frames := StrToIntDef(str1, 0);
      end;
    eStyle.tcfootageStyle:
      begin
        // parameter contains feet only; - no frames...
        frames := StrToInt(str1);
        frames := frames * fFPF;
      end;

  end;

  // Assign value
  fFrames := frames;
end;

function TTimecode.StripDown: String;
var
  I: Integer;
  S: string;
begin
  S := GetText();
  // Strip out non-numbers
  for I := Length(S) downto 1 do
    if not S[I].IsDigit then
      Delete(S, I, 1);
  // strip out leading zeros
  if not S.IsEmpty then
  begin
    while (Length(S) > 0) and (S[1] = '0') do
      Delete(S, 1, 1);
  end;
  result := S;
end;

procedure TTimecode.TimeToFrames(dt: TTime);
begin

end;

// procedure TTimecode.ToggleFPF(Forward: Boolean);
// begin
//
// end;
//
// procedure TTimecode.ToggleFPS(Forward: Boolean);
// begin
//
// end;
//
// procedure TTimecode.ToggleStyle(Forward: Boolean);
// begin
//
// end;

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

  Dest.fStyle := Src.fStyle;
  // Dest.FFPFIndex := Src.FFPFIndex;
  // Dest.FFPSIndex := Src.FFPSIndex;
  // Dest.FCustomFPS := Src.FCustomFPS;
  // Dest.FUseGlobal := Src.FUseGlobal;
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
