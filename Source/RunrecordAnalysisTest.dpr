program RunrecordAnalysisTest;
uses
  ShareMem,
  Forms,
  uFrmTest in 'uFrmTest.pas' {frmTest},
  uVSCombExpress in '���ʽ����\uVSCombExpress.pas',
  uVSLog in '���ʽ����\uVSLog.pas',
  uVSSimpleExpress in '���ʽ����\uVSSimpleExpress.pas',
  uVSRules in '���ʽ����\uVSRules.pas',
  uVSLib in '���ʽ����\uVSLib.pas',
  uLKJRuntimeFile in '����\uLKJRuntimeFile.pas',
  uVSAnalysisResultList in '����\uVSAnalysisResultList.pas',
  uVSConst in '����\uVSConst.pas',
  uRtAdoFileReader in '���м�¼��ȡ\uRtAdoFileReader.pas',
  uVSRuleReader in '���ʽ����\uVSRuleReader.pas',
  uRtfmtFileReader in '���м�¼��ȡ\uRtfmtFileReader.pas',
  uRtOrgFileReader in '���м�¼��ȡ\uRtOrgFileReader.pas',
  uConvertDefine in '���м�¼��ȡ\uConvertDefine.pas',
  uRtHeadInfoReader in '���м�¼��ȡ\uRtHeadInfoReader.pas',
  uRtFileReaderBase in '���м�¼��ȡ\uRtFileReaderBase.pas',
  uXMLlkjFileReader in '���м�¼��ȡ\uXMLlkjFileReader.pas';

{$R *.res}

begin
  ReportMemoryLeaksOnShutdown := True;
  Application.Initialize;
  Application.CreateForm(TfrmTest, frmTest);
  Application.Run;
end.
