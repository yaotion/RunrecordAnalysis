unit uVSCombExpress;
{违标组合表达式单元}
interface
uses
  classes,Windows,SysUtils,Forms,DateUtils,
  uVSConst,uVSSimpleExpress,uLKJRuntimeFile;
type
  //////////////////////////////////////////////////////////////////////////////
  //TVSExpressionCollection，违标表达式列表类，仅从TList继承
  //////////////////////////////////////////////////////////////////////////////
  TVSExpressionCollection  = class(TList)
  private
    FOwnsObjects: Boolean;
  protected
    procedure Notify(Ptr: Pointer; Action: TListNotification); override;
    function GetItem(Index: Integer): TVSExpression;
    procedure SetItem(Index: Integer; AObject: TVSExpression);
  public
    constructor Create; overload;
    constructor Create(AOwnsObjects: Boolean); overload;

    function Add(AObject: TVSExpression): Integer;
    function Extract(Item: TVSExpression): TVSExpression;
    function Remove(AObject: TVSExpression): Integer;
    function IndexOf(AObject: TVSExpression): Integer;
    function FindInstanceOf(AClass: TClass; AExact: Boolean = True; AStartAt: Integer = 0): Integer;
    procedure Insert(Index: Integer; AObject: TVSExpression);
    function First: TVSExpression;
    function Last: TVSExpression;
    property OwnsObjects: Boolean read FOwnsObjects write FOwnsObjects;
    property Items[Index: Integer]: TVSExpression read GetItem write SetItem; default;
  end;

  //////////////////////////////////////////////////////////////////////////////
  //TVSCombExpression 组合与表达式基类  内置表达式列表，
  //////////////////////////////////////////////////////////////////////////////
  TVSCombExpression = class(TVSExpression)
  private
    m_Expressions : TVSExpressionCollection;         //表达式列表
    m_ParentData : Pointer;                          //父日志节点
    m_CurData : Pointer;                             //当前日志节点
  protected
    procedure CreateLog;                             //生成当前日志节点
    procedure SetState(const Value: TVSCState);override;
    procedure SetAcceptData(const Value: Pointer);override;
    procedure SetLastData(const Value: Pointer);override;         //第一个接收状态数据
    function GetAcceptData: Pointer;override;
  public
    constructor Create();override;
    destructor Destroy();override;
  public
    //清空数据，主要用于调用所有子表达式的清空方法
    procedure Reset;override;
    //清空包括LastData的值
    procedure Init;override;
    //重新初始化状态,用于外部赋值与自己赋值相隔开
    procedure InitState(Value : TVSCState);override;
    //重写获取数据
    function GetData : Pointer;override;
    //比对运行记录与表达式定义,
    function  Match(RecHead:RLKJRTFileHeadInfo;RecRow:TLKJRuntimeFileRec;RowList:TList): TVSCState;override;
  public
    //表达式列表
    property Expressions : TVSExpressionCollection read m_Expressions write m_Expressions;
    //父日志节点
    property ParentData : Pointer read m_ParentData write m_ParentData;
    //当前日志节点
    property CurData : Pointer read m_CurData write m_CurData;
  end;

  //////////////////////////////////////////////////////////////////////////////
  //TVSCombAndExpression 组合与表达式  内置表达式列表，当同时匹配时达到捕获条件
  //////////////////////////////////////////////////////////////////////////////
  TVSCombAndExpression = class(TVSCombExpression)
  public
    //重写获取数据
    function GetData : Pointer;override;
    function  Match(RecHead:RLKJRTFileHeadInfo;RecRow:TLKJRuntimeFileRec;RowList:TList): TVSCState;override;
  end;

  //////////////////////////////////////////////////////////////////////////////
  //TVSComboOrExpression 复合或表达式  内置表达式列表，当匹配其中一条时达到捕获条件
  //////////////////////////////////////////////////////////////////////////////
  TVSCombOrExpression = class(TVSCombExpression)
  public
    function GetChildrenData : Pointer;
    //重写获取数据
    function GetData : Pointer;override;
    function  Match(RecHead:RLKJRTFileHeadInfo;RecRow:TLKJRuntimeFileRec;RowList:TList): TVSCState;override;
  end;

  //////////////////////////////////////////////////////////////////////////////
  //TVSCombOrderExpression
  //复合顺序表达式  内置表达式列表，需要逐条按顺序匹配，所有条件满足捕获
  //////////////////////////////////////////////////////////////////////////////
  TVSCombOrderExpression = class(TVSCombExpression)
  private
    //当前活动表达式索引
    m_nActiveIndex : Integer;
    //返货捕获值的节点
    m_nMatchedIndex : Integer;
    //开始范围的表达式的索引
    m_nBeginIndex : integer;
    //结束范围的表达式的索引
    m_nEndIndex : integer;
  protected
    function GetAcceptData: Pointer; override;
  public
    constructor Create();override;
    //清空数据，主要用于调用所有子表达式的清空方法
    procedure Reset;override;

    procedure Init;override;
    //重写获取数据
    function GetData : Pointer;override;
    function GetBeginData : Pointer;override;
    function GetEndData : Pointer;override;
  public
    function  Match(RecHead:RLKJRTFileHeadInfo;RecRow:TLKJRuntimeFileRec;RowList:TList): TVSCState;override;
    //当前活动表达式索引
    property ActiveIndex : Integer read m_nActiveIndex write m_nActiveIndex;
    //返货捕获值的节点
    property MatchedIndex : Integer read m_nMatchedIndex write m_nMatchedIndex;
    //当前活动表达式索引
    property BeginIndex : Integer read m_nBeginIndex write m_nBeginIndex;
    //当前活动表达式索引
    property EndIndex : Integer read m_nEndIndex write m_nEndIndex;
  end;
  //////////////////////////////////////////////////////////////////////////////
  //TVSCombOrderInExpression
  //复合顺序包含表达式  内置表达式列表，需要逐条按顺序非连续匹配，所有条件满足捕获
  //////////////////////////////////////////////////////////////////////////////
  TVSCombOrderInExpression = class(TVSCombExpression)
  private
    //当前活动表达式索引
    m_nActiveIndex : Integer;
    //返货捕获值的节点
    m_nMatchedIndex : Integer;
  public
    constructor Create();override;
    //清空数据，主要用于调用所有子表达式的清空方法
    procedure Reset;override;

    procedure Init;override;
    //重写获取数据
    function GetData : Pointer;override;
  public
    function  Match(RecHead:RLKJRTFileHeadInfo;RecRow:TLKJRuntimeFileRec;RowList:TList): TVSCState;override;
    //当前活动表达式索引
    property ActiveIndex : Integer read m_nActiveIndex write m_nActiveIndex;
    //返货捕获值的节点
    property MatchedIndex : Integer read m_nMatchedIndex write m_nMatchedIndex;
  end;
  //////////////////////////////////////////////////////////////////////////////
  //TVSCombIntervalExpression 范围表达式，内涵开始表达式，结束表达式，比对表达式
  //如果BeginExpression为nil则从文件头开始
  //////////////////////////////////////////////////////////////////////////////
  TVSCombIntervalExpression = class(TVSCombExpression)
  private
    m_bMatchMatch : boolean;               ///捕获匹配的还是未匹配的
    m_bIsFit : boolean;                    //是否已经匹配 开始表达式
    m_BeginExpression : TVSExpression;     //开始表达式
    m_Expression : TVSExpression;          //实际比对表达式
    m_EndExpression : TVSExpression;       //结束表达式
    m_bMatchFirst : boolean;               //只匹配第一个范围
    m_bIntervalEntered : boolean;          //是否已经进入过范围
    m_ReturnType : TVSReturnType;         //返回值是范围开始、范围结束或匹配记录
  public
    constructor Create();override;
    destructor Destroy();override;
  public
    //比对表达式
    function  Match(RecHead:RLKJRTFileHeadInfo;RecRow:TLKJRuntimeFileRec;RowList:TList): TVSCState;override;
    //清空数据，
    procedure Reset;override;
    //初始化数据
    procedure Init;override;
     //获取实际的数据
    function GetData : Pointer;override;
    function GetBeginData : Pointer;override;
    function GetEndData : Pointer;override;
    //开始表达式
    property BeginExpression : TVSExpression read m_BeginExpression write m_BeginExpression;
    //实际比对表达式
    property Expression : TVSExpression read m_Expression write m_Expression;
    //结束表达式
    property EndExpression :TVSExpression read m_EndExpression write m_EndExpression;
    //是否只比对第一个范围
    property MatchFirst : boolean read m_bMatchFirst write m_bMatchFirst;
    //捕获匹配还是未匹配
    property MatchMatch : boolean read m_bMatchMatch write m_bMatchMatch;
    //返回值类型
    property ReturnType : TVSReturnType read m_ReturnType write m_ReturnType;
  end;

  //////////////////////////////////////////////////////////////////////////////
  //TVSCombNoIntervalExpression 范围不包含表达式
  //在范围内不做比对，当不在范围内做比对
  //////////////////////////////////////////////////////////////////////////////
  TVSCombNoIntervalExpression = class(TVSCombExpression)
  private
    m_bIsFit : boolean;                    //是否已经匹配 开始表达式
    m_BeginExpression : TVSExpression;     //开始表达式
    m_Expression : TVSExpression;          //实际比对表达式
    m_EndExpression : TVSExpression;       //结束表达式
