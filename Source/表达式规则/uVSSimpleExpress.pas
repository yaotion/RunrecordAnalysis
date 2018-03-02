unit uVSSimpleExpress;
{违标简单表达式单元}
interface
uses
  classes,Windows,SysUtils,Forms,DateUtils,
  uVSConst,uLKJRuntimeFile,uVSAnalysisResultList;
type

  TCustomGetValueEvent = function(RecHead:RLKJRTFileHeadInfo;
    RecRow:TLKJRuntimeFileRec):Variant of object;
  //////////////////////////////////////////////////////////////////////////////
  //TVSExpression违标条件表达式基类，所有表达式从次继承
  //////////////////////////////////////////////////////////////////////////////
  TVSExpression = class
  private
    {$region '私有变量'}
    m_State : TVSCState;             //条件的当前状态
    m_LastState : TVSCState;         //前一个匹配状态
    m_pLastData : Pointer;           //上一条数据
    m_pFitData  : Pointer;           //第一个适合状态的数据
    m_pAcceptData : Pointer;         //第一个接收状态的数据
    m_strTitle : string;             //用于输出日志的表达式定义
    m_bSaveFirstFit : boolean;       //定义是要保存第一个匹配中还是最后一个匹配中的数据
    m_strExpressID : string;           //ID，作为唯一标识用
    {$endregion '私有变量'}
  protected
    function GetLastState: TVSCState;
    function GetState: TVSCState;virtual;
    function GetLastData: Pointer;virtual;
    procedure SetState(const Value: TVSCState);virtual;
    procedure SetAcceptData(const Value: Pointer);virtual;
    function GetAcceptData: Pointer;virtual;                     //第一个可能适合的值
    procedure SetLastData(const Value: Pointer);virtual;
  public
    {$region '构造、析构'}
    constructor Create();virtual;
    destructor Destroy();override;
    {$endregion '构造、析构'}
  public
    //获取状态的文字说明
    class function GetStateText(s : TVSCState) : string;
    //获取运行记录的列的文字说明
    class function GetColumnText(c : Integer) : string;
    //获取指定机车标压
    class function GetStandardPressure(RecHead:RLKJRTFileHeadInfo):integer;
    //获取当前记录指定违标项的值
    class function GetRecValue(RecField : Integer;RecHead:RLKJRTFileHeadInfo;RecRow:TLKJRuntimeFileRec):Variant;
    //比对单条运行记录，并返回比对结果
    function  Match(RecHead:RLKJRTFileHeadInfo;RecRow:TLKJRuntimeFileRec;RewList:TList): TVSCState;virtual;
    //清空出LastData外其它值
    procedure Reset;virtual;
    //清空包括LastData的值
    procedure Init;virtual;
    //重新初始化状态,用于外部赋值与自己赋值相隔开
    procedure InitState(Value : TVSCState);virtual;
    //获取实际的数据
    function GetData : Pointer;virtual;
    function GetBeginData : Pointer;virtual;
    function GetEndData : Pointer;virtual;
  public
    {$region '属性'}
    //前一个匹配状态
    property LastState : TVSCState read m_LastState write m_LastState;
    //当前匹配状态
    property State : TVSCState read m_State write SetState;
    //第一个接收数据
    property AcceptData : Pointer read m_pAcceptData write SetAcceptData;
    //上一个数据
    property LastData : Pointer read m_pLastData write SetLastData;
    //第一个FIT数据
    property FitData  : Pointer read m_pFitData write m_pFitData;
    //用于输出日志的表达式定义
    property Title : string read m_strTitle write m_strTitle;
    //定义是要保存第一个匹配中还是最后一个匹配中的数据
    property SaveFirstFit : boolean read m_bSaveFirstFit write m_bSaveFirstFit;
    //ID，作为唯一标识用
    property ExpressID : string read m_strExpressID write m_strExpressID;
    {$endregion '属性'}
  end;

  //////////////////////////////////////////////////////////////////////////////
  //TVSCompExpression 比对表达式  例如：限速 < 80
  //////////////////////////////////////////////////////////////////////////////
  TVSCompExpression = class(TVSExpression)
  private
    m_nKey : integer;                 //操作数
    m_OperatorSignal : TVSOperator;   //操作符
    m_Value : Variant;                //被操作符
    m_OnCustomGetValue : TCustomGetValueEvent;    //比对之前由用户操作
  public
    //比对运行记录与表达式定义,
    function  Match(RecHead:RLKJRTFileHeadInfo;RecRow:TLKJRuntimeFileRec;RewList:TList): TVSCState;override;
    //操作数
    property Key : Integer read m_nKey write m_nKey;
    //操作符
    property OperatorSignal : TVSOperator read m_OperatorSignal write m_OperatorSignal;
    //被操作符
    property Value : Variant read m_Value write m_Value;
    //比对之前由用户操作
    property OnCustomGetValue : TCustomGetValueEvent read m_OnCustomGetValue write m_OnCustomGetValue;
  end;


  TInOrNotIn = (tInNotIn,tInNotNot);

  //////////////////////////////////////////////////////////////////////////////
  //TVSInExpression In表达式  例如：10在10、20、30内
  //////////////////////////////////////////////////////////////////////////////
  TVSInExpression = class(TVSExpression)
  private
    m_nKey : integer;
    m_OperatorSignal : TInOrNotIn;
    m_Value : TStrings;
  public
    {$region '构造、析构'}
    constructor Create();override;
    destructor Destroy();override;
    {$endregion '构造、析构'}
  public
    //比对运行记录与表达式定义,
    function  Match(RecHead:RLKJRTFileHeadInfo;RecRow:TLKJRuntimeFileRec;RewList:TList): TVSCState;override;
  public
    //操作数
    property Key : Integer read m_nKey write m_nKey;
    property OperatorSignal : TInOrNotIn read m_OperatorSignal write m_OperatorSignal;
    //被操作符
    property Value : TStrings read m_Value write m_Value;
  end;

  //////////////////////////////////////////////////////////////////////////////
  //TVSOrderExpression 顺序表达式  例如：速度下降
  //////////////////////////////////////////////////////////////////////////////
  TVSOrderExpression = class(TVSExpression)
  private
    m_nKey : Integer;           //操作数
    m_Order : TVSOrder;        //顺序
  public
    constructor Create(); override;
  public
    //比对运行记录与表达式定义,
    function  Match(RecHead:RLKJRTFileHeadInfo;RecRow:TLKJRuntimeFileRec;RewList:TList): TVSCState;override;
    //趋势项代码
    property Key : Integer read m_nKey write m_nKey;
    //趋势值
    property Order : TVSOrder read m_Order write m_Order;

  end;

  //////////////////////////////////////////////////////////////////////////////
  //TVSOffsetExpression 顺序差值表达式  例如：管压下降80kpa
  ///////   ///////////////////////////////////////////////////////////////////////
  TVSOffsetExpression = class(TVSExpression)
  private
    m_nKey : Integer;           //操作数
    m_Order : TVSOrder;         //顺序
    m_nValue : Integer;         //临界值 (增加多少或减少多少)
    m_bIncludeEqual : boolean;  //是否包括等于
    m_breakLimit : Integer;
  public
    constructor Create();override;
    //比对运行记录与表达式定义,
    function  Match(RecHead:RLKJRTFileHeadInfo;RecRow:TLKJRuntimeFileRec;RewList:TList): TVSCState;override;
     //操作数
    property Key : Integer read m_nKey write m_nKey;
    //顺序
    property Order : TVSOrder read m_Order write m_Order;
    //临界值 (增加多少或减少多少)
    property Value : Integer read m_nValue write m_nValue;
    //是否包括等于
    property IncludeEqual : boolean read m_bIncludeEqual write m_bIncludeEqual;
    //数值跳变上限，跳变超限则Reset
    property BreakLimit : Integer read m_breakLimit write m_breakLimit;
  end;


  //////////////////////////////////////////////////////////////////////////////
  //TVSOffsetExExpression 顺序差值表达式 在 TVSOffsetExpression基础上增加差值上限
  //如差值大于上限则不属于要求范围
  //////////////////////////////////////////////////////////////////////////////
  TVSOffsetExExpression = class(TVSExpression)
  private
    m_nKey : Integer;           //操作数
    m_Order : TVSOrder;         //顺序
    m_nValue : Integer;         //临界值 (增加多少或减少多少)
    m_bIncludeEqual : boolean;  //是否包括等于
    m_breakLimit : Integer;
    m_nMaxValue : Integer;      //差值上限
  public
    constructor Create();override;
    //比对运行记录与表达式定义,
    function  Match(RecHead:RLKJRTFileHeadInfo;RecRow:TLKJRuntimeFileRec;RewList:TList): TVSCState;override;
     //操作数
    property Key : Integer read m_nKey write m_nKey;
    //顺序
    property Order : TVSOrder read m_Order write m_Order;
    //临界值 (增加多少或减少多少)
    property Value : Integer read m_nValue write m_nValue;
    //差值上限
    property MaxValue : Integer read m_nMaxValue write m_nMaxValue;
    //是否包括等于
    property IncludeEqual : boolean read m_bIncludeEqual write m_bIncludeEqual;
    //数值跳变上限，跳变超限则Reset
    property BreakLimit : Integer read m_breakLimit write m_breakLimit;
  end;

  //////////////////////////////////////////////////////////////////////////////
  //TVSCompBehindExpression 后置比对表达式  用于比对前面表达式的结果
  //////////////////////////////////////////////////////////////////////////////
  TVSCompBehindExpression = class(TVSExpression)
  private
    m_Key : Integer;                      //比对字段
    m_OperatorSignal : TVSOperator;       //比对方式
    m_CompDataType : TVSDataType;         //比对数据
    m_nValue : Integer;                   //比对差值
    m_FrontExp : TVSExpression;           //前一个简单表达式
    m_BehindExp : TVSExpression;          //后一个简单表达式
  public
    //比对运行记录与表达式定义,
    function  Match(RecHead:RLKJRTFileHeadInfo;RecRow:TLKJRuntimeFileRec;RewList:TList): TVSCState;override;
    //比对字段
    property Key : Integer read m_Key write m_Key;
    //比对方式
    property OperatorSignal : TVSOperator read m_OperatorSignal write m_OperatorSignal;
    //比对数据
    property CompDataType : TVSDataType read m_CompDataType write m_CompDataType;
    //比对差值
    property Value : Integer read m_nValue write m_nValue;
    //前一个简单表达式
    property FrontExp : TVSExpression read m_FrontExp write m_FrontExp;
    //后一个简单表达式
    property BehindExp : TVSExpression read m_BehindExp write m_BehindExp;
  end;

  TVSCompExpExpression = class(TVSExpression)
  private
    m_Key : Integer;                      //比对字段
    m_OperatorSignal : TVSOperator;       //比对方式
    m_CompDataType : TVSDataType;         //比对数据
    m_nValue : Integer;                   //比对差值
    m_Expression : TVSExpression;
  public
    //比对运行记录与表达式定义,
    function  Match(RecHead:RLKJRTFileHeadInfo;RecRow:TLKJRuntimeFileRec;RewList:TList): TVSCState;override;
  public
    //比对字段
    property Key : Integer read m_Key write m_Key;
    //比对方式
    property OperatorSignal : TVSOperator read m_OperatorSignal write m_OperatorSignal;
    //比对数据
    property CompDataType : TVSDataType read m_CompDataType write m_CompDataType;
    //比对差值
    property Value : Integer read m_nValue write m_nValue;
    //表达式
    property Expression : TVSExpression read m_Expression write m_Expression;
  end;
  /////////////////////////////////////////////////////////////////////////
  ///TVSSimpleIntervalExpression 获到在一个范围内从第一个或最后一个某一条件
  ///开始到范围结束的表达式，从指定条件开始，到范围结束返回值为Matching其他
  ///返回为Unmatch
  /////////////////////////////////////////////////////////////////////////
  TVSSimpleIntervalExpression = class(TVSExpression)
  private
    m_StartKey : Integer;               //开始条件
    m_EndKey : Integer;                 //结束条件
    m_Expression : TVSExpression;          //实际比对表达式
    m_StartValue : Variant;
    m_EndValue : Variant;
    m_StartPos : Integer;               //查找到的范围开始索引
    m_EndPos : Integer;                 //查找到的范围结束索引
    m_IsScaned : Boolean;               //已经扫描过标志

  public
    constructor Create();override;
    destructor Destroy; override;
  public
    //清空出LastData外其它值
    procedure Reset;override;
    //清空包括LastData的值
    procedure Init;override;

    function GetData : Pointer;override;
    function Match(RecHead:RLKJRTFileHeadInfo;RecRow:TLKJRuntimeFileRec;RewList:TList): TVSCState;override;
    property StartKey : Integer read m_StartKey write m_StartKey;
    property EndKey : Integer read m_EndKey write m_EndKey;
    property StartValue : Variant read m_StartValue write m_StartValue;
    property EndValue : Variant read m_EndValue write m_EndValue;
    property Expression : TVSExpression read m_Expression write m_Expression;
  end;

  TVSConditionTimesExpression = class(TVSExpression)
  private
    m_Expression : TVSExpression;
    m_InputTimes : Integer;
    m_Times : Integer;
    m_OperatorSignal : TVSOperator;       //比对方式
  public
    constructor Create();override;
    destructor Destroy; override;
    procedure Reset;override;
    procedure Init;override;

    function GetData : Pointer;override;
    function Match(RecHead:RLKJRTFileHeadInfo;RecRow:TLKJRuntimeFileRec;RewList:TList): TVSCState;override;

  public
    property OperatorSignal : TVSOperator  read m_OperatorSignal write m_OperatorSignal;
    property InputTimes : Integer read m_InputTimes write m_InputTimes;
    property Expression : TVSExpression read m_Expression write m_Expression;
  end;

  ///////////////////////////////////////////////////////////////////////////
  ///TVSSimpleConditionExpression 当满足Expression后一直返回Matched，未满足前
  ///持续返回UnMatch
  ///////////////////////////////////////////////////////////////////////////
  TVSSimpleConditionExpression = class(TVSExpression)
  private
    m_Expression : TVSExpression;
    m_ConditionIsTrue : Boolean;
  public
    constructor Create();override;
    destructor Destroy; override;
    procedure Reset;override;
    procedure Init;override;
    function GetData : Pointer;override;
    function Match(RecHead:RLKJRTFileHeadInfo;RecRow:TLKJRuntimeFileRec;RewList:TList): TVSCState;override;
    property Expression : TVSExpression read m_Expression write m_Expression;
  end;

