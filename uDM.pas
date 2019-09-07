unit uDM;

interface

uses
  System.SysUtils, System.Classes, Data.DB, Data.Win.ADODB,uConfig,uLog;

type
  Tdm = class(TDataModule)
    dsPage: TDataSource;
    conn: TADOConnection;
    Q1: TADOQuery;
    tPage: TADOTable;
    tPageDetail: TADOTable;
    dsDetail: TDataSource;
    procedure DataModuleCreate(Sender: TObject);
  private
    { Private declarations }

  public
    { Public declarations }
    function getLastPageID():string;
    function InsertPageInfo(protocol,domain,port,url:string):string;
    function InsertPageDetail(pageID,dt,url,verb,len,qHeader,rHeader,qData,rData:string):string;
    //插入主页信息详细信息：
    function addPageDetail(pageID,dt,url,verb,len,qHeader,rHeader,qData,rData:string):string;
  end;

var
  dm: Tdm;

implementation

{%CLASSGROUP 'Vcl.Controls.TControl'}

{$R *.dfm}
//插入主页信息详细信息：
function TDM.addPageDetail(pageID,dt,url,verb,len,qHeader,rHeader,qData,rData:string):string;
begin
  if(dm.tPageDetail.Active=false)then begin
    dm.tPage.Open;
   dm.tPageDetail.Open;
  end;
  dm.tPageDetail.Append;
  tPageDetail.fieldbyname('page_ID').AsInteger:=strtoint(pageID);
  tPageDetail.fieldbyname('get_time').AsDateTime:=strtodatetime(dt);
  tPageDetail.fieldbyname('target_url').AsString:=url;
  tPageDetail.fieldbyname('op_verb').AsString:=verb;
  tPageDetail.fieldbyname('data_len').AsString:=len;
  tPageDetail.fieldbyname('request_header').AsString:=qHeader;
  tPageDetail.fieldbyname('response_header').AsString:=rHeader;
  tPageDetail.fieldbyname('request_data').AsString:=qData;
  tPageDetail.fieldbyname('response_data').AsString:=rData;
  //Tblobfield(tPageDetail.fieldByName('ExexSql')).as
  tPageDetail.Post;
end;
//插入主页信息详细信息：
function TDM.InsertPageDetail(pageID,dt,url,verb,len,qHeader,rHeader,qData,rData:string):string;
var
  sql:string;
  test1,test2:string;
begin
  result:='';
  Q1.Close;
  test1:='aaa';
  test2:='bbbb';
  sql:='insert into page_detail (page_ID,get_time,target_url,op_verb,data_len,request_header,response_header,request_data,response_data) values ('+pageID+',"'+dt+'","'+url+'","'+verb+'","'+len+'",:request_header,:response_header,"'+qData+'","'+rData+'")';
  Q1.Parameters.CreateParameter('request_header',ftMemo,pdinput,length(qHeader),qHeader);
  Q1.Parameters.CreateParameter('response_header',ftMemo,pdinput,length(rHeader),rHeader);
  //Q1.Parameters.ParamByName('request_header').Value:=qHeader;
  //Q1.Parameters.ParamByName('response_header').Value:=rHeader;
  uLog.Log(sql);
  Q1.SQL.Text:=sql;
  Q1.ExecSQL;
  result:='';
  Q1.Close;
end;
//插入主页信息,,返回主页信息ID：
function TDM.InsertPageInfo(protocol,domain,port,url:string):string;
var
  sql:string;
begin
  result:='';
  Q1.Close;
  sql:='insert into web_page (page_protocol,page_domain,page_port,page_url) values ("'+protocol+'","'+domain+'","'+port+'","'+url+'")';
  uLog.Log(sql);
  Q1.SQL.Text:=sql;
  Q1.ExecSQL;
  result:=getLastPageID;
  Q1.Close;
end;
//查询pageID：
function TDM.getLastPageID():string;
var
  sql:string;
begin
  result:='';
  Q1.Close;
  sql:='select max(ID) from web_page';
  Q1.SQL.Text:=sql;
  Q1.Open;
  if(Q1.RecordCount>0)then begin
    result:=Q1.Fields[0].asString;
  end else begin
    result:='0';
  end;
  Q1.Close;
end;

procedure Tdm.DataModuleCreate(Sender: TObject);
begin
  conn.Connected:=false;
  conn.ConnectionString:=uConfig.dbconn;
  conn.Connected:=true;

end;
{
//插入主页信息详细信息：
function TDM.InsertPageDetail(pageID,dt,url,verb,len,qHeader,rHeader,qData,rData:string):string;
var
  sql:string;
begin
  result:='';
  Q1.Close;
  sql:='insert into page_detail (page_ID,get_time,target_url,op_verb,data_len,request_header,response_header,request_data,response_data) values ('+pageID+',"'+dt+'","'+url+'","'+verb+'","'+len+'","'+qHeader+'","'+rHeader+'","'+qData+'","'+rData+'")';
  uLog.Log(sql);
  Q1.SQL.Text:=sql;
  Q1.ExecSQL;
  result:='';
  Q1.Close;
end;

}

end.
