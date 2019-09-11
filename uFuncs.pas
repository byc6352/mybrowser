unit uFuncs;

interface
uses
  windows,sysutils,strutils,classes,uconfig;
  function saveTofile(filename:string;p:pointer;dwSize:DWORD):boolean;
  function getFilename(workdir:string):string;overload;
  function getFilename(workdir:string;cap:string;ext:string):string;overload;
  function ReversePos(SubStr, S: String): Integer;
  function saveTofile2(filename:string;p:pointer;dwSize:DWORD):boolean;
  function gets(p:pointer;dwSize:DWORD):string;
  function getDataTimeString():string;overload;
  function getDataTimeString(dt:tdatetime):string;overload;
  function my_strtodatetime(str_datetime:string):tdatetime;
implementation
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
function getDataTimeString(dt:tdatetime):string;
var
  s:string;
begin
  result:=FormatDateTime('yyyy-mm-dd hh:nn:ss',dt);
end;
function getDataTimeString():string;
var
  s:string;
begin
  result:=FormatDateTime('yyyy-mm-dd hh:nn:ss',now());
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
  result:=workdir+'\'+cap+FormatDateTime('yyyymmddhhnnsszzz',now())+inttostr(i)+ext;
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
  result:=workdir+'\'+FormatDateTime('yyyymmddhhnnsszzz',now())+inttostr(i)+'.txt';
end;

end.
