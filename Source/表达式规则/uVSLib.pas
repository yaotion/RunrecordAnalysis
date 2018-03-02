////////////////////////////////////////////////////////////////////////////////
//违标分析逻辑单元
////////////////////////////////////////////////////////////////////////////////
unit uVSLib;

interface

uses
  Classes, Contnrs, uVSConst, uVSRules, uVSAnalysisResultList, uLKJRuntimeFile,
  uRtfmtFileReader;
type
  ////////////////////////////////////////////////////////////////////////////////
  //违标分析类
  ////////////////////////////////////////////////////////////////////////////////
  TLKJAnalysis = class
  public
    constructor Create();
    destructor Destroy; override;
  public
    //分析运行记录
    procedure DoAnalysis(LKJFile: TLKJRuntimeFile; var EventArray: TLKJEventList);
    //获取作业时间
    procedure GetOperationTime(RuntimeFiles: TStrings; out OperationTime: ROperationTime; RuleXMLFile: string);
  private
    //规则列表
    m_Rules: TObjectList;
  protected
    //根据ID获取规则
    function GetRuleByID(RuleID: string): TVSRule;
  public
    //规则列表
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
  //清空上一次的分析结果
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
{$REGION '检测指定规则是否适合该运行记录文件'}
      if not vsRule.Check(LKJFile.HeadInfo, LKJFile.Records) then
      begin
        if vsRule.HeadExpression <> nil then
          vsRule.HeadExpression.Init;
        continue;
      end;
{$ENDREGION '检测指定规则是否适合该运行记录文件'}
      matchRlt := vscUnMatch;
            //循环运行记录
      for i := 0 to LKJFile.Records.Count - 1 do
      begin
{$REGION '比对记录，如果比对结果为捕获则保存捕获数据'}
        try
          matchRlt := vsRule.MatchLKJRec(LKJFile.HeadInfo, TLKJRuntimeFileRec(LKJFile.Records[i]), LKJFile.Records);
        except
          continue;
        end;

        if vscMatched = matchRlt then
        begin
          rltData := vsRule.GetCaptureRange;
          if rltData = nil then continue;
              //当规则捕获为正常时，退出循环
              //((有记录违标 (IsVs=False)，无记录违标 (IsVs=True)))
          if not vsRule.IsVS then break;
          EventArray[j].DetailList.Add(rltData);
          vsRule.Reset;
        end;
{$ENDREGION '比对记录，如果比对结果为捕获则保存捕获数据'}
      end;
{$REGION '如果当前记录为最有一条记录，则判断结果是否为捕获中'}
            //比对最后一条记录后将状态为适合的数据视为匹配
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
{$REGION '设置启用的事件及取值范围'}
    eventList := TLKJEventList.Create;
    event := TLKJEventItem.Create;
    event.strEventID := '1000';
    event.strEvent := '入库时间';
    event.nBeforeSeconds := 0;
    event.nAfterSeconds := 0;
    eventList.Add(event);


    eventList := TLKJEventList.Create;
    event := TLKJEventItem.Create;
    event.strEventID := '1001';
    event.strEvent := '出勤车次接车时间';
    event.nBeforeSeconds := 0;
    event.nAfterSeconds := 0;
    eventList.Add(event);

    event := TLKJEventItem.Create;
    event.strEventID := '1002';
    event.strEvent := '出库时间';
    event.nBeforeSeconds := 0;
    event.nAfterSeconds := 0;
    eventList.Add(event);

    event := TLKJEventItem.Create;
    event.strEventID := '1003';
    event.strEvent := '退勤车次到站时间';
    event.nBeforeSeconds := 0;
    event.nAfterSeconds := 0;
    eventList.Add(event);


    event := TLKJEventItem.Create;
    event.strEventID := '1004';
    event.strEvent := '退勤车次到站时间';
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