//    m_IntervalEndTime : TDateTime;
  public
    constructor Create();override;
    destructor Destroy();override;
  public
    //比对表达式
    function  Match(RecHead:RLKJRTFileHeadInfo;RecRow:TLKJRuntimeFileRec;RowList:TList): TVSCState;override;
    //清空数据，
    procedure Reset;override;
    //初始化数据
    procedure Init;override;
     //获取实际的数据
    function GetData : Pointer;override;
    //开始表达式
    property BeginExpression : TVSExpression read m_BeginExpression write m_BeginExpression;
    //实际比对表达式
    property Expression : TVSExpression read m_Expression write m_Expression;
    //结束表达式
    property EndExpression :TVSExpression read m_EndExpression write m_EndExpression;
  end;

  //////////////////////////////////////////////////////////////////////////////
  //TVSCombIntervalExpression 有效范围表达式，开始表达式，结束表达式表示范围
  //当范围结束时，根据有效表达式判断该范围是否有效，如有效则根据判断表达式来判断
  //匹配结果
  //////////////////////////////////////////////////////////////////////////////
  TVSCombValidIntervalExpression = class(TVSCombExpression)
  private
    m_bMatchMatch : boolean;               //捕获匹配的还是未匹配的
    m_bIsFit : boolean;                    //是否已经匹配 开始表达式
    m_BeginExpression : TVSExpression;     //开始表达式
    m_EndExpression : TVSExpression;       //结束表达式
    m_ValidExpression : TVSExpression;     //有效表达式，用于判断范围结束后范围是否有效
    m_Expression : TVSExpression;          //实际比对表达式
  public
    constructor Create();override;
    destructor Destroy();override;
  public
    //比对表达式
    function  Match(RecHead:RLKJRTFileHeadInfo;RecRow:TLKJRuntimeFileRec;RowList:TList): TVSCState;override;
    //清空数据，
    procedure Reset;override;
    //初始化数据
    procedure Init;override;
     //获取实际的数据
    function GetData : Pointer;override;
  public

    property MatchMatch : boolean read m_bMatchMatch write m_bMatchMatch;
    //开始表达式
    property BeginExpression : TVSExpression read m_BeginExpression write m_BeginExpression;
    //结束表达式
    property EndExpression :TVSExpression read m_EndExpression write m_EndExpression;
    //实际比对表达式
    property Expression : TVSExpression read m_Expression write m_Expression;
    //有效表达式，用于判断范围结束后范围是否有效
    property ValidExpression : TVSExpression read m_ValidExpression write m_ValidExpression;
  end;

  //////////////////////////////////////////////////////////////////////////////
  //TVSCombConditionExpression 条件表达式，当条件满足时才匹配对应的数据(目前只匹配一次)
  //////////////////////////////////////////////////////////////////////////////
  TVSCombConditionExpression = class(TVSCombExpression)
  private
    m_ConditionExpression : TVSExpression;
    m_Expression : TVSExpression;
    m_bIsFit : boolean;
  public
    constructor Create();override;
    destructor Destroy();override;
  public
    //比对表达式
    function  Match(RecHead:RLKJRTFileHeadInfo;RecRow:TLKJRuntimeFileRec;RowList:TList): TVSCState;override;
    //清空数据，
    procedure Reset;override;
    //初始化数据
    procedure Init;override;
     //获取实际的数据
    function GetData : Pointer;override;
    //限定条件表达式
    property ConditionExpression : TVSExpression read m_ConditionExpression write m_ConditionExpression;
    //比对表达式
    property Expression : TVSExpression read m_Expression write m_Expression;
  end;

  //////////////////////////////////////////////////////////////////////////////
  //TVSCombIncludeExpression 包含表达式，判断内含表达式是否都匹配过
  //////////////////////////////////////////////////////////////////////////////
  TVSCombIncludeExpression = class(TVSCombExpression)
  public
    //比对表达式
    function  Match(RecHead:RLKJRTFileHeadInfo;RecRow:TLKJRuntimeFileRec;RowList:TList): TVSCState;override;
    //获取实际的数据
    function GetData : Pointer;override;
  end;

  //////////////////////////////////////////////////////////////////////////////
  //TVSCombLastIntervalExpression 最后一个范围表达式，最后一个才有效，其它无效
  //用于判断挂车
  //////////////////////////////////////////////////////////////////////////////
  TVSCombLastIntervalExpression =  class(TVSCombExpression)
  private
    m_bIsFit : boolean;
    m_BeginExpression : TVSExpression;     //开始表达式
    m_EndExpression : TVSExpression;       //结束表达式
    m_Expression : TVSExpression;          //结束表达式
    m_bMatchMatch : boolean;               //是否匹配匹配的数据
    m_TempState : TVSCState;               //内部用状态
  public
    constructor Create();override;
    destructor Destroy();override;
 public
    //清空数据，
    procedure Reset;override;
    //初始化数据
    procedure Init;override;
    //比对表达式
    function  Match(RecHead:RLKJRTFileHeadInfo;RecRow:TLKJRuntimeFileRec;RowList:TList): TVSCState;override;
    //获取实际的数据
    function GetData : Pointer;override;
  public
    //匹配表达式
    property Expression : TVSExpression read m_Expression write m_Expression;
    //开始表达式
    property BeginExpression : TVSExpression read m_BeginExpression write m_BeginExpression;
    //结束表达式
    property EndExpression :TVSExpression read m_EndExpression write m_EndExpression;
    //是否匹配匹配的数据
    property MatchMatch : boolean read m_bMatchMatch write m_bMatchMatch;
  end;

  //////////////////////////////////////////////////////////////////////////////
  //头表达式，用于判断限定复合某个条件之后的所有记录，返回匹配表达式
  //          中的匹配记录项
  //////////////////////////////////////////////////////////////////////////////
  TVSCombHeadExpression = class(TVSCombExpression)
  private
    m_HeadExpression : TVSExpression;   //头表达式
    m_Expression : TVSExpression;       //匹配表达式
  public
    constructor Create();override;
    destructor Destroy();override;
  public
    //清空数据，
    procedure Reset;override;
    //初始化数据
    procedure Init;override;
    //比对表达式
    function  Match(RecHead:RLKJRTFileHeadInfo;RecRow:TLKJRuntimeFileRec;RowList:TList): TVSCState;override;
    //获取实际的数据
    function GetData : Pointer;override;
  public
    //匹配表达式
    property Expression : TVSExpression read m_Expression write m_Expression;
    //头表达式
    property HeadExpression : TVSExpression read m_HeadExpression write m_HeadExpression;
  end;

  //////////////////////////////////////////////////////////////////////////////
  //IF表达式，和if语句类似，满足条件时执行第一个子表达式，否则执行第二个子表达式
  //////////////////////////////////////////////////////////////////////////////
  TVSCombIfExpression = class(TVSCombExpression)
  private
    m_ConditionExpression : TVSExpression;  //条件表达式
    m_TrueExpression : TVSExpression;       //条件匹配时执行
    m_FalseExpression : TVSExpression;      //条件为不匹配时执行
  public
    constructor Create();override;
    destructor Destroy();override;
  public
    //清空数据，
    procedure Reset;override;
    //初始化数据
    procedure Init;override;
    //比对表达式
    function  Match(RecHead:RLKJRTFileHeadInfo;RecRow:TLKJRuntimeFileRec;RowList:TList): TVSCState;override;
    //获取实际的数据
    function GetData : Pointer;override;
  public
    //条件匹配时执行
    property TrueExpression : TVSExpression read m_TrueExpression write m_TrueExpression;
    //条件为不匹配时执行
    property FalseExpression : TVSExpression read m_FalseExpression write m_FalseExpression;
    //头表达式
    property ConditionExpression : TVSExpression read m_ConditionExpression write m_ConditionExpression;
  end;