var
  nJGID : integer;
implementation
uses
  uVSLog;

{$region 'TVSExpression  实现'}
constructor TVSExpression.Create;
begin
  m_State := vscUnMatch;
  m_LastState := vscUnMatch;
  m_pLastData := nil;
  m_pFitData := nil;
  m_pAcceptData := nil;
  m_strTitle := '';
  m_bSaveFirstFit := true;
end;

destructor TVSExpression.Destroy;
begin
  inherited;
end;

function TVSExpression.GetAcceptData: Pointer;
begin
  Result := m_pAcceptData;
end;

function TVSExpression.GetBeginData: Pointer;
begin
  Result := GetData;
end;

class function TVSExpression.GetColumnText(c: Integer): string;
begin
  Result := '异常列';
  case c of
    CommonRec_Column_GuanYa   : Result := '管压';
    CommonRec_Column_GangYa   : Result := '缸压';
    CommonRec_Column_Sudu     : Result := '速度';
    CommonRec_Column_WorkZero : Result := '工况零位';
    CommonRec_Column_HandPos  : Result := '工况前后';
    CommonRec_Column_WorkDrag : Result := '手柄位置';
    CommonRec_Column_DTEvent  : Result := '时间';
    CommonRec_Column_Distance : Result := '信号机距离';
    CommonRec_Column_LampSign : Result := '信号灯';

    CommonRec_Column_SpeedLimit : Result := '限速';
    CommonRec_Head_TotalWeight: Result := '总重';
  end;
