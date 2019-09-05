unit uHookWeb;

interface
uses windows,WinSock2,Messages,WININET,uFuncs,uConfig,uCoding;

Const
  WM_CAP_WORK = WM_USER+1001;
  IDX_HttpOpenRequestW=1;
  IDX_HttpSendRequestW=2;
  IDX_HttpSendRequestExW=3;
  IDX_HttpAddRequestHeadersW=4;
  IDX_InternetReadFile=5;
  IDX_HttpQueryInfoW=6;
  IDX_InternetWriteFile=7;

  STAT_BROWSING=0;
  STAT_IDLE=1;

var
  state:integer; //浏览器状态：STAT_BROWSING正在加载页面；STAT_IDLE空闲；
  original_InternetSetCookieEx : function(lpszUrl, lpszCookieName,lpszCookieData: LPCWSTR; dwFlags: DWORD; lpReserved: Pointer): DWORD; stdcall;

  original_Send: function(s: TSocket; var Buf; len, flags: Integer): Integer; stdcall;

  original_Recv:function (s: TSocket; var Buf; len, flags: Integer): Integer; stdcall;

  original_InternetOpenUrlW:function (hInet: HINTERNET; lpszUrl: LPWSTR;lpszHeaders: LPWSTR; dwHeadersLength: DWORD; dwFlags: DWORD;dwContext: DWORD_PTR): HINTERNET; stdcall;
  //HttpOpenRequestW
  original_HttpOpenRequestW:function (hConnect: HINTERNET; lpszVerb: LPWSTR;
  lpszObjectName: LPWSTR; lpszVersion: LPWSTR; lpszReferrer: LPWSTR;
  lplpszAcceptTypes: PLPSTR; dwFlags: DWORD;
  dwContext: DWORD_PTR): HINTERNET; stdcall;
  //HttpSendRequestA
  original_HttpSendRequestA:function(hRequest: HINTERNET; lpszHeaders: LPSTR;
  dwHeadersLength: DWORD; lpOptional: Pointer;
  dwOptionalLength: DWORD): BOOL; stdcall;
  //HttpSendRequestW
  original_HttpSendRequestW:function(hRequest: HINTERNET; lpszHeaders: LPWSTR;
  dwHeadersLength: DWORD; lpOptional: Pointer;
  dwOptionalLength: DWORD): BOOL; stdcall;
  //HttpSendRequestEx
  original_HttpSendRequestExW:function(hRequest: HINTERNET; lpBuffersIn: PInternetBuffersW;
    lpBuffersOut: PInternetBuffersW;
    dwFlags: DWORD; dwContext: DWORD_PTR): BOOL; stdcall;
  //HttpAddRequestHeadersW
  original_HttpAddRequestHeadersW:function(hRequest: HINTERNET; lpszHeaders: LPWSTR;
  dwHeadersLength: DWORD; dwModifiers: DWORD): BOOL; stdcall;
  //InternetReadFile
  original_InternetReadFile:function(hFile: HINTERNET; lpBuffer: Pointer;
  dwNumberOfBytesToRead: DWORD; var lpdwNumberOfBytesRead: DWORD): BOOL; stdcall;
  //HttpQueryInfoW
  original_HttpQueryInfoW:function(hRequest: HINTERNET; dwInfoLevel: DWORD;
  lpvBuffer: Pointer; var lpdwBufferLength: DWORD;
  var lpdwReserved: DWORD): BOOL; stdcall;
  //InternetWriteFile
  original_InternetWriteFile:function(hFile: HINTERNET; lpBuffer: Pointer;
  dwNumberOfBytesToWrite: DWORD;
  var lpdwNumberOfBytesWritten: DWORD): BOOL; stdcall;

  hForm:HWND;
  gUrl,gVerb,gQHeaders,gRHeaders,gQdata,gRdata,gLength:string;
  s:string;
  function replaced_InternetOpenUrlW(hInet: HINTERNET; lpszUrl: LPWSTR;lpszHeaders: LPWSTR; dwHeadersLength: DWORD; dwFlags: DWORD;dwContext: DWORD_PTR): HINTERNET; stdcall;
  //HttpOpenRequestW
  function replaced_HttpOpenRequestW(hConnect: HINTERNET; lpszVerb: LPWSTR;
  lpszObjectName: LPWSTR; lpszVersion: LPWSTR; lpszReferrer: LPWSTR;
  lplpszAcceptTypes: PLPSTR; dwFlags: DWORD;
  dwContext: DWORD_PTR): HINTERNET; stdcall;
  //HttpSendRequestA
  function replaced_HttpSendRequestA(hRequest: HINTERNET; lpszHeaders: LPSTR;
  dwHeadersLength: DWORD; lpOptional: Pointer;
  dwOptionalLength: DWORD): BOOL; stdcall;
  //HttpSendRequestW
  function replaced_HttpSendRequestW(hRequest: HINTERNET; lpszHeaders: LPWSTR;
  dwHeadersLength: DWORD; lpOptional: Pointer;
  dwOptionalLength: DWORD): BOOL; stdcall;
  //HttpSendRequestEx
  function replaced_HttpSendRequestExW(hRequest: HINTERNET; lpBuffersIn: PInternetBuffersW;
    lpBuffersOut: PInternetBuffersW;
    dwFlags: DWORD; dwContext: DWORD_PTR): BOOL; stdcall;
  //HttpAddRequestHeadersW
  function replaced_HttpAddRequestHeadersW(hRequest: HINTERNET; lpszHeaders: LPWSTR;
  dwHeadersLength: DWORD; dwModifiers: DWORD): BOOL; stdcall;
  //InternetReadFile
  function replaced_InternetReadFile(hFile: HINTERNET; lpBuffer: Pointer;
  dwNumberOfBytesToRead: DWORD; var lpdwNumberOfBytesRead: DWORD): BOOL; stdcall;
  //HttpQueryInfoW
  function replaced_HttpQueryInfoW(hRequest: HINTERNET; dwInfoLevel: DWORD;
  lpvBuffer: Pointer; var lpdwBufferLength: DWORD;
  var lpdwReserved: DWORD): BOOL; stdcall;
  //InternetWriteFile
  function replaced_InternetWriteFile(hFile: HINTERNET; lpBuffer: Pointer;
  dwNumberOfBytesToWrite: DWORD;
  var lpdwNumberOfBytesWritten: DWORD): BOOL; stdcall;

  procedure UnHookWebAPI;
  procedure HookWebAPI;