///////////////////////////////////////////////////////////////////////////
///TVSCombTriggerExpression 触发表达式状态为vscMatched或vscMatching时触发执行
///  子表达式，复位表达式为Unmatch时复位子表达式
///  注：触发表达式和复位表达式不能单独创建，只能使用现有的表达式
///////////////////////////////////////////////////////////////////////////
  TVSCombTriggerExpression = class(TVSCombExpression)
  private
    m_Expression : TVSExpression;  //条件表达式
    m_TriggerExpression : TVSExpression;       //条件匹配时执行
    m_ResetExpression : TVSExpression;      //条件为不匹配时执行
    m_bTriggerEnable : Boolean;
  public
    constructor Create();override;
    destructor Destroy();override;
  public
    //清空数据，
    procedure Reset;override;
    //初始化数据
    procedure Init;override;
    //比对表达式
    function  Match(RecHead:RLKJRTFileHeadInfo;RecRow:TLKJRuntimeFileRec;RowList:TList): TVSCState;override;
    //获取实际的数据
    function GetData : Pointer;override;
  public
    //触发表达式
    property TriggerExpression : TVSExpression read m_TriggerExpression write m_TriggerExpression;
    //复位表达式
    property ResetExpression : TVSExpression read m_ResetExpression write m_ResetExpression;
    //执行表在式
    property Expression : TVSExpression read m_Expression write m_Expression;
  end;
implementation
uses
  uVSLog;
{$region 'TVSExpressionCollection  实现'}
function TVSExpressionCollection.Add(AObject: TVSExpression): Integer;
begin
  Result := inherited Add(AObject);
end;

constructor TVSExpressionCollection.Create;
begin
  inherited Create;
  FOwnsObjects := True;
end;

constructor TVSExpressionCollection.Create(AOwnsObjects: Boolean);
begin
  inherited Create;
  FOwnsObjects := AOwnsObjects;
end;

function TVSExpressionCollection.Extract(Item: TVSExpression): TVSExpression;
begin
  Result := TVSExpression(inherited Extract(Item));
end;

function TVSExpressionCollection.FindInstanceOf(AClass: TClass; AExact: Boolean;
  AStartAt: Integer): Integer;
var
  I: Integer;
begin
  Result := -1;
  for I := AStartAt to Count - 1 do
    if (AExact and
        (Items[I].ClassType = AClass)) or
       (not AExact and
        Items[I].InheritsFrom(AClass)) then
    begin
      Result := I;
      break;
    end;
end;

function TVSExpressionCollection.First: TVSExpression;
begin
  Result := TVSExpression(inherited First);
end;

function TVSExpressionCollection.GetItem(Index: Integer): TVSExpression;
begin
  Result := inherited Items[Index];
end;

function TVSExpressionCollection.IndexOf(AObject: TVSExpression): Integer;
begin
  Result := inherited IndexOf(AObject);
end;

procedure TVSExpressionCollection.Insert(Index: Integer; AObject: TVSExpression);
begin
  inherited Insert(Index, AObject);
end;

function TVSExpressionCollection.Last: TVSExpression;
begin
  Result := TVSExpression(inherited Last);
end;

procedure TVSExpressionCollection.Notify(Ptr: Pointer; Action: TListNotification);
begin
  if OwnsObjects then
    if Action = lnDeleted then
      TVSExpression(Ptr).Free;
  inherited Notify(Ptr, Action);
end;

function TVSExpressionCollection.Remove(AObject: TVSExpression): Integer;
begin
  Result := inherited Remove(AObject);
end;

procedure TVSExpressionCollection.SetItem(Index: Integer; AObject: TVSExpression);
begin
  inherited Items[Index] := AObject;
end;
{$endregion 'TVSExpressionCollection  实现'}

{$region 'TVSCombExpression 实现'}

constructor TVSCombExpression.Create;
begin
  inherited;
  m_Expressions := TVSExpressionCollection.Create;
end;

procedure TVSCombExpression.CreateLog;
begin
  m_ParentData :=  Pointer(VSLog.CreateCombExpress(self,m_CurData));
end;

destructor TVSCombExpression.Destroy;
begin
  m_Expressions.Free;
  inherited;
end;

function TVSCombExpression.GetAcceptData: Pointer;
begin
  Result := nil;  
end;

function TVSCombExpression.GetData: Pointer;
var
  i : Integer;
  p,oldP : Pointer;
begin
  oldP := nil;
  for i := 0 to m_Expressions.Count - 1 do
  begin
    p := m_Expressions[i].GetData;
    if p = nil then
    begin
      continue;
    end;
    if OldP = nil then
    begin
      OldP := TLKJCommonRec(p);
      continue;
    end;
    if TLKJCommonRec(p).CommonRec.nRow < TLKJCommonRec(OldP).CommonRec.nRow then
    begin
      oldP := p; 
    end;
  end;
  Result := OldP;
end;


procedure TVSCombExpression.Init;
var
  i : Integer;
begin
  for i := 0 to m_Expressions.Count - 1 do
  begin
    m_Expressions[i].Init;
  end;
  inherited;
end;

procedure TVSCombExpression.InitState(Value: TVSCState);
var
  i : Integer;
begin
  for i := 0 to Expressions.Count - 1 do
  begin
    Expressions[i].State := Value;
  end;
  inherited;
end;

function TVSCombExpression.Match(RecHead: RLKJRTFileHeadInfo;
  RecRow: TLKJRuntimeFileRec;RowList:TList): TVSCState;
begin
  //比对结果赋值到表达式状态
  VSLog.AddCombExpress(self,RecHead,RecRow);
  //保存数据到上一次数据
  LastData := RecRow;   
end;

procedure TVSCombExpression.Reset;
var
  i : Integer;
begin
  inherited;
  for i := 0 to Expressions.Count - 1 do
  begin
    Expressions[i].Reset;
  end;
end;

procedure TVSCombExpression.SetAcceptData(const Value: Pointer);
var
  i : Integer;
begin
  for i := 0 to Expressions.Count - 1 do
  begin
    Expressions[i].AcceptData := Value;
  end;
  inherited;
end;

procedure TVSCombExpression.SetLastData(const Value: Pointer);
var
  i : Integer;
begin
  inherited;
  for i := 0 to Expressions.Count - 1 do
  begin
    Expressions[i].LastData := Value;
  end;
end;

procedure TVSCombExpression.SetState(const Value: TVSCState);
begin
  inherited;
end;

{$endregion 'TVSCombExpression 实现'}


{$region 'TVSCombAndExpression 实现'}
{ TVSCombAndExpression }


function TVSCombAndExpression.GetData: Pointer;
var
  i : Integer;
  p,oldP : Pointer;
begin
  oldP := nil;
  //循环获取子表达式中最先匹配的数据作为返回数据
  for i := 0 to m_Expressions.Count - 1 do
  begin
    p := m_Expressions[i].GetData;
    if p = nil then
    begin
      continue;
    end;
    if OldP = nil then
    begin
      OldP := TLKJCommonRec(p);
      continue;
    end;
    if TLKJCommonRec(p).CommonRec.nRow >= TLKJCommonRec(OldP).CommonRec.nRow then
    begin
      oldP := p; 
    end;
  end;
  Result := OldP; 
end;

function TVSCombAndExpression.Match(RecHead: RLKJRTFileHeadInfo;
  RecRow: TLKJRuntimeFileRec;RowList:TList): TVSCState;
var
  i : Integer;                    //循环索引
  nAcceptCount : Integer;         //处于接收状态的子表达式
  nFitCount   : Integer;          //处于适合状态的子表达式
  nMatchCount : Integer;          //处于匹配状态的子表达式
  tempRlt : TVSCState;            //临时比对结果
