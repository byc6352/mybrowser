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
    Connection = conn
    CursorType = ctStatic
    TableName = 'web_page'
    Left = 16
    Top = 72
  end
  object tPageDetail: TADOTable
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
    Left = 160
    Top = 72
  end
  object IdSSLIOHandlerSocketOpenSSL1: TIdSSLIOHandlerSocketOpenSSL
    MaxLineAction = maException
    Port = 0
    DefaultPort = 0
    SSLOptions.Method = sslvSSLv23
    SSLOptions.SSLVersions = [sslvSSLv2, sslvSSLv3, sslvTLSv1, sslvTLSv1_1, sslvTLSv1_2]
    SSLOptions.Mode = sslmUnassigned
    SSLOptions.VerifyMode = []
    SSLOptions.VerifyDepth = 0
    Left = 247
    Top = 79
  end
  object IdHTTP1: TIdHTTP
    IOHandler = IdSSLIOHandlerSocketOpenSSL1
    AllowCookies = True
    HandleRedirects = True
    ProxyParams.BasicAuthentication = False
    ProxyParams.ProxyPort = 0
    Request.ContentLength = -1
    Request.ContentRangeEnd = -1
    Request.ContentRangeStart = -1
    Request.ContentRangeInstanceLength = -1
    Request.Accept = 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8'
    Request.BasicAuthentication = False
    Request.UserAgent = 'Mozilla/3.0 (compatible; Indy Library)'
    Request.Ranges.Units = 'bytes'
    Request.Ranges = <>
    HTTPOptions = []
    Left = 239
    Top = 15
  end
end
