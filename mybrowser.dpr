program mybrowser;

uses
  Vcl.Forms,
  uMain in 'uMain.pas' {fMain},
  uHookWeb in 'uHookWeb.pas',
  uFuncs in 'uFuncs.pas',
  uDown in 'uDown.pas',
  uConfig in 'uConfig.pas',
  uCoding in 'uCoding.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfMain, fMain);
  Application.Run;
end.
