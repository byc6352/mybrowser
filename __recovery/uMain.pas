unit uMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ComCtrls, Vcl.OleCtrls, SHDocVw,urlmon,strutils,
  Vcl.ExtCtrls, Vcl.StdCtrls,uhookweb,activex,mshtml,uDown,uConfig, Vcl.Menus,shellapi;

type
  TfMain = class(TForm)
    Panel1: TPanel;
    Label1: TLabel;
    edturl: TEdit;
    btnBrowser: TButton;
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
    Web1: TWebBrowser;
    memCode: TMemo;
    Web2: TWebBrowser;
    btnClear: TButton;
    chkDownAll: TCheckBox;
    PopSelData: TPopupMenu;
    nOpenDir: TMenuItem;
    procedure FormShow(Sender: TObject);
    procedure btnBrowserClick(Sender: TObject);
    procedure Web1DocumentComplete(ASender: TObject; const pDisp: IDispatch;
      const URL: OleVariant);
    procedure Web1NavigateComplete2(ASender: TObject; const pDisp: IDispatch;
      const URL: OleVariant);
    procedure listDataSelectItem(Sender: TObject; Item: TListItem;
      Selected: Boolean);
    procedure Web2BeforeNavigate2(ASender: TObject; const pDisp: IDispatch;
      const URL, Flags, TargetFrameName, PostData, Headers: OleVariant;
      var Cancel: WordBool);
    procedure Web1NewWindow2(ASender: TObject; var ppDisp: IDispatch;
      var Cancel: WordBool);
    procedure Web1BeforeNavigate2(ASender: TObject; const pDisp: IDispatch;
      const URL, Flags, TargetFrameName, PostData, Headers: OleVariant;
      var Cancel: WordBool);
    procedure btnClearClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure nOpenDirClick(Sender: TObject);
  private
    { Private declarations }
    mData:TListItem;
    procedure httpMessage(var MSG:TMessage); message WM_CAP_WORK;
    procedure downMessage(var MSG:TMessage); message WM_DOWN_FILE;
    procedure getResource();
    function findResource(url:string):boolean;
  public
    { Public declarations }
  end;

var
  fMain: TfMain;



implementation

{$R *.dfm}
function TfMain.findResource(url:string):boolean;
const
  mp4='.mp4';
  swf='.swf';
  fla='.fla';
begin
  result:=true;
  if pos(mp4,url)>0 then exit;
  if pos(swf,url)>0 then exit;
  if pos(fla,url)>0 then exit;
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
    url:=listdata.Items.Item[i].SubItems[1];
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
function getDataTimeString():string;
var
  s:string;
begin
  result:=FormatDateTime('yyyy-mm-dd hh:nn:ss',now());
end;
procedure TfMain.downMessage(var msg:TMessage);
var
  i,j:integer;
begin
  i:=msg.LParam;
  j:=msg.WParam;
  if j=1 then
    bar1.Panels[1].Text:='下载完毕！'
  else
    bar1.Panels[1].Text:='已下载：'+inttostr(i)+'['+uDown.mdowns[i]+']';
end;
procedure TfMain.httpMessage(var msg:TMessage);
var
  len,flag:integer;

begin
  len:=msg.LParam;
  flag:=msg.WParam;
  case flag of
  IDX_HttpOpenRequestW:begin
      mData:=listData.Items.Add;
      mData.Caption:=getDataTimeString();
      mData.SubItems.Add(gverb);
      mData.SubItems.Add(gurl);
      mData.SubItems.Add('');
      mData.SubItems.Add('');
      mData.SubItems.Add('');
      mData.SubItems.Add('');
      mData.SubItems.Add('');
      if(chkDownAll.Checked)then uDown.addUrl(gurl);
    end;
  IDX_HttpSendRequestW:begin
      //fmain.MemoInfo.Lines.Add(gData);
       mData.SubItems[3]:=gqHeaders;
    end;
  IDX_HttpSendRequestExW:begin

    end;
  IDX_HttpAddRequestHeadersW:begin  //
      mData.SubItems[3]:=gQHeaders;
      //fmain.MemoInfo.Lines.Add(gHeaders);
    end;
  IDX_InternetWriteFile:begin
     mData.SubItems[5]:=uHookweb.s;
     memoinfo.Lines.Add(uHookweb.s);
  end;
  IDX_InternetReadFile:begin  //
      //mData:=listData.Items.Add;
      //mData.Caption:=getDataTimeString();
      //mData.SubItems.Add(gverb);
      //mData.SubItems.Add(gurl);
      //mData.SubItems.Add(gHeaders);
      //mData.SubItems.Add(grHeaders);
      //mData.SubItems.Add(gQdata);
      //mData.SubItems.Add(gRdata);
      //mData.SubItems[5]:=gRdata;
      mData.SubItems[6]:=uHookweb.s;
      memoinfo.Lines.Add(uHookweb.s);
    end;
  IDX_HttpQueryInfoW:begin  //IDX_InternetReadFile
     //if(len=1)then mData.SubItems[3]:=gqHeaders else
     //if(len=0)then mData.SubItems[4]:=grHeaders else
     //if(len=2)then mData.SubItems[2]:=gLength;
     mData.SubItems[3]:=gqHeaders;
     mData.SubItems[4]:=grHeaders;
     mData.SubItems[2]:=gLength;
    end;
  end;

