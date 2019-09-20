unit uDM;

interface

uses
  windows,System.SysUtils, System.Classes, Data.DB, Data.Win.ADODB,uConfig,uLog,uFuncs,
  IdTCPConnection, IdTCPClient, IdHTTP, IdBaseComponent, IdComponent,
  IdIOHandler, IdIOHandlerSocket, IdIOHandlerStack, IdSSL, IdSSLOpenSSL,strutils,messages;
Const
  WM_DOWN_FILE = WM_USER+1002;
type
  Tdm = class(TDataModule)
    dsPage: TDataSource;
    conn: TADOConnection;
    Q1: TADOQuery;
    tPage: TADOTable;
    tPageDetail: TADOTable;
    dsDetail: TDataSource;
    IdSSLIOHandlerSocketOpenSSL1: TIdSSLIOHandlerSocketOpenSSL;
    IdHTTP1: TIdHTTP;
    procedure DataModuleCreate(Sender: TObject);
  private
    { Private declarations }

  public
    { Public declarations }
    mPage,mDomain,mProtocol,mPort,mTitle,mCharSet,mCookie:string;//主页URL ，站点URL, 协议(http://,https://),工作目录
    mPageIdx:integer;
    function DownFileFromServer(const url,localFileName:string):boolean;
    function getLastPageID():string;
    //function InsertPageInfo(protocol,domain,port,url:string):string;
    //function InsertPageDetail(pageID,dt,url,verb,len,qHeader,rHeader,qData,rData:string):string;
    //插入主页信息详细信息：
    //function addPageDetail(pageID,ServerName,ServerPort,ObjectName,verb,len,qHeader,rHeader,qData,rData:string;dtGet:tdatetime):boolean;
    function addPageDetail(pageID,idx:integer):boolean;
     //添加主页信息,,返回主页信息ID：
    function addPageInfo():integer;
    function UpdatePageInfo():integer;
  end;

var
  dm: Tdm;
  iDown:integer;//下载序号
  bDownFiles,bPause:boolean;//下载工作线程变量；

  mForm:HWND;


function GetLocalFileNameFromIECache(url:string;var CacheFileName:string):DWORD;
function ThreadProc(param: LPVOID): DWORD; stdcall;
function downloadfile(idx:integer):string;
procedure downloadFilesThread();
//--------------------------------------------------------------------------------------------
procedure stop();
procedure pause();
procedure start();overload;
procedure start(workdir:string;hForm:HWND);overload;
procedure clear;
implementation

{%CLASSGROUP 'Vcl.Controls.TControl'}

{$R *.dfm}
uses
  uData,winInet;
var
  mWorkDir:string;
  //添加主页信息,,返回主页信息ID：
function TDM.addPageInfo():integer;
begin
  dm.tPage.Append;
  tPage.fieldbyname('page_protocol').AsString:=mprotocol;
  tPage.fieldbyname('page_domain').AsString:=mDomain;      //strtodatetime(dt)
  tPage.fieldbyname('page_port').AsString:=mport;
  tPage.fieldbyname('page_url').AsString:=mPage;
  tPage.fieldbyname('page_title').AsString:=mTitle;
  tPage.fieldbyname('page_charset').AsString:=mCharSet;
  tPage.fieldbyname('page_cookie').AsString:=mCookie;
  tPage.Post;
  result:=tPage.fieldbyname('ID').AsInteger;
end;
//添加主页信息,,返回主页信息ID：
function TDM.UpdatePageInfo():integer;
begin
  if(dm.tPage.Active=false)then begin
    dm.tPage.Open;
    tPageDetail.Open;
  end;
  //dm.tPage.Last;
  dm.tPage.Edit;
  tPage.fieldbyname('page_protocol').AsString:=mprotocol;
  tPage.fieldbyname('page_domain').AsString:=mDomain;      //strtodatetime(dt)
  tPage.fieldbyname('page_port').AsString:=mport;
  tPage.fieldbyname('page_url').AsString:=mPage;
  tPage.fieldbyname('page_title').AsString:=mTitle;
  tPage.fieldbyname('page_charset').AsString:=mCharSet;
  tPage.fieldbyname('page_cookie').AsString:=mCookie;
  tPage.Post;
  result:=tPage.fieldbyname('ID').AsInteger;
end;

//插入主页信息详细信息：
function TDM.addPageDetail(pageID,idx:integer):boolean;
begin
  result:=false;