begin
  try
    //生成日志节点
    CreateLog;
    nMatchCount := 0;
    nAcceptCount := 0;
    nFitCount := 0;
    //循环每个表达式
    for i := 0 to m_Expressions.Count - 1 do
    begin
      {$region '循环比较子表达式并累加比对结果'}
      tempRlt := m_Expressions.Items[i].Match(RecHead,RecRow,RowList);
      if tempRlt = vscAccept then
      begin
        nAcceptCount := nAcceptCount + 1;
      end;
      if tempRlt = vscMatching then
      begin
        nFitCount := nFitCount + 1;
      end;    
      if tempRlt = vscMatched then
        nMatchCount := nMatchCount + 1;
      {$endregion '循环比较子表达式并累加比对结果'}  
    end;

    if nMatchCount > 0 then
    begin
      {$region '子表达式中有匹配状态是，查询他们前一状态是否都为Matching或Matched'}
      for i := 0 to m_Expressions.Count - 1 do
      begin
        if (m_Expressions[i].LastState <> vscMatching) and (m_Expressions[i].LastState <> vscMatched)  then
        begin
          Result := vscUnMatch;
          State := Result;
          Reset;
          exit;
        end;
      end;
      Result := vscMatched;
      State := Result;
      exit;
      {$endregion '子表达式中有匹配状态是，查询他们前一状态是否都为Matching或Matched'}
    end;
  

    if (nAcceptCount + nMatchCount + nFitCount) < m_Expressions.Count  then
    begin
      {$region '子表达式中有不匹配节点，则整个组合状态为不匹配，同时清空所有表达式数据'}
      Result := vscUnMatch;
      State := Result;
      //清空表达式数据
      Reset;
      //清空各节点状态
      exit;
      {$endregion '子表达式中有不匹配节点，则整个组合状态为不匹配，同时清空所有表达式数据'}
    end;

    if nAcceptCount > 0 then
    begin
      {$region '子表达式中有接受状态，则整个组合状态为接收'}
      Result := vscAccept;
      State := Result;
      exit;
      {$endregion '子表达式中有接受状态，则整个组合状态为接收'}
    end;   

    if (nFitCount > 0) then
    begin
      {$region '所有表达式状态均为适合，则整个组合表达式状态为匹配'}
      Result := vscMatching;
      State := Result;
      exit;
      {$endregion '所有表达式状态均为适合，则整个组合表达式状态为匹配'}
    end;

    //所有表达式状态均为匹配，则整个组合表达式状态为匹配
    Result := vscMatched;
    State := Result;
  finally
    Inherited Match(RecHead,RecRow,RowList);
  end;
end;
{$endregion 'TVSCombAndExpression 实现'}

{$region 'TVSCombOrExpression 实现'}

{ TVSCombOrExpression }

function TVSCombOrExpression.GetChildrenData: Pointer;
begin
  Result := inherited GetData;
end;

function TVSCombOrExpression.GetData: Pointer;
begin
  Result := FitData;
end;

function TVSCombOrExpression.Match(RecHead: RLKJRTFileHeadInfo;
  RecRow: TLKJRuntimeFileRec;RowList:TList): TVSCState;
var
  i : Integer;
  nAcceptCount : Integer; //处于接收状态的子表达式
  nFitCount   : Integer; //处于适合状态的子表达式
  nMatchCount : Integer;  //处于匹配状态的子表达式
  rlt : TVSCState;
begin
  try
    CreateLog;
    nAcceptCount := 0;
    nFitCount   := 0;
    nMatchCount := 0;
    for i := 0 to m_Expressions.Count - 1 do
    begin
      {$region '循环匹配自表达式并累加匹配结果'}
      rlt := m_Expressions.Items[i].Match(RecHead,RecRow,RowList);
      if vscMatched = rlt then
      begin
        nMatchCount := nMatchCount + 1;
      end;
      if vscMatching = rlt then
      begin
        nFitCount   := nFitCount + 1;
      end;
      if vscAccept = rlt then
      begin
        nAcceptCount := nAcceptCount + 1;
      end;
      if vscUnMatch = rlt then
      begin
        m_Expressions.Items[i].Reset;
      end;
      {$endregion '循环匹配自表达式并累加匹配结果'}
    end;
    //有已匹配的则返回状态匹配
    if (nMatchCount > 0) then
    begin
      if (State  = vscUnMatch) or (State = vscAccept) then
      begin
        FitData :=  getChildrenData
      end;
      Result := vscMatched;
      State := Result;
      exit;
    end;
    //有已匹配中的则返回匹配中
    if (nFitCount > 0) then
    begin
      if (State  = vscUnMatch) or (State = vscAccept) then
      begin
        FitData :=  getChildrenData
      end;
      Result := vscMatching;
      State := Result;
      exit;
    end;
    //有已接受的则返回接受
    if (nAcceptCount > 0) then
    begin
      if State = vscMatching then
      begin
        Result := vscMatched;
        State := Result;
        exit;
      end;
      Result := vscAccept;
      State := Result;
      exit;
    end;
    if State = vscMatching then
    begin
      Result := vscMatched;
      State := Result;
      exit;
    end;
    //返回不匹配
    Result := vscUnMatch;
    State := Result;
  finally
    Inherited Match(RecHead,RecRow,RowList);
  end;
end;

{$endregion 'TVSCombOrExpression 实现'}

{$region 'TVSCombOrderExpression 实现'}

{ TVSCombOrderExpression }

constructor TVSCombOrderExpression.Create;
begin
  m_nActiveIndex := 0;
  m_nMatchedIndex := 0;
  inherited;
end;

function TVSCombOrderExpression.GetAcceptData: Pointer;
begin
  Result := nil;
  if m_Expressions.Count > 0 then
  begin
    if m_nMatchedIndex <m_Expressions.Count  then
      Result := m_Expressions[m_nMatchedIndex].AcceptData
    else
      Result := m_Expressions[0].AcceptData;
  end;
end;

function TVSCombOrderExpression.GetBeginData: Pointer;
begin
  Result := m_Expressions[m_nBeginIndex].GetBeginData;
end;

function TVSCombOrderExpression.GetData: Pointer;
begin
  Result := nil;
  if m_Expressions.Count > 0 then
  begin
    if m_nMatchedIndex <m_Expressions.Count  then
      Result := m_Expressions[m_nMatchedIndex].GetData
    else
      Result := m_Expressions[0].GetData;
  end;
end;

function TVSCombOrderExpression.GetEndData: Pointer;
begin
  Result := m_Expressions[m_nEndIndex].GetEndData;
end;

procedure TVSCombOrderExpression.Init;
begin
   m_nActiveIndex := 0;
  inherited;

end;

function TVSCombOrderExpression.Match(RecHead: RLKJRTFileHeadInfo;
  RecRow: TLKJRuntimeFileRec;RowList:TList): TVSCState;
var
  p : Pointer;
  bFlag : boolean;
begin
  bFlag := false;
  try
    CreateLog;
    {$region '索引超出则重新归初始索引'}
    if (m_nActiveIndex > m_Expressions.Count -1) then
    begin
      m_nActiveIndex := 0;
    end;
    {$endregion '索引超出则重新归初始索引'}
    //获取当前表达式上一个数据
    p := m_Expressions.Items[m_nActiveIndex].LastData;
    //匹配当前表达式
    result :=  m_Expressions.Items[m_nActiveIndex].Match(RecHead,RecRow,RowList);

    {$region '如果不匹配则重新匹配'}
    //如果不匹配则重新匹配
    if result = vscUnMatch then
    begin
      if m_nActiveIndex > 0 then
      begin
        m_nActiveIndex := 0;
        Init;
        m_Expressions.Items[m_nActiveIndex].AcceptData := p;
        m_Expressions.Items[m_nActiveIndex].LastData := p;
        m_Expressions[m_nActiveIndex].InitState(vscAccept);
        bFlag := true;
        VSLog.AddCombExpress(self,RecHead,RecRow);
        Result := Match(RecHead,RecRow,RowList);
        m_Expressions.Items[m_nActiveIndex].Match(RecHead,RecRow,RowList);
        exit;
      end;
      m_nActiveIndex := 0;
      Init;
    end;
    {$endregion '如果不匹配则重新匹配'}

    {$region '如果已匹配则将当前数据传递到下一个表达式中进行匹配'}
    if result = vscMatched then
    begin
      m_nActiveIndex := m_nActiveIndex + 1;
      if (m_nActiveIndex < m_Expressions.Count)  then
      begin
        m_Expressions[m_nActiveIndex].AcceptData := p;
        m_Expressions[m_nActiveIndex].LastData := p;
        m_Expressions[m_nActiveIndex].InitState(vscAccept);
        bFlag := true;
        VSLog.AddCombExpress(self,RecHead,RecRow);
        Result := Match(RecHead,RecRow,RowList);
      end;
    end;
    {$endregion '如果已匹配则将当前数据传递到下一个表达式中进行匹配'}

    {$region '根据匹配状态设置返回值'}
    //如果接受则返回接受
    if (Result = vscAccept)  then
    begin
      Result := vscAccept;
    end;
    //如果匹配中且当前为最后一个节点则返回匹配中，否则返回接受
    if (Result = vscMatching) then
    begin
      if m_nActiveIndex = m_Expressions.Count - 1 then
      begin
        Result := vscMatching;
      end
      else
      begin
        Result := vscAccept;
      end;
    end;
    {$endregion '根据匹配状态设置返回值'}
    State := Result;
  finally
    if not bFlag then
    begin
      Inherited Match(RecHead,RecRow,RowList);
    end
    else
      LastData := RecRow;
  end;
