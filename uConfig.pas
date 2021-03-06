unit uConfig;

interface
uses
  windows,sysutils;
const
  APP_NAME='我的浏览器';
  APP_VERSION='1.00';
  DEBUG=true;
  DB_NAME:string='web.mdb';
  WORK_DIR='web';
  WEB_CACHE='cache';
  LOG_NAME:string='webLog.txt';
  YINYUETAI_DIR='yinyuetai';
var
  workdir,yinyuetaiDir,webCache:string;
  dbfile,dbConn,logfile:string;// 数据库子目录,数据库
  isInit:boolean=false;
procedure init();
implementation
procedure init();
var
  me:string;
begin
  //me:=application.ExeName;
  isInit:=true;
  me:=ParamStr(0);
  workdir:=extractfilepath(me)+WORK_DIR;
  if(not directoryexists(workdir))then forcedirectories(workdir);
  webCache:=workdir+'\'+WEB_CACHE;
  if(not directoryexists(webCache))then forcedirectories(webCache);
  yinyuetaiDir:=workdir+'\'+YINYUETAI_DIR;
  if(not directoryexists(yinyuetaiDir))then forcedirectories(yinyuetaiDir);
  logfile:=workdir+'\'+LOG_NAME;
  dbfile:=workdir+'\'+DB_NAME;

  //D:\works\delphi\authserver\Win32\Debug\database\author.mdb
  dbConn := 'Provider = MicroSoft.jet.OLEDB.4.0;'+
                       'Persist Security Info = False;'+
                       'Data Source='+dbfile+';'+//数据库本地目录
                       'Mode = ReadWrite;'+
                       'Jet OLEDB:Database Password="";'// 加入密码

end;
initialization
  init();
finalization

{
     //dbConn:='Provider=Microsoft.Jet.OLEDB.4.0;Password="";User ID=Admin;Data Source='+dbfile+
   // ';Mode=Share Deny None;Extended Properties="";Jet OLEDB:System database="";Jet OLEDB:Registry Path="";Jet OLEDB:Database Password="";'+
   // 'Jet OLEDB:Engine Type=5;Jet OLEDB:Database Locking Mode=1;Jet OLEDB:Global Partial Bulk Ops=2;Jet OLEDB:Global Bulk Transactions=1;'+
   // 'Jet OLEDB:New Database Password="";Jet OLEDB:Create System Database=False;Jet OLEDB:Encrypt Database=False;Jet OLEDB:Jet OLEDB:Compact Without Replica Repair=False;Jet OLEDB:SFP=False';
}
end.
