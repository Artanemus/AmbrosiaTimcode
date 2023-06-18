object Main: TMain
  Left = 0
  Top = 0
  Caption = 'Main'
  ClientHeight = 442
  ClientWidth = 628
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  OnCreate = FormCreate
  TextHeight = 15
  object Edit1: TEdit
    Left = 8
    Top = 8
    Width = 121
    Height = 23
    TabOrder = 0
    Text = 'Edit1'
  end
  object TCEdit1: TTCEdit
    Left = 48
    Top = 96
    Alignment = taCenter
    Text = '00:00:20:21'
    TC_Font.Charset = DEFAULT_CHARSET
    TC_Font.Color = clWindowText
    TC_Font.Height = -85
    TC_Font.Name = 'Courier New'
    TC_Font.Style = [fsBold]
    TC_Standard = tcFILM
    Perforation = mm35_4perf
    Frames = 500.000000000000000000
  end
end