end;
procedure TVSCombOrderExpression.Reset;
begin
  inherited;
  m_nActiveIndex := 0;
end;
{$endregion 'TVSCombOrderExpression 实现'}

{$region 'TVSCombIntervalExpression 实现'}

{ TVSCombIntervalExpression }

constructor TVSCombIntervalExpression.Create;
begin
  inherited;
  m_bIsFit := false;
  m_bMatchFirst := false;
  m_bIntervalEntered := false;
  m_bMatchMatch := true;
  m_ReturnType := vsrMatched;
end;

destructor TVSCombIntervalExpression.Destroy;
begin
  if m_BeginExpression <> nil then
    m_BeginExpression.Free;
  if m_Expression <> nil then
    m_Expression.Free;
  if m_EndExpression <> nil then
    m_EndExpression.Free;
  inherited;
end;

function TVSCombIntervalExpression.GetBeginData: Pointer;
begin
  Result := m_BeginExpression.GetBeginData;
end;

function TVSCombIntervalExpression.GetData: Pointer;
begin
  if m_ReturnType = vsrBegin then
    Result := m_BeginExpression.GetData
  else
    Result := FitData;
end;

function TVSCombIntervalExpression.GetEndData: Pointer;
begin
  Result := m_BeginExpression.GetEndData;
end;

procedure TVSCombIntervalExpression.Init;
begin
  inherited;
  m_bIsFit := false;
  m_bIntervalEntered := false;
  if m_BeginExpression <> nil then
    m_BeginExpression.Init;
  if m_Expression <> nil then
    m_Expression.Init;
  if m_EndExpression <> nil then
    m_EndExpression.Init;

  if not m_bMatchMatch then
    m_ReturnType := vsrBegin;
end;

function TVSCombIntervalExpression.Match(RecHead: RLKJRTFileHeadInfo;
  RecRow: TLKJRuntimeFileRec;RowList:TList): TVSCState;
var
  rlt : TVSCState;
begin
  try
    CreateLog;
    {$region '如果要求只匹配第一个范围且已经进入过范围则不再参加比对'}
    if m_bMatchFirst then
    begin
      if m_bIntervalEntered then
      begin
        Result := vscUnMatch;
        State := Result;
        exit;
      end;
    end;
    {$endregion '如果要求只匹配第一个范围且已经进入过范围则不再参加比对'}
    Result := vscUnMatch;
    {$region '判断开始表达式'}
    //如果没有进入范围则与范围的开始表达式进行判断
    if not(m_bIsFit) then
    begin
        rlt := m_BeginExpression.Match(RecHead,RecRow,RowList);
      //如果匹配开始表达式则设置能够进入标志，否则则退出
      if (rlt = vscMatching) or (rlt = vscMatched) then
      begin
        m_bIsFit := true;
        Result := vscAccept;
        State := Result;
        exit;
      end
      else
      begin
        m_BeginExpression.Reset;
        exit;
      end;
    end;
    {$endregion '判断开始表达式'}

    {$region '判断是否超出范围'}
    if m_EndExpression <> nil then
    begin
      rlt := m_EndExpression.Match(RecHead,RecRow,RowList);
      //最后一条记录，依然交与表达式进行判断，并强制揭示条件匹配
      if RowList.Items[RowList.Count - 1] = RecRow then
      begin
        {$region '如果以前匹配为通过则需要进行匹配，返回值依据匹配的结果'}
        if (State = vscMatching) or (State = vscMatched) then
        begin
          rlt := vscMatching;
        end
        else
        begin
          rlt := m_Expression.Match(RecHead,RecRow,RowList);
          if (rlt = vscUnMatch) or (rlt = vscAccept) then
          begin
            rlt := vscAccept;
          end
          else
          begin
            rlt := vscMatching;
          end;
        end;
        {$endregion '如果以前匹配为通过则需要进行匹配，返回值依据匹配的结果'}

        Result := rlt;
        State := Result;
        rlt := vscMatched;
      end;
      {$region '退出条件满足'}
      if (rlt = vscMatching) or (rlt = vscMatched)  then
      begin

        if m_bMatchFirst then
        begin
          m_bIntervalEntered := true;
        end;
        Result := vscUnMatch;

        if (State = vscMatching) or (State = vscMatched) then
        begin
          {$region '如果之前匹配过'}
          if m_bMatchMatch then
          begin
            //条件匹配且要求捕获匹配
            Result := vscMatched;
            State := Result;
          end
          else
          begin
            //条件匹配且要求捕获不匹配
            Result := vscUnMatch;
            State := Result;
            if not MatchFirst then
              Init;
          end;
          {$endregion '如果之前匹配过'}
        end
        else begin
          {$region '如果之前没有匹配过'}
          if m_bMatchMatch then
          begin
            //条件不匹配且要求捕获匹配
            Result := vscUnMatch;
            State := Result;
            if not MatchFirst then
              Init;
          end
          else
          begin
            //条件不匹配且要求捕获不匹配
            Result := vscMatched;
            State := Result;
          end;
          {$endregion '如果之前没有匹配过'}
        end;
        exit;
      end;
      {$endregion '退出条件满足'}

    end;
    {$endregion '判断是否超出范围'}

    {$region '比对数据'}
      {$region '如果以前已经匹配过则直接返回匹配中'}
      if (State = vscMatching) or (State = vscMatched) then
      begin
        FitData := m_Expression.GetData;
        Result := vscMatching;
        State := Result;
        exit;
      end;
      {$endregion '如果以前已经匹配过则直接返回匹配中'}

      {$region '如果以前匹配为通过则需要进行匹配，返回值依据匹配的结果'}
      rlt := m_Expression.Match(RecHead,RecRow,RowList);
      if (rlt = vscUnMatch) or (rlt = vscAccept) then
      begin
        rlt := vscAccept;
      end
      else
      begin
        rlt := vscMatching;
      end;
      {$endregion '如果以前匹配为通过则需要进行匹配，返回值依据匹配的结果'}
      if (rlt = vscMatching) or (rlt = vscMatched) then
      begin
        FitData := m_Expression.GetData;
      end;

      Result := rlt;
      State := Result;
      {$endregion '比对数据'}
  finally
    inherited  Match(RecHead,RecRow,RowList);
  end;
end;

procedure TVSCombIntervalExpression.Reset;
begin
  inherited;
  m_bIsFit := false;
  if m_BeginExpression <> nil then
    m_BeginExpression.Reset;
  if m_Expression <> nil then
    m_Expression.Reset;
  if m_EndExpression <> nil then
    m_EndExpression.Reset;
end;

{$endregion 'TVSCombIntervalExpression 实现'}

{$region 'TVSCombNoIntervalExpression 实现'}

{ TVSCombNoIntervalExpression }

constructor TVSCombNoIntervalExpression.Create;
begin
  inherited;
  m_bIsFit := false;
end;

destructor TVSCombNoIntervalExpression.Destroy;
begin
  if m_BeginExpression <> nil then
    m_BeginExpression.Free;
  if m_Expression <> nil then
    m_Expression.Free;
  if m_EndExpression <> nil then
    m_EndExpression.Free;
  inherited;