implementation
uses
  HookUtils,uMain;
//HttpQueryInfoW
function replaced_HttpQueryInfoW(hRequest: HINTERNET; dwInfoLevel: DWORD;
  lpvBuffer: Pointer; var lpdwBufferLength: DWORD;
  var lpdwReserved: DWORD): BOOL; stdcall;
var
  tmp:DWORD;
  buf:array[0..10*1023] of char;
begin
  //MessageBeep(2000); //简单的响一声
  if(dwInfoLevel=HTTP_QUERY_RAW_HEADERS_CRLF)then begin
    tmp:=1024*10;
    if(original_HttpQueryInfoW(hRequest,HTTP_QUERY_FLAG_REQUEST_HEADERS or HTTP_QUERY_RAW_HEADERS_CRLF,@buf[0],tmp,lpdwReserved))then begin
      gQHeaders:=buf;
      //sendMessage(hform, WM_CAP_WORK,IDX_HttpQueryInfoW,1);
    end else gQHeaders:='';
    tmp:=1024*10;
    if(original_HttpQueryInfoW(hRequest,HTTP_QUERY_CONTENT_LENGTH,@buf[0],tmp,lpdwReserved))then begin
      gLength:=buf;
      //sendMessage(hform, WM_CAP_WORK,IDX_HttpQueryInfoW,2);
    end else gLength:='';
  end;

  result:=original_HttpQueryInfoW(hRequest,dwInfoLevel,lpvBuffer,lpdwBufferLength,lpdwReserved);
  //这儿进行接收的数据处理
  if(dwInfoLevel=HTTP_QUERY_RAW_HEADERS_CRLF)then begin
    gRHeaders:=pchar(lpvBuffer);
    //postMessage(hform, WM_CAP_WORK,IDX_HttpOpenRequestW,0);
    sendMessage(hform, WM_CAP_WORK,IDX_HttpQueryInfoW,0);
  end;
  {
  if(dwInfoLevel=HTTP_QUERY_CONTENT_LENGTH)then begin
    gLength:=pchar(lpvBuffer);
    MessageBeep(2000); //简单的响一声
    //postMessage(hform, WM_CAP_WORK,IDX_HttpOpenRequestW,0);
    sendMessage(hform, WM_CAP_WORK,IDX_HttpQueryInfoW,2);
  end;
  if(dwInfoLevel=HTTP_QUERY_FLAG_REQUEST_HEADERS or HTTP_QUERY_RAW_HEADERS_CRLF)then begin
    gQHeaders:=pchar(lpvBuffer);
    MessageBeep(2000); //简单的响一声
    //postMessage(hform, WM_CAP_WORK,IDX_HttpOpenRequestW,0);
    sendMessage(hform, WM_CAP_WORK,IDX_HttpQueryInfoW,1);
  end;

  if(dwInfoLevel=HTTP_QUERY_RAW_HEADERS)then begin
    gRHeaders:=pchar(lpvBuffer);
    MessageBeep(2000); //简单的响一声
    //postMessage(hform, WM_CAP_WORK,IDX_HttpOpenRequestW,0);
    sendMessage(hform, WM_CAP_WORK,IDX_HttpQueryInfoW,0);
  end;
  }
