unit uVSSimpleExpress;
{Υ��򵥱��ʽ��Ԫ}
interface
uses
  classes,Windows,SysUtils,Forms,DateUtils,
  uVSConst,uLKJRuntimeFile,uVSAnalysisResultList;
type

  TCustomGetValueEvent = function(RecHead:RLKJRTFileHeadInfo;
    RecRow:TLKJRuntimeFileRec):Variant of object;
  //////////////////////////////////////////////////////////////////////////////
  //TVSExpressionΥ���������ʽ���࣬���б��ʽ�Ӵμ̳�
  //////////////////////////////////////////////////////////////////////////////
  TVSExpression = class
  private
    {$region '˽�б���'}
    m_State : TVSCState;             //�����ĵ�ǰ״̬
    m_LastState : TVSCState;         //ǰһ��ƥ��״̬
    m_pLastData : Pointer;           //��һ������
    m_pFitData  : Pointer;           //��һ���ʺ�״̬������
    m_pAcceptData : Pointer;         //��һ������״̬������
    m_strTitle : string;             //���������־�ı��ʽ����
    m_bSaveFirstFit : boolean;       //������Ҫ�����һ��ƥ���л������һ��ƥ���е�����
    m_strExpressID : string;           //ID����ΪΨһ��ʶ��
    {$endregion '˽�б���'}
  protected
    function GetLastState: TVSCState;
    function GetState: TVSCState;virtual;
    function GetLastData: Pointer;virtual;
    procedure SetState(const Value: TVSCState);virtual;
    procedure SetAcceptData(const Value: Pointer);virtual;
    function GetAcceptData: Pointer;virtual;                     //��һ�������ʺϵ�ֵ
    procedure SetLastData(const Value: Pointer);virtual;
  public
    {$region '���졢����'}
    constructor Create();virtual;
    destructor Destroy();override;
    {$endregion '���졢����'}
  public
    //��ȡ״̬������˵��
    class function GetStateText(s : TVSCState) : string;
    //��ȡ���м�¼���е�����˵��
    class function GetColumnText(c : Integer) : string;
    //��ȡָ��������ѹ
    class function GetStandardPressure(RecHead:RLKJRTFileHeadInfo):integer;
    //��ȡ��ǰ��¼ָ��Υ�����ֵ
    class function GetRecValue(RecField : Integer;RecHead:RLKJRTFileHeadInfo;RecRow:TLKJRuntimeFileRec):Variant;
    //�ȶԵ������м�¼�������رȶԽ��
    function  Match(RecHead:RLKJRTFileHeadInfo;RecRow:TLKJRuntimeFileRec;RewList:TList): TVSCState;virtual;
    //��ճ�LastData������ֵ
    procedure Reset;virtual;
    //��հ���LastData��ֵ
    procedure Init;virtual;
    //���³�ʼ��״̬,�����ⲿ��ֵ���Լ���ֵ�����
    procedure InitState(Value : TVSCState);virtual;
    //��ȡʵ�ʵ�����
    function GetData : Pointer;virtual;
    function GetBeginData : Pointer;virtual;
    function GetEndData : Pointer;virtual;
  public
    {$region '����'}
    //ǰһ��ƥ��״̬
    property LastState : TVSCState read m_LastState write m_LastState;
    //��ǰƥ��״̬
    property State : TVSCState read m_State write SetState;
    //��һ����������
    property AcceptData : Pointer read m_pAcceptData write SetAcceptData;
    //��һ������
    property LastData : Pointer read m_pLastData write SetLastData;
    //��һ��FIT����
    property FitData  : Pointer read m_pFitData write m_pFitData;
    //���������־�ı��ʽ����
    property Title : string read m_strTitle write m_strTitle;
    //������Ҫ�����һ��ƥ���л������һ��ƥ���е�����
    property SaveFirstFit : boolean read m_bSaveFirstFit write m_bSaveFirstFit;
    //ID����ΪΨһ��ʶ��
    property ExpressID : string read m_strExpressID write m_strExpressID;
    {$endregion '����'}
  end;

  //////////////////////////////////////////////////////////////////////////////
  //TVSCompExpression �ȶԱ��ʽ  ���磺���� < 80
  //////////////////////////////////////////////////////////////////////////////
  TVSCompExpression = class(TVSExpression)
  private
    m_nKey : integer;                 //������
    m_OperatorSignal : TVSOperator;   //������
    m_Value : Variant;                //��������
    m_OnCustomGetValue : TCustomGetValueEvent;    //�ȶ�֮ǰ���û�����
  public
    //�ȶ����м�¼����ʽ����,
    function  Match(RecHead:RLKJRTFileHeadInfo;RecRow:TLKJRuntimeFileRec;RewList:TList): TVSCState;override;
    //������
    property Key : Integer read m_nKey write m_nKey;
    //������
    property OperatorSignal : TVSOperator read m_OperatorSignal write m_OperatorSignal;
    //��������
    property Value : Variant read m_Value write m_Value;
    //�ȶ�֮ǰ���û�����
    property OnCustomGetValue : TCustomGetValueEvent read m_OnCustomGetValue write m_OnCustomGetValue;
  end;


  TInOrNotIn = (tInNotIn,tInNotNot);

  //////////////////////////////////////////////////////////////////////////////
  //TVSInExpression In���ʽ  ���磺10��10��20��30��
  //////////////////////////////////////////////////////////////////////////////
  TVSInExpression = class(TVSExpression)
  private
    m_nKey : integer;
    m_OperatorSignal : TInOrNotIn;
    m_Value : TStrings;
  public
    {$region '���졢����'}
    constructor Create();override;
    destructor Destroy();override;
    {$endregion '���졢����'}
  public
    //�ȶ����м�¼����ʽ����,
    function  Match(RecHead:RLKJRTFileHeadInfo;RecRow:TLKJRuntimeFileRec;RewList:TList): TVSCState;override;
  public
    //������
    property Key : Integer read m_nKey write m_nKey;
    property OperatorSignal : TInOrNotIn read m_OperatorSignal write m_OperatorSignal;
    //��������
    property Value : TStrings read m_Value write m_Value;
  end;

  //////////////////////////////////////////////////////////////////////////////
  //TVSOrderExpression ˳����ʽ  ���磺�ٶ��½�
  //////////////////////////////////////////////////////////////////////////////
  TVSOrderExpression = class(TVSExpression)
  private
    m_nKey : Integer;           //������
    m_Order : TVSOrder;        //˳��
  public
    constructor Create(); override;
  public
    //�ȶ����м�¼����ʽ����,
    function  Match(RecHead:RLKJRTFileHeadInfo;RecRow:TLKJRuntimeFileRec;RewList:TList): TVSCState;override;
    //���������
    property Key : Integer read m_nKey write m_nKey;
    //����ֵ
    property Order : TVSOrder read m_Order write m_Order;

  end;

  //////////////////////////////////////////////////////////////////////////////
  //TVSOffsetExpression ˳���ֵ���ʽ  ���磺��ѹ�½�80kpa
  ///////   ///////////////////////////////////////////////////////////////////////
  TVSOffsetExpression = class(TVSExpression)
  private
    m_nKey : Integer;           //������
    m_Order : TVSOrder;         //˳��
    m_nValue : Integer;         //�ٽ�ֵ (���Ӷ��ٻ���ٶ���)
    m_bIncludeEqual : boolean;  //�Ƿ��������
    m_breakLimit : Integer;
  public
    constructor Create();override;
    //�ȶ����м�¼����ʽ����,
    function  Match(RecHead:RLKJRTFileHeadInfo;RecRow:TLKJRuntimeFileRec;RewList:TList): TVSCState;override;
     //������
    property Key : Integer read m_nKey write m_nKey;
    //˳��
    property Order : TVSOrder read m_Order write m_Order;
    //�ٽ�ֵ (���Ӷ��ٻ���ٶ���)
    property Value : Integer read m_nValue write m_nValue;
    //�Ƿ��������
    property IncludeEqual : boolean read m_bIncludeEqual write m_bIncludeEqual;
    //��ֵ�������ޣ����䳬����Reset
    property BreakLimit : Integer read m_breakLimit write m_breakLimit;
  end;


  //////////////////////////////////////////////////////////////////////////////
  //TVSOffsetExExpression ˳���ֵ���ʽ �� TVSOffsetExpression���������Ӳ�ֵ����
  //���ֵ��������������Ҫ��Χ
  //////////////////////////////////////////////////////////////////////////////
  TVSOffsetExExpression = class(TVSExpression)
  private
    m_nKey : Integer;           //������
    m_Order : TVSOrder;         //˳��
    m_nValue : Integer;         //�ٽ�ֵ (���Ӷ��ٻ���ٶ���)
    m_bIncludeEqual : boolean;  //�Ƿ��������
    m_breakLimit : Integer;
    m_nMaxValue : Integer;      //��ֵ����
  public
    constructor Create();override;
    //�ȶ����м�¼����ʽ����,
    function  Match(RecHead:RLKJRTFileHeadInfo;RecRow:TLKJRuntimeFileRec;RewList:TList): TVSCState;override;
     //������
    property Key : Integer read m_nKey write m_nKey;
    //˳��
    property Order : TVSOrder read m_Order write m_Order;
    //�ٽ�ֵ (���Ӷ��ٻ���ٶ���)
    property Value : Integer read m_nValue write m_nValue;
    //��ֵ����
    property MaxValue : Integer read m_nMaxValue write m_nMaxValue;
    //�Ƿ��������
    property IncludeEqual : boolean read m_bIncludeEqual write m_bIncludeEqual;
    //��ֵ�������ޣ����䳬����Reset
    property BreakLimit : Integer read m_breakLimit write m_breakLimit;
  end;

  //////////////////////////////////////////////////////////////////////////////
  //TVSCompBehindExpression ���ñȶԱ��ʽ  ���ڱȶ�ǰ����ʽ�Ľ��
  //////////////////////////////////////////////////////////////////////////////
  TVSCompBehindExpression = class(TVSExpression)
  private
    m_Key : Integer;                      //�ȶ��ֶ�
    m_OperatorSignal : TVSOperator;       //�ȶԷ�ʽ
    m_CompDataType : TVSDataType;         //�ȶ�����
    m_nValue : Integer;                   //�ȶԲ�ֵ
    m_FrontExp : TVSExpression;           //ǰһ���򵥱��ʽ
    m_BehindExp : TVSExpression;          //��һ���򵥱��ʽ
  public
    //�ȶ����м�¼����ʽ����,
    function  Match(RecHead:RLKJRTFileHeadInfo;RecRow:TLKJRuntimeFileRec;RewList:TList): TVSCState;override;
    //�ȶ��ֶ�
    property Key : Integer read m_Key write m_Key;
    //�ȶԷ�ʽ
    property OperatorSignal : TVSOperator read m_OperatorSignal write m_OperatorSignal;
    //�ȶ�����
    property CompDataType : TVSDataType read m_CompDataType write m_CompDataType;
    //�ȶԲ�ֵ
    property Value : Integer read m_nValue write m_nValue;
    //ǰһ���򵥱��ʽ
    property FrontExp : TVSExpression read m_FrontExp write m_FrontExp;
    //��һ���򵥱��ʽ
    property BehindExp : TVSExpression read m_BehindExp write m_BehindExp;
  end;

  TVSCompExpExpression = class(TVSExpression)
  private
    m_Key : Integer;                      //�ȶ��ֶ�
    m_OperatorSignal : TVSOperator;       //�ȶԷ�ʽ
    m_CompDataType : TVSDataType;         //�ȶ�����
    m_nValue : Integer;                   //�ȶԲ�ֵ
    m_Expression : TVSExpression;
  public
    //�ȶ����м�¼����ʽ����,
    function  Match(RecHead:RLKJRTFileHeadInfo;RecRow:TLKJRuntimeFileRec;RewList:TList): TVSCState;override;
  public
    //�ȶ��ֶ�
    property Key : Integer read m_Key write m_Key;
    //�ȶԷ�ʽ
    property OperatorSignal : TVSOperator read m_OperatorSignal write m_OperatorSignal;
    //�ȶ�����
    property CompDataType : TVSDataType read m_CompDataType write m_CompDataType;
    //�ȶԲ�ֵ
    property Value : Integer read m_nValue write m_nValue;
    //���ʽ
    property Expression : TVSExpression read m_Expression write m_Expression;
  end;
  /////////////////////////////////////////////////////////////////////////
  ///TVSSimpleIntervalExpression ����һ����Χ�ڴӵ�һ�������һ��ĳһ����
  ///��ʼ����Χ�����ı��ʽ����ָ��������ʼ������Χ��������ֵΪMatching����
  ///����ΪUnmatch
  /////////////////////////////////////////////////////////////////////////
  TVSSimpleIntervalExpression = class(TVSExpression)
  private
    m_StartKey : Integer;               //��ʼ����
    m_EndKey : Integer;                 //��������
    m_Expression : TVSExpression;          //ʵ�ʱȶԱ��ʽ
    m_StartValue : Variant;
    m_EndValue : Variant;
    m_StartPos : Integer;               //���ҵ��ķ�Χ��ʼ����
    m_EndPos : Integer;                 //���ҵ��ķ�Χ��������
    m_IsScaned : Boolean;               //�Ѿ�ɨ�����־

  public
    constructor Create();override;
    destructor Destroy; override;
  public
    //��ճ�LastData������ֵ
    procedure Reset;override;
    //��հ���LastData��ֵ
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
    m_OperatorSignal : TVSOperator;       //�ȶԷ�ʽ
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
  ///TVSSimpleConditionExpression ������Expression��һֱ����Matched��δ����ǰ
  ///��������UnMatch
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

