object dm: Tdm
  OldCreateOrder = False
  OnCreate = DataModuleCreate
  Height = 239
  Width = 463
  object dsPage: TDataSource
    DataSet = tPage
    Left = 24
    Top = 16
  end
  object conn: TADOConnection
    Connected = True
    ConnectionString = 
      'Provider=Microsoft.Jet.OLEDB.4.0;Password="";Data Source=D:\work' +
      's\delphi\mybrowser\Win32\Debug\web\web.mdb;Persist Security Info' +
      '=True'
    LoginPrompt = False
    Mode = cmShareDenyNone
    Provider = 'Microsoft.Jet.OLEDB.4.0'
    Left = 80
    Top = 16
  end
  object Q1: TADOQuery
    Connection = conn
    Parameters = <>
    Left = 152
    Top = 16
  end
  object tPage: TADOTable
    Active = True
    Connection = conn
    CursorType = ctStatic
    TableName = 'web_page'
    Left = 16
    Top = 72
  end
  object tPageDetail: TADOTable
    Active = True
    Connection = conn
    CursorType = ctStatic
    IndexFieldNames = 'page_ID'
    MasterFields = 'ID'
    MasterSource = dsPage
    TableName = 'page_detail'
    Left = 96
    Top = 72
  end
  object dsDetail: TDataSource
    DataSet = tPageDetail
    Left = 168
    Top = 80
  end
end
