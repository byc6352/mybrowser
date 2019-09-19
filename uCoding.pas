unit uCoding;

interface

uses Windows,sysutils;

type
  UTF8String = AnsiString;

  function AnsiToWide(const S: AnsiString): WideString;
  function WideToUTF8(const WS: WideString): UTF8String;
  function AnsiToUTF8(const S: AnsiString): UTF8String;
  function UTF8ToWide(const US: UTF8String): WideString;
  function WideToAnsi(const WS: WideString): AnsiString;
  function UTF8ToAnsi(const S: UTF8String): AnsiString;
  function AnsiToUnicode(Str: ansistring): string;

implementation
function AnsiToUnicode(Str: ansistring): string;
var
  s: ansistring;
  i:integer;
  j,k:String[2];
  a:array [1..1000] of  ansichar;
begin
  s:='';
  StringToWideChar(Str,@(a[1]),500);
  i:=1;
  while ((a[i]<>#0) or (a[i+1]<>#0)) do
  begin
    j:=IntToHex(Integer(a[i]),2);
    k:=IntToHex(Integer(a[i+1]),2);
    s:=s+'\u'+k+j;
    i:=i+2;
  end;
  Result:=s;
end;

function AnsiToWide(const S: AnsiString): WideString;
var
  len: integer;
  ws: WideString;
begin
  Result:='';
  if (Length(S) = 0) then
    exit;
  len:=MultiByteToWideChar(CP_ACP, 0, PansiChar(s), -1, nil, 0);
  SetLength(ws, len);
  MultiByteToWideChar(CP_ACP, 0, PansiChar(s), -1, PWideChar(ws), len);
  Result:=ws;
end;

function WideToUTF8(const WS: WideString): UTF8String;
var
  len: integer;
  us: UTF8String;
begin
  Result:='';
  if (Length(WS) = 0) then
    exit;
  len:=WideCharToMultiByte(CP_UTF8, 0, PWideChar(WS), -1, nil, 0, nil, nil);
  SetLength(us, len);
  WideCharToMultiByte(CP_UTF8, 0, PWideChar(WS), -1, PansiChar(us), len, nil, nil);
  Result:=us;
end;

function AnsiToUTF8(const S: AnsiString): UTF8String;
begin
  Result:=WideToUTF8(AnsiToWide(S));
end;

function UTF8ToWide(const US: UTF8String): WideString;
var
  len: integer;
  ws: WideString;
begin
  Result:='';
  if (Length(US) = 0) then
    exit;
  len:=MultiByteToWideChar(CP_UTF8, 0, PansiChar(US), -1, nil, 0);
  SetLength(ws, len);
  MultiByteToWideChar(CP_UTF8, 0, PansiChar(US), -1, PWideChar(ws), len);
  Result:=ws;
end;

function WideToAnsi(const WS: WideString): AnsiString;
var
  len: integer;
  s: AnsiString;
begin
  Result:='';
  if (Length(WS) = 0) then
    exit;
  len:=WideCharToMultiByte(CP_ACP, 0, PWideChar(WS), -1, nil, 0, nil, nil);
  SetLength(s, len);
  WideCharToMultiByte(CP_ACP, 0, PWideChar(WS), -1, PansiChar(s), len, nil, nil);
  Result:=s;
end;

function UTF8ToAnsi(const S: UTF8String): AnsiString;
begin
  Result:=WideToAnsi(UTF8ToWide(S));
end;

end.
