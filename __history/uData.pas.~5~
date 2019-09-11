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
    hRequest:DWORD;
    dt:tdatetime; //时间
    url:string;   //请求对象
    verb:string;  //请求方法
    len:string;   //数据长度
    qHeader:string; //讲求头
    rHeader:string; //返回头
    qData:string; //发送数据
    rData:string; //返回数据
  end;

var
  datas:array[0..MAX_RECORD] of stData;
  iData:integer;//当前记录指针；


function addUrl(hRequest:DWORD;url:string;verb:string):integer;
  //添加qHeader,rHeader,len;
function addHeader(hRequest:DWORD;qHeader:string;rHeader:string;len:string):integer;
//添加addData;
function addData(hRequest:DWORD;dType:DWORD;p:pointer;len:DWORD):integer;
//
procedure clear;

implementation
//添加URL,verb;
function addUrl(hRequest:DWORD;url:string;verb:string):integer;
begin
  datas[iData].hRequest:=hRequest;
  datas[iData].dt:=now();
  datas[iData].url:=url;
  datas[iData].verb:=verb;
  iData:=iData+1;
  if(iData>=MAX_RECORD)then iData:=0;
  result:=iData;
end;
//添加qHeader,rHeader,len;
function addHeader(hRequest:DWORD;qHeader:string;rHeader:string;len:string):integer;
begin
  result:=-1;
  if(hRequest<>datas[iData-1].hRequest)then exit;
  datas[iData].qHeader:=qHeader;
  datas[iData].rHeader:=rHeader;
  datas[iData].len:=len;
  result:=iData-1;
end;
//添加addData;
function addData(hRequest:DWORD;dType:DWORD;p:pointer;len:DWORD):integer;
var
  filename:string;
begin
  //result:=-1;
  //if(hRequest<>datas[iData].hRequest)then exit;
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