end;

function TVSCombNoIntervalExpression.GetData: Pointer;
begin
  Result:= m_Expression.GetData;
end;

procedure TVSCombNoIntervalExpression.Init;
begin
  inherited;
  m_bIsFit := false;
  if m_BeginExpression <> nil then
    m_BeginExpression.Init;
  if m_Expression <> nil then
    m_Expression.Init;
  if m_EndExpression <> nil then
    m_EndExpression.Init;
end;

function TVSCombNoIntervalExpression.Match(RecHead: RLKJRTFileHeadInfo;
  RecRow: TLKJRuntimeFileRec;RowList:TList): TVSCState;
var
  rlt : TVSCState;

begin
  try
    CreateLog;
    //如果要求只匹配第一个范围且已经进入过范围则不再参加比对
    Result := vscUnMatch;
    {$region '判断开始表达式'}
    //如果没有进入范围则与范围的开始表达式进行判断
    if not(m_bIsFit) then
    begin
      rlt := m_BeginExpression.Match(RecHead,RecRow,RowList);
      //如果匹配开始表达式则设置能够进入标志，否则则退出
      if (rlt = vscMatching) or (rlt = vscMatched) then
      begin
        m_bIsFit := true;
        m_Expression.Reset;
      end
      else
      begin
        if not m_bIsFit then
        begin
          rlt := m_Expression.Match(RecHead,RecRow,RowList);
          Result := rlt;
        end;
      end;
      State := Result;
      exit;
    end;
    {$endregion '判断开始表达式'}

    {$region '判断结束表达式'}
    //判断是否超出范围

    rlt := m_EndExpression.Match(RecHead,RecRow,RowList);
    //条件已经超出范围
    if (rlt = vscMatching) or (rlt = vscMatched)  then
    begin
      Result := vscUnMatch;
      //如果之前匹配过了这结果范围已匹配
//      if (State = vscMatching) or (State = vscMatched) then
//      begin
//        m_bIsFit := false;
//        //记录范围结束时间
////        m_IntervalEndTime := TLKJCommonRec(RecRow).CommonRec.DTEvent;
//      end;
      m_bIsFit := False;
      m_Expression.Reset();
      State := Result;
      exit;
    end;
   {$endregion '判断结束表达式'}
  finally
    inherited  Match(RecHead,RecRow,RowList);
  end;
end;

procedure TVSCombNoIntervalExpression.Reset;
begin
  inherited;
  m_bIsFit := false;
//  m_IntervalEndTime := 0;
  if m_BeginExpression <> nil then
    m_BeginExpression.Reset;
  if m_Expression <> nil then
    m_Expression.Reset;
  if m_EndExpression <> nil then
    m_EndExpression.Reset;
end;
{$endregion 'TVSCombNoIntervalExpression 实现'}

{$region 'TVSCombValidIntervalExpression 实现'}

constructor TVSCombValidIntervalExpression.Create;
begin
  inherited;
  m_bIsFit := false;
  m_bMatchMatch := false;
end;

destructor TVSCombValidIntervalExpression.Destroy;
begin
  if m_BeginExpression <> nil then
    m_BeginExpression.Free;
  if m_Expression <> nil then
    m_Expression.Free;
  if m_EndExpression <> nil then
    m_EndExpression.Free;
  if m_ValidExpression <> nil then
    m_ValidExpression.Free;
  inherited;
end;

function TVSCombValidIntervalExpression.GetData: Pointer;
begin
  Result := m_BeginExpression.GetData();
end;

procedure TVSCombValidIntervalExpression.Init;
begin
  inherited;
  m_bIsFit := false;
  if m_BeginExpression <> nil then
    m_BeginExpression.Init;
  if m_EndExpression <> nil then
    m_EndExpression.Init;
  if m_ValidExpression <> nil then
    m_ValidExpression.Init;
  if m_Expression <> nil then
    m_Expression.Init;  
end;

function TVSCombValidIntervalExpression.Match(RecHead: RLKJRTFileHeadInfo;
  RecRow: TLKJRuntimeFileRec;RowList:TList): TVSCState;
var
  rlt : TVSCState;  
begin
  try
    CreateLog;
    Result := vscUnMatch;
    if m_BeginExpression = nil then exit;

    {$region '判断开始表达式,如果匹配则进入范围比对，否则则退出'}
    //如果没有进入范围则与范围的开始表达式进行判断
    if not(m_bIsFit) then
    begin
      rlt := m_BeginExpression.Match(RecHead,RecRow,RowList);
      if RowList.Items[RowList.Count - 1] = RecRow then
      begin
        rlt := vscMatched;
      end;
      //如果匹配开始表达式则设置能够进入标志，否则则退出
      if (rlt = vscMatching) or (rlt = vscMatched) then
      begin
        m_bIsFit := true;
      end
      else
      begin
        m_BeginExpression.Reset;
        State := Result;
        exit;
      end;
    end;
    {$endregion '判断开始表达式,如果匹配则进入范围比对，否则则退出'}

    {$region '结束表达式匹配'}
    rlt := m_EndExpression.Match(RecHead,RecRow,RowList);
    //范围已经结束
    if (rlt = vscMatching) or (rlt = vscMatched)  then
    begin
      {$region '范围结束，判断范围是否有效'}
      Result := vscUnMatch;
      //判断范围是否有效
      rlt := m_ValidExpression.Match(RecHead,RecRow,RowList);
      {$region '如果范围无效则返回'}
      if (rlt = vscUnMatch) or (rlt = vscAccept) then
      begin
        State := Result;
        Reset;
        exit;
      end;
      {$endregion '如果范围无效则返回'}  

      {$region '如果有效则判断匹配表达式是否匹配,并将匹配表达式的结果返回'}
      //如果之前匹配过了这结果范围已匹配
      if (State = vscMatching) or (State = vscMatched) then
      begin
        if m_bMatchMatch then
        begin
          Result := vscMatched;
          State := Result;
        end
        else
        begin
          Result := vscUnMatch;
          State := Result;
          Reset;
        end;
        exit;
      end
      //否则范围表达式再进一步判断，并返回判断结果
      else begin
        rlt := m_Expression.Match(RecHead,RecRow,RowList);
        if (rlt = vscAccept) or (rlt = vscUnMatch) then
        begin
          if m_bMatchMatch then
          begin
            Result := vscUnMatch;
            State := Result;
            Reset;
          end
          else
          begin
            Result := vscMatched;
            State := Result;
          end;
          exit;
        end
        else begin
          if m_bMatchMatch then
          begin
            Result := vscMatched;
            State := Result;
          end
          else
          begin
            Result := vscUnMatch;
            State := Result;
            Reset;
          end;
          exit;
        end;
      end;
      {$endregion '如果有效则判断匹配表达式是否有效'}
      {$endregion '范围结束，判断范围是否有效'}  
    end;
   {$endregion '判断结束表达式'}

    //有效表达式获取数据
    m_ValidExpression.Match(RecHead,RecRow,RowList);
    
    //如果以前已经匹配过了这
    if (State = vscMatching) or (State = vscMatched) then
    begin
      Result := vscMatching;
      State := Result;
      exit;
    end;

    //如果以前没有匹配则进行匹配
    rlt := m_Expression.Match(RecHead,RecRow,RowList);
    if (rlt = vscUnMatch) or (rlt = vscAccept) then
    begin
      rlt := vscAccept;
    end
    else
    begin
      rlt := vscMatching;
    end;
    
    Result := rlt;
    State := Result;    
  finally
    inherited Match(RecHead,RecRow,RowList);
  end;
end;

procedure TVSCombValidIntervalExpression.Reset;
begin
  inherited;
  m_bIsFit := false;
  if m_BeginExpression <> nil then
    m_BeginExpression.Reset;
  if m_EndExpression <> nil then
    m_EndExpression.Reset;
  if m_ValidExpression <> nil then
    m_ValidExpression.Reset;
  if m_Expression <> nil then
    m_Expression.Reset;  
end;

{$endregion 'TVSCombValidIntervalExpression 实现'}

{$region 'TVSCombConditionExpression 实现'}

{ TVSCombConditionExpression }

constructor TVSCombConditionExpression.Create;
begin
  inherited;
  m_bIsFit := false;
end;