end;

function TVSExpression.GetData: Pointer;
begin
  Result := m_pFitData;
end;

function TVSExpression.GetEndData: Pointer;
begin
  Result := GetData;
end;

function TVSExpression.GetLastData: Pointer;
begin
  Result := m_pLastData;
end;

function TVSExpression.GetLastState: TVSCState;
begin
  Result := m_LastState;
end;

class function TVSExpression.GetRecValue(RecField: Integer;
  RecHead: RLKJRTFileHeadInfo; RecRow: TLKJRuntimeFileRec): Variant;
var
  dt : TDateTime;
  h,m,s,ms:word;
begin

  Result := 0;
  case RecField of
     CommonRec_Head_KeHuo :
     begin
       result := RecHead.TrainType;
       exit;
     end;
     CommonRec_Head_TotalWeight://总重
     begin
       result := RecHead.nTotalWeight;
       exit;
     end;
     CommonRec_Head_CheCi: //车次
     begin
       result := RecHead.nTrainNo;
       exit;
     end;
     CommonRec_Head_LiangShu: //辆数
     begin
       result := RecHead.nSum;
       exit;
     end;
     CommonRec_Head_LocalType: //车型
     begin
       result := RecHead.nLocoType;
       exit;
     end;
     CommonRec_Head_LocalID: //车号
     begin
       result := RecHead.nLocoID;
       exit;
     end;
     CommonRec_Head_Factory: //监控厂家
     begin
       result := RecHead.Factory;
       exit;
     end;
  end;
  if RecRow = nil then
  begin
    //异常
    PostMessage(ErrorHandle,WM_ERROR_GETVALUE,RecField,0);
    exit;
  end;
  case RecField of
     CommonRec_Column_GuanYa :
     begin
       result := TLKJCommonRec(RecRow).CommonRec.nLieGuanPressure;
       exit;
     end;
     CommonRec_Column_JGPressure :
     begin
       case nJGID of
        1 :
          Result := TLKJCommonRec(RecRow).CommonRec.nJG1Pressure;  
        2 : 
          Result := TLKJCommonRec(RecRow).CommonRec.nJG2Pressure; 
       end;       
       Exit;
     end;
     CommonRec_Column_Sudu :
     begin
       result := TLKJCommonRec(RecRow).CommonRec.nSpeed;
       exit;
     end;
     CommonRec_Column_WorkZero :
     begin
       result := TLKJCommonRec(RecRow).CommonRec.WorkZero;
       exit;
     end;

     CommonRec_Column_HandPos :
     begin
       result := TLKJCommonRec(RecRow).CommonRec.HandPos;
       exit;
     end;

     CommonRec_Column_WorkDrag :
     begin
       result := TLKJCommonRec(RecRow).CommonRec.WorkDrag;
       exit;
     end;
     
     CommonRec_Column_DTEvent :
     begin
       try
        dt := TLKJCommonRec(RecRow).CommonRec.DTEvent;
        DecodeTime(dt,h,m,s,ms);
        result := h * SecsPerMin*MinsPerHour + m*SecsPerMin + s;
       except
        PostMessage(ErrorHandle,WM_ERROR_GETVALUE,RecField,1);
        result := 0;
       end;
       exit;
     end;
     CommonRec_Column_Coord :
     begin
       result := TLKJCommonRec(RecRow).CommonRec.nCoord;
       exit;
     end;

     CommonRec_Column_Distance:      //信号机距离;
     begin
       result := TLKJCommonRec(RecRow).CommonRec.nDistance;
       exit;
     end;
     CommonRec_Column_LampSign :      //信号灯类型;
     begin
       result := TLKJCommonRec(RecRow).CommonRec.LampSign;
       exit;
     end;
     CommonRec_Column_SpeedLimit :      //信号灯类型;
     begin
       result := TLKJCommonRec(RecRow).CommonRec.nLimitSpeed;
       exit;
     end;
     CommonRec_Event_Column : //事件编号
     begin
       result := TLKJCommonRec(RecRow).CommonRec.nEvent;
       exit;
     end;
     CommonRec_Column_GangYa: //缸压
     begin
       result := TLKJCommonRec(RecRow).CommonRec.nGangPressure;
       exit;
     end;
     CommonRec_Column_Other: //其它
     begin
       result := TLKJCommonRec(RecRow).CommonRec.strOther;
       exit;
     end;
     CommonRec_Column_StartStation : //终点站
     begin
       result := TLKJCommonRec(RecRow).CommonRec.nStation;
       exit;
     end;
     CommonRec_Column_EndStation : //终点站
     begin
       result := TLKJCommonRec(RecRow).CommonRec.nToStation;
       exit;
     end;
     CommonRec_Column_LampNumber :
     begin
      Result := TLKJCommonRec(RecRow).CommonRec.nLampNo;
      Exit;
     end;
     CommonRec_Column_Rotate :
     begin
      Result := TLKJCommonRec(RecRow).CommonRec.nRotate;
      Exit;
     end;
     CommonRec_Column_ZT :
     begin
      Result := TLKJCommonRec(RecRow).CommonRec.JKZT;
      Exit;
     end;
  end;
end;

class function TVSExpression.GetStandardPressure(
  RecHead: RLKJRTFileHeadInfo): integer;
