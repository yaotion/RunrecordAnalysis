unit uVSRules;

interface
uses
  classes, Windows, SysUtils, Forms, Contnrs, DateUtils, xmldom, XMLIntf, msxmldom, XMLDoc,
  uVSConst, uVSSimpleExpress, uVSCombExpress, uLKJRuntimeFile,uVSAnalysisResultList;
type
   //////////////////////////////////////////////////////////////////////////////
  //TVSRule 违标规则
  //////////////////////////////////////////////////////////////////////////////
  TVSRule = class
    public
      constructor Create(); virtual;
      destructor Destroy(); override;
    protected
      m_nSortID: Integer;                    //所属分类编号
      m_nID: Integer;                        //规则编号
      m_strTitle: string;                    //规则说明
      m_HeadExpression: TVSExpression;       //头表达式
      m_RootExpression: TVSExpression;       //根表达式
      m_bIsVS: bool;                         //有/无则违标((有记录违标 (IsVs=False)，无记录违标 (IsVs=True)))
      m_RecHead: RLKJRTFileHeadInfo;         //运行记录文件头
      m_RecList: TList;                      //运行记录
      m_Description : string;                //规则描述
      m_nBeforeSeconds : integer;
      m_nAfterSeconds : integer;
      m_bIsRange : boolean;
    public
      //获取当前的值
      function GetData: Pointer; virtual;
      //重置
      procedure Reset; virtual;
      //重新初始化
      procedure Init; virtual;
      //检查文件是否适合本规则，适合则返回true，不适合则返回false
      function Check(RecHead: RLKJRTFileHeadInfo; RecList: TList): boolean; virtual;
      //比对一条运行记录，并返回比对状态
      function MatchLKJRec(RecHead: RLKJRTFileHeadInfo; RecRow: TLKJRuntimeFileRec; RewList: TList): TVSCState; virtual;
      //获取规则捕获的时间范围项
      function GetCaptureRange : TLKJEventDetail;
    public
      //规则编号
      property ID: integer read m_nID write m_nID;
      //所属分类编号
      property SortID: Integer read m_nSortID write m_nSortID;
      //规则标题
      property Title: string read m_strTitle write m_strTitle;
      //获取规则的描述
      property Description: string read m_Description write m_Description;
      //有/无则违标
      property IsVS: bool read m_bIsVS write m_bIsVS;
      //根表达式
      property RootExpression: TVSExpression read m_RootExpression write m_RootExpression;
      //头表达式
      property HeadExpression: TVSExpression read m_HeadExpression write m_HeadExpression;

      //是否为范围选项
      property IsRange : boolean read m_bIsRange write m_bIsRange;
      //取范围前都少秒
      property BeforeSeconds : integer read m_nBeforeSeconds write m_nBeforeSeconds;
      //取范围后多少秒
      property AfterSeconds : integer read m_nAfterSeconds write m_nAfterSeconds;    

  end;


implementation

function TVSRule.Check(RecHead: RLKJRTFileHeadInfo; RecList: TList): boolean;
var
  rlt: TVSCState;
begin
  Result := true;
  if (UpperCase(Trim(RecHead.strTrainHead)) = '0D')
    or (UpperCase(Trim(RecHead.strTrainHead)) = 'DJ')
    or (UpperCase(Trim(RecHead.strTrainHead)) = 'D') then
    begin
      Result := false;
      exit;
    end;
  m_RecHead := RecHead;
  m_RecList := RecList;
  if m_HeadExpression = nil then exit;
  Result := false;
  rlt := m_HeadExpression.Match(RecHead, nil, RecList);
  if (rlt = vscMatching) or (rlt = vscMatched) then
    begin
      Result := true;
    end;
end;

constructor TVSRule.Create;
begin
  m_bIsVS := true;
end;

destructor TVSRule.Destroy;
begin
  if m_RootExpression <> nil then
    m_RootExpression.Free;
  if m_HeadExpression <> nil then
    m_HeadExpression.Free;
  inherited;
end;

function TVSRule.GetCaptureRange: TLKJEventDetail;
var
  rec : TLKJCommonRec;
begin
  Result := TLKJEventDetail.Create;
  rec :=  TLKJCommonRec(m_RootExpression.GetData);
  Result.dtCurrentTime := rec.CommonRec.DTEvent;
  rec :=  TLKJCommonRec(m_RootExpression.GetBeginData);
  Result.dtBeginTime := rec.CommonRec.DTEvent;
  Result.dtBeginTime := IncSecond(Result.dtBeginTime,-1*m_nBeforeSeconds);
  rec :=  TLKJCommonRec(m_RootExpression.GetEndData);
  Result.dtEndTime := rec.CommonRec.DTEvent;
  Result.dtEndTime := IncSecond(Result.dtEndTime,m_nAfterSeconds);
end;

function TVSRule.GetData: Pointer;
begin
  Result := m_RootExpression.GetData;
end;


procedure TVSRule.Init;
begin
  if m_HeadExpression <> nil then
    m_HeadExpression.Init;
  if m_RootExpression <> nil then
    m_RootExpression.Init;
end;

//用所有规则比对一条运行记录
function TVSRule.MatchLKJRec(RecHead: RLKJRTFileHeadInfo;
  RecRow: TLKJRuntimeFileRec; RewList: TList): TVSCState;
begin
  Result := vscUnMatch;
  if m_RootExpression <> nil then
  begin
    Result := m_RootExpression.Match(RecHead, RecRow, RewList)
  end;
end;

procedure TVSRule.Reset;
begin
  if m_RootExpression <> nil then
    m_RootExpression.Reset;
end;

end.