try
  dm.tPageDetail.Append;
  tPageDetail.fieldbyname('page_ID').AsInteger:=pageID;
  tPageDetail.fieldbyname('get_time').AsDateTime:=uData.datas[idx].dt;      //
  tPageDetail.fieldbyname('server_name').AsString:=uData.datas[idx].ServerName;
  tPageDetail.fieldbyname('server_port').AsString:=inttostr(uData.datas[idx].ServerPort);
  tPageDetail.fieldbyname('object_name').AsString:=uData.datas[idx].ObjectName;
  tPageDetail.fieldbyname('op_verb').AsString:=uData.datas[idx].verb;
  tPageDetail.fieldbyname('data_len').AsString:=uData.datas[idx].len;
  tPageDetail.fieldbyname('request_header').AsString:=uData.datas[idx].qHeader;
  tPageDetail.fieldbyname('response_header').AsString:=uData.datas[idx].rHeader;
  tPageDetail.fieldbyname('request_data').AsString:=uData.datas[idx].qData;
  tPageDetail.fieldbyname('response_data').AsString:=uData.datas[idx].rData;
  tPageDetail.fieldbyname('down_len').AsString:=inttostr(uData.datas[idx].dataLen);
  //Tblobfield(tPageDetail.fieldByName('ExexSql')).as
  tPageDetail.Post;
  result:=true;
  //application.
except
    on E: Exception do
    begin
      Log(format('addPageDetail fail: %s.  raise by:%s.',[uData.datas[idx].ObjectName,e.Message]));
      //raise Exception.CreateFmt('IdHTTP1 down file fail: %s.raise by:%s.',[url,e.Message]);
    end;
end;
end;

//查询pageID：
function TDM.getLastPageID():string;
var
  sql:string;
begin
  result:='';
  Q1.Close;
  sql:='select max(ID) from web_page';
  Q1.SQL.Text:=sql;
  Q1.Open;
  if(Q1.RecordCount>0)then begin
    result:=Q1.Fields[0].asString;
  end else begin
    result:='0';
  end;
  Q1.Close;
end;

procedure Tdm.DataModuleCreate(Sender: TObject);
begin
  conn.Connected:=false;
  conn.ConnectionString:=uConfig.dbconn;
  conn.Connected:=true;
  tpage.Active:=true;
  tpagedetail.Active:=true;
  mWorkDir:=uConfig.webCache;
end;













//-------------------------------------------------------------------------------------------------


//------------------------------------------启动，暂停，停止区---------------------------------
procedure stop();
begin
  bDownFiles:=false;
end;
procedure pause();
begin
  bPause:=true;
end;
procedure start(workdir:string;hForm:HWND);
begin
  mworkdir:=workdir;
  mForm:=hForm;
  start();
end;
procedure start();
begin
  bPause:=false;
  downloadFilesThread();
end;
procedure clear();
begin
  iDown:=0;
end;
//------------------------------------------下载线程区------------------------------------------
procedure downloadFilesThread();
var
  threadId: TThreadID;
begin
  if(bDownFiles)then exit;
  bDownFiles:=true;
  CreateThread(nil, 0, @ThreadProc, nil, 0, threadId);
end;
function ThreadProc(param: LPVOID): DWORD; stdcall;
begin
  iDown:=0;
  while bDownFiles do begin
    if(iDown>uData.iData-1)then begin sleep(1000);continue;end;
    if(bPause)then begin sleep(1000);continue;end;
    if(iDown=uData.iData-1)then begin sleep(1000);end;

    downloadfile(iDown);
    dm.addPageDetail(dm.mPageIdx,iDown);
    PostMessage(mForm, WM_DOWN_FILE,0,iDown);
    //sleep(1000);
    iDown:=iDown+1;
  end;
  PostMessage(mForm, WM_DOWN_FILE,1,iDown);
  Result := 0;
end;

//下载指定链接的文件 dm.addPageDetail(pageID,servername,inttostr(ServerPort),ObjectName,verb,len,qHeader,rHeader,qData,rData,dtGet);
function downloadfile(idx:integer):string;
var
  CacheFileName,localFileName:string;
  url,ServerName,ObjectName:string;
  ServerPort,ret:DWORD;
