unit TimecodeTypes;

interface

type
  eStyle = (tcStyle, tcTimeStyle, tcFrameStyle, tcFootageStyle);

  eStandard = (tcPAL, tcFILM, tcNTSCDF, tcNTSC, tcCUSTOM);

  ePerforation = (mm16, mm16_35_sound, mm35_3perf, mm35_4perf, mm35_8perf,
    mm65_70_3perf, mm65_70_4perf, mm65_70_5perf, mm65_70_6perf, mm65_70_7perf,
    mm65_70_8perf, mm65_70_9perf, mm65_70_10perf, mm65_70_11perf,
    mm65_70_12perf, mm65_70_13perf, mm65_70_14perf, mm65_70_15perf);

  eOperation = (tcMultiply, tcAdd, tcSubtract, tcDivide, tcEquals, tcNone);

  type FPS_TABLE = record
    Caption: array [0 .. 24] of Char;
    fps: Double;
    FPSCaption: array [0 .. 24] of Char;
  end;

  type FPF_TABLE = record
    Caption: array [0 .. 24] of Char;
    fpf: Integer;
    GateWidth: Double;
    perf: Integer;
    gate: Integer;
  end;

  type TC_DISPLAYSTYLE = record
    Caption: array [0 .. 24] of Char;
    style: Integer;
    AltCaption: array [0 .. 24] of Char;
  end;

implementation

end.
