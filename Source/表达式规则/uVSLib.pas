////////////////////////////////////////////////////////////////////////////////
//Υ������߼���Ԫ
////////////////////////////////////////////////////////////////////////////////
unit uVSLib;

interface

uses
  Classes, Contnrs, uVSConst, uVSRules, uVSAnalysisResultList, uLKJRuntimeFile,
  uRtfmtFileReader;
type
  ////////////////////////////////////////////////////////////////////////////////
  //Υ�������
  ////////////////////////////////////////////////////////////////////////////////
  TLKJAnalysis = class
  public
    constructor Create();
    destructor Destroy; override;
  public
    //�������м�¼
    procedure DoAnalysis(LKJFile: TLKJRuntimeFile; var EventArray: TLKJEventList);
    //��ȡ��ҵʱ��
    procedure GetOperationTime(RuntimeFiles: TStrings; out OperationTime: ROperationTime; RuleXMLFile: string);
  private
    //�����б�
    m_Rules: TObjectList;
  protected
    //����ID��ȡ����
    function GetRuleByID(RuleID: string): TVSRule;
  public
    //�����б�
    property Rules: TObjectList read m_Rules;
  end;

implementation
uses
  SysUtils, DateUtils,
  uVSLog, uVSSimpleExpress, uVSCombExpress, uVSRuleReader;

procedure TLKJAnalysis.DoAnalysis(LKJFile: TLKJRuntimeFile;
  var EventArray: TLKJEventList);
var
  i, j: Integer;
  matchRlt: TVSCState;
  vsRule: TVSRule;
  rltData: TLKJEventDetail;
begin
  //�����һ�εķ������
  VSLog := TVSXMLLog.Create;
  try
    vslOG.OpenLog := false;
    for j := 0 to EventArray.Count - 1 do
    begin
      vsRule := GetRuleByID(EventArray.Items[j].strEventID);
      if vsRule = nil then continue;

      VSLog.AddRule(vsRule.Title);
      vsRule.BeforeSeconds := EventArray[j].nBeforeSeconds;
      vsRule.AfterSeconds := EventArray[j].nAfterSeconds;
      if vsRule = nil then continue;

      vsRule.Init;
{$REGION '���ָ�������Ƿ��ʺϸ����м�¼�ļ�'}
      if not vsRule.Check(LKJFile.HeadInfo, LKJFile.Records) then
      begin
        if vsRule.HeadExpression <> nil then
          vsRule.HeadExpression.Init;
        continue;
      end;
{$ENDREGION '���ָ�������Ƿ��ʺϸ����м�¼�ļ�'}
      matchRlt := vscUnMatch;
            //ѭ�����м�¼
      for i := 0 to LKJFile.Records.Count - 1 do
      begin
{$REGION '�ȶԼ�¼������ȶԽ��Ϊ�����򱣴沶������'}
        try
          matchRlt := vsRule.MatchLKJRec(LKJFile.HeadInfo, TLKJRuntimeFileRec(LKJFile.Records[i]), LKJFile.Records);
        except
          continue;
        end;

        if vscMatched = matchRlt then
        begin
          rltData := vsRule.GetCaptureRange;
          if rltData = nil then continue;
              //�����򲶻�Ϊ����ʱ���˳�ѭ��
              //((�м�¼Υ�� (IsVs=False)���޼�¼Υ�� (IsVs=True)))
          if not vsRule.IsVS then break;
          EventArray[j].DetailList.Add(rltData);
          vsRule.Reset;
        end;
{$ENDREGION '�ȶԼ�¼������ȶԽ��Ϊ�����򱣴沶������'}
      end;
{$REGION '�����ǰ��¼Ϊ����һ����¼�����жϽ���Ƿ�Ϊ������'}
            //�ȶ����һ����¼��״̬Ϊ�ʺϵ�������Ϊƥ��
      if (vscMatching = matchRlt) and (vsRule.IsVS) then
      begin
        rltData := vsRule.GetCaptureRange;
        EventArray[j].DetailList.Add(rltData);
        vsRule.Reset;
      end;
    end;

  finally
    VSLog.Free;
  end;
end;

procedure TLKJAnalysis.GetOperationTime(RuntimeFiles: TStrings;
  out OperationTime: ROperationTime; RuleXMLFile: string);
var
  eventList: TLKJEventList;
  i: Integer;
  event: TLKJEventItem;
  lkjFile: TLKJRuntimeFile;
  reader: TfmtFileReader;
  ruleReader: TVSRuleReader;