begin
  Result := SYSTEM_STANDARDPRESSURE_KE;
  if RecHead.TrainType = ttCargo then
  begin
    Result := SYSTEM_STANDARDPRESSURE_HUO;
    if UpperCase(Trim(RecHead.strTrainHead)) = 'X' then
    begin
      Result := SYSTEM_STANDARDPRESSURE_XING;
    end;
  end;
end;

function TVSExpression.GetState: TVSCState;
begin
  Result := m_State;
end;

class function TVSExpression.GetStateText(s : TVSCState): string;
begin
  Result := '异常状态';
  case s of
    vscAccept: result := '接受';
    vscMatching: result := '匹配中';
    vscMatched: result := '已匹配';
    vscUnMatch: result := '未匹配';
  end;
end;

procedure TVSExpression.Init;
begin
  m_State := vscUnMatch;
  m_LastState := vscUnMatch;
  m_pLastData := nil;
  m_pFitData  := nil;
  m_pAcceptData := nil;
end;

procedure TVSExpression.InitState(Value : TVSCState);
begin
  State := Value;
end;

function TVSExpression.Match(RecHead: RLKJRTFileHeadInfo;
  RecRow: TLKJRuntimeFileRec;RewList:TList): TVSCState;
begin
  //比对结果赋值到表达式状态
  VSLog.AddExpress(self,RecHead,RecRow);
  //保存数据到上一次数据
  m_pLastData := RecRow;
end;

procedure TVSExpression.Reset;
begin
  m_State := vscUnMatch;
  m_LastState := vscUnMatch;
  m_pAcceptData := nil;
  m_pFitData := nil;
end;

procedure TVSExpression.SetAcceptData(const Value: Pointer);
begin
  m_pAcceptData := Value;
end;

procedure TVSExpression.SetLastData(const Value: Pointer);
begin
  m_pLastData := Value;
end;

procedure TVSExpression.SetState(const Value: TVSCState);
begin
  m_LastState := m_State;
  m_State := Value;
end;

{$endregion}

{$region 'TVSCompExpression 实现'}

//比对运行记录与表达式定义,
function TVSCompExpression.Match(RecHead: RLKJRTFileHeadInfo;
  RecRow: TLKJRuntimeFileRec;RewList:TList): TVSCState;
const
  SPVAILD =20;            //标压的有效范围
var
  inputValue : Variant;   //当前据说的值
  transValue : Variant;   //管压经过翻译后的值
  bFlag : Boolean;        //比对结果
begin
  case Key of
    CommonRec_Column_VscMatched :
      begin
        Result := vscMatched;
        m_pFitData := RewList.Items[0];
        State := Result;
        Exit;
      end;
    CommonRec_Column_VscUnMatch :
      begin
        Result := vscUnMatch;
        State := Result;
        Exit;
      end;
  end;

  transValue := Value;
  //比对结果
  bFlag := false;
  //后去输入的值
  if Assigned(m_OnCustomGetValue) then
    transValue := m_OnCustomGetValue(RecHead,RecRow);

  inputValue := GetRecValue(Key,RecHead,RecRow);


  if ((Key = CommonRec_Column_GuanYa)or(Key = CommonRec_Column_JGPressure))
     and (Value = SYSTEM_STANDARDPRESSURE ) AND (OperatorSignal=vspEqual) then
  begin
    if inputValue >= GetStandardPressure(RecHead) - SPVAILD then
    begin
      bFlag := true;
    end;
  end
  else begin
   if  ((Key = CommonRec_Column_GuanYa)or(Key = CommonRec_Column_JGPressure)) and (Value >10000 ) then
   begin
    {$region '标压比对特殊处理'}
    transValue := Value - SYSTEM_STANDARDPRESSURE +  GetStandardPressure(RecHead);
    {$endregion '翻译标压及标压差值'}
   end;
    {$region '比对输入值与标准值'}
    case OperatorSignal of
      vspMore: //大于
      begin
        if inputValue > transValue then
          bFlag := true;
      end;
      vspLess:
      begin
        if inputValue < transValue then
          bFlag := true;
      end;
      vspEqual:
      begin
        if inputValue = transValue then
          bFlag := true;
      end;
      vspNoMore:
      begin
        if inputValue <= transValue then
          bFlag := true;
      end;
      vspNoLess:
      begin
        if inputValue >= transValue then
          bFlag := true;
      end;
      vspNoEqual:
      begin
        if inputValue <> transValue then
          bFlag := true;
      end;
      vspLeftLike:
      begin
        if Copy(transValue,0,Pos('?',transValue)-1) = Copy(inputValue,0,Pos('?',transValue)-1) then
        begin
          if length(transValue) = length(inputValue) then
          begin
            bFlag := true;
          end;
        end;
      end;
      vspLeftNotLike:
      begin
        if length(transValue) <> length(inputValue) then
        begin
          bFlag := true;
        end
        else begin
          if Copy(transValue,0,Pos('?',transValue)-1) <> Copy(inputValue,0,Pos('?',transValue)-1) then
          begin
              bFlag := true;
          end;
        end;
      end;
    end;
    {$endregion '比对输入值与标准值'}
  end;

  //如果上一次已经匹配过则判断上一次数据和此次数据是否相等，不等则返回不匹配
  if (m_pLastData <> nil) and (OperatorSignal = vspEqual) and ((State = vscMatching) or (State = vscMatched)) then
  begin
    if GetRecValue(Key,RecHead,m_pLastData) <> inputValue then
    begin
      bFlag := false;
    end;
  end;

  {$region '状态判断'}
  //比对通过
  if bFlag then
  begin
    {$region '比对通过'}
    //当前一次状态为不匹配，则将状态置为适合，且记录第一次适合的数据
    if (State = vscUnMatch) or (State = vscAccept) then
    begin
      m_pFitData := RecRow;
    end;
    //保存最后一个匹配值
    if not SaveFirstFit then
      m_pFitData := RecRow;
    Result := vscMatching;
    {$endregion '比对通过'}
  end
  else begin
    {$region '比对不通过'}
    //当前一次状态为适合，则将状态置为匹配，否则状态置为不匹配
    if State = vscMatching then
      Result := vscMatched
    else
      Result := vscUnMatch;
    {$endregion '比对不通过'}  
  end;
  {$endregion '状态判断'}

  State := Result;
  inherited Match(RecHead,RecRow,RewList);
end;

{$endregion 'TVSCompExpression 实现'}

{$region 'TVSOrderExpression 实现'}
{ TVSOrderExpression }

//比对运行记录与表达式定义,
constructor TVSOrderExpression.Create;
begin
  m_nKey := 0;
  inherited;
end;

function TVSOrderExpression.Match(RecHead: RLKJRTFileHeadInfo;
  RecRow: TLKJRuntimeFileRec;RewList:TList): TVSCState;
var
  inputValue : Variant;     //输入的值
  lastValue : Variant;      //上一个值