{$region 'TVSExpression  ʵ��'}
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
  Result := '�쳣��';
  case c of
    CommonRec_Column_GuanYa   : Result := '��ѹ';
    CommonRec_Column_GangYa   : Result := '��ѹ';
    CommonRec_Column_Sudu     : Result := '�ٶ�';
    CommonRec_Column_WorkZero : Result := '������λ';
    CommonRec_Column_HandPos  : Result := '����ǰ��';
    CommonRec_Column_WorkDrag : Result := '�ֱ�λ��';
    CommonRec_Column_DTEvent  : Result := 'ʱ��';
    CommonRec_Column_Distance : Result := '�źŻ�����';
    CommonRec_Column_LampSign : Result := '�źŵ�';

    CommonRec_Column_SpeedLimit : Result := '����';
    CommonRec_Head_TotalWeight: Result := '����';
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
     CommonRec_Head_TotalWeight://����
     begin
       result := RecHead.nTotalWeight;
       exit;
     end;
     CommonRec_Head_CheCi: //����
     begin
       result := RecHead.nTrainNo;
       exit;
     end;
     CommonRec_Head_LiangShu: //����
     begin
       result := RecHead.nSum;
       exit;
     end;
     CommonRec_Head_LocalType: //����
     begin
       result := RecHead.nLocoType;
       exit;
     end;
     CommonRec_Head_LocalID: //����
     begin
       result := RecHead.nLocoID;
       exit;
     end;
     CommonRec_Head_Factory: //��س���
     begin
       result := RecHead.Factory;
       exit;
     end;
  end;
  if RecRow = nil then
  begin
    //�쳣
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

     CommonRec_Column_Distance:      //�źŻ�����;
     begin
       result := TLKJCommonRec(RecRow).CommonRec.nDistance;
       exit;
     end;
     CommonRec_Column_LampSign :      //�źŵ�����;
     begin
       result := TLKJCommonRec(RecRow).CommonRec.LampSign;
       exit;
     end;
     CommonRec_Column_SpeedLimit :      //�źŵ�����;
     begin
       result := TLKJCommonRec(RecRow).CommonRec.nLimitSpeed;
       exit;
     end;
     CommonRec_Event_Column : //�¼����
     begin
       result := TLKJCommonRec(RecRow).CommonRec.nEvent;
       exit;
     end;
     CommonRec_Column_GangYa: //��ѹ
     begin
       result := TLKJCommonRec(RecRow).CommonRec.nGangPressure;
       exit;
     end;
     CommonRec_Column_Other: //����
     begin
       result := TLKJCommonRec(RecRow).CommonRec.strOther;
       exit;
     end;
     CommonRec_Column_StartStation : //�յ�վ
     begin
       result := TLKJCommonRec(RecRow).CommonRec.nStation;
       exit;
     end;
     CommonRec_Column_EndStation : //�յ�վ
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
  Result := '�쳣״̬';
  case s of
    vscAccept: result := '����';
    vscMatching: result := 'ƥ����';
    vscMatched: result := '��ƥ��';
    vscUnMatch: result := 'δƥ��';
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
  //�ȶԽ����ֵ�����ʽ״̬
  VSLog.AddExpress(self,RecHead,RecRow);
  //�������ݵ���һ������
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

