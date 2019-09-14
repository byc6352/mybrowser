unit uYinyuetai;

interface
uses
  windows, Winapi.Messages, System.SysUtils,classes,strutils;
var
  videoInfo: string;
  function yinyuetai(url:string):boolean;
  procedure downloadThread(videoInfoUrl:string);
  function ThreadProc(param: LPVOID): DWORD; stdcall;
  function parseJsonFile(videoInfoFileName:string;var videoInfo:string):tstrings;
implementation
uses
  System.json,uDown;
//----------------------------------------------音乐台---------------------------------------
function yinyuetai(url:string):boolean;
const
  VIDEO_URL='v.yinyuetai.com/video'; //音乐台视频地址；
  VIDEO_INF_URL='http://ext.yinyuetai.com/main/get-h-mv-info?json=true&videoId='; //音乐台视频信息地址
var
  jsonObject: TJSONObject; // JSON类
  i,j: Integer; // 循环变量
  temp,videoID,videoInfoUrl: string; // 临时使用变量 ,视频ID，视频信息地址
  jsonArray: TJSONArray; // JSON数组变量
  subJsonObject: TJSONObject;
  ss:tstrings;
begin
  result:=false;
  temp:=url;
  i:=pos(VIDEO_URL,temp);
  if(i=0)then exit;
  i:=pos('?',temp);
  if(i>0)then temp:=leftstr(temp,i-1);
  videoID:=rightstr(temp,7);
  videoInfoUrl:=VIDEO_INF_URL+videoID;
  downloadThread(videoInfoUrl);
end;
function parseJsonFile(videoInfoFileName:string;var videoInfo:string):tstrings;
var
  jsonObject: TJSONObject; // JSON类
  i,j,k: Integer; // 循环变量
  temp,videoUrl: string; // 临时使用变量
  jsonArray: TJSONArray; // JSON数组变量
  subJsonObject: TJSONObject;
  ss:tstrings;

begin
  jsonObject := nil;
  try
    ss:=tstringlist.Create;
    ss.LoadFromFile(videoInfoFileName,TEncoding.UTF8);
    temp:=ss.Text;
    ss.Clear;
    if(pos('{',temp)<>1)then begin
      i:=pos('(',temp);
      j:=pos(')',temp);
      if(i>0)then temp:=MidStr(temp,i+1,j-i-1);
    end;
    jsonObject :=TJSONObject.ParseJSONValue(TEncoding.UTF8.GetBytes(temp), 0) as TJSONObject;
    if(jsonObject=nil)then exit;
    if jsonObject.Count = 0 then exit;
    subJsonObject := TJSONObject(jsonObject.GetValue('videoInfo'));
    if(subJsonObject=nil) or (subJsonObject.Count=0)then exit;
    subJsonObject := TJSONObject(subJsonObject.GetValue('coreVideoInfo'));
    if(subJsonObject=nil) or (subJsonObject.Count=0)then exit;
    JSONArray := TJSONArray(subJsonObject.GetValue('videoUrlModels'));
    if(JSONArray=nil) or (JSONArray.Size=0)then exit;
    for I := 0 to JSONArray.Size-1 do
    begin
     subJsonObject := TJSONObject(JSONArray.Items[i]);
     if(subJsonObject=nil) or (subJsonObject.Count=0)then continue;
     for j := 0 to subJsonObject.count - 1 do
     begin
       temp:=subJsonObject.Get(j).JsonString.toString;
       if(temp='"videoUrl"')then begin
         videoUrl:=subJsonObject.Get(j).JsonValue.ToString;
         videoUrl:=replacestr(videoUrl,'"','');
         videoUrl:=replacestr(videoUrl,'\/','/');
         k:=pos('?',videoUrl);
         if(k>0)then videoUrl:=leftstr(videoUrl,k-1);
         ss.Add(videoUrl);
       end;
       temp:=subJsonObject.Get(j).JsonString.toString + ' = ' + subJsonObject.Get(j).JsonValue.ToString;
       videoInfo:=videoInfo+#13#10+temp;
     end;
   end;
  finally
    result:=ss;
    if(assigned(jsonObject))then
      jsonObject.Free;
  end;
end;
//------------------------------------------下载线程区------------------------------------------
function ThreadProc(param: LPVOID): DWORD; stdcall;
var
  url,localfilename:string;
  ss:tstrings;
  i:integer;
begin
  url:=pchar(param);
  localfilename:=uDown.downloadfile(url); //下载视频信息文件；
  if(localfilename='')then exit;
  ss:=parseJsonFile(localfilename,videoInfo); //解析视频信息文件；
  if not assigned(ss) then exit;
  if(ss.count=0)then exit;
  PostMessage(mForm, WM_DOWN_FILE,2,ss.count);
  for i:=0 to ss.count-1  do begin
    uDown.downloadfile(ss[i]); //下载视频文件；
  end;

  Result := 0;
end;
procedure downloadThread(videoInfoUrl:string);
var
  threadId: TThreadID;
begin

  CreateThread(nil, 0, @ThreadProc, pchar(videoInfoUrl), 0, threadId);
end;

end.