begin
  Result := vscUnMatch;
  //获取输入值
  inputValue := GetRecValue(Key,RecHead,RecRow);
  //获取上一个值
  if (m_pLastData <> nil) then
  begin
    lastValue := GetRecValue(Key,RecHead,TLKJRuntimeFileRec(m_pLastData));
  end;

  //判断排序规则
  case order of
    vsoArc:
    begin
      {$region '需要上升的数据'}
      //当为第一条数据时,直接置为接收状态
      if m_pLastData = nil then
      begin
        m_pLastData := RecRow;
        m_pAcceptData := RecRow;
        Result := vscAccept;
      end
      else begin
        if inputValue >= lastValue then
        begin
          {$region '当传入的值处于上升趋势'}
          if inputValue = lastValue then
          begin
            {$region '两次值相等时'}
            //上一次为不匹配，此次为接受且记录第一个接收的值
            if State = vscUnMatch then
            begin
               m_pAcceptData := RecRow;
               Result := vscAccept;
            end;
            //上一次为接收，此次仍为接受
            if State = vscAccept then
            begin
              Result := vscAccept;
            end;
            //上一次为匹配中，此次仍为接受
            if State = vscMatching then
            begin
              Result := vscMatching;              
            end;
            {$endregion '两次值相等时'}
          end
          else begin
            {$region '当传入的值为上升时，状态置为匹配中'}
            //当上一次为未匹配则此次为接受中，且记录第一个接收的值及第一个匹配中的值
            if State = vscUnMatch then
            begin
              m_pAcceptData := RecRow;
              m_pFitData := RecRow;
            end;
            //当上一次为接受中则此次为匹配中，且记录第一个匹配中的值
            if State = vscAccept then
            begin
              m_pFitData := RecRow;
            end;
            Result := vscMatching;
            {$endregion '当传入的值为上升时，状态置为匹配中'}
          end;
          {$endregion '当传入的值处于上升趋势'}
        end
        else begin
          {$region '当传入的值为下降时'}
          if State = vscMatching then
          begin
            Result := vscMatched;
          end else
            Result := vscUnMatch;
          {$endregion '当传入的值为下降时'}  
        end;
      end;
      {$endregion 需要上升的数据}
    end;
    vsoDesc:
    begin
      {$region '需要下降的数据'}
      //当为第一条数据时,直接置为接收状态
      if m_pLastData = nil then
      begin
        m_pLastData := RecRow;
        m_pAcceptData := RecRow;
        Result := vscAccept;
      end
      else begin
        if inputValue <= lastValue then
        begin
          {$region '当传入的值处于下降趋势'}
          if inputValue = lastValue then
          begin
            {$region '两次值相等时'}
            //上一次为不匹配，此次为接受且记录第一个接收的值
            if State = vscUnMatch then
            begin
               m_pAcceptData := RecRow;
               Result := vscAccept;
            end;
            //上一次为接收，此次仍为接受
            if State = vscAccept then
            begin
              Result := vscAccept;
            end;
            //上一次为匹配中，此次仍为接受
            if State = vscMatching then
            begin
              Result := vscMatching;              
            end;
            {$endregion '两次值相等时'}
          end
          else begin
            {$region '当传入的值为下降时，状态置为匹配中'}
            //当上一次为未匹配则此次为接受中，且记录第一个接收的值及第一个匹配中的值
            if State = vscUnMatch then
            begin
              m_pAcceptData := RecRow;
              m_pFitData := RecRow;
            end;
            //当上一次为接受中则此次为匹配中，且记录第一个匹配中的值
            if State = vscAccept then
            begin
              m_pFitData := RecRow;
            end;
            Result := vscMatching;
            {$endregion '当传入的值为上升时，状态置为匹配中'}
          end;
          {$endregion '当传入的值处于下降趋势'}
        end
        else begin
          {$region '当传入的值为上升时'}
          if State = vscMatching then
          begin
            Result := vscMatched;
          end else
            Result := vscUnMatch;
          {$endregion '当传入的值为上升时'}  
        end;
      end;
      {$endregion 需要下降的数据}
    end;
  end;
  State := Result;
  inherited Match(RecHead,RecRow,RewList);
end;

{$endregion 'TVSOrderExpression 实现'}

{$region 'TVSOffsetExpression 实现'}
{ TVSOffsetExpression }

constructor TVSOffsetExpression.Create;
begin
  inherited;
  m_bIncludeEqual := true;
  m_breakLimit := 0;
end;

function TVSOffsetExpression.Match(RecHead: RLKJRTFileHeadInfo;
  RecRow: TLKJRuntimeFileRec;RewList:TList): TVSCState;
var
  inputValue : Variant;               //输入值
  lastValue : Variant;                //上一个值
  acceptValue : Variant;              //接收的值
  bFlag : boolean;                    //比对结果
begin
  Result := vscUnMatch;
  //获取输入值
  inputValue := GetRecValue(Key,RecHead,RecRow);
  //获取上一个值
  if (m_pLastData <> nil) then
  begin
    lastValue := GetRecValue(Key,RecHead,TLKJRuntimeFileRec(m_pLastData));
  end;
  //如果数据跳变超过上限，则复位
  if m_breakLimit <> 0 then
  begin
    if Abs(inputValue - lastValue) > m_breakLimit then
    begin
      Reset();
      Exit;
    end;
  end;

  case order of
    vsoArc:
    begin
      {$region '需要上升趋势判断'}
      //第一次记录直接置为接收且保存第一次接收状态的数据
      if (m_pLastData = nil) or (m_pAcceptData = nil) then
      begin
        if m_pLastData = nil then
          m_pLastData := RecRow;
        if m_pAcceptData = nil then
          m_pAcceptData := RecRow;
        Result := vscAccept;
      end
      else begin
        //获取第一次接受的值
        acceptValue := GetRecValue(Key,RecHead,TLKJRuntimeFileRec(m_pAcceptData));

        if inputValue >= lastValue then
        begin
          {$region '当接收到上升趋势的数据时'}
          //判断是否上升了指定的值
          bFlag := (inputValue - acceptValue) > m_nValue;
          if (m_bIncludeEqual) then
            bFlag := (inputValue - acceptValue) >= m_nValue;
          if bFlag then
          begin
            {$region '结果匹配,记录状态为匹配中'}
            //上一次为未匹配则本次为接受状态，且记录第一次接受和匹配的值
            if State = vscUnMatch then
            begin
              m_pAcceptData := RecRow;
              m_pFitData := RecRow;
            end;
            //上一次为接受则本次仍为接受状态，且记录第一次匹配的值
            if (State = vscAccept) then
            begin
              m_pFitData := RecRow;
            end;
            Result := vscMatching;
            {$endregion '结果匹配,记录状态为匹配中'}
          end
          else begin
            {$region '结果不匹，记录状态为接收'}
            if State = vscUnMatch then
            begin
              m_pAcceptData := RecRow;
            end;
            Result := vscAccept;
            {$endregion '结果不匹，记录状态为接收'}
          end;
          {$endregion '当接收到上升趋势的数据时'}
        end
        else begin
          {$region '当接收到下降趋势的数据时'}
          if State = vscMatching then
          begin
            Result := vscMatched;
          end
          else
            Result := vscUnMatch;
          {$endregion '当接收到下降趋势的数据时'}  
        end;
      end;
      {$endregion '需要上升趋势判断'}
    end;
    vsoDesc:
    begin
      {$region '需要下降趋势判断'}
      //第一次记录直接置为接收且保存第一次接收状态的数据
      if (m_pLastData = nil) or (m_pAcceptData = nil) then
      begin
        if m_pLastData = nil then
          m_pLastData := RecRow;
        if m_pAcceptData = nil then
          m_pAcceptData := RecRow;
        Result := vscAccept;
      end
      else begin
        //获取接受状态的值
        acceptValue := GetRecValue(Key,RecHead,TLKJRuntimeFileRec(m_pAcceptData));
        if inputValue <= lastValue then
        begin
          {$region '当接受到下降趋势的值'}
          bFlag := (acceptValue - inputValue) > m_nValue;
          if (m_bIncludeEqual) then
            bFlag := (acceptValue - inputValue) >= m_nValue;           
          if bFlag then
          begin
            {$region '结果匹配，记录状态为匹配中'}
            //上次状态为未匹配则记录记录第一次接受及匹配中的值
            if (State = vscUnMatch)then
            begin
              m_pAcceptData := RecRow;
              m_pFitData := RecRow;
            end;
            //上一次状态为接受则记录第一次匹配中的值
            if (State = vscAccept) then
            begin
              m_pFitData := RecRow;
            end;
            Result := vscMatching;
            {$endregion '结果匹配，记录状态为匹配中'}
          end
          else
          begin
            {$region '结果不匹配，记录状态为接受中'}
            if State = vscUnMatch then
            begin
              m_pAcceptData := RecRow;
            end;
            Result := vscAccept;
            {$endregion '结果不匹配，记录状态为接受中'}
          end;
          {$endregion '当接受到下降趋势的值'}
        end
        else begin
          {$region '当接受到上升趋势的值'}
          if State = vscMatching then
          begin
            Result := vscMatched;
          end
          else
            Result := vscUnMatch;
          {$endregion '当接受到上升趋势的值'}
        end;
      end;
      {$endregion '需要下降趋势判断'}
    end;
  end;
  State := Result;
  inherited Match(RecHead,RecRow,RewList);