end;
//HttpOpenRequestW
function replaced_HttpOpenRequestW(hConnect: HINTERNET; lpszVerb: LPWSTR;
  lpszObjectName: LPWSTR; lpszVersion: LPWSTR; lpszReferrer: LPWSTR;
  lplpszAcceptTypes: PLPSTR; dwFlags: DWORD;
  dwContext: DWORD_PTR): HINTERNET; stdcall;
begin
  //这儿进行接收的数据处理
  gUrl:=lpszObjectName;
  gVerb:=lpszVerb;

  //postMessage(hform, WM_CAP_WORK,IDX_HttpOpenRequestW,0);
  sendMessage(hform, WM_CAP_WORK,IDX_HttpOpenRequestW,0);
  //MessageBeep(2000); //简单的响一声
  result:=original_HttpOpenRequestW(hConnect,lpszVerb,lpszObjectName,lpszVersion,lpszReferrer,lplpszAcceptTypes,dwFlags,dwContext);
end;

//HttpSendRequestA
function replaced_HttpSendRequestA(hRequest: HINTERNET; lpszHeaders: LPSTR;
  dwHeadersLength: DWORD; lpOptional: Pointer;
  dwOptionalLength: DWORD): BOOL; stdcall;
begin
  //这儿进行接收的数据处理
  if(dwHeadersLength>0)then begin
    gQHeaders:=lpszHeaders;
    //sendMessage(hform, WM_CAP_WORK,IDX_HttpSendRequestW,0);
    MessageBeep(2000); //简单的响一声
  end;
  result:=original_HttpSendRequestA(hRequest,lpszHeaders,dwHeadersLength,lpOptional,dwOptionalLength);
end;

 //HttpSendRequestW
function replaced_HttpSendRequestW(hRequest: HINTERNET; lpszHeaders: LPWSTR;
  dwHeadersLength: DWORD; lpOptional: Pointer;
  dwOptionalLength: DWORD): BOOL; stdcall;
