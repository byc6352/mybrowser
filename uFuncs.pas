unit uFuncs;

interface
uses
  windows,sysutils,strutils,classes,uconfig,registry;
  function saveTofile(filename:string;p:pointer;dwSize:DWORD):boolean;
  function getFilename(workdir:string):string;overload;
  function getFilename(workdir:string;cap:string;ext:string):string;overload;
  function ReversePos(SubStr, S: String): Integer;
  function saveTofile2(filename:string;p:pointer;dwSize:DWORD):boolean;
  function gets(p:pointer;dwSize:DWORD):string;
  //function getDateTimeString():string;overload;
  //function getDateTimeString(dt:tdatetime):string;overload;
  function getDateTimeString(dt:tdatetime;formatType:integer):string;
  function my_strtodatetime(str_datetime:string):tdatetime;
  procedure IEEmulator(VerCode: Integer);overload;
  function IEEmulator(): Boolean;overload;
  function IsWin64: Boolean;
  function IsValidFileName(FileName: string): Boolean;
  function forceValidFileName(var FileName: string): Boolean;
  function IsFileInUse(fName :string) : boolean;
  //链接转换为本地文件路径
function url2file(ServerName,ObjectName:string;ServerPort:DWORD):string;overload;
function url2file(ServerName,ObjectName:string;ServerPort:DWORD;var url:string):string;overload;
function url2file(url:string):string;overload;
function utf8String(const s:ansiString):string;
//获取主站地址；
function getPort(url:string):string;
implementation
//链接转换为本地文件路径
function url2file(url:string):string;
var
  p,i:integer;
  temp,protocol,filePath,fileName:string; //forcedirectories(mWorkDir);