{$region 'TVSCompExpression ʵ��'}

//�ȶ����м�¼����ʽ����,
function TVSCompExpression.Match(RecHead: RLKJRTFileHeadInfo;
  RecRow: TLKJRuntimeFileRec;RewList:TList): TVSCState;
const
  SPVAILD =20;            //��ѹ����Ч��Χ
var
  inputValue : Variant;   //��ǰ��˵��ֵ
  transValue : Variant;   //��ѹ����������ֵ
  bFlag : Boolean;        //�ȶԽ��
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
  //�ȶԽ��
  bFlag := false;
  //��ȥ�����ֵ
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
    {$region '��ѹ�ȶ����⴦��'}
    transValue := Value - SYSTEM_STANDARDPRESSURE +  GetStandardPressure(RecHead);
    {$endregion '�����ѹ����ѹ��ֵ'}
   end;
    {$region '�ȶ�����ֵ���׼ֵ'}
    case OperatorSignal of
      vspMore: //����
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
    {$endregion '�ȶ�����ֵ���׼ֵ'}
  end;

  //�����һ���Ѿ�ƥ������ж���һ�����ݺʹ˴������Ƿ���ȣ������򷵻ز�ƥ��
  if (m_pLastData <> nil) and (OperatorSignal = vspEqual) and ((State = vscMatching) or (State = vscMatched)) then
  begin
    if GetRecValue(Key,RecHead,m_pLastData) <> inputValue then
    begin
      bFlag := false;
    end;
  end;

  {$region '״̬�ж�'}
  //�ȶ�ͨ��
  if bFlag then
  begin
    {$region '�ȶ�ͨ��'}
    //��ǰһ��״̬Ϊ��ƥ�䣬��״̬��Ϊ�ʺϣ��Ҽ�¼��һ���ʺϵ�����
    if (State = vscUnMatch) or (State = vscAccept) then
    begin
      m_pFitData := RecRow;
    end;
    //�������һ��ƥ��ֵ
    if not SaveFirstFit then
      m_pFitData := RecRow;
    Result := vscMatching;
    {$endregion '�ȶ�ͨ��'}
  end
  else begin
    {$region '�ȶԲ�ͨ��'}
    //��ǰһ��״̬Ϊ�ʺϣ���״̬��Ϊƥ�䣬����״̬��Ϊ��ƥ��
    if State = vscMatching then
      Result := vscMatched
    else
      Result := vscUnMatch;
    {$endregion '�ȶԲ�ͨ��'}  
  end;
  {$endregion '״̬�ж�'}

  State := Result;
  inherited Match(RecHead,RecRow,RewList);
