object frmTest: TfrmTest
  Left = 0
  Top = 0
  Caption = 'frmTest'
  ClientHeight = 499
  ClientWidth = 1083
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object PageControl1: TPageControl
    Left = 0
    Top = 0
    Width = 1083
    Height = 499
    ActivePage = TabSheet1
    Align = alClient
    TabOrder = 0
    object TabSheet1: TTabSheet
      Caption = #20840#31243#35760#24405#26597#30475
      object Panel1: TPanel
        Left = 0
        Top = 0
        Width = 1075
        Height = 113
        Align = alTop
        BevelOuter = bvNone
        TabOrder = 0
        object Button1: TButton
          Left = 831
          Top = 82
          Width = 75
          Height = 25
          Caption = 'Button1'
          TabOrder = 0
          OnClick = Button1Click
        end
        object Memo1: TMemo
          Left = 0
          Top = 7
          Width = 825
          Height = 100
          Lines.Strings = (
            'C:\runRecords\0423\33049-53-4017140-4017434H0.0423'
            'C:\runRecords\0423\51082-246-4010313-4017476H0.0423')
          TabOrder = 1
        end
        object RadioGroup1: TRadioGroup
          Left = 831
          Top = 7
          Width = 242
          Height = 69
          Caption = #21152#36733#26041#24335
          TabOrder = 2
        end
        object rbtOrigin: TRadioButton
          Left = 848
          Top = 24
          Width = 73
          Height = 17
          Caption = #21407#22987#25991#20214
          Checked = True
          TabOrder = 3
          TabStop = True
        end
        object rbtADO: TRadioButton
          Left = 848
          Top = 47
          Width = 113
          Height = 17
          Caption = 'ADO'#25991#20214
          TabOrder = 4
        end
        object rbtfmt: TRadioButton
          Left = 927
          Top = 24
          Width = 82
          Height = 17
          Caption = #26684#24335#21270#25991#20214
          TabOrder = 5
        end
      end
      object AdvStringGrid1: TAdvStringGrid
        Left = 0
        Top = 113
        Width = 1075
        Height = 358
        Cursor = crDefault
        Align = alClient
        Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRangeSelect, goColSizing]
        ScrollBars = ssBoth
        TabOrder = 1
        ActiveCellFont.Charset = DEFAULT_CHARSET
        ActiveCellFont.Color = clWindowText
        ActiveCellFont.Height = -11
        ActiveCellFont.Name = 'Tahoma'
        ActiveCellFont.Style = [fsBold]
        ControlLook.FixedGradientHoverFrom = clGray
        ControlLook.FixedGradientHoverTo = clWhite
        ControlLook.FixedGradientDownFrom = clGray
        ControlLook.FixedGradientDownTo = clSilver
        ControlLook.DropDownHeader.Font.Charset = DEFAULT_CHARSET
        ControlLook.DropDownHeader.Font.Color = clWindowText
        ControlLook.DropDownHeader.Font.Height = -11
        ControlLook.DropDownHeader.Font.Name = 'Tahoma'
        ControlLook.DropDownHeader.Font.Style = []
        ControlLook.DropDownHeader.Visible = True
        ControlLook.DropDownHeader.Buttons = <>
        ControlLook.DropDownFooter.Font.Charset = DEFAULT_CHARSET
        ControlLook.DropDownFooter.Font.Color = clWindowText
        ControlLook.DropDownFooter.Font.Height = -11
        ControlLook.DropDownFooter.Font.Name = 'Tahoma'
        ControlLook.DropDownFooter.Font.Style = []
        ControlLook.DropDownFooter.Visible = True
        ControlLook.DropDownFooter.Buttons = <>
        Filter = <>
        FilterDropDown.Font.Charset = DEFAULT_CHARSET
        FilterDropDown.Font.Color = clWindowText
        FilterDropDown.Font.Height = -11
        FilterDropDown.Font.Name = 'Tahoma'
        FilterDropDown.Font.Style = []
        FilterDropDownClear = '(All)'
        FixedRowHeight = 22
        FixedFont.Charset = DEFAULT_CHARSET
        FixedFont.Color = clWindowText
        FixedFont.Height = -11
        FixedFont.Name = 'Tahoma'
        FixedFont.Style = [fsBold]
        FloatFormat = '%.2f'
        PrintSettings.DateFormat = 'dd/mm/yyyy'
        PrintSettings.Font.Charset = DEFAULT_CHARSET
        PrintSettings.Font.Color = clWindowText
        PrintSettings.Font.Height = -11
        PrintSettings.Font.Name = 'Tahoma'
        PrintSettings.Font.Style = []
        PrintSettings.FixedFont.Charset = DEFAULT_CHARSET
        PrintSettings.FixedFont.Color = clWindowText
        PrintSettings.FixedFont.Height = -11
        PrintSettings.FixedFont.Name = 'Tahoma'
        PrintSettings.FixedFont.Style = []
        PrintSettings.HeaderFont.Charset = DEFAULT_CHARSET
        PrintSettings.HeaderFont.Color = clWindowText
        PrintSettings.HeaderFont.Height = -11
        PrintSettings.HeaderFont.Name = 'Tahoma'
        PrintSettings.HeaderFont.Style = []
        PrintSettings.FooterFont.Charset = DEFAULT_CHARSET
        PrintSettings.FooterFont.Color = clWindowText
        PrintSettings.FooterFont.Height = -11
        PrintSettings.FooterFont.Name = 'Tahoma'
        PrintSettings.FooterFont.Style = []
        PrintSettings.PageNumSep = '/'
        ScrollWidth = 16
        SearchFooter.FindNextCaption = 'Find &next'
        SearchFooter.FindPrevCaption = 'Find &previous'
        SearchFooter.Font.Charset = DEFAULT_CHARSET
        SearchFooter.Font.Color = clWindowText
        SearchFooter.Font.Height = -11
        SearchFooter.Font.Name = 'Tahoma'
        SearchFooter.Font.Style = []
        SearchFooter.HighLightCaption = 'Highlight'
        SearchFooter.HintClose = 'Close'
        SearchFooter.HintFindNext = 'Find next occurence'
        SearchFooter.HintFindPrev = 'Find previous occurence'
        SearchFooter.HintHighlight = 'Highlight occurences'
        SearchFooter.MatchCaseCaption = 'Match case'
        ShowDesignHelper = False
        Version = '5.6.0.0'
      end
    end
    object TabSheet2: TTabSheet
      Caption = #39033#28857#20998#26512
      ImageIndex = 1
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitWidth = 0
      ExplicitHeight = 417
      object Panel2: TPanel
        Left = 0
        Top = 0
        Width = 1075
        Height = 73
        Align = alTop
        BevelOuter = bvNone
        TabOrder = 0
        object btnAnalysis: TButton
          Left = 992
          Top = 7
          Width = 75
          Height = 25
          Caption = #20998#26512
          TabOrder = 0
          OnClick = btnAnalysisClick
        end
        object Edit1: TEdit
          Left = 8
          Top = 9
          Width = 969
          Height = 21
          TabOrder = 1
          Text = 'C:\runRecords\0423\33049-53-4017140-4017434H0.0423'
        end
        object edtRuleXML: TEdit
          Left = 8
          Top = 36
          Width = 969
          Height = 21
          TabOrder = 2
          Text = 'E:\'#23002#26032'\'#30021#24819#33258#21160#21270'\Share\'#20844#21496#32452#20214'\'#36890#29992#36816#35760#20998#26512'\02_'#24320#21457'\Execute\Rules.xml'
        end
      end
      object Memo3: TMemo
        Left = 0
        Top = 73
        Width = 1075
        Height = 398
        Align = alClient
        Lines.Strings = (
          'Memo3')
        TabOrder = 1
      end
    end
    object TabSheet3: TTabSheet
      Caption = 'XML'#21152#36733#39033#28857#27979#35797
      ImageIndex = 2
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitWidth = 0
      ExplicitHeight = 417
      object Panel3: TPanel
        Left = 0
        Top = 0
        Width = 1075
        Height = 46
        Align = alTop
        BevelOuter = bvNone
        TabOrder = 0
        object btnTest: TButton
          Left = 992
          Top = 7
          Width = 75
          Height = 25
          Caption = #20998#26512
          TabOrder = 0
          OnClick = btnTestClick
        end
        object edtXMLFile: TEdit
          Left = 8
          Top = 9
          Width = 969
          Height = 21
          TabOrder = 1
          Text = 'E:\'#23002#26032'\'#30021#24819#33258#21160#21270'\Share\'#20844#21496#32452#20214'\'#36890#29992#36816#35760#20998#26512'\02_'#24320#21457'\Execute\Rules.xml'
        end
      end
    end
    object TabSheet4: TTabSheet
      Caption = #25805#20316#26102#38388#20998#26512
      ImageIndex = 3
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitWidth = 0
      ExplicitHeight = 417
      object Panel4: TPanel
        Left = 0
        Top = 0
        Width = 1075
        Height = 73
        Align = alTop
        BevelOuter = bvNone
        TabOrder = 0
        object btnReadTimes: TButton
          Left = 992
          Top = 7
          Width = 75
          Height = 25
          Caption = #20998#26512
          TabOrder = 0
          OnClick = btnReadTimesClick
        end
        object edtFiles: TEdit
          Left = 8
          Top = 9
          Width = 969
          Height = 21
          TabOrder = 1
          Text = 'c:\78662-2681447.0713'
        end
        object edtRule: TEdit
          Left = 8
          Top = 36
          Width = 969
          Height = 21
          TabOrder = 2
          Text = 'D:\share\'#20844#21496#32452#20214'\'#36890#29992#36816#35760#20998#26512'\02_'#24320#21457'\OperationRules.xml'
        end
      end
      object Memo2: TMemo
        Left = 0
        Top = 73
        Width = 1075
        Height = 398
        Align = alClient
        Lines.Strings = (
          'Memo3')
        ScrollBars = ssVertical
        TabOrder = 1
      end
    end
  end
  object OpenDialog1: TOpenDialog
    Options = [ofHideReadOnly, ofAllowMultiSelect, ofEnableSizing]
    Left = 96
    Top = 120
  end
  object XPManifest1: TXPManifest
    Left = 128
    Top = 120
  end
end
