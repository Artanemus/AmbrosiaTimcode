object TCPreferences: TTCPreferences
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'Timecode Preferences.'
  ClientHeight = 155
  ClientWidth = 197
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -13
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poOwnerFormCenter
  OnClose = FormClose
  OnCreate = FormCreate
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 16
  object Label2: TLabel
    Left = 13
    Top = 77
    Width = 112
    Height = 16
    Margins.Left = 2
    Margins.Top = 2
    Margins.Right = 2
    Margins.Bottom = 2
    Alignment = taRightJustify
    Caption = 'Enter Custom FPS :'
  end
  object Label1: TLabel
    Left = 8
    Top = 8
    Width = 26
    Height = 16
    Margins.Left = 2
    Margins.Top = 2
    Margins.Right = 2
    Margins.Bottom = 2
    Alignment = taRightJustify
    Caption = 'FPF:'
  end
  object Label3: TLabel
    Left = 8
    Top = 36
    Width = 27
    Height = 16
    Margins.Left = 2
    Margins.Top = 2
    Margins.Right = 2
    Margins.Bottom = 2
    Alignment = taRightJustify
    Caption = 'FPS:'
  end
  object Panel2: TPanel
    Left = 0
    Top = 112
    Width = 197
    Height = 43
    Margins.Left = 2
    Margins.Top = 2
    Margins.Right = 2
    Margins.Bottom = 2
    Align = alBottom
    TabOrder = 0
    DesignSize = (
      197
      43)
    object BtnCancel: TButton
      Left = 21
      Top = 8
      Width = 75
      Height = 25
      Margins.Left = 2
      Margins.Top = 2
      Margins.Right = 2
      Margins.Bottom = 2
      Anchors = [akTop, akRight]
      Caption = 'Cancel'
      ModalResult = 2
      TabOrder = 0
    end
    object BtnOk: TButton
      Left = 101
      Top = 8
      Width = 75
      Height = 25
      Margins.Left = 2
      Margins.Top = 2
      Margins.Right = 2
      Margins.Bottom = 2
      Anchors = [akTop, akRight]
      Caption = 'Ok'
      Default = True
      ModalResult = 1
      TabOrder = 1
    end
  end
  object ComboBox1: TComboBox
    Left = 38
    Top = 7
    Width = 147
    Height = 24
    Margins.Left = 2
    Margins.Top = 2
    Margins.Right = 2
    Margins.Bottom = 2
    Style = csDropDownList
    TabOrder = 1
  end
  object Edit1: TEdit
    Left = 129
    Top = 74
    Width = 57
    Height = 24
    Margins.Left = 2
    Margins.Top = 2
    Margins.Right = 8
    Margins.Bottom = 2
    Alignment = taRightJustify
    AutoSize = False
    TabOrder = 2
    Text = '00.000'
    OnChange = Edit1Change
  end
  object ComboBox2: TComboBox
    Left = 39
    Top = 35
    Width = 147
    Height = 24
    Margins.Left = 2
    Margins.Top = 2
    Margins.Right = 2
    Margins.Bottom = 2
    Style = csDropDownList
    TabOrder = 3
    OnChange = ComboBox2Change
  end
end