end;

{ TVSCombExpression }
{$endregion 'TVSOffsetExpression 实现'}

{$region 'TVSCompBehindExpression 实现'}

{ TVSCompBehindExpression }
function TVSCompBehindExpression.Match(RecHead: RLKJRTFileHeadInfo;RecRow:TLKJRuntimeFileRec;RewList:TList): TVSCState;
var
  frontValue : Variant;            //前面的值
  behindValue : Variant;           //后面的值
  bFlag : boolean;                 //比对结果
begin
  frontValue := 0;
  behindValue := 0;

  if (m_CompDataType=vsdtAccept) then
  begin
    {$region '比对接受的值'}
    frontValue := GetRecValue(Key,recHead,TLKJRuntimeFileRec(m_FrontExp.m_pAcceptData));
    behindValue := GetRecValue(Key,recHead,TLKJRuntimeFileRec(m_BehindExp.m_pAcceptData));
    {$endregion '比对接受的值'}
  end;
  if (m_CompDataType=vsdtMatcing) then
  begin

    if (m_FrontExp.GetData = nil) or (m_BehindExp.GetData = nil) then
    begin
      Result := vscUnMatch;
      State := Result;
      inherited Match(RecHead,RecRow,RewList);
      exit;
    end;
    
    {$region '比对匹配的值'}
    frontValue := GetRecValue(Key,recHead,TLKJRuntimeFileRec(m_FrontExp.GetData));
    behindValue := GetRecValue(Key,recHead,TLKJRuntimeFileRec(m_BehindExp.GetData));
    {$endregion '比对匹配的值'}
  end;
  if (m_CompDataType=vsdtLast) then
  begin
    {$region '比对上一个的值'}
    frontValue := GetRecValue(Key,recHead,TLKJRuntimeFileRec(m_FrontExp.LastData));
    behindValue := GetRecValue(Key,recHead,TLKJRuntimeFileRec(m_BehindExp.LastData));
    {$endregion '比对上一个的值'}
  end;
  bFlag := false;
  case m_OperatorSignal of
    {$region '比对结果，采用绝对值差值比较'}
    vspMore : bFlag :=  (Abs(behindValue - frontValue) > Value);
    vspLess : bFlag :=  (Abs(frontValue - behindValue) < Value);
    vspEqual : bFlag :=  (behindValue = (frontValue + Value));
    vspNoMore: bFlag :=  (Abs(frontValue - behindValue) <= Value);
    vspNoLess : bFlag :=  (Abs(frontValue - behindValue) >= Value);
    vspNoEqual:  bFlag :=  (behindValue <> (frontValue + Value));
    {$endregion '比对结果，采用绝对值差值比较'}
  end;

  Result := vscUnMatch;
  if bFlag then
    Result := vscMatched;
  State := Result;
  inherited Match(RecHead,RecRow,RewList);
end;


{ TVSInExpression }

constructor TVSInExpression.Create;
begin
  inherited;
  m_Value := TStringList.Create;
end;

destructor TVSInExpression.Destroy;
begin
  m_Value.Free;
  inherited;
end;

function TVSInExpression.Match(RecHead: RLKJRTFileHeadInfo;
  RecRow: TLKJRuntimeFileRec; RewList: TList): TVSCState;
var
  ValueIndex : Integer;
  inputValue : Variant;   //当前据说的值
  bFlag : boolean;
begin
  bFlag := false;
  if m_OperatorSignal = tInNotNot then
  begin
    bFlag := true;
  end;

  inputValue := GetRecValue(Key,RecHead,RecRow);

  ValueIndex := m_Value.IndexOf(string(inputValue));
  if ValueIndex <> -1 then
  begin
    bFlag := True;
    if m_OperatorSignal = tInNotNot then
      begin
        bFlag := false;
      end;

  end;


////
//  for i := 0 to m_Value.Count - 1 do
//  begin
//    if Value[i] = string(inputValue)  then
//    begin
//      bFlag := true;
//      if m_OperatorSignal = tInNotNot then
//      begin
//        bFlag := false;
//      end;
//      break;
//    end;
//  end;
  //比对通过
  if bFlag then
  begin
    {$region '比对通过'}
    //当前一次状态为不匹配，则将状态置为适合，且记录第一次适合的数据
    if (State = vscUnMatch) or (State = vscAccept) then
    begin
      m_pFitData := RecRow;
    end;
    //保存最后一个匹配值
    if not SaveFirstFit then
      m_pFitData := RecRow;
    Result := vscMatching;
    {$endregion '比对通过'}
  end
  else begin
    {$region '比对不通过'}
    //当前一次状态为适合，则将状态置为匹配，否则状态置为不匹配
    if State = vscMatching then
      Result := vscMatched
    else
      Result := vscUnMatch;
    {$endregion '比对不通过'}  
  end;
  {$endregion '状态判断'}

  State := Result;
  inherited Match(RecHead,RecRow,RewList);
end;

{ TVSCompExpExpression }

function TVSCompExpExpression.Match(RecHead: RLKJRTFileHeadInfo;
  RecRow: TLKJRuntimeFileRec; RewList: TList): TVSCState;