begin
  result:='';
  ServerName:=uData.datas[idx].ServerName;
  ObjectName:=uData.datas[idx].ObjectName;
  ServerPort:=uData.datas[idx].ServerPort;
  localFileName:=url2file(ServerName,ObjectName,ServerPort,url);
  if(localFileName='')then exit;

  if(fileExists(localFileName))then begin
    result:=localFileName;
    uData.datas[idx].rData:=localFileName;
    exit;
  end;

  ret:=GetLocalFileNameFromIECache(url,CacheFileName);
  if(ret=S_OK)then begin
    if(CopyFile(pchar(CacheFileName),pchar(localFileName),false))then begin
      result:=localFileName;
      uData.datas[idx].rData:=localFileName;
    end else begin
      //result:='';
    end;
  end else begin //remote file
    //if(dm.DownFileFromServer(url,localFileName))then begin
    //  result:=localFileName;
   //   uData.datas[idx].rData:=localFileName;
   // end;
  end;
end;

function GetLocalFileNameFromIECache(url:string;var CacheFileName:string):DWORD;
var
D: Cardinal;
T: PInternetCacheEntryInfo;
begin
  result := S_OK;
  D := 0;
  T:=nil;
  GetUrlCacheEntryInfo(PChar(Url), T^, D);
  Getmem(T, D);
  try
    if (GetUrlCacheEntryInfo(PChar(Url), T^, D)) then
    begin
      CacheFileName:=T^.lpszLocalFileName;
    end else
      Result := GetLastError;
  finally
    Freemem(T, D);
  end;
end;

function tdm.DownFileFromServer(const url,localFileName:string):boolean;
var
  ss: tstrings;
  mm: TMemoryStream;
  IdHTTP2:TIdHTTP;
  IdSSLIOHandlerSocketOpenSSL2:TIdSSLIOHandlerSocketOpenSSL;
function isUtf8():boolean;
var
  responseInfo,responseData:string;
  //bUtf8,bText:boolean; //Content-Type: text
begin
  result:=false;
  responseInfo:=idhttp1.Response.CharSet;
  if(responseInfo<>'')then begin
    responseInfo:=lowercase(responseInfo);
    if(pos(lowercase('UTF-8'),responseInfo)>0)then begin result:=true;exit;end;
  end;
end;
begin
  result:=false;
  ss:=nil;
  IdSSLIOHandlerSocketOpenSSL2:=nil;
  try
    IdHTTP2 := TIdHTTP.create(nil);
    mm:=TMemoryStream.Create;
    if(pos(lowercase('https://'),lowercase(url))>0)then begin
      IdSSLIOHandlerSocketOpenSSL2 := TIdSSLIOHandlerSocketOpenSSL.Create(nil);
      IdHTTP2.IOHandler := IdSSLIOHandlerSocketOpenSSL2;
    end;
    //IdHTTP2.IOHandler:=nil else IdHTTP2.IOHandler:=dm.IdSSLIOHandlerSocketOpenSSL1;
    IdHTTP2.HandleRedirects := True; //[hoInProcessAuth,hoKeepOrigProtocol,hoForceEncodeParams]
  try
    //if(pos('http://',url)>0)then idhttp1.IOHandler:=nil else idhttp1.IOHandler:=dm.IdSSLIOHandlerSocketOpenSSL1;
    //IdHTTP1.HandleRedirects := True; //[hoInProcessAuth,hoKeepOrigProtocol,hoForceEncodeParams]
    IdHTTP2.ReadTimeout:= 10*60*1000;
    IdHTTP2.ConnectTimeout := 10*60*1000;
    IdHTTP2.get(url,mm);
    mm.Position:=0;
    //IdHTTP1
    if(isUtf8())then begin
      ss:=tstringlist.Create;
      ss.LoadFromStream(mm,TEncoding.UTF8);
      ss.SaveToFile(localFileName,Tencoding.UTF8);
    end else begin
      mm.SaveToFile(localFileName);
    end;
    result:=true;
    Log(format('IdHTTP2 down file suc:url: %s.   localFileName:%s.',[url,localFileName]));
  except
    on E: Exception do
    begin
      Log(format('IdHTTP2 down file fail: %s.raise by:%s.',[url,e.Message]));
      //raise Exception.CreateFmt('IdHTTP1 down file fail: %s.raise by:%s.',[url,e.Message]);
    end;
  end;
  finally
    if(assigned(IdHTTP2))then IdHTTP2.Free;
    if(assigned(ss))then ss.Free;
    if(assigned(mm))then mm.Free;
    if(assigned(IdSSLIOHandlerSocketOpenSSL2))then IdSSLIOHandlerSocketOpenSSL2.Free;
  end;
end;