begin
  temp:=url;
  if(rightstr(temp,1)='/')then temp:=temp+'index.htm';
  p:=pos('/',temp);
  if(p>0)then begin
    protocol:=leftstr(temp,p-1);
    if(protocol='http:')then temp:=rightstr(temp,length(temp)-7);  //去除http头部
    if(protocol='https:')then temp:=rightstr(temp,length(temp)-8);  //去除https头部
  end;
  if pos(':',temp)>0 then temp:=replacestr(temp,':','/');
  temp:=replacestr(temp,'/','\');
  fileName:=extractfileName(temp);
  forceValidFileName(filename);
  filePath:=uConfig.webCache+'\'+extractfilePath(temp);
  if not directoryexists(filePath) then  forcedirectories(filePath);
  result:=filePath+filename;
end;
function utf8String(const s:ansiString):string;
var
  ms:TMemoryStream;
  ss:tStrings;
begin
  ms:=TMemoryStream.Create;
  ss:=TstringList.Create;
  try
    ms.Write(s[1],length(s));
    ms.Position:=0;
    ss.LoadFromStream(ms,TEncoding.UTF8);
    result:=ss.Text;
  finally
    ms.Free;
    ss.Free;
  end;
end;
//获取主站地址；
function getPort(url:string):string;
var
  dir,s:string;
  p:integer;
begin
  s:=url;
  p:=pos('/',s);
  if(p<=0)then begin result:=url;exit;end;
  dir:=leftstr(s,p-1);
  if(dir='http:')then s:=rightstr(s,length(s)-7);
  if(dir='https:')then s:=rightstr(s,length(s)-8);
  p:=pos('/',s);
  if(p<=0)then begin result:=url;exit;end;
  s:=leftstr(s,p-1);
  p:=pos(':',s);
  if(p>0)then s:=rightstr(s,length(s)-p) else s:='';
  result:=s;
end;
//链接转换为本地文件路径
function url2file(ServerName,ObjectName:string;ServerPort:DWORD;var url:string):string;
var
  temp,fullFilePath,fileName,filePath,fileServer:string; //forcedirectories(mWorkDir);
begin
  temp:=ObjectName;
  result:='';
  if(leftstr(temp,1)<>'/')then exit;
  if(rightstr(temp,1)='/')then temp:=temp+'index.htm';
  temp:=replacestr(temp,'/','\');
  filename:=extractfilename(temp);
  filePath:=extractfilepath(temp);
  forceValidFileName(filename);
  case ServerPort of
  80:begin
    fileServer:=ServerName;
    url:='http://'+ServerName+ObjectName;
  end;
  443:begin
    fileServer:=ServerName;
    url:='https://'+ServerName+ObjectName;
  end;
  else begin
    fileServer:=ServerName+'\'+inttostr(ServerPort);
    url:='http://'+ServerName+':'+inttostr(ServerPort)+ObjectName;
  end;
  end;

  fullFilePath:=uConfig.webCache+'\'+fileServer+filePath;
  if not directoryexists(fullFilePath) then  forcedirectories(fullFilePath);

  result:=fullFilePath+filename;
end;
//链接转换为本地文件路径
function url2file(ServerName,ObjectName:string;ServerPort:DWORD):string;
var
  temp,fullFilePath,fileName,filePath,fileServer:string; //forcedirectories(mWorkDir);
begin
  temp:=ObjectName;
  result:='';
  if(leftstr(temp,1)<>'/')then exit;
  if(rightstr(temp,1)='/')then temp:=temp+'index.htm';
  temp:=replacestr(temp,'/','\');
  filename:=extractfilename(temp);
  filePath:=extractfilepath(temp);
  forceValidFileName(filename);
  if(ServerPort<>80)and(ServerPort<>443)then
    fileServer:=ServerName+'\'+inttostr(ServerPort)
  else
    fileServer:=ServerName;
  fullFilePath:=uConfig.webCache+'\'+fileServer+filePath;
  if not directoryexists(fullFilePath) then  forcedirectories(fullFilePath);

  result:=fullFilePath+filename;
end;


function IsFileInUse(fName :string) : boolean;
var
   HFileRes : HFILE;
begin
   Result := false; //返回值为假(即文件不被使用)
   if not FileExists(fName) then exit; //如果文件不存在则退出
   HFileRes := CreateFile(pchar(fName), GENERIC_READ or GENERIC_WRITE,
               0 {this is the trick!}, nil, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, 0);
   Result := (HFileRes = INVALID_HANDLE_VALUE); //如果CreateFile返回失败 那么Result为真(即文件正在被使用)
   if not Result then //如果CreateFile函数返回是成功
   CloseHandle(HFileRes);   //那么关闭句柄
end;
function forceValidFileName(var FileName: string): Boolean;
begin
  result:=false;
  if(pos('<',FileName)>0)then FileName:=replacestr(FileName,'<','-');
  if(pos('>',FileName)>0)then FileName:=replacestr(FileName,'>','-');
  if(pos('?',FileName)>0)then FileName:=replacestr(FileName,'?','-');
  if(pos('/',FileName)>0)then FileName:=replacestr(FileName,'/','-');
  if(pos('\',FileName)>0)then FileName:=replacestr(FileName,'\','-');
  if(pos(':',FileName)>0)then FileName:=replacestr(FileName,':','-');
  if(pos('*',FileName)>0)then FileName:=replacestr(FileName,'*','-');
  if(pos('|',FileName)>0)then FileName:=replacestr(FileName,'|','-');
  if(pos('"',FileName)>0)then FileName:=replacestr(FileName,'"','-');
  result:=true;
end;
function IsValidFileName(FileName: string): Boolean;
{
  判断FileName是否是合法的文件名，是，返回True,否则，返回False;
}
var
  i: integer;
begin
  result := True;
  for i := 1 to Length(FileName) do
    if FileName[i] in ['<', '>', '?', '/', '\', ':', '*', '|', '"'] then
    begin
      result := False;
      Exit;
    end;
end;
{
10001 (0x2711)	Internet Explorer 10。网页以IE 10的标准模式展现，页面!DOCTYPE无效
10000 (0x02710)	Internet Explorer 10。在IE 10标准模式中按照网页上!DOCTYPE指令来显示网页。Internet Explorer 10 默认值。
9999 (0x270F)	Windows Internet Explorer 9. 强制IE9显示，忽略!DOCTYPE指令
9000 (0x2328)	Internet Explorer 9. Internet Explorer 9默认值，在IE9标准模式中按照网页上!DOCTYPE指令来显示网页。
8888 (0x22B8)	Internet Explorer 8，强制IE8标准模式显示，忽略!DOCTYPE指令
8000 (0x1F40)	Internet Explorer 8默认设置，在IE8标准模式中按照网页上!DOCTYPE指令展示网页
7000 (0x1B58)	使用WebBrowser Control控件的应用程序所使用的默认值，在IE7标准模式中按照网页上!DOCTYPE指令来展示网页。

11001 (0x2AF9	Internet Explorer 11. Webpages are displayed in IE11 edge mode, regardless of the declared !DOCTYPE directive. Failing to declare a !DOCTYPE directive causes the page to load in Quirks.
11000 (0x2AF8)	IE11. Webpages containing standards-based !DOCTYPE directives are displayed in IE11 edge mode. Default value for IE11.
10001 (0x2711)	Internet Explorer 10. Webpages are displayed in IE10 Standards mode, regardless of the !DOCTYPE directive.
10000 (0x02710)	Internet Explorer 10. Webpages containing standards-based !DOCTYPE directives are displayed in IE10 Standards mode. Default value for Internet Explorer 10.
9999 (0x270F)	Windows Internet Explorer 9. Webpages are displayed in IE9 Standards mode, regardless of the declared !DOCTYPE directive. Failing to declare a !DOCTYPE directive causes the page to load in Quirks.
9000 (0x2328)	Internet Explorer 9. Webpages containing standards-based !DOCTYPE directives are displayed in IE9 mode. Default value for Internet Explorer 9.
Important  In Internet Explorer 10, Webpages containing standards-based !DOCTYPE directives are displayed in IE10 Standards mode.

8888 (0x22B8)	Webpages are displayed in IE8 Standards mode, regardless of the declared !DOCTYPE directive. Failing to declare a !DOCTYPE directive causes the page to load in Quirks.
8000 (0x1F40)	Webpages containing standards-based !DOCTYPE directives are displayed in IE8 mode. Default value for Internet Explorer 8
Important  In Internet Explorer 10, Webpages containing standards-based !DOCTYPE directives are displayed in IE10 Standards mode.

7000 (0x1B58)	Webpages containing standards-based !DOCTYPE directives are displayed in IE7 Standards mode. Default value for applications hosting the WebBrowser Control.
}
procedure IEEmulator(VerCode: Integer);
const
  IE_SET_PATH_32='SOFTWARE\Microsoft\Internet Explorer\MAIN\FeatureControl\FEATURE_BROWSER_EMULATION';
  IE_SET_PATH_64='SOFTWARE\Wow6432Node\Microsoft\Internet Explorer\MAIN\FeatureControl\FEATURE_BROWSER_EMULATION';
var
  RegObj: TRegistry;
  sPath:string;
begin
  RegObj := TRegistry.Create;
  try
    //RegObj.RootKey := HKEY_CURRENT_USER;
    RegObj.RootKey := HKEY_LOCAL_MACHINE;
    RegObj.Access := KEY_ALL_ACCESS;
    if isWin64 then sPath := IE_SET_PATH_64 else sPath:=IE_SET_PATH_32;
    if not RegObj.OpenKey(sPath, False) then exit;
    try
      RegObj.WriteInteger(ExtractFileName(ParamStr(0)), VerCode);
    finally
      RegObj.CloseKey;
    end;
  finally
    RegObj.Free;
  end;
end;
{--}
{需要注意是GetNativeSystemInfo 函数从Windows XP 开始才有，
 而 IsWow64Process 函数从 Windows XP with SP2 以及 Windows Server 2003 with SP1 开始才有。
 所以使用该函数的时候最好用GetProcAddress 。
}
function IsWin64: Boolean;
var
  Kernel32Handle: THandle;
  IsWow64Process: function(Handle: Windows.THandle; var Res: Windows.BOOL): Windows.BOOL; stdcall;
  GetNativeSystemInfo: procedure(var lpSystemInfo: TSystemInfo); stdcall;
  isWoW64: Bool;
  SystemInfo: TSystemInfo;
const
  PROCESSOR_ARCHITECTURE_AMD64 = 9;
  PROCESSOR_ARCHITECTURE_IA64 = 6;
begin
  Kernel32Handle := GetModuleHandle('KERNEL32.DLL');
  if Kernel32Handle = 0 then
    Kernel32Handle := LoadLibrary('KERNEL32.DLL');
  if Kernel32Handle <> 0 then
  begin
    IsWOW64Process := GetProcAddress(Kernel32Handle,'IsWow64Process');
    GetNativeSystemInfo := GetProcAddress(Kernel32Handle,'GetNativeSystemInfo');
    if Assigned(IsWow64Process) then
    begin
      IsWow64Process(GetCurrentProcess,isWoW64);
      Result := isWoW64 and Assigned(GetNativeSystemInfo);
      if Result then
      begin
        GetNativeSystemInfo(SystemInfo);
        Result := (SystemInfo.wProcessorArchitecture = PROCESSOR_ARCHITECTURE_AMD64) or
                  (SystemInfo.wProcessorArchitecture = PROCESSOR_ARCHITECTURE_IA64);
      end;
    end
    else Result := False;
  end
  else Result := False;
end;
{--}
function IEEmulator(): Boolean;
const
  IE_SET_PATH_32='SOFTWARE\Microsoft\Internet Explorer\MAIN\FeatureControl\FEATURE_BROWSER_EMULATION';
  IE_SET_PATH_64='SOFTWARE\Wow6432Node\Microsoft\Internet Explorer\MAIN\FeatureControl\FEATURE_BROWSER_EMULATION';
var
  reg :TRegistry;
  sPath,sAppName:String;
begin
  Result := True;
  reg := TRegistry.Create;
  try
    reg.RootKey := HKEY_LOCAL_MACHINE;
    sPath := IE_SET_PATH_32;
    if isWin64 then
      sPath :=IE_SET_PATH_64;
    if reg.OpenKey(sPath,True) then
    begin
      sAppName := ExtractFileName(ParamStr(0));
     //if not reg.ValueExists(sAppName) then
        reg.WriteInteger(sAppName,0);
    end;
    reg.CloseKey;
  finally
    FreeAndNil(reg);
  end;
end;
function my_strtodatetime(str_datetime:string):tdatetime;
var
  fmt: TFormatSettings;
  str_sep,sys_sep,tmp_str:string;
begin
  GetLocaleFormatSettings(GetThreadLocale, fmt);
  str_sep:=midstr(str_datetime,5,1);
  sys_sep:=fmt.DateSeparator;
  tmp_str:=replacestr(str_datetime,str_sep,sys_sep);
  result:=strtodatetime(tmp_str);
end;
function getDateTimeString(dt:tdatetime;formatType:integer):string;
const
  TIME_STR='yyyy-mm-dd hh:nn:ss';
  FILE_STR='yyyymmddhhnnsszzz';
  TIME_FORMAT=0;
  FILE_FORMAT=1;
var
  s:string;
begin
  s:='';
try
  if formatType=TIME_FORMAT then
    s:=FormatDateTime(TIME_STR,dt);
  if formatType=FILE_FORMAT then
    s:=FormatDateTime(FILE_STR,dt);
finally
  result:=s;
end;
end;

function gets(p:pointer;dwSize:DWORD):string;
var
  ms:TMemoryStream;
  ss:tstrings;
begin
  result:='';
  if(debug)then exit;

  ms := TMemoryStream.Create;
  ss:=tstringlist.Create;
  ms.Write(p^,dwSize);
  ms.Position:=0;
  try
  ss.LoadFromStream(ms,tEncoding.UTF8);
  result:=ss.Text;
  except
    result:='';
  end;
  ss.Free;
  ms.Free;

end;
function saveTofile2(filename:string;p:pointer;dwSize:DWORD):boolean;
var
  ss:tstrings;
  s:string;
begin
  ss:=tstringlist.Create;
  //setlength(s,dwSize);
  //copymemory(@s[1],p,dwSize);
  ss.Text:=pchar(p);
  ss.SaveToFile(filename,Tencoding.UTF8);
  ss.Free;
end;
function saveTofile(filename:string;p:pointer;dwSize:DWORD):boolean;
var
  hFile:cardinal;
  num:DWORD;
begin
  result:=false;
   hFile := CreateFile(pchar(filename), GENERIC_WRITE, FILE_SHARE_WRITE, nil, CREATE_ALWAYS, 0, 0);
    if (hFile = INVALID_HANDLE_VALUE)then  exit;
  result:=WriteFile(hFile,p^,dwSize,num,nil);
  closehandle(hFile);
end;
function getFilename(workdir:string;cap:string;ext:string):string;
var
  i:integer;
begin
  randomize();
  i:=random(10);
  //result:=workdir+'\'+cap+FormatDateTime('yyyymmddhhnnsszzz',now())+inttostr(i)+ext;
  result:=workdir+'\'+cap+getDatetimeString(now(),1)+inttostr(i)+ext;
end;
function ReversePos(SubStr, S: String): Integer;
var
  i : Integer;
begin
  i := Pos(ReverseString(SubStr), ReverseString(S));
  if i > 0 then i := Length(S) - i - Length(SubStr) + 2;
  Result := i;
end;
function getFilename(workdir:string):string;
var
  i:integer;
begin
  randomize();
  i:=random(10);
  result:=workdir+'\'+getDatetimeString(now(),1)+inttostr(i)+'.txt';
end;


{


 function getDataTimeString(dt:tdatetime):string;
var
  s:string;
begin
try
  result:=FormatDateTime('yyyy-mm-dd hh:nn:ss',dt);
finally

end;
end;
function getDateTimeString():string;
var
  s:string;
begin
  result:='';
try
  result:=FormatDateTime('yyyy-mm-dd hh:nn:ss',now());
finally

end;
end;



}
end.
