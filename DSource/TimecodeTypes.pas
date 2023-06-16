unit TimecodeTypes;

interface

uses System.SysUtils, System.Classes;

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
  FPSrecord = record
    fps: Double;
    Caption: string;
    ABREV: string;
    constructor Create(Afps: Double; ACaption, AABREV: string);
  end;

type
  FPFrecord = record
    fpf: Integer;
    Caption: string;
    GateWidth: Double;
    perf: Integer;
    gate: Integer;
    constructor Create(Afpf: Integer; ACaption: string; AGateWidth: Double;
      Aperf, Agate: Integer);
  end;

type
  TCDisplayStyle = record
    ID: Integer;
    Caption: string;
    ABREV: string;
    constructor Create(AID: Integer; ACaption, AABREV: string);
  end;

procedure BuildFPS_TABLE;
procedure BuildFPF_TABLE;
procedure BuildTC_DISPLAY;
procedure BuildMathsChar;

var
  FPS_TABLE: ARRAY of FPSrecord;
  FPF_TABLE: ARRAY of FPFrecord;
  TC_DISPLAY: ARRAY of TCDisplayStyle;
  MathsChar: ARRAY of PWideChar;

const GlobalFPFIndex:integer = 3;
const GlobalFPSIndex:integer = 0;
const GlobalCustomFPS:double = 12.0;


implementation

procedure BuildFPS_TABLE;
begin
  SetLength(FPS_TABLE, 5);
  FPS_TABLE[0] := FPSrecord.Create(25.00, '25fps', 'PAL');
  FPS_TABLE[1] := FPSrecord.Create(24.00, '24fps', 'FILM');
  FPS_TABLE[2] := FPSrecord.Create(29.97, '29.97', 'NTSC DF');
  FPS_TABLE[3] := FPSrecord.Create(30.00, '30fps', 'NTSC');
  FPS_TABLE[4] := FPSrecord.Create(12.00, 'Custom fps', 'CUSTOM');
end;

procedure BuildFPF_TABLE;
begin
  SetLength(FPF_TABLE, 18);

  FPF_TABLE[0] := FPFrecord.Create(40, '16mm', 0.3, 2, 16);
  FPF_TABLE[1] := FPFrecord.Create(16, '16/35mm sound', 0.75, 2, 16);
  FPF_TABLE[2] := FPFrecord.Create(22, '35mm 3-perf', 0.5454545454545, 3, 35);
  FPF_TABLE[3] := FPFrecord.Create(16, '35mm 4-perf', 0.75, 4, 35);
  FPF_TABLE[4] := FPFrecord.Create(8, '35mm 8-perf', 1.5, 8, 65);
  FPF_TABLE[5] := FPFrecord.Create(22, '65/70mm 3-perf',
    0.5454545454545, 3, 65);
  FPF_TABLE[6] := FPFrecord.Create(16, '65/70mm 4-perf', 0.75, 4, 65);
  FPF_TABLE[7] := FPFrecord.Create(13, '65/70mm 5-perf',
    0.9230769230769, 5, 65);
  FPF_TABLE[8] := FPFrecord.Create(11, '65/70mm 6-perf', 1.090909090909, 6, 65);
  FPF_TABLE[9] := FPFrecord.Create(10, '65/70mm 7-perf', 1.2, 7, 65);
  FPF_TABLE[10] := FPFrecord.Create(8, '65/70mm 8-perf', 1.5, 8, 65);
  FPF_TABLE[11] := FPFrecord.Create(8, '65/70mm 9-perf', 1.5, 9, 65);
  FPF_TABLE[12] := FPFrecord.Create(7, '65/70mm 10-perf',
    1.714285714286, 10, 65);
  FPF_TABLE[13] := FPFrecord.Create(6, '65/70mm 11-perf', 2.0, 11, 65);
  FPF_TABLE[14] := FPFrecord.Create(6, '65/70mm 12-perf', 2.0, 12, 65);
  FPF_TABLE[15] := FPFrecord.Create(5, '65/70mm 13-perf', 2.4, 13, 65);
  FPF_TABLE[16] := FPFrecord.Create(5, '65/70mm 14-perf', 2.4, 14, 65);
  FPF_TABLE[17] := FPFrecord.Create(5, '65/70mm 15-perf', 2.4, 15, 65);
end;

procedure BuildTC_DISPLAY;
begin
  SetLength(TC_DISPLAY, 4);
  TC_DISPLAY[0] := TCDisplayStyle.Create(0, 'HH:MM:SS:FF', 'Timecode');
  TC_DISPLAY[1] := TCDisplayStyle.Create(1, 'Hr.Min.Sec', 'Time');
  TC_DISPLAY[2] := TCDisplayStyle.Create(2, 'Frames', 'Frames');
  TC_DISPLAY[3] := TCDisplayStyle.Create(3, 'Footage', 'Footage');
end;

procedure BuildMathsChar;
begin
  SetLength(MathsChar,5);
  MathsChar[0] := '*';
  MathsChar[1] := '+';
  MathsChar[2] := '-';
  MathsChar[3] := '/';
  MathsChar[4] := '=';
end;

constructor FPSrecord.Create(Afps: Double; ACaption, AABREV: string);
begin
  fps := Afps;
  Caption := ACaption;
  ABREV := AABREV;
end;

constructor TCDisplayStyle.Create(AID: Integer; ACaption, AABREV: string);
begin
  ID := AID;
  Caption := ACaption;
  ABREV := AABREV;

end;

constructor FPFrecord.Create(Afpf: Integer; ACaption: string;
  AGateWidth: Double; Aperf, Agate: Integer);
begin
  fpf := Afpf;
  Caption := ACaption;
  GateWidth := AGateWidth;
  perf := Aperf;
  gate := Agate;
end;

end.
