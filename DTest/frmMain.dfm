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
  TextHeight = 15
  object Label1: TLabel
    Left = 32
    Top = 47
    Width = 118
    Height = 15
    Caption = 'tc1 = 24fps 100 frames'
  end
  object Label2: TLabel
    Left = 32
    Top = 68
    Width = 118
    Height = 15
    Caption = 'tc2 = 24fps 100 frames'
  end
  object Label3: TLabel
    Left = 72
    Top = 200
    Width = 169
    Height = 15
    AutoSize = False
    Caption = 'tc1 '
  end
  object Button1: TButton
    Left = 16
    Top = 16
    Width = 249
    Height = 25
    Caption = 'create x 2 TTimecode, then sum.'
    TabOrder = 0
    OnClick = Button1Click
  end
end
