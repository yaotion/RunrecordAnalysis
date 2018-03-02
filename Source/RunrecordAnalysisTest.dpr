program RunrecordAnalysisTest;
uses
  ShareMem,
  Forms,
  uFrmTest in 'uFrmTest.pas' {frmTest},
  uVSCombExpress in '表达式规则\uVSCombExpress.pas',
  uVSLog in '表达式规则\uVSLog.pas',
  uVSSimpleExpress in '表达式规则\uVSSimpleExpress.pas',
  uVSRules in '表达式规则\uVSRules.pas',
  uVSLib in '表达式规则\uVSLib.pas',
  uLKJRuntimeFile in '定义\uLKJRuntimeFile.pas',
  uVSAnalysisResultList in '定义\uVSAnalysisResultList.pas',
  uVSConst in '定义\uVSConst.pas',
  uRtAdoFileReader in '运行记录读取\uRtAdoFileReader.pas',
  uVSRuleReader in '表达式规则\uVSRuleReader.pas',
  uRtfmtFileReader in '运行记录读取\uRtfmtFileReader.pas',
  uRtOrgFileReader in '运行记录读取\uRtOrgFileReader.pas',
  uConvertDefine in '运行记录读取\uConvertDefine.pas',
  uRtHeadInfoReader in '运行记录读取\uRtHeadInfoReader.pas',
  uRtFileReaderBase in '运行记录读取\uRtFileReaderBase.pas',
  uXMLlkjFileReader in '运行记录读取\uXMLlkjFileReader.pas';

{$R *.res}

begin
  ReportMemoryLeaksOnShutdown := True;
  Application.Initialize;
  Application.CreateForm(TfrmTest, frmTest);
  Application.Run;
end.