end;

{$endregion 'TVSCompExpression ʵ��'}

{$region 'TVSOrderExpression ʵ��'}
{ TVSOrderExpression }

//�ȶ����м�¼����ʽ����,
constructor TVSOrderExpression.Create;
begin
  m_nKey := 0;
  inherited;
end;

function TVSOrderExpression.Match(RecHead: RLKJRTFileHeadInfo;
  RecRow: TLKJRuntimeFileRec;RewList:TList): TVSCState;
var
  inputValue : Variant;     //�����ֵ
  lastValue : Variant;      //��һ��ֵ
begin
  Result := vscUnMatch;
  //��ȡ����ֵ
  inputValue := GetRecValue(Key,RecHead,RecRow);
  //��ȡ��һ��ֵ
  if (m_pLastData <> nil) then
  begin
    lastValue := GetRecValue(Key,RecHead,TLKJRuntimeFileRec(m_pLastData));
  end;

  //�ж��������
  case order of
    vsoArc:
    begin
      {$region '��Ҫ����������'}
      //��Ϊ��һ������ʱ,ֱ����Ϊ����״̬
      if m_pLastData = nil then
      begin
        m_pLastData := RecRow;
        m_pAcceptData := RecRow;
        Result := vscAccept;
      end
      else begin
        if inputValue >= lastValue then
        begin
          {$region '�������ֵ������������'}
          if inputValue = lastValue then
          begin
            {$region '����ֵ���ʱ'}
            //��һ��Ϊ��ƥ�䣬�˴�Ϊ�����Ҽ�¼��һ�����յ�ֵ
            if State = vscUnMatch then
            begin
               m_pAcceptData := RecRow;
               Result := vscAccept;
            end;
            //��һ��Ϊ���գ��˴���Ϊ����
            if State = vscAccept then
            begin
              Result := vscAccept;
            end;
            //��һ��Ϊƥ���У��˴���Ϊ����
            if State = vscMatching then
            begin
              Result := vscMatching;              
            end;
            {$endregion '����ֵ���ʱ'}
          end
          else begin
            {$region '�������ֵΪ����ʱ��״̬��Ϊƥ����'}
            //����һ��Ϊδƥ����˴�Ϊ�����У��Ҽ�¼��һ�����յ�ֵ����һ��ƥ���е�ֵ
            if State = vscUnMatch then
            begin
              m_pAcceptData := RecRow;
              m_pFitData := RecRow;
            end;
            //����һ��Ϊ��������˴�Ϊƥ���У��Ҽ�¼��һ��ƥ���е�ֵ
            if State = vscAccept then
            begin
              m_pFitData := RecRow;
            end;
            Result := vscMatching;
            {$endregion '�������ֵΪ����ʱ��״̬��Ϊƥ����'}
          end;
          {$endregion '�������ֵ������������'}
        end
        else begin
          {$region '�������ֵΪ�½�ʱ'}
          if State = vscMatching then
          begin
            Result := vscMatched;
          end else
            Result := vscUnMatch;
          {$endregion '�������ֵΪ�½�ʱ'}  
        end;
      end;
      {$endregion ��Ҫ����������}
    end;
    vsoDesc:
    begin
      {$region '��Ҫ�½�������'}
      //��Ϊ��һ������ʱ,ֱ����Ϊ����״̬
      if m_pLastData = nil then
      begin
        m_pLastData := RecRow;
        m_pAcceptData := RecRow;
        Result := vscAccept;
      end
      else begin
        if inputValue <= lastValue then
        begin
          {$region '�������ֵ�����½�����'}
          if inputValue = lastValue then
          begin
            {$region '����ֵ���ʱ'}
            //��һ��Ϊ��ƥ�䣬�˴�Ϊ�����Ҽ�¼��һ�����յ�ֵ
            if State = vscUnMatch then
            begin
               m_pAcceptData := RecRow;
               Result := vscAccept;
            end;
            //��һ��Ϊ���գ��˴���Ϊ����
            if State = vscAccept then
            begin
              Result := vscAccept;
            end;
            //��һ��Ϊƥ���У��˴���Ϊ����
            if State = vscMatching then
            begin
              Result := vscMatching;              
            end;
            {$endregion '����ֵ���ʱ'}
          end
          else begin
            {$region '�������ֵΪ�½�ʱ��״̬��Ϊƥ����'}
            //����һ��Ϊδƥ����˴�Ϊ�����У��Ҽ�¼��һ�����յ�ֵ����һ��ƥ���е�ֵ
            if State = vscUnMatch then
            begin
              m_pAcceptData := RecRow;
              m_pFitData := RecRow;
            end;
            //����һ��Ϊ��������˴�Ϊƥ���У��Ҽ�¼��һ��ƥ���е�ֵ
            if State = vscAccept then
            begin
              m_pFitData := RecRow;
            end;
            Result := vscMatching;
            {$endregion '�������ֵΪ����ʱ��״̬��Ϊƥ����'}
          end;
          {$endregion '�������ֵ�����½�����'}
        end
        else begin
          {$region '�������ֵΪ����ʱ'}
          if State = vscMatching then
          begin
            Result := vscMatched;
          end else
            Result := vscUnMatch;
          {$endregion '�������ֵΪ����ʱ'}  
        end;
      end;
      {$endregion ��Ҫ�½�������}
    end;
  end;
  State := Result;
  inherited Match(RecHead,RecRow,RewList);
