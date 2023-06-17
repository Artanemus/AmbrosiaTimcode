unit TimecodeHelper;

interface

uses System.Classes, Timecode;

type
  tcStyle = (tcTimecodeStyle, tcTimeStyle, tcFrameStyle, tcFootageStyle);

type
  tcStandard = (tcPAL, tcFILM, tcNTSCDF, tcNTSC, tcCUSTOM);

type
  tcPerforation = (mm16, mm16_35_sound, mm35_3perf, mm35_4perf, mm35_8perf,
    mm65_70_3perf, mm65_70_4perf, mm65_70_5perf, mm65_70_6perf, mm65_70_7perf,
    mm65_70_8perf, mm65_70_9perf, mm65_70_10perf, mm65_70_11perf,
    mm65_70_12perf, mm65_70_13perf, mm65_70_14perf, mm65_70_15perf);

type
  tcOperation = (tcMultiply, tcAdd, tcSubtract, tcDivide, tcEquals, tcNone);

type

  TTimecodeHelper = record helper for TTimecode

    function GetRawText(const tcString: string): String;
    function GetSimpleText(ATimecodeStyle: tcStyle): String;
    function GetText(ATimecodeStyle: tcStyle): String;
    function GetPerfFPF(APerforation: tcPerforation): integer;
    function GetPerfCount(APerforation: tcPerforation): integer;
    function GetGateStandard(APerforation: tcPerforation): integer;
    function GetGateWidth(APerforation: tcPerforation): double;
    function GetFPSStandard(AStandard: tcStandard): double;

    // Special display string ...
    // function GetStatus(ATimecodeStyle: tcStyle;
    // APerforation: tcPerforation): string;
    // function GetTextFPS(ATimecodeStyle: tcStyle): string;overload;
    function GetTextFPS(): string;
    function GetTextPerforation(APerforation: tcPerforation): string;
    function GetTextStandard(ATimecodeStandard: tcStandard): string;
    function GetTextTimecodeStyle(ATimecodeStyle: tcStyle): string;

    function IterTimecodeStyle(CurrTimecodeStyle: tcStyle;
      DoForward: boolean = true): tcStyle;
    function IterStandard(CurrStandard: tcStandard; DoForward: boolean)
      : tcStandard;
    function IterPerforation(CurrPerforation: tcPerforation; DoForward: boolean)
      : tcPerforation;

    procedure SetText(var tc: TTimecode; ATimecodeStyle: tcStyle;
      tcString: string);

  end;

implementation

uses System.SysUtils, System.Character, System.DateUtils, System.Math;

function TTimecodeHelper.GetFPSStandard(AStandard: tcStandard): double;
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

function TTimecodeHelper.GetGateWidth(APerforation: tcPerforation): double;
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

function TTimecodeHelper.GetGateStandard(APerforation: tcPerforation): integer;
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

function TTimecodeHelper.GetPerfCount(APerforation: tcPerforation): integer;
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

function TTimecodeHelper.GetPerfFPF(APerforation: tcPerforation): integer;
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

function TTimecodeHelper.GetSimpleText(ATimecodeStyle: tcStyle): String;
var
  FText, temp: String;
  dt: TTime;
  Hour, Min, sec, MSec: Word;
begin
  // Verbose, readable text that displays in tcStyle
  // Routine trims any redundant fields. String width will vary.
  case ATimecodeStyle of
    tcTimeStyle:
      begin
        dt := self.FramesToTime;
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

// function TTimecodeHelper.GetStatus(ATimecodeStyle: tcStyle;
// APerforation: tcPerforation): string;
// begin
//
// end;

function TTimecodeHelper.GetTextPerforation(APerforation
  : tcPerforation): string;