destructor TVSCombConditionExpression.Destroy;
begin
  if m_ConditionExpression <> nil then m_ConditionExpression.Free;
  if m_Expression <> nil then m_Expression.Free;
  inherited;
end;

function TVSCombConditionExpression.GetData: Pointer;
begin
  Result := nil;
  if m_ConditionExpression <> nil then
    Result := m_ConditionExpression.GetData;    
end;

procedure TVSCombConditionExpression.Init;
begin
  inherited;
  if m_ConditionExpression <> nil then m_ConditionExpression.Init;
  if m_Expression <> nil then m_Expression.Init;
  m_bIsFit := false;
end;

function TVSCombConditionExpression.Match(RecHead: RLKJRTFileHeadInfo;
  RecRow: TLKJRuntimeFileRec;RowList:TList): TVSCState;
var
  rlt : TVSCState;
begin
  try
    CreateLog;
    //如果已经匹配过则不再匹配
    if m_bIsFit then
    begin
      Result := vscUnMatch;
      State := Result;
      exit;
    end;
    //如果复合条件则进一步判断
    rlt := m_ConditionExpression.Match(RecHead,RecRow,RowList);
    if (rlt = vscMatching) or (rlt = vscMatched) then
    begin
      m_bIsFit := true;
      rlt := m_Expression.Match(RecHead,RecRow,RowList);
      //如果进一步判断复合条件则返回已捕获
      if (rlt = vscMatching) or (rlt= vscMatched) then
      begin
        Result := vscMatched;
        State := Result;
        exit;
      end;
      //否则返回捕获失败
      Result := vscUnMatch;
      State := Result;
    end;
  finally
    inherited Match(RecHead,RecRow,RowList);
  end;
end;

procedure TVSCombConditionExpression.Reset;
begin
  inherited;
  if m_ConditionExpression <> nil then m_ConditionExpression.Reset;
  if m_Expression <> nil then m_Expression.Reset;
  
end;
{$endregion 'TVSCombConditionExpression 实现'}

{$region 'TVSCombIncludeExpression 实验'}
{ TVSCombIncludeExpression }

function TVSCombIncludeExpression.GetData: Pointer;
begin
  Result := Inherited GetData;
end;

function TVSCombIncludeExpression.Match(RecHead: RLKJRTFileHeadInfo;
  RecRow: TLKJRuntimeFileRec;RowList:TList): TVSCState;
var
  i : Integer;
  matchCount : Integer;
  rlt : TVSCState;
begin
  Result := vscUnMatch;
  CreateLog;
  try
    matchCount := 0;
    for i := 0 to Expressions.Count - 1 do
    begin
      rlt := Expressions[i].State;
      //当子表达式中有没有匹配的项则重新进行匹配
      if (vscUnMatch = rlt) or (vscAccept = rlt) then
      begin
        rlt := Expressions[i].Match(RecHead,RecRow,RowList);
      end;
      //当子表达式匹配则匹配技术加1
      if (vscMatching = rlt) or (vscMatched = rlt) then
      begin
        matchCount := matchCount + 1;
      end;
    end;
    //当所有子节点都匹配则返回匹配，否则返回未匹配
    if matchCount = Expressions.Count then
    begin
      Result := vscMatched;
    end;
    State := Result;
  finally
    inherited Match(RecHead,RecRow,RowList);
  end;
end;
{$endregion 'TVSCombIncludeExpression 实验'}

{$region 'TVSCombLastIntervalExpression'}
{ TVSCombLastIntervalExpression }

constructor TVSCombLastIntervalExpression.Create;
begin
  inherited;
  m_bIsFit := false;
  m_bMatchMatch := true;
end;

destructor TVSCombLastIntervalExpression.Destroy;
begin
  if m_BeginExpression <> nil then
    m_BeginExpression.Free;
  if m_Expression <> nil then
    m_Expression.Free;
  if m_EndExpression <> nil then
    m_EndExpression.Free;
  inherited;
end;

function TVSCombLastIntervalExpression.GetData: Pointer;
begin
  Result := FitData;
end;

procedure TVSCombLastIntervalExpression.Init;
begin
  inherited;
  m_bIsFit := false;
  m_TempState := vscUnMatch;
  if m_BeginExpression <> nil then
    m_BeginExpression.Init;
  if m_EndExpression <> nil then
    m_EndExpression.Init;
   if m_Expression <> nil then
    m_Expression.Init;
end;

function TVSCombLastIntervalExpression.Match(RecHead: RLKJRTFileHeadInfo;
  RecRow: TLKJRuntimeFileRec;RowList:TList): TVSCState;
var
  rlt : TVSCState;
begin
 try
    CreateLog;
    Result := vscUnMatch;
    if m_BeginExpression = nil then exit;

    {$region '判断开始表达式,如果匹配则进入范围比对，否则则退出'}
    //如果没有进入范围则与范围的开始表达式进行判断
    if not(m_bIsFit) then
    begin
      rlt := m_BeginExpression.Match(RecHead,RecRow,RowList);
      //如果匹配开始表达式则设置能够进入标志，否则则退出
      if (rlt = vscMatching) or (rlt = vscMatched) or (rlt = vscAccept) then
      begin
        if rlt  = vscAccept then
        begin
          State := vscAccept;
          exit;
        end;
        m_bIsFit := true;
        FitData := RecRow;
        Result := vscAccept;
        m_TempState := vscAccept;
      end
      else
      begin
        Result := State;
        exit;
      end;
    end;
    {$endregion '判断开始表达式,如果匹配则进入范围比对，否则则退出'}

    {$region '结束表达式匹配'}
    rlt := m_EndExpression.Match(RecHead,RecRow,RowList);
    if RowList.Items[RowList.Count - 1] = RecRow then
    begin
      rlt := vscMatched;
    end;
    //范围已经结束
    if (rlt = vscMatching) or (rlt = vscMatched)  then
    begin
      try
        //如果之前已经匹配则返回匹配中
        if (vscMatched = m_TempState) or (vscMatching = m_TempState) then
        begin
          if m_bMatchMatch then
          begin
            Result :=vscMatching;
            State := Result;
          end
          else
          begin
            Result :=vscUnMatch;
            State := Result;
          end;
          exit;
        end;
        rlt := m_Expression.Match(RecHead,RecRow,RowList);
        if (rlt = vscMatched) or (rlt = vscMatching) then
        begin
          if m_bMatchMatch then
          begin
            Result :=vscMatching;
            State := Result;
          end
          else
          begin
            Result :=vscUnMatch;
            State := Result;
          end;
          exit;
        end;
        if m_bMatchMatch then
        begin
          Result :=vscUnMatch;
          State := Result;
        end
        else
        begin
          Result :=vscMatching;
          State := Result;
        end;
      finally
        m_bIsFit := false;
        if m_EndExpression <> nil then
          m_EndExpression.Init;
        if m_Expression <> nil then
          m_Expression.Init;
        m_BeginExpression.Init;
      end;
      exit;
    end;
    {$endregion '判断结束表达式'}

    {$region '进入范围，进行匹配'}
    if (m_TempState = vscMatching) or (m_TempState = vscMatched) then
    begin
      m_TempState := vscMatching;
      Result := vscAccept;
      State := Result;
      exit;
    end;
    rlt := m_Expression.Match(RecHead,RecRow,RowList);
    m_TempState := rlt;
    Result := vscAccept;
    State := Result;
    {$endregion '进入范围，进行匹配'}
 finally
  inherited Match(RecHead,RecRow,RowList);
 end;
end;
procedure TVSCombLastIntervalExpression.Reset;
begin
  inherited;
  m_bIsFit := false;
  m_TempState := vscUnMatch;
  if m_BeginExpression <> nil then
    m_BeginExpression.Reset;
  if m_EndExpression <> nil then
    m_EndExpression.Reset;
  if m_Expression <> nil then
    m_Expression.Reset;
end;

{$endregion 'TVSCombLastIntervalExpression'}
{ TVSCombHeadExpression }

constructor TVSCombHeadExpression.Create;
begin
  inherited;

end;

destructor TVSCombHeadExpression.Destroy;
begin
  if m_HeadExpression <> nil then
    m_HeadExpression.Free;
  if m_Expression <> nil then
    m_Expression.Free;
  inherited;
end;

function TVSCombHeadExpression.GetData: Pointer;
begin
  Result := nil;
  if m_Expression <> nil then
    Result := m_Expression.GetData;