end;

{$endregion 'TVSOrderExpression ʵ��'}

{$region 'TVSOffsetExpression ʵ��'}
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
  inputValue : Variant;               //����ֵ
  lastValue : Variant;                //��һ��ֵ
  acceptValue : Variant;              //���յ�ֵ
  bFlag : boolean;                    //�ȶԽ��
begin
  Result := vscUnMatch;
  //��ȡ����ֵ
  inputValue := GetRecValue(Key,RecHead,RecRow);
  //��ȡ��һ��ֵ
  if (m_pLastData <> nil) then
  begin
    lastValue := GetRecValue(Key,RecHead,TLKJRuntimeFileRec(m_pLastData));
  end;
  //����������䳬�����ޣ���λ
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
      {$region '��Ҫ���������ж�'}
      //��һ�μ�¼ֱ����Ϊ�����ұ����һ�ν���״̬������
      if (m_pLastData = nil) or (m_pAcceptData = nil) then
      begin
        if m_pLastData = nil then
          m_pLastData := RecRow;
        if m_pAcceptData = nil then
          m_pAcceptData := RecRow;
        Result := vscAccept;
      end
      else begin
        //��ȡ��һ�ν��ܵ�ֵ
        acceptValue := GetRecValue(Key,RecHead,TLKJRuntimeFileRec(m_pAcceptData));

        if inputValue >= lastValue then
        begin
          {$region '�����յ��������Ƶ�����ʱ'}
          //�ж��Ƿ�������ָ����ֵ
          bFlag := (inputValue - acceptValue) > m_nValue;
          if (m_bIncludeEqual) then
            bFlag := (inputValue - acceptValue) >= m_nValue;
          if bFlag then
          begin
            {$region '���ƥ��,��¼״̬Ϊƥ����'}
            //��һ��Ϊδƥ���򱾴�Ϊ����״̬���Ҽ�¼��һ�ν��ܺ�ƥ���ֵ
            if State = vscUnMatch then
            begin
              m_pAcceptData := RecRow;
              m_pFitData := RecRow;
            end;
            //��һ��Ϊ�����򱾴���Ϊ����״̬���Ҽ�¼��һ��ƥ���ֵ
            if (State = vscAccept) then
            begin
              m_pFitData := RecRow;
            end;
            Result := vscMatching;
            {$endregion '���ƥ��,��¼״̬Ϊƥ����'}
          end
          else begin
            {$region '�����ƥ����¼״̬Ϊ����'}
            if State = vscUnMatch then
            begin
              m_pAcceptData := RecRow;
            end;
            Result := vscAccept;
            {$endregion '�����ƥ����¼״̬Ϊ����'}
          end;
          {$endregion '�����յ��������Ƶ�����ʱ'}
        end
        else begin
          {$region '�����յ��½����Ƶ�����ʱ'}
          if State = vscMatching then
          begin
            Result := vscMatched;
          end
          else
            Result := vscUnMatch;
          {$endregion '�����յ��½����Ƶ�����ʱ'}  
        end;
      end;
      {$endregion '��Ҫ���������ж�'}
    end;
    vsoDesc:
    begin
      {$region '��Ҫ�½������ж�'}
      //��һ�μ�¼ֱ����Ϊ�����ұ����һ�ν���״̬������
      if (m_pLastData = nil) or (m_pAcceptData = nil) then
      begin
        if m_pLastData = nil then
          m_pLastData := RecRow;
        if m_pAcceptData = nil then
          m_pAcceptData := RecRow;
        Result := vscAccept;
      end
      else begin
        //��ȡ����״̬��ֵ
        acceptValue := GetRecValue(Key,RecHead,TLKJRuntimeFileRec(m_pAcceptData));
        if inputValue <= lastValue then
        begin
          {$region '�����ܵ��½����Ƶ�ֵ'}
          bFlag := (acceptValue - inputValue) > m_nValue;
          if (m_bIncludeEqual) then
            bFlag := (acceptValue - inputValue) >= m_nValue;           
          if bFlag then
          begin
            {$region '���ƥ�䣬��¼״̬Ϊƥ����'}
            //�ϴ�״̬Ϊδƥ�����¼��¼��һ�ν��ܼ�ƥ���е�ֵ
            if (State = vscUnMatch)then
            begin
              m_pAcceptData := RecRow;
              m_pFitData := RecRow;
            end;
            //��һ��״̬Ϊ�������¼��һ��ƥ���е�ֵ
            if (State = vscAccept) then
            begin
              m_pFitData := RecRow;
            end;
            Result := vscMatching;
            {$endregion '���ƥ�䣬��¼״̬Ϊƥ����'}
          end
          else
          begin
            {$region '�����ƥ�䣬��¼״̬Ϊ������'}
            if State = vscUnMatch then
            begin
              m_pAcceptData := RecRow;
            end;
            Result := vscAccept;
            {$endregion '�����ƥ�䣬��¼״̬Ϊ������'}
          end;
          {$endregion '�����ܵ��½����Ƶ�ֵ'}
        end
        else begin
          {$region '�����ܵ��������Ƶ�ֵ'}
          if State = vscMatching then
          begin
            Result := vscMatched;
          end
          else
            Result := vscUnMatch;
          {$endregion '�����ܵ��������Ƶ�ֵ'}
        end;
      end;
      {$endregion '��Ҫ�½������ж�'}
    end;
  end;
  State := Result;
  inherited Match(RecHead,RecRow,RewList);