begin
  result := '';
  case APerforation of
    mm16:
      result := '16mm';
    mm16_35_sound:
      result := '16/35mm sound';
    mm35_3perf:
      result := '35mm 3-perf';
    mm35_4perf:
      result := '35mm 4-perf';
    mm35_8perf:
      result := '35mm 8-perf';
    mm65_70_3perf:
      result := '65/70mm 3-perf';
    mm65_70_4perf:
      result := '65/70mm 4-perf';
    mm65_70_5perf:
      result := '65/70mm 5-perf';
    mm65_70_6perf:
      result := '65/70mm 6-perf';
    mm65_70_7perf:
      result := '65/70mm 7-perf';
    mm65_70_8perf:
      result := '65/70mm 8-perf';
    mm65_70_9perf:
      result := '65/70mm 9-perf';
    mm65_70_10perf:
      result := '65/70mm 10-perf';
    mm65_70_11perf:
      result := '65/70mm 11-perf';
    mm65_70_12perf:
      result := '65/70mm 12-perf';
    mm65_70_13perf:
      result := '65/70mm 13-perf';
    mm65_70_14perf:
      result := '65/70mm 14-perf';
    mm65_70_15perf:
      result := '65/70mm 15-perf';
  end;
end;

// function TTimecodeHelper.GetTextFPS(ATimecodeStyle: tcStyle): string;
// var
// s: string;
// begin
// result :='';
// s := Format('%3.2ffps', [self.FPS]);
// case ATimecodeStyle of
// tcTimecodeStyle:
// result := 'Timecode ' + s;
// tcTimeStyle:
// result := 'Time ' + s;
// tcFrameStyle:
// result := 'Frames ' + s;
// tcFootageStyle:
// result := 'Footage ' + s;
// end;
// end;

function TTimecodeHelper.GetTextFPS(): string;
var
  d: double;
begin
  d := self.FPS;
  result := Format('%gfps', [d]);
end;

function TTimecodeHelper.GetTextStandard(ATimecodeStandard: tcStandard): string;
begin
  result := '';
  case ATimecodeStandard of
    tcPAL:
      result := 'PAL';
    tcFILM:
      result := 'FILM';
    tcNTSCDF:
      result := 'NTSC DF';
    tcNTSC:
      result := 'NTSC';
    tcCUSTOM:
      result := 'CUSTOM';
  end;
end;

function TTimecodeHelper.GetTextTimecodeStyle(ATimecodeStyle: tcStyle): string;
begin
  result := '';
  case ATimecodeStyle of
    tcTimecodeStyle:
      result := 'HH:MM:SS:FF';
    tcTimeStyle:
      result := 'Hr.Min.Sec';
    tcFrameStyle:
      result := 'Frames';
    tcFootageStyle:
      result := 'Footage';
  end;
end;

function TTimecodeHelper.IterPerforation(CurrPerforation: tcPerforation;
  DoForward: boolean): tcPerforation;
var
  APerforation: tcPerforation;
begin
  result := CurrPerforation;
  for APerforation := Low(tcPerforation) to High(tcPerforation) do
  begin
    if APerforation = CurrPerforation then
    begin
      if DoForward then
        result := System.Succ(APerforation)
      else
        result := System.Pred(APerforation);
      break;
    end;
  end;
end;

function TTimecodeHelper.IterStandard(CurrStandard: tcStandard;
  DoForward: boolean): tcStandard;
var
  AStandard: tcStandard;
begin
  result := CurrStandard;
  for AStandard := Low(tcStandard) to High(tcStandard) do
  begin
    if AStandard = CurrStandard then
    begin
      if DoForward then
        result := System.Succ(AStandard)
      else
        result := System.Pred(AStandard);
      break;
    end;
  end;
end;

function TTimecodeHelper.IterTimecodeStyle(CurrTimecodeStyle: tcStyle;
  DoForward: boolean): tcStyle;
var
  ATimecodeStyle: tcStyle;