end;

procedure TVSCombHeadExpression.Init;
begin
  inherited;
  if m_HeadExpression <> nil then
    m_HeadExpression.Init;
  if m_Expression <> nil then
    m_Expression.Init;
end;

function TVSCombHeadExpression.Match(RecHead: RLKJRTFileHeadInfo;
  RecRow: TLKJRuntimeFileRec;RowList:TList): TVSCState;
var
  rlt : TVSCState;
begin
  try
    CreateLog;
    Result := vscMatched;
    if m_HeadExpression = nil then
    begin
      exit;
    end;
    //判断头表达式，如不匹配则返回，如匹配则进行匹配表达式判断
    if (m_HeadExpression.State = vscUnMatch) or (m_HeadExpression.State = vscAccept) then
    begin
      rlt := m_HeadExpression.Match(RecHead,RecRow,RowList);
      if (m_HeadExpression.State = vscUnMatch) or (m_HeadExpression.State = vscAccept)  then
      begin
        Result := rlt;
        exit;
      end;
    end;
    Result := m_Expression.Match(RecHead,RecRow,RowList);
  finally
    State := Result;
    inherited Match(RecHead,RecRow,RowList);
  end;
end;

procedure TVSCombHeadExpression.Reset;
begin
  inherited;
//  if m_HeadExpression <> nil then
//    m_HeadExpression.Reset;
  if m_Expression <> nil then
    m_Expression.Reset;
end;

{ TVSCombOrderInExpression }

constructor TVSCombOrderInExpression.Create;
begin
  inherited;
  m_nActiveIndex := 0;
  m_nMatchedIndex := 0;
end;

function TVSCombOrderInExpression.GetData: Pointer;
begin
  Result := nil;
  if m_Expressions.Count > 0 then
  begin
    if m_nMatchedIndex <m_Expressions.Count  then
      Result := m_Expressions[m_nMatchedIndex].GetData
    else
      Result := m_Expressions[0].GetData;
  end;

end;

procedure TVSCombOrderInExpression.Init;
begin
  inherited;
   m_nActiveIndex := 0;
end;

function TVSCombOrderInExpression.Match(RecHead: RLKJRTFileHeadInfo;
  RecRow: TLKJRuntimeFileRec; RowList: TList): TVSCState;
var
  p : Pointer;
  bFlag : boolean;
begin

  bFlag := false;
  try
    CreateLog;
    {$region '索引超出则重新归初始索引'}
    if (m_nActiveIndex > m_Expressions.Count -1) then
    begin
      m_nActiveIndex := 0;
    end;
    {$endregion '索引超出则重新归初始索引'}
    //获取当前表达式上一个数据
    p := m_Expressions.Items[m_nActiveIndex].LastData;
    //匹配当前表达式
    result :=  m_Expressions.Items[m_nActiveIndex].Match(RecHead,RecRow,RowList);

    {$region '如果不匹配则重新匹配'}
    //如果不匹配则重新匹配
    if result = vscUnMatch then
    begin
      exit;
    end;
    {$endregion '如果不匹配则重新匹配'}

    {$region '如果已匹配则将当前数据传递到下一个表达式中进行匹配'}
    if result = vscMatched then
    begin
      m_nActiveIndex := m_nActiveIndex + 1;
      if (m_nActiveIndex < m_Expressions.Count)  then
      begin
        m_Expressions[m_nActiveIndex].AcceptData := p;
        m_Expressions[m_nActiveIndex].LastData := p;
        m_Expressions[m_nActiveIndex].InitState(vscAccept);
        bFlag := true;
        VSLog.AddCombExpress(self,RecHead,RecRow);
        Result := Match(RecHead,RecRow,RowList);
      end;
    end;
    {$endregion '如果已匹配则将当前数据传递到下一个表达式中进行匹配'}

    {$region '根据匹配状态设置返回值'}
    //如果接受则返回接受
    if (Result = vscAccept)  then
    begin
      Result := vscAccept;
    end;
    //如果匹配中且当前为最后一个节点则返回匹配中，否则返回接受
    if (Result = vscMatching) then
    begin
      if m_nActiveIndex = m_Expressions.Count - 1 then
      begin
        Result := vscMatching;
      end
      else
      begin
        Result := vscAccept;
      end;
    end;
    {$endregion '根据匹配状态设置返回值'}
    State := Result;
  finally
    if not bFlag then
    begin
      Inherited Match(RecHead,RecRow,RowList);
    end
    else
      LastData := RecRow;
  end;
end;

procedure TVSCombOrderInExpression.Reset;
begin
  inherited;
  m_nActiveIndex := 0;
end;

{ TVSCombIfExpression }

constructor TVSCombIfExpression.Create;
begin
  inherited;

end;

destructor TVSCombIfExpression.Destroy;
begin
  if m_ConditionExpression <> nil then
    FreeAndNil(m_ConditionExpression);
  if m_TrueExpression <> nil then
    FreeAndNil(m_TrueExpression);
  if m_FalseExpression <> nil then
    FreeAndNil(m_FalseExpression);
  inherited;
end;

function TVSCombIfExpression.GetData: Pointer;
begin
  Result := FitData;
end;

procedure TVSCombIfExpression.Init;
begin
  inherited;
  if m_ConditionExpression <> nil then
    m_ConditionExpression.Init();
  if m_TrueExpression <> nil then
    m_TrueExpression.Init();
  if m_FalseExpression <> nil then
    m_FalseExpression.Init();
end;

function TVSCombIfExpression.Match(RecHead: RLKJRTFileHeadInfo;
  RecRow: TLKJRuntimeFileRec; RowList: TList): TVSCState;
var
  Rtl : TVSCState;
begin
  Rtl := m_ConditionExpression.Match(RecHead,RecRow,RowList);
  if (Rtl = vscMatched) or (Rtl = vscMatching) then
  begin
    if m_TrueExpression <> nil then
    begin
      Result := m_TrueExpression.Match(RecHead,RecRow,RowList);
    end
    else
      Result := vscUnMatch;
    FitData := m_TrueExpression.GetData;

    State := Result;
    Exit;
  end
  else
  begin
    if m_FalseExpression <> nil then
    begin
      Result := m_FalseExpression.Match(RecHead,RecRow,RowList);
    end
    else
      Result := vscUnMatch;
    FitData := m_FalseExpression.GetData;
    State := Result;
    Exit;
  end;

end;

procedure TVSCombIfExpression.Reset;
begin
  inherited;
  m_ConditionExpression.Reset;
  m_TrueExpression.Reset;
  m_FalseExpression.Reset;
end;

{ TVSCombTriggerExpression }

constructor TVSCombTriggerExpression.Create;
begin
  inherited;
  m_bTriggerEnable := False;
end;

destructor TVSCombTriggerExpression.Destroy;
begin
  if m_Expression <> nil then
    FreeAndNil(m_Expression);
  inherited;
end;

function TVSCombTriggerExpression.GetData: Pointer;
begin
  Result := m_Expression.GetData;
end;

procedure TVSCombTriggerExpression.Init;
begin
  inherited;
  m_bTriggerEnable := False;
end;

function TVSCombTriggerExpression.Match(RecHead: RLKJRTFileHeadInfo;
  RecRow: TLKJRuntimeFileRec; RowList: TList): TVSCState;
begin

  try
    CreateLog;
    Result := vscUnMatch;
    if LastState = vscMatched then
      Reset;

    if not m_bTriggerEnable then
    begin
      if m_TriggerExpression = nil then
        Exit;
      if m_TriggerExpression.State = vscMatching then
      begin
        m_bTriggerEnable := True;
      end;
    end
    else
    begin
      if m_ResetExpression = nil then
        Exit;
      if m_ResetExpression.State = vscUnMatch then
      begin
        m_Expression.Reset;
        m_bTriggerEnable := False;
      end;
    end;
    if m_bTriggerEnable then
    begin
      if m_Expression = nil then
        Exit;
      Result := m_Expression.Match(RecHead,RecRow,RowList);
    end;
  finally
    State := Result;
    inherited Match(RecHead,RecRow,RowList);
  end;
end;

procedure TVSCombTriggerExpression.Reset;
begin
  inherited;
  m_Expression.Reset;
  m_bTriggerEnable := False;
end;

end.