end;

{ TVSCombExpression }
{$endregion 'TVSOffsetExpression ʵ��'}

{$region 'TVSCompBehindExpression ʵ��'}

{ TVSCompBehindExpression }
function TVSCompBehindExpression.Match(RecHead: RLKJRTFileHeadInfo;RecRow:TLKJRuntimeFileRec;RewList:TList): TVSCState;
var
  frontValue : Variant;            //ǰ���ֵ
  behindValue : Variant;           //�����ֵ
  bFlag : boolean;                 //�ȶԽ��
begin
  frontValue := 0;
  behindValue := 0;

  if (m_CompDataType=vsdtAccept) then
  begin
    {$region '�ȶԽ��ܵ�ֵ'}
    frontValue := GetRecValue(Key,recHead,TLKJRuntimeFileRec(m_FrontExp.m_pAcceptData));
    behindValue := GetRecValue(Key,recHead,TLKJRuntimeFileRec(m_BehindExp.m_pAcceptData));
    {$endregion '�ȶԽ��ܵ�ֵ'}
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
    
    {$region '�ȶ�ƥ���ֵ'}
    frontValue := GetRecValue(Key,recHead,TLKJRuntimeFileRec(m_FrontExp.GetData));
    behindValue := GetRecValue(Key,recHead,TLKJRuntimeFileRec(m_BehindExp.GetData));
    {$endregion '�ȶ�ƥ���ֵ'}
  end;
  if (m_CompDataType=vsdtLast) then
  begin
    {$region '�ȶ���һ����ֵ'}
    frontValue := GetRecValue(Key,recHead,TLKJRuntimeFileRec(m_FrontExp.LastData));
    behindValue := GetRecValue(Key,recHead,TLKJRuntimeFileRec(m_BehindExp.LastData));
    {$endregion '�ȶ���һ����ֵ'}
  end;
  bFlag := false;
  case m_OperatorSignal of
    {$region '�ȶԽ�������þ���ֵ��ֵ�Ƚ�'}
    vspMore : bFlag :=  (Abs(behindValue - frontValue) > Value);
    vspLess : bFlag :=  (Abs(frontValue - behindValue) < Value);
    vspEqual : bFlag :=  (behindValue = (frontValue + Value));
    vspNoMore: bFlag :=  (Abs(frontValue - behindValue) <= Value);
    vspNoLess : bFlag :=  (Abs(frontValue - behindValue) >= Value);
    vspNoEqual:  bFlag :=  (behindValue <> (frontValue + Value));
    {$endregion '�ȶԽ�������þ���ֵ��ֵ�Ƚ�'}
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
  inputValue : Variant;   //��ǰ��˵��ֵ
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
  //�ȶ�ͨ��
  if bFlag then
  begin
    {$region '�ȶ�ͨ��'}
    //��ǰһ��״̬Ϊ��ƥ�䣬��״̬��Ϊ�ʺϣ��Ҽ�¼��һ���ʺϵ�����
    if (State = vscUnMatch) or (State = vscAccept) then
    begin
      m_pFitData := RecRow;
    end;
    //�������һ��ƥ��ֵ
    if not SaveFirstFit then
      m_pFitData := RecRow;
    Result := vscMatching;
    {$endregion '�ȶ�ͨ��'}
  end
  else begin
    {$region '�ȶԲ�ͨ��'}
    //��ǰһ��״̬Ϊ�ʺϣ���״̬��Ϊƥ�䣬����״̬��Ϊ��ƥ��
    if State = vscMatching then
      Result := vscMatched
    else
      Result := vscUnMatch;
    {$endregion '�ȶԲ�ͨ��'}  
  end;
  {$endregion '״̬�ж�'}

  State := Result;
  inherited Match(RecHead,RecRow,RewList);
