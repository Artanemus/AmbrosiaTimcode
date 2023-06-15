unit TimecodeUtils;

interface

uses System.Classes, Timecode;

type
  eStyle = (tcStyle, tcTimeStyle, tcFrameStyle, tcFootageStyle);

type
  eStandard = (tcPAL, tcFILM, tcNTSCDF, tcNTSC, tcCUSTOM);

type
  ePerforation = (mm16, mm16_35_sound, mm35_3perf, mm35_4perf, mm35_8perf,
    mm65_70_3perf, mm65_70_4perf, mm65_70_5perf, mm65_70_6perf, mm65_70_7perf,
    mm65_70_8perf, mm65_70_9perf, mm65_70_10perf, mm65_70_11perf,
    mm65_70_12perf, mm65_70_13perf, mm65_70_14perf, mm65_70_15perf);

function StriptcString(const tcString: string): String;

function GetSimpleText(tc: TTimecode; ATimecodeStyle: eStyle): String;
function GetText(tc: TTimecode; ATimecodeStyle: eStyle): String;
procedure SetText(var tc: TTimecode; ATimecodeStyle: eStyle; tcString: string);

function GetPerfFPF(APerforation: ePerforation): integer;
function GetPerfCount(APerforation: ePerforation): integer;
function GetGateStandard(APerforation: ePerforation): integer;
function GetGateWidth(APerforation: ePerforation): double;
function GetFPSStandard(AStandard: eStandard): double;

implementation

uses System.SysUtils, System.Character, System.DateUtils, System.Math;

function GetFPSStandard(AStandard: eStandard): double;
begin
  result := 0;
  case AStandard of
    tcPAL:
      result := 25.0;
    tcFILM:
      result := 24.0;
    tcNTSCDF:
      result := 29.97;
    tcNTSC:
      result := 30.00;
    tcCUSTOM:
      result := 12.00;
  end;
end;

function GetGateWidth(APerforation: ePerforation): double;
begin
  result := 0;
  case APerforation of
    mm16:
      result := 0.3;
    mm16_35_sound:
      result := 0.75;
    mm35_3perf:
      result := 0.5454545454545;
    mm35_4perf:
      result := 0.75;
    mm35_8perf:
      result := 1.5;
    mm65_70_3perf:
      result := 0.5454545454545;
    mm65_70_4perf:
      result := 0.75;
    mm65_70_5perf:
      result := 0.5454545454545;
    mm65_70_6perf:
      result := 1.090909090909;
    mm65_70_7perf:
      result := 1.2;
    mm65_70_8perf:
      result := 1.5;
    mm65_70_9perf:
      result := 1.5;
    mm65_70_10perf:
      result := 1.714285714286;
    mm65_70_11perf:
      result := 2.0;
    mm65_70_12perf:
      result := 2.0;
    mm65_70_13perf:
      result := 2.4;
    mm65_70_14perf:
      result := 2.4;
    mm65_70_15perf:
      result := 2.4;
  end;
end;

function GetGateStandard(APerforation: ePerforation): integer;
begin
  result := 0;
  case APerforation of
    mm16:
      result := 16;
    mm16_35_sound:
      result := 16;
    mm35_3perf:
      result := 35;
    mm35_4perf:
      result := 35;
    mm35_8perf:
      result := 35;
    mm65_70_3perf:
      result := 65;
    mm65_70_4perf:
      result := 65;
    mm65_70_5perf:
      result := 65;
    mm65_70_6perf:
      result := 65;
    mm65_70_7perf:
      result := 65;
    mm65_70_8perf:
      result := 65;
    mm65_70_9perf:
      result := 65;
    mm65_70_10perf:
      result := 65;
    mm65_70_11perf:
      result := 65;
    mm65_70_12perf:
      result := 65;
    mm65_70_13perf:
      result := 65;
    mm65_70_14perf:
      result := 65;
    mm65_70_15perf:
      result := 65;
  end;
end;

function GetPerfCount(APerforation: ePerforation): integer;
begin
  result := 0;
  case APerforation of
    mm16:
      result := 2;
    mm16_35_sound:
      result := 2;
    mm35_3perf:
      result := 3;
    mm35_4perf:
      result := 4;
    mm35_8perf:
      result := 8;
    mm65_70_3perf:
      result := 3;
    mm65_70_4perf:
      result := 4;
    mm65_70_5perf:
      result := 5;
    mm65_70_6perf:
      result := 6;
    mm65_70_7perf:
      result := 7;
    mm65_70_8perf:
      result := 8;
    mm65_70_9perf:
      result := 9;
    mm65_70_10perf:
      result := 10;
    mm65_70_11perf:
      result := 11;
    mm65_70_12perf:
      result := 12;
    mm65_70_13perf:
      result := 13;
    mm65_70_14perf:
      result := 14;
    mm65_70_15perf:
      result := 15;
  end;