const
  SPVAILD =20;            //标压的有效范围
var
  inputValue : Variant;
  transValue : Variant;   //管压经过翻译后的值
  bFlag : boolean;
begin
  Result := vscUnMatch;
  bFlag := false;
  transValue := Value;
  case m_CompDataType of
    vsdtAccept:
    begin
      if m_Expression.AcceptData = nil then
      begin
        MessageBeep(0);
        exit;
      end;
      inputValue := GetRecValue(Key,RecHead,m_Expression.AcceptData);
    end;
    vsdtMatcing:
    begin
      if m_Expression.GetData = nil then
        exit;
      inputValue := GetRecValue(Key,RecHead, m_Expression.GetData);
    end;
    vsdtLast:
    begin
      if m_Expression.LastData = nil then
        exit;
      inputValue := GetRecValue(Key,RecHead,m_Expression.LastData);
    end;
  end;
   if (Key = CommonRec_Column_GuanYa) and (Value = SYSTEM_STANDARDPRESSURE ) AND (OperatorSignal=vspEqual) then
  begin
    if inputValue >= GetStandardPressure(RecHead) - SPVAILD then
    begin
      bFlag := true;
    end;
  end
  else begin
   if  (Key = CommonRec_Column_GuanYa) and (Value >10000 ) then
   begin
    {$region '标压比对特殊处理'}
    transValue := Value - SYSTEM_STANDARDPRESSURE +  GetStandardPressure(RecHead);
    {$endregion '翻译标压及标压差值'}
   end;
    {$region '比对输入值与标准值'}
    case OperatorSignal of
      vspMore: //大于
      begin
        if inputValue > transValue then
          bFlag := true;
      end;
      vspLess:
      begin
        if inputValue < transValue then
          bFlag := true;
      end;
      vspEqual:
      begin
        if inputValue = transValue then
          bFlag := true;
      end;
      vspNoMore:
      begin
        if inputValue <= transValue then
          bFlag := true;
      end;
      vspNoLess:
      begin
        if inputValue >= transValue then
          bFlag := true;
      end;
      vspNoEqual:
      begin
        if inputValue <> transValue then
          bFlag := true;
      end;
    end;
    {$endregion '比对输入值与标准值'}
  end;
  if bFlag then
  begin
    Result := vscMatched;
    FitData := nil;
    case m_CompDataType of
      vsdtAccept:
      begin
        FitData := m_Expression.AcceptData;
      end;
      vsdtMatcing:
      begin
        FitData := m_Expression.FitData;
      end;
      vsdtLast:
      begin
        FitData := m_Expression.LastData;
      end;
    end;
  end;
  State := Result;
  inherited Match(RecHead,RecRow,RewList);
end;


{ TVSSimpleIntervalExpression }

constructor TVSSimpleIntervalExpression.create;
begin
  inherited;
  m_StartKey := -1;
  m_EndKey := -1;
  m_IsScaned := False;
  m_StartPos := -1;
  m_EndPos := -1;
end;

destructor TVSSimpleIntervalExpression.Destroy;
begin
  if m_Expression <> nil then
    FreeAndNil(m_Expression);
  inherited;
end;

function TVSSimpleIntervalExpression.GetData: Pointer;
begin
  result := nil;
  if m_Expression <> nil then
  Result := m_Expression.GetData;
end;

procedure TVSSimpleIntervalExpression.Init;
begin
  inherited;
  m_IsScaned := False;
  m_StartPos := -1;
  m_EndPos := -1;
  m_Expression.Init;
end;

function TVSSimpleIntervalExpression.Match(RecHead: RLKJRTFileHeadInfo;
  RecRow: TLKJRuntimeFileRec; RewList: TList): TVSCState;
var
  i : Integer;
  RecIndex : Integer;
  rec : TLKJCommonRec;
begin
  Result := vscUnMatch;
  RecIndex := RewList.IndexOf(RecRow);
  if m_IsScaned then
  begin
    if (m_StartPos = -1) then
      Exit;
    if (RecIndex > m_StartPos) and (RecIndex < m_EndPos) then
        Result := m_Expression.Match(RecHead,RecRow,RewList);
    Exit;
  end;


  m_IsScaned := True;
  for i := 0 to RewList.Count - 1 do
    begin
      rec := TLKJCommonRec(RewList[i]);
      if m_StartValue = GetRecValue(StartKey,RecHead,rec) then
      begin
        m_StartPos := i;
        Break;
      end;

    end;

    for i := 0 to RewList.Count - 1 do
    begin
      rec := TLKJCommonRec(RewList[i]);
      if i = RewList.Count - 1 then
        m_EndPos := i
      else
        if m_EndPos = GetRecValue(EndKey,RecHead,rec) then
        begin
          m_EndPos := i;
          Break;
        end;

    end;

    if (m_StartPos = -1) then
      Exit;
    if (RecIndex > m_StartPos) and (RecIndex < m_EndPos) then
        Result := m_Expression.Match(RecHead,RecRow,RewList);

end;

procedure TVSSimpleIntervalExpression.Reset;
begin
  inherited;
  m_Expression.Reset;
end;


{ TVSConditionTimesExpression }

constructor TVSConditionTimesExpression.Create;
begin
  inherited;
  m_Times := 0;
end;

destructor TVSConditionTimesExpression.Destroy;
begin
  if m_Expression <> nil then
    FreeAndNil(m_Expression);
  inherited;
end;

function TVSConditionTimesExpression.GetData: Pointer;
begin
  Result := m_Expression.GetData;
end;

procedure TVSConditionTimesExpression.Init;
begin
  inherited;
  m_Times := 0;
  m_Expression.Init();
end;

function TVSConditionTimesExpression.Match(RecHead: RLKJRTFileHeadInfo;
  RecRow: TLKJRuntimeFileRec; RewList: TList): TVSCState;
var
  Rtl : TVSCState;
  bFlag : Boolean;
begin
  try
    Result := vscUnMatch;
    if LastState = vscMatched then
      m_Expression.Reset;

    Rtl := m_Expression.Match(RecHead,RecRow,RewList);
    if Rtl = vscMatched then
    begin
      Inc(m_Times);
    end;
    bFlag := False;
    case m_OperatorSignal of
      vspMore:
        begin
          if m_Times > m_InputTimes then
            bFlag := True;
        end;
      vspLess:
        begin
          if m_Times < m_InputTimes then
            bFlag := True;
        end;
      vspEqual:
        begin
          if m_Times = m_InputTimes then
            bFlag := True;
        end;
      vspNoMore:
        begin
          if m_Times <= m_InputTimes then
            bFlag := True;
        end;
      vspNoLess:
        begin
          if m_Times >= m_InputTimes then
            bFlag := True;
        end;
      vspNoEqual:
        begin
          if m_Times <> m_InputTimes then
            bFlag := True;
        end;    
    end;

    if bFlag then
    begin
      State := vscMatching;
      Result := State;
      Exit;
    end
    else
    begin
      
      if State = vscMatching then
      begin
        Result := vscMatched;
        State := Result;
      end;
    end;
  finally
    LastState := State;
    inherited Match(RecHead,RecRow,RewList);
  end;

