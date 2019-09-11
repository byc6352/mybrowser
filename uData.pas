unit uData;

interface
uses
  windows,sysutils,uFuncs,uConfig;
const
  MAX_RECORD=10000;//最大记录数；
  DATA_TYPE_REQUEST=0;//请求的数据；
  DATA_TYPE_REPONSE=1;//返回的数据；
type
  stData=record
    wRequest:DWORD;
    ServerPort:DWORD;
    dt:tdatetime; //时间
    ServerName:string;//服务器名称；
    ObjectName:string;   //请求对象
    verb:string;  //请求方法
    len:string;   //数据长度
    qHeader:string; //讲求头
    rHeader:string; //返回头
    qData:string; //发送数据
    rData:string; //返回数据
  end;
stServer=record  //服务器信息；
  wConnect:DWORD;
  ServerPort:DWORD;
  ServerName:string;//服务器名称；
end;

var
  server:stServer;
  datas:array[0..MAX_RECORD] of stData;
  iData:integer;//当前记录指针；


function addUrl(wConnect,wRequest:DWORD;ObjectName:string;verb:string):integer;
  //添加qHeader,rHeader,len;
function addHeader(wRequest:DWORD;qHeader:string;rHeader:string;len:string):integer;
//添加addData;
function addData(wRequest:DWORD;dType:DWORD;p:pointer;len:DWORD):integer;
//
procedure clear;

implementation
//添加URL,verb;
function addUrl(wConnect,wRequest:DWORD;ObjectName:string;verb:string):integer;
begin
  if(wConnect=server.wConnect)then begin
    datas[iData].ServerName:=server.ServerName;
    datas[iData].ServerPort:=server.ServerPort;
  end;
  datas[iData].wRequest:=wRequest;
  datas[iData].dt:=now();
  datas[iData].ObjectName:=ObjectName;
  datas[iData].verb:=verb;
  iData:=iData+1;
  if(iData>=MAX_RECORD)then iData:=0;
  result:=iData;
end;
//添加qHeader,rHeader,len;
function addHeader(wRequest:DWORD;qHeader:string;rHeader:string;len:string):integer;
begin
  result:=-1;
  if(wRequest<>datas[iData-1].wRequest)then exit;
  datas[iData-1].qHeader:=qHeader;
  datas[iData-1].rHeader:=rHeader;
  datas[iData-1].len:=len;
  result:=iData-1;
end;
//添加addData;
function addData(wRequest:DWORD;dType:DWORD;p:pointer;len:DWORD):integer;
var
  filename:string;
begin
  //result:=-1;
  //if(wRequest<>datas[iData].wRequest)then exit;
  if(dType=DATA_TYPE_REQUEST)then begin
    filename:=uFuncs.getFilename(uConfig.workdir,'request','.txt');
    datas[iData-1].qData:=filename;
  end else begin
    filename:=uFuncs.getFilename(uConfig.workdir,'reponse','.txt');
    datas[iData-1].rData:=filename;
  end;
  uFuncs.saveTofile(filename,p,len);
  result:=iData-1;
end;
//
procedure clear;
begin
  iData:=0;
end;
end.