end;
procedure TfMain.listDataSelectItem(Sender: TObject; Item: TListItem;
  Selected: Boolean);
begin
  memData.Clear;
  memData.Lines.Add('-------------request target ---------------');
  memData.Lines.Add(item.SubItems[1]);
  memData.Lines.Add('');
  memData.Lines.Add('');
  memData.Lines.Add('-------------request length---------------');
  memData.Lines.Add(item.SubItems[2]);
  memData.Lines.Add('');
  memData.Lines.Add('');
  memData.Lines.Add('-------------request headers---------------');
  memData.Lines.Add(item.SubItems[3]);
  memData.Lines.Add('------------response headers---------------');
  memData.Lines.Add(item.SubItems[4]);
  memData.Lines.Add('-------------request data------------------');
  memData.Lines.Add(item.SubItems[5]);
  memData.Lines.Add('-------------response data-----------------');
  memData.Lines.Add(item.SubItems[6]);
end;

procedure TfMain.nOpenDirClick(Sender: TObject);
var
  url,localdir:string;
begin
  url:=listdata.Selected.SubItems[1];
  if pos(mSite,url)<=0 then url:=mSite+url;
  localdir:=uDown.url2file(url);
  localdir:=extractfiledir(localdir);
  ShellExecute(Handle,'open','Explorer.exe',pchar(localdir),nil,1);
end;

procedure TfMain.btnBrowserClick(Sender: TObject);
begin
  web1.Navigate(trim(edtUrl.Text));
end;

procedure TfMain.btnClearClick(Sender: TObject);
begin
  if MessageBox(0, '即将清空所有数据，请确认!', '警告', MB_OKCANCEL + MB_ICONWARNING) = ID_OK then  begin  //   MB_ICONQUESTION
    listData.Clear;
    bar1.Panels[0].Text:='数据已经清空！';
  end;
end;

procedure TfMain.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  uDown.stop;
end;

procedure TfMain.FormShow(Sender: TObject);
begin
  uhookweb.hForm:=fmain.Handle; //
  uDown.start(uConfig.workdir,fmain.Handle);
  TWinControl(Web2).Visible:=False;
end;

procedure TfMain.Web1BeforeNavigate2(ASender: TObject; const pDisp: IDispatch;
  const URL, Flags, TargetFrameName, PostData, Headers: OleVariant;
  var Cancel: WordBool);
begin
  uDown.pause();
  bar1.Panels[0].Text:='正在加载页面...';
end;

procedure TfMain.Web1DocumentComplete(ASender: TObject; const pDisp: IDispatch;
  const URL: OleVariant);
var
  doc:IHTMLDocument2;
begin
  if not assigned(web1.Document) then exit;
  if(web1.Busy)then exit;

  doc:=web1.Document as IHTMLDocument2;
  getPageCode(doc,memcode.Lines);
  //doc.designMode:='On';
  mPage:=doc.url;
  mPort:=getPort(mPage);
  msite:=doc.domain;
  mProtocol:=doc.protocol;
  if(mProtocol='HyperText Transfer Protocol with Privacy')then mProtocol:='https://' else mProtocol:='http://';

  if(chkDownAll.Checked)then begin
    uDown.setHost(mprotocol,msite);
    uDown.addUrl(mPage);
    uDown.start();
  end;
  getResource();
  bar1.Panels[0].Text:='页面加载完毕！共有：'+inttostr(listdata.Items.Count)+'项！';
end;

procedure TfMain.Web1NavigateComplete2(ASender: TObject; const pDisp: IDispatch;
  const URL: OleVariant);
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