begin

  result:=original_HttpSendRequestW(hRequest,lpszHeaders,dwHeadersLength,lpOptional,dwOptionalLength);
  //这儿进行接收的数据处理
  if(dwHeadersLength>0)then begin
    gqHeaders:=lpszHeaders;
    sendMessage(hform, WM_CAP_WORK,IDX_HttpSendRequestW,0);
    MessageBeep(2000); //简单的响一声
  end;
  if(dwOptionalLength>0)then begin
    gQData:=pchar(lpOptional);
    sendMessage(hform, WM_CAP_WORK,IDX_HttpSendRequestW,0);
    MessageBeep(2000); //简单的响一声
  end;
end;

  //HttpSendRequestEx
function replaced_HttpSendRequestExW(hRequest: HINTERNET; lpBuffersIn: PInternetBuffersW;
    lpBuffersOut: PInternetBuffersW;
    dwFlags: DWORD; dwContext: DWORD_PTR): BOOL; stdcall;
begin
  //这儿进行接收的数据处理

  MessageBeep(2000); //简单的响一声
  result:=original_HttpSendRequestExW(hRequest,lpBuffersIn,lpBuffersOut,dwFlags,dwContext);
end;

  //HttpAddRequestHeadersW
function replaced_HttpAddRequestHeadersW(hRequest: HINTERNET; lpszHeaders: LPWSTR;
  dwHeadersLength: DWORD; dwModifiers: DWORD): BOOL; stdcall;
begin
  //这儿进行接收的数据处理
  if(dwHeadersLength>0)then begin
    gQHeaders:=lpszHeaders;
    SendMessage(hform, WM_CAP_WORK,IDX_HttpAddRequestHeadersW,0);

    //MessageBeep(2000); //简单的响一声
  end;
  result:=original_HttpAddRequestHeadersW(hRequest,lpszHeaders,dwHeadersLength,dwModifiers);

end;
  //InternetReadFile
function replaced_InternetReadFile(hFile: HINTERNET; lpBuffer: Pointer;
  dwNumberOfBytesToRead: DWORD; var lpdwNumberOfBytesRead: DWORD): BOOL; stdcall;
var

  buf:array[0..1023] of ansichar;

begin
  result:=original_InternetReadFile(hFile,lpBuffer,dwNumberOfBytesToRead,lpdwNumberOfBytesRead);
  if not result then exit;
  //这儿进行接收的数据处理
  if((lpdwNumberOfBytesRead>0) and (lpdwNumberOfBytesRead<100))or(state=STAT_IDLE)or(gverb='POST')then begin
    gRdata:=gets(lpBuffer,lpdwNumberOfBytesRead);
    MessageBeep(10); //简单的响一声
    uFuncs.saveTofile(uFuncs.getFilename(uConfig.workdir,'reponse','.txt'),lpBuffer,lpdwNumberOfBytesRead);
    SendMessage(hform, WM_CAP_WORK,IDX_InternetReadFile,0);
  end;

end;
  //InternetWriteFile
function replaced_InternetWriteFile(hFile: HINTERNET; lpBuffer: Pointer;
  dwNumberOfBytesToWrite: DWORD;
  var lpdwNumberOfBytesWritten: DWORD): BOOL; stdcall;
begin
  //这儿进行接收的数据处理
  gQdata:=gets(lpBuffer,dwNumberOfBytesToWrite);
  SendMessage(hform, WM_CAP_WORK,IDX_InternetReadFile,0);
  uFuncs.saveTofile(uFuncs.getFilename(uConfig.workdir,'quest','.txt'),lpBuffer,dwNumberOfBytesToWrite);
  MessageBeep(10); //简单的响一声
  result:=original_InternetWriteFile(hFile,lpBuffer,dwNumberOfBytesToWrite,lpdwNumberOfBytesWritten);
end;

