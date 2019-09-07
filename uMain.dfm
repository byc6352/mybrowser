object fMain: TfMain
  Left = 0
  Top = 0
  Caption = #25105#30340#27983#35272#22120
  ClientHeight = 835
  ClientWidth = 1080
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnClose = FormClose
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Splitter1: TSplitter
    Left = 788
    Top = 33
    Height = 783
    Align = alRight
    ExplicitLeft = 544
    ExplicitTop = 384
    ExplicitHeight = 100
  end
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 1080
    Height = 33
    Align = alTop
    TabOrder = 0
    object edturl: TEdit
      Left = 75
      Top = 6
      Width = 644
      Height = 21
      TabOrder = 0
      Text = 'http://localhost:8080/index.htm'
      OnEnter = edturlEnter
    end
    object btnClear: TButton
      Left = 728
      Top = 5
      Width = 75
      Height = 25
      Caption = #28165#31354
      TabOrder = 1
      OnClick = btnClearClick
    end
    object chkDownAll: TCheckBox
      Left = 811
      Top = 8
      Width = 121
      Height = 17
      Caption = #19979#36733#25152#26377#32593#39029#36164#28304
      Checked = True
      State = cbChecked
      TabOrder = 2
    end
    object btnBack: TBitBtn
      Left = 2
      Top = 5
      Width = 24
      Height = 25
      Caption = #22238
      Enabled = False
      TabOrder = 3
      OnClick = btnBackClick
    end
    object btnForward: TBitBtn
      Left = 25
      Top = 5
      Width = 24
      Height = 25
      Caption = #21069
      Enabled = False
      TabOrder = 4
      OnClick = btnForwardClick
    end
    object btnBrush: TBitBtn
      Left = 49
      Top = 5
      Width = 24
      Height = 25
      Caption = #21047
      TabOrder = 5
      OnClick = btnBrushClick
    end
  end
  object Bar1: TStatusBar
    Left = 0
    Top = 816
    Width = 1080
    Height = 19
    Panels = <
      item
        Width = 300
      end
      item
        Width = 50
      end>
    ExplicitLeft = 552
    ExplicitTop = 424
    ExplicitWidth = 0
  end
  object Page1: TPageControl
    Left = 791
    Top = 33
    Width = 289
    Height = 783
    ActivePage = tsInfo
    Align = alRight
    TabOrder = 2
    ExplicitLeft = 408
    ExplicitTop = 344
    ExplicitHeight = 193
    object tsData: TTabSheet
      Caption = #25968#25454
      ExplicitHeight = 165
      object memData: TMemo
        Left = 0
        Top = 0
        Width = 281
        Height = 755
        Align = alClient
        ScrollBars = ssBoth
        TabOrder = 0
        ExplicitHeight = 752
      end
    end
    object tsInfo: TTabSheet
      Caption = #20449#24687
      ImageIndex = 1
      ExplicitHeight = 165
      object MemoInfo: TMemo
        Left = 0
        Top = 0
        Width = 281
        Height = 755
        Align = alClient
        ScrollBars = ssBoth
        TabOrder = 0
        ExplicitHeight = 752
      end
    end
  end
  object Panel2: TPanel
    Left = 0
    Top = 33
    Width = 788
    Height = 783
    Align = alClient
    TabOrder = 3
    ExplicitLeft = 456
    ExplicitTop = 416
    ExplicitWidth = 185
    ExplicitHeight = 41
    object Splitter2: TSplitter
      Left = 1
      Top = 629
      Width = 786
      Height = 3
      Cursor = crVSplit
      Align = alBottom
      ExplicitTop = 151
      ExplicitWidth = 478
    end
    object listData: TListView
      Left = 1
      Top = 632
      Width = 786
      Height = 150
      Align = alBottom
      Columns = <
        item
          Caption = 'time'
          Width = 120
        end
        item
          Caption = 'Verb'
          Width = 36
        end
        item
          Caption = 'Request'
          Width = 360
        end
        item
          Caption = 'length'
        end
        item
          Caption = 'RequestHeader'
        end
        item
          Caption = 'ResponseHeader'
        end
        item
          Caption = 'RequestData'
        end
        item
          Caption = 'ResponseData'
        end>
      GridLines = True
      RowSelect = True
      PopupMenu = PopSelData
      SortType = stBoth
      TabOrder = 0
      ViewStyle = vsReport
      OnSelectItem = listDataSelectItem
      ExplicitLeft = 272
      ExplicitTop = 312
      ExplicitWidth = 250
    end
    object Page2: TPageControl
      Left = 1
      Top = 1
      Width = 786
      Height = 628
      ActivePage = tsRecord
      Align = alClient
      TabOrder = 1
      object tsweb: TTabSheet
        Caption = #27983#35272#22120
        ExplicitWidth = 281
        ExplicitHeight = 165
        object Web1: TWebBrowser
          Left = 0
          Top = 0
          Width = 778
          Height = 600
          Align = alClient
          TabOrder = 0
          OnBeforeNavigate2 = Web1BeforeNavigate2
          OnNewWindow2 = Web1NewWindow2
          OnNavigateComplete2 = Web1NavigateComplete2
          OnDocumentComplete = Web1DocumentComplete
          ExplicitLeft = 368
          ExplicitTop = 384
          ExplicitWidth = 300
          ExplicitHeight = 150
          ControlData = {
            4C0000003C510000984000000000000000000000000000000000000000000000
            000000004C000000000000000000000001000000E0D057007335CF11AE690800
            2B2E126208000000000000004C0000000114020000000000C000000000000046
            8000000000000000000000000000000000000000000000000000000000000000
            00000000000000000100000000000000000000000000000000000000}
        end
        object Web2: TWebBrowser
          Left = 368
          Top = 288
          Width = 10
          Height = 10
          TabOrder = 1
          OnBeforeNavigate2 = Web2BeforeNavigate2
          ControlData = {
            4C00000009010000090100000000000000000000000000000000000000000000
            000000004C000000000000000000000001000000E0D057007335CF11AE690800
            2B2E126208000000000000004C0000000114020000000000C000000000000046
            8000000000000000000000000000000000000000000000000000000000000000
            00000000000000000100000000000000000000000000000000000000}
        end
      end
      object tscode: TTabSheet
        Caption = #20195#30721
        ImageIndex = 1
        ExplicitWidth = 281
        ExplicitHeight = 165
        object memCode: TMemo
          Left = 0
          Top = 0
          Width = 778
          Height = 600
          Align = alClient
          ScrollBars = ssBoth
          TabOrder = 0
          ExplicitWidth = 281
          ExplicitHeight = 752
        end
      end
      object tsRecord: TTabSheet
        Caption = #21382#21490#35760#24405
        ImageIndex = 2
        ExplicitLeft = 3
        ExplicitTop = 22
        object Splitter3: TSplitter
          Left = 0
          Top = 120
          Width = 778
          Height = 3
          Cursor = crVSplit
          Align = alTop
          ExplicitWidth = 480
        end
        object DBGrid1: TDBGrid
          Left = 0
          Top = 0
          Width = 778
          Height = 120
          Align = alTop
          DataSource = dm.dsPage
          TabOrder = 0
          TitleFont.Charset = DEFAULT_CHARSET
          TitleFont.Color = clWindowText
          TitleFont.Height = -11
          TitleFont.Name = 'Tahoma'
          TitleFont.Style = []
        end
        object DBGrid2: TDBGrid
          Left = 0
          Top = 123
          Width = 778
          Height = 477
          Align = alClient
          DataSource = dm.dsDetail
          TabOrder = 1
          TitleFont.Charset = DEFAULT_CHARSET
          TitleFont.Color = clWindowText
          TitleFont.Height = -11
          TitleFont.Name = 'Tahoma'
          TitleFont.Style = []
          OnCellClick = DBGrid2CellClick
        end
      end
    end
  end
  object PopSelData: TPopupMenu
    Left = 536
    Top = 424
    object nOpenDir: TMenuItem
      Caption = #25171#24320#26412#22320#25991#20214#22841
      OnClick = nOpenDirClick
    end
    object n1: TMenuItem
      Caption = '-'
    end
    object nOpenRequestData: TMenuItem
      Caption = #25171#24320#35831#27714#30340#25968#25454
      OnClick = nOpenRequestDataClick
    end
    object nOpenResponseData: TMenuItem
      Caption = #25171#24320#36820#22238#30340#25968#25454
      OnClick = nOpenResponseDataClick
    end
  end
  object Timer1: TTimer
    OnTimer = Timer1Timer
    Left = 544
    Top = 432
  end
end
