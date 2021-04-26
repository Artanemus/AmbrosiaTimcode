# EBUTimecode
VCL and FMX components that manage SMPTE EBU TIMECODE

Written in C++ for Embarcadero RAD Studio

VCL / FMX Components :
TCLabel: Displays EBU in TC, Frames, Time (PAL, NTSC, DROP FRAME, FILM, CUSTOM FPS)
TCEdit: Edit box with custom build-in timecode mask for easy data entry. (PAL, NTSC, DROP FAME, FILM, CUSTOM FPS)
TCCalculator: Add, subtract, mulitpy, divide and EBU or custom framerate. Double width precision.

Utilities and tools :
Conversion routines for System Time to EBU Timecode (PAL, NTSC, DROP FRAME, FILM, CUSTOM FPS)
.. and more

TTimecode::ConvertFramesDFtoND(double value)
TTimecode::ConvertFramesNDtoDF(double value)
TTimecode::SetText(UnicodeString value)
TTimecode::GetSimpleText()
TTimecode::GetText()
TTimecode::GetStatusFPF()
TTimecode::GetShortStatusFPS()
TTimecode::GetStatusFPS()
TTimecode::GetStatus()
TTimecode::GetStandard(void)
TTimecode::SetStandard(TTimecode::eStandard eFPSvalue)
TTimecode::GetFPF(void)
TTimecode::GetGateWidth(void)
TTimecode::GetPerf(void)
TTimecode::GetGate(void)
TTimecode::GetFPS(void)
TTimecode::GetCustomFPS(void)
TTimecode::FramesToTime()
TTimecode::TimeToFrames(TTime dt)

This project was started in RAD 2016 
Last compile was done in RAD 2019 ... 

A little work (but not much) will be needed for SYDNEY 10.4

FMX and VCL icons are included in the project.
There's a Photoshop PSD project included. (This was used to create the icons)