end;

function GetPerfFPF(APerforation: ePerforation): integer;
begin
  result := 0;
  case APerforation of
    mm16:
      result := 40;
    mm16_35_sound:
      result := 16;
    mm35_3perf:
      result := 22;
    mm35_4perf:
      result := 16;
    mm35_8perf:
      result := 8;
    mm65_70_3perf:
      result := 22;
    mm65_70_4perf:
      result := 16;
    mm65_70_5perf:
      result := 13;
    mm65_70_6perf:
      result := 11;
    mm65_70_7perf:
      result := 10;
    mm65_70_8perf:
      result := 8;
    mm65_70_9perf:
      result := 8;
    mm65_70_10perf:
      result := 7;
    mm65_70_11perf:
      result := 6;
    mm65_70_12perf:
      result := 6;
    mm65_70_13perf:
      result := 5;
    mm65_70_14perf:
      result := 5;
    mm65_70_15perf:
      result := 5;
  end;
end;

function GetSimpleText(tc: TTimecode; ATimecodeStyle: eStyle): String;
var
  FText, temp: String;
  dt: TTime;
  Hour, Min, sec, MSec: Word;
begin
  // Verbose, readable text that displays in eStyle
  // Routine trims any redundant fields. String width will vary.
  case ATimecodeStyle of
    tcTimeStyle:
      begin
        dt := tc.FramesToTime;
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
  end;
  result := FText;
end;

function GetText(tc: TTimecode; ATimecodeStyle: eStyle): String;
var
  FText, Buf: String;
  fraction, hours, minutes, seconds, frames: double;
  Quotient, Remainder: single;
  Format: UnicodeString;
  frameRate: double;
begin

  if tc.UseDropFrame then
    FText := '00;00;00;00'
  else
    FText := '00:00:00:00';

  Format := '00.00';
  frames := tc.frames;
  case ATimecodeStyle of
    tcStyle, tcTimeStyle:
      begin
        frameRate := tc.FPS;
        if frameRate = 0 then
        begin
          FText := 'ER:R_:FP:S_';
          Exit;
        end;
        if (tc.frames = 0) and (ATimecodeStyle = tcStyle) then
          Exit;
        if frames < 0 then // sort out negative amounts
        begin
          frames := -frames;
          frames := (frameRate * 3600.0 * frameRate) - frames;
        end;
        if tc.UseDropFrame then
        begin
          // take 29.97 and convert for display as 30fps
          // using the drop frame conversion rules...
          frames := tc.ConvertFramesDFtoND(frames);
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
        if ATimecodeStyle = tcStyle then
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
    tcFrameStyle:
      FText := String.Format('%dfr', [frames]);
    tcFootageStyle:
      begin
        Quotient := FMod(Trunc(frames), Trunc(tc.FPF));
        Remainder := frac(frames / tc.FPF) * tc.FPF;
        FText := String.Format('%0.0fFt.%2.0ffr', [Quotient, Remainder]);
      end;

  else
    ;
  end;

  result := FText;

end;

procedure SetText(var tc: TTimecode; ATimecodeStyle: eStyle; tcString: string);
var
  str1, str2: String;
  I: integer;
  frames, fpm, fph: double;
begin
  frames := 0;

  if Length(tcString) = 0 then
  begin
    tc.frames := 0;
    Exit;
  end;

  { TODO :
    Extract feet + frames from Footage Style
    Extract fraction of seconds from Time Style
    no error checking of Hrs, Mins, secs, Frames.....!!
  }

  fpm := tc.FPS * 60.0;
  fph := tc.FPS * 3600.0;

  // TEMPLATE REQUIRED '00000000' - MAX LENGTH = 8
  str1 := tcString;
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

  case (ATimecodeStyle) of

    eStyle.tcStyle: // cheap and nasty way to extract HH:MM:SS:FF
      begin
        str2 := str1.SubString(1, 2);
        frames := StrToInt(str2) * fph;
        str2 := str1.SubString(3, 2);
        frames := StrToInt(str2) * fpm + frames;
        str2 := str1.SubString(5, 2);
        frames := StrToInt(str2) * tc.FPS + frames;
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
        frames := StrToInt(str2) * tc.FPS + frames;
      end;

    eStyle.tcFrameStyle:
      begin
        frames := StrToIntDef(str1, 0);
      end;
    eStyle.tcFootageStyle:
      begin
        // parameter contains feet only; - no frames...
        frames := StrToInt(str1);
        frames := frames * tc.FPF;
      end;

  end;

  // Assign value
  tc.frames := frames;
end;

function StriptcString(const tcString: string): String;
var
  I: integer;
  S: string;
begin
  S := tcString;
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

end.
