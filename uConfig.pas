unit uConfig;

interface
uses
  windows,sysutils;
var
  workdir:string;
procedure init();
implementation
procedure init();
var
  me:string;
begin
  //me:=application.ExeName;
  me:=ParamStr(0);
  workdir:=extractfilepath(me)+'web';
  if(not directoryexists(workdir))then forcedirectories(workdir);
end;
initialization
  init();
finalization

end.