{
//添加主页信息,,返回主页信息ID：
function TDM.addPageInfo(url:string):integer;
begin
  if(dm.tPage.Active=false)then begin
    dm.tPage.Open;
    tPageDetail.Open;
  end;
  dm.tPage.Append;
  tPage.fieldbyname('page_protocol').AsString:='';
  tPage.fieldbyname('page_domain').AsString:='';      //strtodatetime(dt)
  tPage.fieldbyname('page_port').AsString:='';
  tPage.fieldbyname('page_url').AsString:=url;
  tPage.Post;
  result:=tPage.fieldbyname('ID').AsInteger;
end;




function tdm.DownFileFromServer(const url,localFileName:string):boolean;
var
  ss: tstrings;
  mm: TMemoryStream;
function isUtf8():boolean;
var
  responseInfo,responseData:string;
  //bUtf8,bText:boolean; //Content-Type: text
begin
  result:=false;
  responseInfo:=idhttp1.Response.CharSet;
  if(responseInfo<>'')then begin
    responseInfo:=lowercase(responseInfo);
    if(pos(lowercase('UTF-8'),responseInfo)>0)then begin result:=true;exit;end;
  end;
end;
begin
  result:=false;
  mm:=TMemoryStream.Create;

  try
    if(pos('http://',url)>0)then idhttp1.IOHandler:=nil else idhttp1.IOHandler:=dm.IdSSLIOHandlerSocketOpenSSL1;
    IdHTTP1.HandleRedirects := True; //[hoInProcessAuth,hoKeepOrigProtocol,hoForceEncodeParams]
    idhttp1.ReadTimeout:= 15000;
    idhttp1.ConnectTimeout := 15000;
    IdHTTP1.get(url,mm);
    mm.Position:=0;
    //IdHTTP1
    if(isUtf8())then begin
      ss:=tstringlist.Create;
      ss.LoadFromStream(mm,TEncoding.UTF8);
      ss.SaveToFile(localFileName,Tencoding.UTF8);
    end else begin
      mm.SaveToFile(localFileName);
    end;
    result:=true;
  except
    on E: Exception do
    Log(format('IdHTTP1 down file fail: %s.raise by:%s.',[url,e.Message]));
    //raise Exception.CreateFmt('IdHTTP1 down file fail: %s', [url]);
  end;
  if(assigned(ss))then ss.Free;
  mm.Free;
end;


   on E: Exception do
    begin
      raise Exception.Create('下载文件'+aURL+'失败：'+e.Message);
    end;

  responseInfo:=idhttp1.Response.ContentType;
  if(pos(lowercase('text'),responseInfo)>0)then begin
    mm.Position:=0;
    setLength(responseData,mm.Size);
    move(mm.Memory^,responseData[1],mm.Size);
    if(pos(lowercase('UTF-8'),responseData)>0)then begin result:=true;exit;end;
  end;


procedure myCloseFileHandle(var hFile:HWND);
begin
  if(hFile=0)then exit;
  try
    closeHandle(hFile);
  finally
    hFile:=0;
  end;

end;
procedure myCloseHandle(wInet:DWORD);
begin
  if(wInet<>uData.datas[idata-1].wRequest)then exit;
  if(hLocalFile<>0)then begin
    closeHandle(hLocalFile);
    hLocalFile:=0;
  end;
end;
procedure SaveFile(wFile: DWORD; lpBuffer: Pointer;lpdwNumberOfBytesRead: DWORD);
var
  localFileName,ServerName,ObjectName:string;
  ServerPort:DWORD;
  lpNumberOfBytesWritten:DWORD;
  ret:BOOL;
begin
  if(wFile<>uData.datas[idata-1].wRequest)then exit;
  try
  if(uData.datas[idata-1].dataLen=0)then begin
    ServerName:=uData.datas[idata-1].ServerName;
    ObjectName:=uData.datas[idata-1].ObjectName;
    ServerPort:=uData.datas[idata-1].ServerPort;
    localFileName:=url2file(ServerName,ObjectName,ServerPort);
    if(localFileName='')then exit;
    if(fileexists(localFileName))then exit;
    if(hLocalFile<>0)then myCloseFileHandle(hLocalFile);
    uData.datas[idata-1].rData:=localFilename;
    hLocalFile:=CreateFile(pchar(localFileName),GENERIC_WRITE,FILE_SHARE_WRITE,nil,CREATE_ALWAYS,FILE_ATTRIBUTE_NORMAL,0);
    if(hLocalFile = INVALID_HANDLE_VALUE)then exit;
  end else begin
    if(hLocalFile=0)then exit;
  end;
  lpNumberOfBytesWritten:=0;
  while(lpNumberOfBytesWritten<lpdwNumberOfBytesRead)do
  begin
    ret:=writeFile(hLocalFile,lpBuffer^,lpdwNumberOfBytesRead,lpNumberOfBytesWritten,0);
    if(ret=false)then begin CloseHandle(hLocalFile);hLocalFile:=0;exit;end;
  end;
  finally
    uData.datas[idata-1].dataLen:=uData.datas[idata-1].dataLen+lpdwNumberOfBytesRead;
  end;

end;




//插入主页信息详细信息：
function TDM.InsertPageDetail(pageID,dt,url,verb,len,qHeader,rHeader,qData,rData:string):string;
var
  sql:string;
  test1,test2:string;
begin
  result:='';
  Q1.Close;
  test1:='aaa';
  test2:='bbbb';
  sql:='insert into page_detail (page_ID,get_time,target_url,op_verb,data_len,request_header,response_header,request_data,response_data) values ('+pageID+',"'+dt+'","'+url+'","'+verb+'","'+len+'",:request_header,:response_header,"'+qData+'","'+rData+'")';
  Q1.Parameters.CreateParameter('request_header',ftMemo,pdinput,length(qHeader),qHeader);
  Q1.Parameters.CreateParameter('response_header',ftMemo,pdinput,length(rHeader),rHeader);
  //Q1.Parameters.ParamByName('request_header').Value:=qHeader;
  //Q1.Parameters.ParamByName('response_header').Value:=rHeader;
  uLog.Log(sql);
  Q1.SQL.Text:=sql;
  Q1.ExecSQL;
  result:='';
  Q1.Close;
end;
//插入主页信息,,返回主页信息ID：
function TDM.InsertPageInfo(protocol,domain,port,url:string):string;
var
  sql:string;
begin
  result:='';
  Q1.Close;
  sql:='insert into web_page (page_protocol,page_domain,page_port,page_url) values ("'+protocol+'","'+domain+'","'+port+'","'+url+'")';
  uLog.Log(sql);
  Q1.SQL.Text:=sql;
  Q1.ExecSQL;
  result:=getLastPageID;
  Q1.Close;
end;

//插入主页信息详细信息：
function TDM.addPageDetail(pageID,ServerName,ServerPort,ObjectName,verb,len,qHeader,rHeader,qData,rData:string;dtGet:tdatetime):boolean;
begin
  result:=false;
  try
  if(dm.tPageDetail.Active=false)then begin
    dm.tPage.Open;
   dm.tPageDetail.Open;
  end;
  dm.tPageDetail.Append;
  tPageDetail.fieldbyname('page_ID').AsInteger:=strtoint(pageID);
  tPageDetail.fieldbyname('get_time').AsDateTime:=dtGet;      //
  tPageDetail.fieldbyname('server_name').AsString:=ServerName;
  tPageDetail.fieldbyname('server_port').AsString:=ServerPort;
  tPageDetail.fieldbyname('object_name').AsString:=ObjectName;
  tPageDetail.fieldbyname('op_verb').AsString:=verb;
  tPageDetail.fieldbyname('data_len').AsString:=len;
  tPageDetail.fieldbyname('request_header').AsString:=qHeader;
  tPageDetail.fieldbyname('response_header').AsString:=rHeader;
  tPageDetail.fieldbyname('request_data').AsString:=qData;
  tPageDetail.fieldbyname('response_data').AsString:=rData;
  //Tblobfield(tPageDetail.fieldByName('ExexSql')).as
  tPageDetail.Post;
  result:=true;
  finally

  end;
end;

//插入主页信息详细信息：
function TDM.InsertPageDetail(pageID,dt,url,verb,len,qHeader,rHeader,qData,rData:string):string;
var
  sql:string;
begin
  result:='';
  Q1.Close;
  sql:='insert into page_detail (page_ID,get_time,target_url,op_verb,data_len,request_header,response_header,request_data,response_data) values ('+pageID+',"'+dt+'","'+url+'","'+verb+'","'+len+'","'+qHeader+'","'+rHeader+'","'+qData+'","'+rData+'")';
  uLog.Log(sql);
  Q1.SQL.Text:=sql;
  Q1.ExecSQL;
  result:='';
  Q1.Close;
end;

}

end.