begin
  OperationTime.inhousetime := 0;
  OperationTime.jctime := 0;
  OperationTime.outhousetime := 0;
  OperationTime.tqarrivetime := 0;
  OperationTime.tqdat := 0;
  OperationTime.jhtqtime := 0;
  Rules.Clear;
  try

    ruleReader := TVSRuleReader.Create(Rules);
    ruleReader.LoadFromXML(RuleXMLFile);
    ruleReader.Free;
{$REGION '�������õ��¼���ȡֵ��Χ'}
    eventList := TLKJEventList.Create;
    event := TLKJEventItem.Create;
    event.strEventID := '1000';
    event.strEvent := '���ʱ��';
    event.nBeforeSeconds := 0;
    event.nAfterSeconds := 0;
    eventList.Add(event);


    eventList := TLKJEventList.Create;
    event := TLKJEventItem.Create;
    event.strEventID := '1001';
    event.strEvent := '���ڳ��νӳ�ʱ��';
    event.nBeforeSeconds := 0;
    event.nAfterSeconds := 0;
    eventList.Add(event);

    event := TLKJEventItem.Create;
    event.strEventID := '1002';
    event.strEvent := '����ʱ��';
    event.nBeforeSeconds := 0;
    event.nAfterSeconds := 0;
    eventList.Add(event);

    event := TLKJEventItem.Create;
    event.strEventID := '1003';
    event.strEvent := '���ڳ��ε�վʱ��';
    event.nBeforeSeconds := 0;
    event.nAfterSeconds := 0;
    eventList.Add(event);


    event := TLKJEventItem.Create;
    event.strEventID := '1004';
    event.strEvent := '���ڳ��ε�վʱ��';
    event.nBeforeSeconds := 0;
    event.nAfterSeconds := 0;
    eventList.Add(event);
{$ENDREGION ''}
    try
      lkjFile := TLKJRuntimeFile.Create();
      try
        reader := TfmtFileReader.Create();
        try
          reader.LoadFromFiles(RuntimeFiles, lkjFile);
        finally
          reader.Free;
        end;
          

        DoAnalysis(lkjFile, eventList);
      finally
        lkjFile.Free;
      end;

      for i := 0 to eventList.Count - 1 do
      begin
        if eventList.Items[i].strEventID = '1000' then
        begin
          if eventList[i].DetailList.Count > 0 then
          begin
            OperationTime.inhousetime := eventList[i].DetailList.Items[eventList[i].DetailList.Count - 1].dtCurrentTime;
          end;
        end;
        if eventList.Items[i].strEventID = '1001' then
        begin
          if eventList[i].DetailList.Count > 0 then
          begin
            OperationTime.jctime := eventList[i].DetailList.Items[eventList[i].DetailList.Count - 1].dtCurrentTime;
          end;
        end;
        if eventList.Items[i].strEventID = '1002' then
        begin
          if eventList[i].DetailList.Count > 0 then
          begin
            OperationTime.outhousetime := eventList[i].DetailList.Items[eventList[i].DetailList.Count - 1].dtCurrentTime;
          end;
        end;
        if eventList.Items[i].strEventID = '1003' then
        begin
          if eventList[i].DetailList.Count > 0 then
          begin
            OperationTime.tqarrivetime := eventList[i].DetailList.Items[eventList[i].DetailList.Count - 1].dtCurrentTime;
          end;
        end;
        if eventList.Items[i].strEventID = '1004' then
        begin
          if eventList[i].DetailList.Count > 0 then
          begin
            OperationTime.tqdat := eventList[i].DetailList.Items[eventList[i].DetailList.Count - 1].dtCurrentTime;
          end;
        end;
      end;

      if OperationTime.jhtqtime > 0 then
      begin
        OperationTime.jhtqtime := IncMinute(OperationTime.jhtqtime, 30);
      end else begin
        if OperationTime.tqarrivetime > 0 then
        begin
          OperationTime.jhtqtime := IncMinute(OperationTime.tqarrivetime, 30);
        end;
      end;
      if OperationTime.inhousetime = 0 then
      begin
        if OperationTime.tqarrivetime > 0 then
        begin
          OperationTime.inhousetime := IncMinute(OperationTime.tqarrivetime, 30);
        end;
      end;
    finally
      eventList.Free;
    end;
  finally
    rules.Clear;
  end;
end;

function TLKJAnalysis.GetRuleByID(RuleID: string): TVSRule;
var
  i: Integer;
begin
  result := nil;
  for i := 0 to m_Rules.Count - 1 do
  begin
    if IntToStr(TVSRule(m_Rules.Items[i]).ID) = RuleID then
    begin
      Result := TVSRule(m_Rules.Items[i]);
    end;
  end;
end;

constructor TLKJAnalysis.Create();
begin
  m_Rules := TObjectList.Create;
end;

destructor TLKJAnalysis.Destroy;
begin
  m_Rules.Free;
  inherited;
end;

end.

