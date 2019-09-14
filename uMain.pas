unit uMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ComCtrls, Vcl.OleCtrls, SHDocVw,urlmon,strutils,
  Vcl.ExtCtrls, Vcl.StdCtrls,uhookweb,activex,mshtml,uDown,uConfig, Vcl.Menus,shellapi,uData,
  Vcl.Buttons,uFuncs,uDM, Data.DB, Vcl.Grids, Vcl.DBGrids, SHDocVw_EWB, EwbCore,
  EmbeddedWB;

type
  TfMain = class(TForm)
    Panel1: TPanel;
    Bar1: TStatusBar;
    Page1: TPageControl;
    tsData: TTabSheet;
    tsInfo: TTabSheet;
    memData: TMemo;
    MemoInfo: TMemo;
    Panel2: TPanel;
    Splitter1: TSplitter;
    listData: TListView;
    Splitter2: TSplitter;
    Page2: TPageControl;
    tsweb: TTabSheet;
    tscode: TTabSheet;
    Web1: TEmbeddedWB;
    memCode: TMemo;
    Web2: TWebBrowser;
    btnClear: TButton;
    chkDownAll: TCheckBox;
    PopSelData: TPopupMenu;
    nOpenDir: TMenuItem;
    btnBack: TBitBtn;
    btnForward: TBitBtn;
    btnBrush: TBitBtn;
    nOpenRequestData: TMenuItem;
    n1: TMenuItem;
    nOpenResponseData: TMenuItem;
    Timer1: TTimer;
    tsRecord: TTabSheet;
    DBGrid1: TDBGrid;
    DBGrid2: TDBGrid;
    Splitter3: TSplitter;
    cmbUrl: TComboBox;
    procedure FormShow(Sender: TObject);

    procedure listDataSelectItem(Sender: TObject; Item: TListItem;
      Selected: Boolean);
    procedure Web2BeforeNavigate2(ASender: TObject; const pDisp: IDispatch;
      const URL, Flags, TargetFrameName, PostData, Headers: OleVariant;
      var Cancel: WordBool);
    procedure Web1NewWindow2(ASender: TObject; var ppDisp: IDispatch;
      var Cancel: WordBool);

    procedure btnClearClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure nOpenDirClick(Sender: TObject);
    procedure btnBrushClick(Sender: TObject);
    procedure btnBackClick(Sender: TObject);
    procedure btnForwardClick(Sender: TObject);
    procedure nOpenRequestDataClick(Sender: TObject);
    procedure nOpenResponseDataClick(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure DBGrid2CellClick(Column: TColumn);
    procedure FormCreate(Sender: TObject);
    procedure cmbUrlChange(Sender: TObject);
    procedure Web1BeforeNavigate2(ASender: TObject; const pDisp: IDispatch;
      var URL, Flags, TargetFrameName, PostData, Headers: OleVariant;
      var Cancel: WordBool);
    procedure Web1DocumentComplete(ASender: TObject; const pDisp: IDispatch;
      var URL: OleVariant);
    procedure Web1NavigateComplete2(ASender: TObject; const pDisp: IDispatch;
      var URL: OleVariant);
  private
    { Private declarations }
    bProcessData,bDocumentComplete:boolean;
    mPage,mPageIdx,mSite,mProtocol,mPort,mWorkDir:string;//主页URL ，站点URL, 协议(http://,https://),工作目录
    procedure httpMessage(var MSG:TMessage); message WM_CAP_WORK;
    procedure downMessage(var MSG:TMessage); message WM_DOWN_FILE;
    procedure getResource();
    function findResource(url:string):boolean;
    procedure getDataToShow();

  public
    { Public declarations }
  end;

var
  fMain: TfMain;
  function MergeUrl(ServerName,ObjectName:string;ServerPort:DWORD):string;//组合url

implementation

{$R *.dfm}
uses
  uYinyuetai;

function MergeUrl(ServerName,ObjectName:string;ServerPort:DWORD):string;//组合url
var
  protocol:string;
begin
  case ServerPort of
  80:begin
    protocol:='http';
    result:=protocol+'://'+ServerName+ObjectName;
  end;
  443:begin
    protocol:='https';
    result:=protocol+'://'+ServerName+ObjectName;
  end;
  else begin
    protocol:='http';
    result:=protocol+'://'+ServerName+':'+inttostr(ServerPort)+ObjectName;
  end;
  end;
end;
procedure TfMain.getDataToShow();
var
  data:TListItem;
  i,j:integer;
  pageID,url,ObjectName,verb,len,qHeader,rHeader,qData,rData,ServerName:string;
  ServerPort:DWORD;
  dtGet:tdatetime;
begin
  if(bProcessData)then exit;
  while listData.Items.Count<uData.iData do
  begin
    bProcessData:=true;
    i:=listData.Items.Count;
    pageID:=mPageIdx;
    dtGet:=uData.datas[i].dt;
    verb:=uData.datas[i].verb;
    ObjectName:=uData.datas[i].ObjectName;
    len:=uData.datas[i].len;
    qHeader:=uData.datas[i].qHeader;
    rHeader:=uData.datas[i].rHeader;
    qData:=uData.datas[i].qData;
    rData:=uData.datas[i].rData;
    ServerName:=uData.datas[i].ServerName;
    ServerPort:=uData.datas[i].ServerPort;

    data:=listData.Items.Add;
    data.Caption:=ufuncs.getDataTimeString(dtGet);
    data.SubItems.Add(ServerName);
    data.SubItems.Add(inttostr(ServerPort));
    data.SubItems.Add(verb);
    data.SubItems.Add(ObjectName);
    data.SubItems.Add(len);
    data.SubItems.Add(qHeader);
    data.SubItems.Add(rHeader);
    data.SubItems.Add(qData);
    data.SubItems.Add(rData);
    if(chkDownAll.Checked)then begin
      url:=MergeUrl(Servername,ObjectName,Serverport);
      uDown.addUrl(url);
      dm.addPageDetail(pageID,servername,inttostr(ServerPort),ObjectName,verb,len,qHeader,rHeader,qData,rData,dtGet);
      if(findResource(ObjectName))then memoinfo.Lines.Add(url);
    end;
    //application.ProcessMessages;
  end;
  bProcessData:=false;
end;
function TfMain.findResource(url:string):boolean;
const
  mp4='.mp4';
  swf='.swf';
  fla='.fla';
  mvi='get-h-mv-info';
begin
  result:=true;
  if pos(mp4,url)>0 then exit;
  if pos(swf,url)>0 then exit;
  if pos(fla,url)>0 then exit;
  if pos(mvi,url)>0 then exit;
  result:=false;
end;
procedure TfMain.getResource();
var
  i:integer;
  url:string;
  ss:tstrings;
begin
  if(listdata.Items.Count=0)then exit;
  ss:=tstringlist.Create;
  for i:=0 to listdata.Items.Count-1 do begin
    url:=listdata.Items.Item[i].SubItems[3];
    if(findResource(url))then ss.Add(url);
  end;
  if(ss.Count>0)then memoinfo.Lines.AddStrings(ss);
  ss.Free;
end;
function getPageCode(doc:IHTMLDocument2;ss:tstrings):tstrings;//返回页面源代码
var
  ms: TMemoryStream;
begin
  if not assigned(ss) then ss:=tstringlist.Create;

  ms := TMemoryStream.Create;
 (doc as IPersistStreamInit).Save(TStreamAdapter.Create(ms), True);
  ms.Position := 0;
  ss.LoadFromStream(ms,TEncoding.UTF8);
  ms.Free;
  result:=ss;
end;

procedure TfMain.downMessage(var msg:TMessage);
var
  i,j:integer;
begin
  i:=msg.LParam;
  j:=msg.WParam;
  if j=1 then
    bar1.Panels[1].Text:='下载完毕！'
  else if j=0 then
    bar1.Panels[1].Text:='已下载：'+inttostr(i)+'['+uDown.mdowns[i]+']'
  else if j=2 then begin
    memoInfo.lines.add(uYinyuetai.videoInfo);
  end;
end;
procedure TfMain.httpMessage(var msg:TMessage);
var
  len,flag:integer;

begin
  len:=msg.LParam;
  flag:=msg.WParam;
end;
procedure TfMain.listDataSelectItem(Sender: TObject; Item: TListItem;
  Selected: Boolean);
begin
  memData.Clear;
  memData.Lines.Add('-------------request target ---------------');
  memData.Lines.Add(item.SubItems[3]);
  memData.Lines.Add('');
  memData.Lines.Add('');
  memData.Lines.Add('-------------request length---------------');
  memData.Lines.Add(item.SubItems[4]);
  memData.Lines.Add('');
  memData.Lines.Add('');
  memData.Lines.Add('-------------request headers---------------');
  memData.Lines.Add(item.SubItems[5]);
  memData.Lines.Add('------------response headers---------------');
  memData.Lines.Add(item.SubItems[6]);
  memData.Lines.Add('-------------request data------------------');
  memData.Lines.Add(item.SubItems[7]);
  memData.Lines.Add('-------------response data-----------------');
  memData.Lines.Add(item.SubItems[8]);
end;

procedure TfMain.nOpenDirClick(Sender: TObject);
var
  url,localdir,objectName,serverName:string;
begin
  objectName:=listdata.Selected.SubItems[3];
  serverName:=listdata.Selected.SubItems[0];
  if pos(serverName,objectName)<=0 then url:=serverName+objectName;
  localdir:=uDown.url2file(url);
  localdir:=extractfiledir(localdir);
  ShellExecute(Handle,'open','Explorer.exe',pchar(localdir),nil,1);
end;

procedure TfMain.nOpenRequestDataClick(Sender: TObject);
var
  data,localdir:string;
begin
  data:=listdata.Selected.SubItems[7];
  if(data='')then exit;
  ShellExecute(Handle,'open','notepad.exe',pchar(data),nil,1);

end;

procedure TfMain.nOpenResponseDataClick(Sender: TObject);
var
  data,localdir:string;
begin
  data:=listdata.Selected.SubItems[8];
  if(data='')then exit;
  ShellExecute(Handle,'open','notepad.exe',pchar(data),nil,1);

end;

procedure TfMain.Timer1Timer(Sender: TObject);
begin
  getDataToShow();
end;

procedure TfMain.btnBackClick(Sender: TObject);
begin
  page2.ActivePageIndex:=0;
  web1.GoBack;
end;

procedure TfMain.btnBrushClick(Sender: TObject);
begin
  page2.ActivePageIndex:=0;
  //web1.Navigate(trim(cmburl.Items[cmburl.ItemIndex]));
  web1.Navigate(trim(cmburl.Text));
  btnBack.Enabled:=true;
  btnForward.Enabled:=true;
end;

procedure TfMain.btnClearClick(Sender: TObject);
begin
  if MessageBox(0, '即将清空所有数据，请确认!', '警告', MB_OKCANCEL + MB_ICONWARNING) = ID_OK then  begin  //   MB_ICONQUESTION
    listData.Clear;
    memData.Lines.Clear;
    uDown.clear();
    uData.clear;
    bar1.Panels[0].Text:='数据已经清空！';
  end;
end;

procedure TfMain.btnForwardClick(Sender: TObject);
begin
  page2.ActivePageIndex:=0;
  web1.GoForward;
end;

procedure TfMain.cmbUrlChange(Sender: TObject);
begin
  web1.Navigate(trim(cmburl.Items[cmburl.ItemIndex]));
end;

procedure TfMain.DBGrid2CellClick(Column: TColumn);
begin
  memData.Clear;
  memData.Lines.Add('-------------server ---------------------');
  memData.Lines.Add(dm.tPageDetail.FieldByName('server_name').AsString);
  memData.Lines.Add(dm.tPageDetail.FieldByName('server_port').AsString);
  memData.Lines.Add('');
  memData.Lines.Add('');
  memData.Lines.Add('-------------request target ---------------');
  memData.Lines.Add(dm.tPageDetail.FieldByName('object_name').AsString);
  memData.Lines.Add('');
  memData.Lines.Add('');
  memData.Lines.Add('-------------request length---------------');
  memData.Lines.Add(dm.tPageDetail.FieldByName('data_len').AsString);
  memData.Lines.Add('');
  memData.Lines.Add('');
  memData.Lines.Add('-------------request headers---------------');
  memData.Lines.Add(dm.tPageDetail.FieldByName('request_header').AsString);
  memData.Lines.Add('------------response headers---------------');
  memData.Lines.Add(dm.tPageDetail.FieldByName('response_header').AsString);
  memData.Lines.Add('-------------request data------------------');
  memData.Lines.Add(dm.tPageDetail.FieldByName('request_data').AsString);
  memData.Lines.Add('-------------response data-----------------');
  memData.Lines.Add(dm.tPageDetail.FieldByName('response_data').AsString);
  //memoinfo.Lines.Add(dm.tPageDetail.FieldByName('request_header').AsString);
end;

procedure TfMain.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  uDown.stop;
end;

procedure TfMain.FormCreate(Sender: TObject);
begin

  Set8087CW(Longword($133f));
  IEEmulator(11001);
  //IEEmulator();
end;

procedure TfMain.FormShow(Sender: TObject);
begin
  //uhookweb.hForm:=fmain.Handle; //
  cmburl.ItemIndex:=0;
  timer1.Enabled:=false;
  uDown.start(uConfig.workdir,fmain.Handle);
  TWinControl(Web2).Visible:=False;
  fmain.Caption:=APP_NAME+'v'+APP_VERSION;

end;



procedure TfMain.Web1BeforeNavigate2(ASender: TObject; const pDisp: IDispatch;
  var URL, Flags, TargetFrameName, PostData, Headers: OleVariant;
  var Cancel: WordBool);
begin
  uDown.pause();
  uHookweb.state:=STAT_BROWSING;
  timer1.Enabled:=false;
  bar1.Panels[0].Text:='正在加载页面...';
end;

procedure TfMain.Web1DocumentComplete(ASender: TObject; const pDisp: IDispatch;
  var URL: OleVariant);
var
  doc:IHTMLDocument2;
begin
  if(Web1.ReadyState<>READYSTATE_COMPLETE)then exit;
  if(uHookweb.state=STAT_IDLE)then exit;
  //if not assigned(web1.Document) then exit;
  //if(web1.Busy)then exit;

  doc:=web1.Document as IHTMLDocument2;
  getPageCode(doc,memcode.Lines);
  //doc.designMode:='On';
  mPage:=doc.url;
  mPort:=getPort(mPage);

  msite:=doc.domain;
  mProtocol:=doc.protocol;
  if(mProtocol='HyperText Transfer Protocol with Privacy')then mProtocol:='https' else mProtocol:='http';

  cmburl.Text:=mpage;
  fmain.Caption:=APP_NAME+'v'+APP_VERSION+'('+mpage+')';
  uHookweb.state:=STAT_IDLE;
  bar1.Panels[0].Text:='页面加载完毕！';


  if(chkDownAll.Checked)then begin
    uDown.addUrl(mPage);
    uDown.start();
    mpageIdx:=dm.addPageInfo(mProtocol,msite,mPort,mpage);
    timer1.Enabled:=true;
  end;
  yinyuetai(mPage);
end;

procedure TfMain.Web1NavigateComplete2(ASender: TObject; const pDisp: IDispatch;
  var URL: OleVariant);
begin
 web1.Silent:=true;
end;

procedure TfMain.Web1NewWindow2(ASender: TObject; var ppDisp: IDispatch;
  var Cancel: WordBool);
begin
ppDisp := web2.Application; // 新的窗口先指向WebBrowser2
end;

procedure TfMain.Web2BeforeNavigate2(ASender: TObject; const pDisp: IDispatch;
  const URL, Flags, TargetFrameName, PostData, Headers: OleVariant;
  var Cancel: WordBool);
begin
  web1.Navigate(string(URL)); // 再指回WebBrowser1
  Cancel := True;
end;



//----------------------------------------------函数区---------------------------------------




//-------------------------------------------------------------------------------------------

initialization
  OleInitialize(nil);
finalization
  OleUninitialize;
end.
