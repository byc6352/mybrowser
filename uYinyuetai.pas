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
//----------------------------------------------����̨---------------------------------------
function yinyuetai(url:string):boolean;
const
  VIDEO_URL='v.yinyuetai.com/video'; //����̨��Ƶ��ַ��
  VIDEO_INF_URL='http://ext.yinyuetai.com/main/get-h-mv-info?json=true&videoId='; //����̨��Ƶ��Ϣ��ַ
var
  jsonObject: TJSONObject; // JSON��
  i,j: Integer; // ѭ������
  temp,videoID,videoInfoUrl: string; // ��ʱʹ�ñ��� ,��ƵID����Ƶ��Ϣ��ַ
  jsonArray: TJSONArray; // JSON�������
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
  jsonObject: TJSONObject; // JSON��
  i,j,k: Integer; // ѭ������
  temp,videoUrl: string; // ��ʱʹ�ñ���
  jsonArray: TJSONArray; // JSON�������
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
//------------------------------------------�����߳���------------------------------------------
function ThreadProc(param: LPVOID): DWORD; stdcall;
var
  url,localfilename:string;
  ss:tstrings;
  i:integer;
begin
  url:=pchar(param);
  localfilename:=uDown.downloadfile(url); //������Ƶ��Ϣ�ļ���
  if(localfilename='')then exit;
  ss:=parseJsonFile(localfilename,videoInfo); //������Ƶ��Ϣ�ļ���
  if not assigned(ss) then exit;
  if(ss.count=0)then exit;
  PostMessage(mForm, WM_DOWN_FILE,2,ss.count);
  for i:=0 to ss.count-1  do begin
    uDown.downloadfile(ss[i]); //������Ƶ�ļ���
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