end;

{ TVSCompExpExpression }

function TVSCompExpExpression.Match(RecHead: RLKJRTFileHeadInfo;
  RecRow: TLKJRuntimeFileRec; RewList: TList): TVSCState;
const
  SPVAILD =20;            //��ѹ����Ч��Χ
var
  inputValue : Variant;
  transValue : Variant;   //��ѹ����������ֵ
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
    {$region '��ѹ�ȶ����⴦��'}
    transValue := Value - SYSTEM_STANDARDPRESSURE +  GetStandardPressure(RecHead);
    {$endregion '�����ѹ����ѹ��ֵ'}
   end;
    {$region '�ȶ�����ֵ���׼ֵ'}
    case OperatorSignal of
      vspMore: //����
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
    {$endregion '�ȶ�����ֵ���׼ֵ'}
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
  inputValue : Variant;               //����ֵ
  lastValue : Variant;                //��һ��ֵ
  acceptValue : Variant;              //���յ�ֵ
  bFlag : boolean;                    //�ȶԽ��
begin
  Result := vscUnMatch;
  //��ȡ����ֵ
  inputValue := GetRecValue(Key,RecHead,RecRow);
  //��ȡ��һ��ֵ
  if (m_pLastData <> nil) then
  begin
    lastValue := GetRecValue(Key,RecHead,TLKJRuntimeFileRec(m_pLastData));
  end;
  //����������䳬�����ޣ���λ
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
      {$region '��Ҫ���������ж�'}
      //��һ�μ�¼ֱ����Ϊ�����ұ����һ�ν���״̬������
      if (m_pLastData = nil) or (m_pAcceptData = nil) then
      begin
        if m_pLastData = nil then
          m_pLastData := RecRow;
        if m_pAcceptData = nil then
          m_pAcceptData := RecRow;
        Result := vscAccept;
      end
      else begin
        //��ȡ��һ�ν��ܵ�ֵ
        acceptValue := GetRecValue(Key,RecHead,TLKJRuntimeFileRec(m_pAcceptData));

        if inputValue >= lastValue then
        begin
          {$region '�����յ��������Ƶ�����ʱ'}
          //�ж��Ƿ�������ָ����ֵ
          bFlag := (inputValue - acceptValue) > m_nValue;
          if (m_bIncludeEqual) then
            bFlag := (inputValue - acceptValue) >= m_nValue;
          if bFlag then
          begin
            {$region '���ƥ��,��¼״̬Ϊƥ����'}
            //��һ��Ϊδƥ���򱾴�Ϊ����״̬���Ҽ�¼��һ�ν��ܺ�ƥ���ֵ
            if State = vscUnMatch then
            begin
              m_pAcceptData := RecRow;
              m_pFitData := RecRow;
            end;
            //��һ��Ϊ�����򱾴���Ϊ����״̬���Ҽ�¼��һ��ƥ���ֵ
            if (State = vscAccept) then
            begin
              m_pFitData := RecRow;
            end;
            Result := vscMatching;
            {$endregion '���ƥ��,��¼״̬Ϊƥ����'}
          end
          else begin
            {$region '�����ƥ����¼״̬Ϊ����'}
            if State = vscUnMatch then
            begin
              m_pAcceptData := RecRow;
            end;
            Result := vscAccept;
            {$endregion '�����ƥ����¼״̬Ϊ����'}
          end;
          {$endregion '�����յ��������Ƶ�����ʱ'}
        end
        else begin
          {$region '�����յ��½����Ƶ�����ʱ'}
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


          {$endregion '�����յ��½����Ƶ�����ʱ'}
        end;
      end;
      {$endregion '��Ҫ���������ж�'}
    end;
    vsoDesc:
    begin
      {$region '��Ҫ�½������ж�'}
      //��һ�μ�¼ֱ����Ϊ�����ұ����һ�ν���״̬������
      if (m_pLastData = nil) or (m_pAcceptData = nil) then
      begin
        if m_pLastData = nil then
          m_pLastData := RecRow;
        if m_pAcceptData = nil then
          m_pAcceptData := RecRow;
        Result := vscAccept;
      end
      else begin
        //��ȡ����״̬��ֵ
        acceptValue := GetRecValue(Key,RecHead,TLKJRuntimeFileRec(m_pAcceptData));
        if inputValue <= lastValue then
        begin
          {$region '�����ܵ��½����Ƶ�ֵ'}
          bFlag := (acceptValue - inputValue) > m_nValue;
          if (m_bIncludeEqual) then
            bFlag := (acceptValue - inputValue) >= m_nValue;
          if bFlag then
          begin
            {$region '���ƥ�䣬��¼״̬Ϊƥ����'}
            //�ϴ�״̬Ϊδƥ�����¼��¼��һ�ν��ܼ�ƥ���е�ֵ
            if (State = vscUnMatch)then
            begin
              m_pAcceptData := RecRow;
              m_pFitData := RecRow;
            end;
            //��һ��״̬Ϊ�������¼��һ��ƥ���е�ֵ
            if (State = vscAccept) then
            begin
              m_pFitData := RecRow;
            end;
            Result := vscMatching;
            {$endregion '���ƥ�䣬��¼״̬Ϊƥ����'}
          end
          else
          begin
            {$region '�����ƥ�䣬��¼״̬Ϊ������'}
            if State = vscUnMatch then
            begin
              m_pAcceptData := RecRow;
            end;
            Result := vscAccept;
            {$endregion '�����ƥ�䣬��¼״̬Ϊ������'}
          end;
          {$endregion '�����ܵ��½����Ƶ�ֵ'}
        end
        else begin
          {$region '�����ܵ��������Ƶ�ֵ'}
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

          {$endregion '�����ܵ��������Ƶ�ֵ'}
        end;
      end;
      {$endregion '��Ҫ�½������ж�'}
    end;
  end;
  State := Result;
  inherited Match(RecHead,RecRow,RewList);
end;

end.