begin
  result := CurrTimecodeStyle;
  for ATimecodeStyle := Low(tcStyle) to High(tcStyle) do
  begin
    if ATimecodeStyle = CurrTimecodeStyle then
    begin
      if DoForward then
        result := System.Succ(ATimecodeStyle)
      else
        result := System.Pred(ATimecodeStyle);
      break;
    end;
  end;
end;

function TTimecodeHelper.GetText(ATimecodeStyle: tcStyle): String;
var
  FText, Buf: String;
  fraction, hours, minutes, seconds, dframes: double;
  Quotient, Remainder: single;
  Format: UnicodeString;
  frameRate: double;
begin

  if self.UseDropFrame then
    FText := '00;00;00;00'
  else
    FText := '00:00:00:00';

  Format := '00.00';
  dframes := self.frames;
  case ATimecodeStyle of
    tcTimecodeStyle, tcTimeStyle:
      begin
        frameRate := self.FPS;
        if frameRate = 0 then
        begin
          FText := 'ER:R_:FP:S_';
          Exit;
        end;
        if (self.frames = 0) and (ATimecodeStyle = tcTimecodeStyle) then
          Exit;
        if dframes < 0 then // sort out negative amounts
        begin
          dframes := -dframes;
          dframes := (frameRate * 3600.0 * frameRate) - dframes;
        end;
        if self.UseDropFrame then
        begin
          // take 29.97 and convert for display as 30fps
          // using the drop frame conversion rules...
          dframes := self.ConvertFramesDFtoND(dframes);
          // frame rate is now 30fps
          // frameRate = 30.0;
        end;
        // step one: find the number of seconds.... and the number of dframes...
        seconds := dframes / frameRate; //
        fraction := frac(seconds); //
        dframes := frameRate * fraction; // find dframes
        hours := seconds / 3600.0; // find hours
        hours := Int(hours); //
        if hours > 0 then
          seconds := seconds - (3600.0 * hours);
        minutes := seconds / 60.0; // find minutes
        minutes := Int(minutes); //
        if minutes > 0 then
          seconds := seconds - (60.0 * minutes);
        fraction := frac(dframes); // resolve rounding problems
        if fraction >= 0.5 then
          dframes := dframes + 1; // round up or down - by hand...
        if dframes >= frameRate then
        // dframes may exceed the current timebase. Make the appropriate adjustment...
        begin
          dframes := 0; //
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
        if ATimecodeStyle = tcTimecodeStyle then
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
          Buf := FormatFloat(Format, dframes);
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
      FText := String.Format('%dfr', [dframes]);
    tcFootageStyle:
      begin
        Quotient := FMod(Trunc(dframes), Trunc(self.FPF));
        Remainder := frac(dframes / self.FPF) * self.FPF;
        FText := String.Format('%0.0fFt.%2.0ffr', [Quotient, Remainder]);
      end;

  else
    ;
  end;

  result := FText;

end;

procedure TTimecodeHelper.SetText(var tc: TTimecode; ATimecodeStyle: tcStyle;
  tcString: string);
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

    tcStyle.tcTimecodeStyle: // cheap and nasty way to extract HH:MM:SS:FF
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
    tcStyle.tcTimeStyle:
      begin
        // extract hrs::Mins::Secs...
        str2 := str1.SubString(3, 2);
        frames := StrToInt(str2) * fph;
        str2 := str1.SubString(5, 2);
        frames := StrToInt(str2) * fpm + frames;
        str2 := str1.SubString(7, 2);
        frames := StrToInt(str2) * tc.FPS + frames;
      end;

    tcStyle.tcFrameStyle:
      begin
        frames := StrToIntDef(str1, 0);
      end;
    tcStyle.tcFootageStyle:
      begin
        // parameter contains feet only; - no frames...
        frames := StrToInt(str1);
        frames := frames * tc.FPF;
      end;

  end;

  // Assign value
  tc.frames := frames;
end;

function TTimecodeHelper.GetRawText(const tcString: string): String;
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