function replaced_InternetOpenUrlW(hInet: HINTERNET; lpszUrl: LPWSTR;lpszHeaders: LPWSTR; dwHeadersLength: DWORD; dwFlags: DWORD;dwContext: DWORD_PTR): HINTERNET; stdcall;
begin
  //这儿进行接收的数据处理
  gUrl:=lpszUrl;
  postMessage(hform, WM_CAP_WORK,0,2);
  //MessageBeep(2000); //简单的响一声
  result:=original_InternetOpenUrlW(hInet,lpszUrl,lpszHeaders,dwHeadersLength,dwFlags,dwContext);
end;

{------------------------------------}
{过程功能:HookAPI
{过程参数:无
{------------------------------------}
procedure HookWebAPI;
begin
  if not(Assigned(original_InternetOpenUrlW)) then
  begin
    //@original_InternetOpenUrlW := HookProcInModule('WININET.dll', 'InternetOpenUrlW', @replaced_InternetOpenUrlW);
  end;

  if not(Assigned(original_HttpOpenRequestW)) then
  begin
    @original_HttpOpenRequestW := HookProcInModule('wininet.dll', 'HttpOpenRequestW', @replaced_HttpOpenRequestW);
  end;

  if not(Assigned(original_HttpSendRequestA)) then
  begin
    //@original_HttpSendRequestA := HookProcInModule('wininet.dll', 'HttpSendRequestA', @replaced_HttpSendRequestA);

  end;

  if not(Assigned(original_HttpSendRequestW)) then
  begin
    @original_HttpSendRequestW := HookProcInModule('wininet.dll', 'HttpSendRequestW', @replaced_HttpSendRequestW);
  end;

  if not(Assigned(original_HttpSendRequestExW)) then
  begin
    @original_HttpSendRequestExW:= HookProcInModule('wininet.dll', 'HttpSendRequestExW', @replaced_HttpSendRequestExW);
  end;

  if not(Assigned(original_HttpAddRequestHeadersW)) then
  begin
    @original_HttpAddRequestHeadersW := HookProcInModule('wininet.dll', 'HttpAddRequestHeadersW', @replaced_HttpAddRequestHeadersW);
  end;

  if not(Assigned(original_InternetReadFile)) then
  begin
    @original_InternetReadFile := HookProcInModule('wininet.dll', 'InternetReadFile', @replaced_InternetReadFile);
  end;

  if not(Assigned(original_HttpQueryInfoW)) then
  begin
    @original_HttpQueryInfoW := HookProcInModule('wininet.dll', 'HttpQueryInfoW', @replaced_HttpQueryInfoW);
  end;
  //InternetWriteFile
  if not(Assigned(original_InternetWriteFile)) then
  begin
    @original_InternetWriteFile := HookProcInModule('wininet.dll', 'InternetWriteFile', @replaced_InternetWriteFile);
  end;
end;
{------------------------------------}
{过程功能:取消HOOKAPI
{过程参数:无
{------------------------------------}
procedure UnHookWebAPI;
begin
  if Assigned(original_Send) then
    UnHook(@original_Send);
  if Assigned(original_Recv) then
    UnHook(@original_Recv);

  if Assigned(original_HttpOpenRequestW) then
    UnHook(@original_HttpOpenRequestW);

  if Assigned(original_HttpSendRequestA) then
    UnHook(@original_HttpSendRequestA);

  if Assigned(original_HttpSendRequestW) then
    UnHook(@original_HttpSendRequestW);

  if Assigned(original_HttpAddRequestHeadersW) then
    UnHook(@original_HttpAddRequestHeadersW);

  if Assigned(original_HttpSendRequestExW) then
    UnHook(@original_HttpSendRequestExW);

  if Assigned(original_InternetReadFile) then
    UnHook(@original_InternetReadFile);

  if Assigned(original_HttpQueryInfoW) then
    UnHook(@original_HttpQueryInfoW);
  //InternetWriteFile
  if Assigned(original_InternetWriteFile) then
    UnHook(@original_InternetWriteFile);
end;


initialization
  HookWebAPI;
finalization
  UnHookWebAPI;
end.

