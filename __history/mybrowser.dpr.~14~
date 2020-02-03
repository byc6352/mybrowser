program mybrowser;

uses
  Vcl.Forms,
  uMain in 'uMain.pas' {fMain},
  uHookWeb in 'uHookWeb.pas',
  uFuncs in 'uFuncs.pas',
  uDown in 'uDown.pas',
  uConfig in 'uConfig.pas',
  uCoding in 'uCoding.pas',
  uData in 'uData.pas',
  uDatabase in 'uDatabase.pas',
  uDM in 'uDM.pas' {dm: TDataModule},
  uYinyuetai in 'uYinyuetai.pas',
  uDataDown in 'uDataDown.pas',
  uSocketDown in 'uSocketDown.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfMain, fMain);
  Application.CreateForm(Tdm, dm);
  Application.Run;
end.