end;

procedure TVSConditionTimesExpression.Reset;
begin
  inherited;
  m_Times := 0;
  m_Expression.Reset;
end;

{ TVSSimpleConditionExpression }

constructor TVSSimpleConditionExpression.Create;
begin
  inherited;
  m_ConditionIsTrue := False;
end;

destructor TVSSimpleConditionExpression.Destroy;
begin
  if m_Expression <> nil then
    FreeAndNil(m_Expression);
  inherited;
end;

function TVSSimpleConditionExpression.GetData: Pointer;
begin
  Result := m_Expression.GetData;
end;

procedure TVSSimpleConditionExpression.Init;
begin
  inherited;
  m_ConditionIsTrue := False;
  m_Expression.Init();
end;

function TVSSimpleConditionExpression.Match(RecHead: RLKJRTFileHeadInfo;
  RecRow: TLKJRuntimeFileRec; RewList: TList): TVSCState;
var
  Rlt : TVSCState;
begin
  Result := vscUnMatch;
  if m_ConditionIsTrue then
  begin
    Result := vscMatched;
    Exit;
  end;
  Rlt := m_Expression.Match(RecHead,RecRow,RewList);
  Self.State := m_Expression.State;
  if Rlt = vscMatched then
  begin
    m_ConditionIsTrue := True;
    Result := vscMatched;
  end;
end;

procedure TVSSimpleConditionExpression.Reset;
begin
  inherited;
  m_ConditionIsTrue := False;
  m_Expression.Reset;
end;

{ TVSOffsetExExpression }

constructor TVSOffsetExExpression.Create;
begin
  inherited;
  m_bIncludeEqual := true;
  m_breakLimit := 0;
end;

function TVSOffsetExExpression.Match(RecHead: RLKJRTFileHeadInfo;
  RecRow: TLKJRuntimeFileRec; RewList: TList): TVSCState;
var
  inputValue : Variant;               //输入值
  lastValue : Variant;                //上一个值
  acceptValue : Variant;              //接收的值
  bFlag : boolean;                    //比对结果
begin
  Result := vscUnMatch;
  //获取输入值
  inputValue := GetRecValue(Key,RecHead,RecRow);
  //获取上一个值
  if (m_pLastData <> nil) then
  begin
    lastValue := GetRecValue(Key,RecHead,TLKJRuntimeFileRec(m_pLastData));
  end;
  //如果数据跳变超过上限，则复位
  if m_breakLimit <> 0 then
  begin
    if Abs(inputValue - lastValue) > m_breakLimit then
    begin
      Reset();
      Exit;
    end;
  end;

  case order of
    vsoArc:
    begin
      {$region '需要上升趋势判断'}
      //第一次记录直接置为接收且保存第一次接收状态的数据
      if (m_pLastData = nil) or (m_pAcceptData = nil) then
      begin
        if m_pLastData = nil then
          m_pLastData := RecRow;
        if m_pAcceptData = nil then
          m_pAcceptData := RecRow;
        Result := vscAccept;
      end
      else begin
        //获取第一次接受的值
        acceptValue := GetRecValue(Key,RecHead,TLKJRuntimeFileRec(m_pAcceptData));

        if inputValue >= lastValue then
        begin
          {$region '当接收到上升趋势的数据时'}
          //判断是否上升了指定的值
          bFlag := (inputValue - acceptValue) > m_nValue;
          if (m_bIncludeEqual) then
            bFlag := (inputValue - acceptValue) >= m_nValue;
          if bFlag then
          begin
            {$region '结果匹配,记录状态为匹配中'}
            //上一次为未匹配则本次为接受状态，且记录第一次接受和匹配的值
            if State = vscUnMatch then
            begin
              m_pAcceptData := RecRow;
              m_pFitData := RecRow;
            end;
            //上一次为接受则本次仍为接受状态，且记录第一次匹配的值
            if (State = vscAccept) then
            begin
              m_pFitData := RecRow;
            end;
            Result := vscMatching;
            {$endregion '结果匹配,记录状态为匹配中'}
          end
          else begin
            {$region '结果不匹，记录状态为接收'}
            if State = vscUnMatch then
            begin
              m_pAcceptData := RecRow;
            end;
            Result := vscAccept;
            {$endregion '结果不匹，记录状态为接收'}
          end;
          {$endregion '当接收到上升趋势的数据时'}
        end
        else begin
          {$region '当接收到下降趋势的数据时'}
          bFlag := (acceptValue - lastValue) < m_nMaxValue;
          if bFlag then
          begin
            if State = vscMatching then
            begin
              Result := vscMatched;
            end
            else
              Result := vscUnMatch;
          end
          else
          begin
            Result := vscUnMatch;
          end;


          {$endregion '当接收到下降趋势的数据时'}
        end;
      end;
      {$endregion '需要上升趋势判断'}
    end;
    vsoDesc:
    begin
      {$region '需要下降趋势判断'}
      //第一次记录直接置为接收且保存第一次接收状态的数据
      if (m_pLastData = nil) or (m_pAcceptData = nil) then
      begin
        if m_pLastData = nil then
          m_pLastData := RecRow;
        if m_pAcceptData = nil then
          m_pAcceptData := RecRow;
        Result := vscAccept;
      end
      else begin
        //获取接受状态的值
        acceptValue := GetRecValue(Key,RecHead,TLKJRuntimeFileRec(m_pAcceptData));
        if inputValue <= lastValue then
        begin
          {$region '当接受到下降趋势的值'}
          bFlag := (acceptValue - inputValue) > m_nValue;
          if (m_bIncludeEqual) then
            bFlag := (acceptValue - inputValue) >= m_nValue;
          if bFlag then
          begin
            {$region '结果匹配，记录状态为匹配中'}
            //上次状态为未匹配则记录记录第一次接受及匹配中的值
            if (State = vscUnMatch)then
            begin
              m_pAcceptData := RecRow;
              m_pFitData := RecRow;
            end;
            //上一次状态为接受则记录第一次匹配中的值
            if (State = vscAccept) then
            begin
              m_pFitData := RecRow;
            end;
            Result := vscMatching;
            {$endregion '结果匹配，记录状态为匹配中'}
          end
          else
          begin
            {$region '结果不匹配，记录状态为接受中'}
            if State = vscUnMatch then
            begin
              m_pAcceptData := RecRow;
            end;
            Result := vscAccept;
            {$endregion '结果不匹配，记录状态为接受中'}
          end;
          {$endregion '当接受到下降趋势的值'}
        end
        else begin
          {$region '当接受到上升趋势的值'}
          bFlag := (lastValue - acceptValue) < m_nMaxValue;

          if bFlag then
          begin
            if State = vscMatching then
            begin
              Result := vscMatched;
            end
            else
              Result := vscUnMatch;
          end
          else
          begin
            Result := vscUnMatch;
          end;

          {$endregion '当接受到上升趋势的值'}
        end;
      end;
      {$endregion '需要下降趋势判断'}
    end;
  end;
  State := Result;
  inherited Match(RecHead,RecRow,RewList);
end;

end.
