unit uVSCombExpress;
{Υ����ϱ��ʽ��Ԫ}
interface
uses
  classes,Windows,SysUtils,Forms,DateUtils,
  uVSConst,uVSSimpleExpress,uLKJRuntimeFile;
type
  //////////////////////////////////////////////////////////////////////////////
  //TVSExpressionCollection��Υ����ʽ�б��࣬����TList�̳�
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
  //TVSCombExpression �������ʽ����  ���ñ��ʽ�б�
  //////////////////////////////////////////////////////////////////////////////
  TVSCombExpression = class(TVSExpression)
  private
    m_Expressions : TVSExpressionCollection;         //���ʽ�б�
    m_ParentData : Pointer;                          //����־�ڵ�
    m_CurData : Pointer;                             //��ǰ��־�ڵ�
  protected
    procedure CreateLog;                             //���ɵ�ǰ��־�ڵ�
    procedure SetState(const Value: TVSCState);override;
    procedure SetAcceptData(const Value: Pointer);override;
    procedure SetLastData(const Value: Pointer);override;         //��һ������״̬����
    function GetAcceptData: Pointer;override;
  public
    constructor Create();override;
    destructor Destroy();override;
  public
    //������ݣ���Ҫ���ڵ��������ӱ��ʽ����շ���
    procedure Reset;override;
    //��հ���LastData��ֵ
    procedure Init;override;
    //���³�ʼ��״̬,�����ⲿ��ֵ���Լ���ֵ�����
    procedure InitState(Value : TVSCState);override;
    //��д��ȡ����
    function GetData : Pointer;override;
    //�ȶ����м�¼����ʽ����,
    function  Match(RecHead:RLKJRTFileHeadInfo;RecRow:TLKJRuntimeFileRec;RowList:TList): TVSCState;override;
  public
    //���ʽ�б�
    property Expressions : TVSExpressionCollection read m_Expressions write m_Expressions;
    //����־�ڵ�
    property ParentData : Pointer read m_ParentData write m_ParentData;
    //��ǰ��־�ڵ�
    property CurData : Pointer read m_CurData write m_CurData;
  end;

  //////////////////////////////////////////////////////////////////////////////
  //TVSCombAndExpression �������ʽ  ���ñ��ʽ�б���ͬʱƥ��ʱ�ﵽ��������
  //////////////////////////////////////////////////////////////////////////////
  TVSCombAndExpression = class(TVSCombExpression)
  public
    //��д��ȡ����
    function GetData : Pointer;override;
    function  Match(RecHead:RLKJRTFileHeadInfo;RecRow:TLKJRuntimeFileRec;RowList:TList): TVSCState;override;
  end;

  //////////////////////////////////////////////////////////////////////////////
  //TVSComboOrExpression ���ϻ���ʽ  ���ñ��ʽ�б���ƥ������һ��ʱ�ﵽ��������
  //////////////////////////////////////////////////////////////////////////////
  TVSCombOrExpression = class(TVSCombExpression)
  public
    function GetChildrenData : Pointer;
    //��д��ȡ����
    function GetData : Pointer;override;
    function  Match(RecHead:RLKJRTFileHeadInfo;RecRow:TLKJRuntimeFileRec;RowList:TList): TVSCState;override;
  end;

  //////////////////////////////////////////////////////////////////////////////
  //TVSCombOrderExpression
  //����˳����ʽ  ���ñ��ʽ�б���Ҫ������˳��ƥ�䣬�����������㲶��
  //////////////////////////////////////////////////////////////////////////////
  TVSCombOrderExpression = class(TVSCombExpression)
  private
    //��ǰ����ʽ����
    m_nActiveIndex : Integer;
    //��������ֵ�Ľڵ�
    m_nMatchedIndex : Integer;
    //��ʼ��Χ�ı��ʽ������
    m_nBeginIndex : integer;
    //������Χ�ı��ʽ������
    m_nEndIndex : integer;
  protected
    function GetAcceptData: Pointer; override;
  public
    constructor Create();override;
    //������ݣ���Ҫ���ڵ��������ӱ��ʽ����շ���
    procedure Reset;override;

    procedure Init;override;
    //��д��ȡ����
    function GetData : Pointer;override;
    function GetBeginData : Pointer;override;
    function GetEndData : Pointer;override;
  public
    function  Match(RecHead:RLKJRTFileHeadInfo;RecRow:TLKJRuntimeFileRec;RowList:TList): TVSCState;override;
    //��ǰ����ʽ����
    property ActiveIndex : Integer read m_nActiveIndex write m_nActiveIndex;
    //��������ֵ�Ľڵ�
    property MatchedIndex : Integer read m_nMatchedIndex write m_nMatchedIndex;
    //��ǰ����ʽ����
    property BeginIndex : Integer read m_nBeginIndex write m_nBeginIndex;
    //��ǰ����ʽ����
    property EndIndex : Integer read m_nEndIndex write m_nEndIndex;
  end;
  //////////////////////////////////////////////////////////////////////////////
  //TVSCombOrderInExpression
  //����˳��������ʽ  ���ñ��ʽ�б���Ҫ������˳�������ƥ�䣬�����������㲶��
  //////////////////////////////////////////////////////////////////////////////
  TVSCombOrderInExpression = class(TVSCombExpression)
  private
    //��ǰ����ʽ����
    m_nActiveIndex : Integer;
    //��������ֵ�Ľڵ�
    m_nMatchedIndex : Integer;
  public
    constructor Create();override;
    //������ݣ���Ҫ���ڵ��������ӱ��ʽ����շ���
    procedure Reset;override;

    procedure Init;override;
    //��д��ȡ����
    function GetData : Pointer;override;
  public
    function  Match(RecHead:RLKJRTFileHeadInfo;RecRow:TLKJRuntimeFileRec;RowList:TList): TVSCState;override;
    //��ǰ����ʽ����
    property ActiveIndex : Integer read m_nActiveIndex write m_nActiveIndex;
    //��������ֵ�Ľڵ�
    property MatchedIndex : Integer read m_nMatchedIndex write m_nMatchedIndex;
  end;
  //////////////////////////////////////////////////////////////////////////////
  //TVSCombIntervalExpression ��Χ���ʽ���ں���ʼ���ʽ���������ʽ���ȶԱ��ʽ
  //���BeginExpressionΪnil����ļ�ͷ��ʼ
  //////////////////////////////////////////////////////////////////////////////
  TVSCombIntervalExpression = class(TVSCombExpression)
  private
    m_bMatchMatch : boolean;               ///����ƥ��Ļ���δƥ���
    m_bIsFit : boolean;                    //�Ƿ��Ѿ�ƥ�� ��ʼ���ʽ
    m_BeginExpression : TVSExpression;     //��ʼ���ʽ
    m_Expression : TVSExpression;          //ʵ�ʱȶԱ��ʽ
    m_EndExpression : TVSExpression;       //�������ʽ
    m_bMatchFirst : boolean;               //ֻƥ���һ����Χ
    m_bIntervalEntered : boolean;          //�Ƿ��Ѿ��������Χ
    m_ReturnType : TVSReturnType;         //����ֵ�Ƿ�Χ��ʼ����Χ������ƥ���¼
  public
    constructor Create();override;
    destructor Destroy();override;
  public
    //�ȶԱ��ʽ
    function  Match(RecHead:RLKJRTFileHeadInfo;RecRow:TLKJRuntimeFileRec;RowList:TList): TVSCState;override;
    //������ݣ�
    procedure Reset;override;
    //��ʼ������
    procedure Init;override;
     //��ȡʵ�ʵ�����
    function GetData : Pointer;override;
    function GetBeginData : Pointer;override;
    function GetEndData : Pointer;override;
    //��ʼ���ʽ
    property BeginExpression : TVSExpression read m_BeginExpression write m_BeginExpression;
    //ʵ�ʱȶԱ��ʽ
    property Expression : TVSExpression read m_Expression write m_Expression;
    //�������ʽ
    property EndExpression :TVSExpression read m_EndExpression write m_EndExpression;
    //�Ƿ�ֻ�ȶԵ�һ����Χ
    property MatchFirst : boolean read m_bMatchFirst write m_bMatchFirst;
    //����ƥ�仹��δƥ��
    property MatchMatch : boolean read m_bMatchMatch write m_bMatchMatch;
    //����ֵ����
    property ReturnType : TVSReturnType read m_ReturnType write m_ReturnType;
  end;

  //////////////////////////////////////////////////////////////////////////////
  //TVSCombNoIntervalExpression ��Χ���������ʽ
  //�ڷ�Χ�ڲ����ȶԣ������ڷ�Χ�����ȶ�
  //////////////////////////////////////////////////////////////////////////////
  TVSCombNoIntervalExpression = class(TVSCombExpression)
  private
    m_bIsFit : boolean;                    //�Ƿ��Ѿ�ƥ�� ��ʼ���ʽ
    m_BeginExpression : TVSExpression;     //��ʼ���ʽ
    m_Expression : TVSExpression;          //ʵ�ʱȶԱ��ʽ
    m_EndExpression : TVSExpression;       //�������ʽ
//    m_IntervalEndTime : TDateTime;
  public
    constructor Create();override;
    destructor Destroy();override;
  public
    //�ȶԱ��ʽ
    function  Match(RecHead:RLKJRTFileHeadInfo;RecRow:TLKJRuntimeFileRec;RowList:TList): TVSCState;override;
    //������ݣ�
    procedure Reset;override;
    //��ʼ������
    procedure Init;override;
     //��ȡʵ�ʵ�����
    function GetData : Pointer;override;
    //��ʼ���ʽ
    property BeginExpression : TVSExpression read m_BeginExpression write m_BeginExpression;
    //ʵ�ʱȶԱ��ʽ
    property Expression : TVSExpression read m_Expression write m_Expression;
    //�������ʽ
    property EndExpression :TVSExpression read m_EndExpression write m_EndExpression;
  end;

  //////////////////////////////////////////////////////////////////////////////
  //TVSCombIntervalExpression ��Ч��Χ���ʽ����ʼ���ʽ���������ʽ��ʾ��Χ
  //����Χ����ʱ��������Ч���ʽ�жϸ÷�Χ�Ƿ���Ч������Ч������жϱ��ʽ���ж�
  //ƥ����
  //////////////////////////////////////////////////////////////////////////////
  TVSCombValidIntervalExpression = class(TVSCombExpression)
  private
    m_bMatchMatch : boolean;               //����ƥ��Ļ���δƥ���
    m_bIsFit : boolean;                    //�Ƿ��Ѿ�ƥ�� ��ʼ���ʽ
    m_BeginExpression : TVSExpression;     //��ʼ���ʽ
    m_EndExpression : TVSExpression;       //�������ʽ
    m_ValidExpression : TVSExpression;     //��Ч���ʽ�������жϷ�Χ������Χ�Ƿ���Ч
    m_Expression : TVSExpression;          //ʵ�ʱȶԱ��ʽ
  public
    constructor Create();override;
    destructor Destroy();override;
  public
    //�ȶԱ��ʽ
    function  Match(RecHead:RLKJRTFileHeadInfo;RecRow:TLKJRuntimeFileRec;RowList:TList): TVSCState;override;
    //������ݣ�
    procedure Reset;override;
    //��ʼ������
    procedure Init;override;
     //��ȡʵ�ʵ�����
    function GetData : Pointer;override;
  public

    property MatchMatch : boolean read m_bMatchMatch write m_bMatchMatch;
    //��ʼ���ʽ
    property BeginExpression : TVSExpression read m_BeginExpression write m_BeginExpression;
    //�������ʽ
    property EndExpression :TVSExpression read m_EndExpression write m_EndExpression;
    //ʵ�ʱȶԱ��ʽ
    property Expression : TVSExpression read m_Expression write m_Expression;
    //��Ч���ʽ�������жϷ�Χ������Χ�Ƿ���Ч
    property ValidExpression : TVSExpression read m_ValidExpression write m_ValidExpression;
  end;

  //////////////////////////////////////////////////////////////////////////////
  //TVSCombConditionExpression �������ʽ������������ʱ��ƥ���Ӧ������(Ŀǰֻƥ��һ��)
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
    //�ȶԱ��ʽ
    function  Match(RecHead:RLKJRTFileHeadInfo;RecRow:TLKJRuntimeFileRec;RowList:TList): TVSCState;override;
    //������ݣ�
    procedure Reset;override;
    //��ʼ������
    procedure Init;override;
     //��ȡʵ�ʵ�����
    function GetData : Pointer;override;
    //�޶��������ʽ
    property ConditionExpression : TVSExpression read m_ConditionExpression write m_ConditionExpression;
    //�ȶԱ��ʽ
    property Expression : TVSExpression read m_Expression write m_Expression;
  end;

  //////////////////////////////////////////////////////////////////////////////
  //TVSCombIncludeExpression �������ʽ���ж��ں����ʽ�Ƿ�ƥ���
  //////////////////////////////////////////////////////////////////////////////
  TVSCombIncludeExpression = class(TVSCombExpression)
  public
    //�ȶԱ��ʽ
    function  Match(RecHead:RLKJRTFileHeadInfo;RecRow:TLKJRuntimeFileRec;RowList:TList): TVSCState;override;
    //��ȡʵ�ʵ�����
    function GetData : Pointer;override;
  end;

  //////////////////////////////////////////////////////////////////////////////
  //TVSCombLastIntervalExpression ���һ����Χ���ʽ�����һ������Ч��������Ч
  //�����жϹҳ�
  //////////////////////////////////////////////////////////////////////////////
  TVSCombLastIntervalExpression =  class(TVSCombExpression)
  private
    m_bIsFit : boolean;
    m_BeginExpression : TVSExpression;     //��ʼ���ʽ
    m_EndExpression : TVSExpression;       //�������ʽ
    m_Expression : TVSExpression;          //�������ʽ
    m_bMatchMatch : boolean;               //�Ƿ�ƥ��ƥ�������
    m_TempState : TVSCState;               //�ڲ���״̬
  public
    constructor Create();override;
    destructor Destroy();override;
 public
    //������ݣ�
    procedure Reset;override;
    //��ʼ������
    procedure Init;override;
    //�ȶԱ��ʽ
    function  Match(RecHead:RLKJRTFileHeadInfo;RecRow:TLKJRuntimeFileRec;RowList:TList): TVSCState;override;
    //��ȡʵ�ʵ�����
    function GetData : Pointer;override;
  public
    //ƥ����ʽ
    property Expression : TVSExpression read m_Expression write m_Expression;
    //��ʼ���ʽ
    property BeginExpression : TVSExpression read m_BeginExpression write m_BeginExpression;
    //�������ʽ
    property EndExpression :TVSExpression read m_EndExpression write m_EndExpression;
    //�Ƿ�ƥ��ƥ�������
    property MatchMatch : boolean read m_bMatchMatch write m_bMatchMatch;
  end;

  //////////////////////////////////////////////////////////////////////////////
  //ͷ���ʽ�������ж��޶�����ĳ������֮������м�¼������ƥ����ʽ
  //          �е�ƥ���¼��
  //////////////////////////////////////////////////////////////////////////////
  TVSCombHeadExpression = class(TVSCombExpression)
  private
    m_HeadExpression : TVSExpression;   //ͷ���ʽ
    m_Expression : TVSExpression;       //ƥ����ʽ
  public
    constructor Create();override;
    destructor Destroy();override;
  public
    //������ݣ�
    procedure Reset;override;
    //��ʼ������
    procedure Init;override;
    //�ȶԱ��ʽ
    function  Match(RecHead:RLKJRTFileHeadInfo;RecRow:TLKJRuntimeFileRec;RowList:TList): TVSCState;override;
    //��ȡʵ�ʵ�����
    function GetData : Pointer;override;
  public
    //ƥ����ʽ
    property Expression : TVSExpression read m_Expression write m_Expression;
    //ͷ���ʽ
    property HeadExpression : TVSExpression read m_HeadExpression write m_HeadExpression;
  end;

  //////////////////////////////////////////////////////////////////////////////
  //IF���ʽ����if������ƣ���������ʱִ�е�һ���ӱ��ʽ������ִ�еڶ����ӱ��ʽ
  //////////////////////////////////////////////////////////////////////////////
  TVSCombIfExpression = class(TVSCombExpression)
  private
    m_ConditionExpression : TVSExpression;  //�������ʽ
    m_TrueExpression : TVSExpression;       //����ƥ��ʱִ��
    m_FalseExpression : TVSExpression;      //����Ϊ��ƥ��ʱִ��
  public
    constructor Create();override;
    destructor Destroy();override;
  public
    //������ݣ�
    procedure Reset;override;
    //��ʼ������
    procedure Init;override;
    //�ȶԱ��ʽ
    function  Match(RecHead:RLKJRTFileHeadInfo;RecRow:TLKJRuntimeFileRec;RowList:TList): TVSCState;override;
    //��ȡʵ�ʵ�����
    function GetData : Pointer;override;
  public
    //����ƥ��ʱִ��
    property TrueExpression : TVSExpression read m_TrueExpression write m_TrueExpression;
    //����Ϊ��ƥ��ʱִ��
    property FalseExpression : TVSExpression read m_FalseExpression write m_FalseExpression;
    //ͷ���ʽ
    property ConditionExpression : TVSExpression read m_ConditionExpression write m_ConditionExpression;
  end;
///////////////////////////////////////////////////////////////////////////
///TVSCombTriggerExpression �������ʽ״̬ΪvscMatched��vscMatchingʱ����ִ��
///  �ӱ��ʽ����λ���ʽΪUnmatchʱ��λ�ӱ��ʽ
///  ע���������ʽ�͸�λ���ʽ���ܵ���������ֻ��ʹ�����еı��ʽ
///////////////////////////////////////////////////////////////////////////
  TVSCombTriggerExpression = class(TVSCombExpression)
  private
    m_Expression : TVSExpression;  //�������ʽ
    m_TriggerExpression : TVSExpression;       //����ƥ��ʱִ��
    m_ResetExpression : TVSExpression;      //����Ϊ��ƥ��ʱִ��
    m_bTriggerEnable : Boolean;
  public
    constructor Create();override;
    destructor Destroy();override;
  public
    //������ݣ�
    procedure Reset;override;
    //��ʼ������
    procedure Init;override;
    //�ȶԱ��ʽ
    function  Match(RecHead:RLKJRTFileHeadInfo;RecRow:TLKJRuntimeFileRec;RowList:TList): TVSCState;override;
    //��ȡʵ�ʵ�����
    function GetData : Pointer;override;
  public
    //�������ʽ
    property TriggerExpression : TVSExpression read m_TriggerExpression write m_TriggerExpression;
    //��λ���ʽ
    property ResetExpression : TVSExpression read m_ResetExpression write m_ResetExpression;
    //ִ�б���ʽ
    property Expression : TVSExpression read m_Expression write m_Expression;
  end;
implementation
uses
  uVSLog;
{$region 'TVSExpressionCollection  ʵ��'}
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
{$endregion 'TVSExpressionCollection  ʵ��'}

{$region 'TVSCombExpression ʵ��'}

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
  //�ȶԽ����ֵ�����ʽ״̬
  VSLog.AddCombExpress(self,RecHead,RecRow);
  //�������ݵ���һ������
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

{$endregion 'TVSCombExpression ʵ��'}


{$region 'TVSCombAndExpression ʵ��'}
{ TVSCombAndExpression }


function TVSCombAndExpression.GetData: Pointer;
var
  i : Integer;
  p,oldP : Pointer;
begin
  oldP := nil;
  //ѭ����ȡ�ӱ��ʽ������ƥ���������Ϊ��������
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
  i : Integer;                    //ѭ������
  nAcceptCount : Integer;         //���ڽ���״̬���ӱ��ʽ
  nFitCount   : Integer;          //�����ʺ�״̬���ӱ��ʽ
  nMatchCount : Integer;          //����ƥ��״̬���ӱ��ʽ
  tempRlt : TVSCState;            //��ʱ�ȶԽ��
begin
  try
    //������־�ڵ�
    CreateLog;
    nMatchCount := 0;
    nAcceptCount := 0;
    nFitCount := 0;
    //ѭ��ÿ�����ʽ
    for i := 0 to m_Expressions.Count - 1 do
    begin
      {$region 'ѭ���Ƚ��ӱ��ʽ���ۼӱȶԽ��'}
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
      {$endregion 'ѭ���Ƚ��ӱ��ʽ���ۼӱȶԽ��'}  
    end;

    if nMatchCount > 0 then
    begin
      {$region '�ӱ��ʽ����ƥ��״̬�ǣ���ѯ����ǰһ״̬�Ƿ�ΪMatching��Matched'}
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
      {$endregion '�ӱ��ʽ����ƥ��״̬�ǣ���ѯ����ǰһ״̬�Ƿ�ΪMatching��Matched'}
    end;
  

    if (nAcceptCount + nMatchCount + nFitCount) < m_Expressions.Count  then
    begin
      {$region '�ӱ��ʽ���в�ƥ��ڵ㣬���������״̬Ϊ��ƥ�䣬ͬʱ������б��ʽ����'}
      Result := vscUnMatch;
      State := Result;
      //��ձ��ʽ����
      Reset;
      //��ո��ڵ�״̬
      exit;
      {$endregion '�ӱ��ʽ���в�ƥ��ڵ㣬���������״̬Ϊ��ƥ�䣬ͬʱ������б��ʽ����'}
    end;

    if nAcceptCount > 0 then
    begin
      {$region '�ӱ��ʽ���н���״̬�����������״̬Ϊ����'}
      Result := vscAccept;
      State := Result;
      exit;
      {$endregion '�ӱ��ʽ���н���״̬�����������״̬Ϊ����'}
    end;   

    if (nFitCount > 0) then
    begin
      {$region '���б��ʽ״̬��Ϊ�ʺϣ���������ϱ��ʽ״̬Ϊƥ��'}
      Result := vscMatching;
      State := Result;
      exit;
      {$endregion '���б��ʽ״̬��Ϊ�ʺϣ���������ϱ��ʽ״̬Ϊƥ��'}
    end;

    //���б��ʽ״̬��Ϊƥ�䣬��������ϱ��ʽ״̬Ϊƥ��
    Result := vscMatched;
    State := Result;
  finally
    Inherited Match(RecHead,RecRow,RowList);
  end;
end;
{$endregion 'TVSCombAndExpression ʵ��'}

{$region 'TVSCombOrExpression ʵ��'}

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
  nAcceptCount : Integer; //���ڽ���״̬���ӱ��ʽ
  nFitCount   : Integer; //�����ʺ�״̬���ӱ��ʽ
  nMatchCount : Integer;  //����ƥ��״̬���ӱ��ʽ
  rlt : TVSCState;
begin
  try
    CreateLog;
    nAcceptCount := 0;
    nFitCount   := 0;
    nMatchCount := 0;
    for i := 0 to m_Expressions.Count - 1 do
    begin
      {$region 'ѭ��ƥ���Ա��ʽ���ۼ�ƥ����'}
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
      {$endregion 'ѭ��ƥ���Ա��ʽ���ۼ�ƥ����'}
    end;
    //����ƥ����򷵻�״̬ƥ��
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
    //����ƥ���е��򷵻�ƥ����
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
    //���ѽ��ܵ��򷵻ؽ���
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
    //���ز�ƥ��
    Result := vscUnMatch;
    State := Result;
  finally
    Inherited Match(RecHead,RecRow,RowList);
  end;
end;

{$endregion 'TVSCombOrExpression ʵ��'}

{$region 'TVSCombOrderExpression ʵ��'}

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
    {$region '�������������¹��ʼ����'}
    if (m_nActiveIndex > m_Expressions.Count -1) then
    begin
      m_nActiveIndex := 0;
    end;
    {$endregion '�������������¹��ʼ����'}
    //��ȡ��ǰ���ʽ��һ������
    p := m_Expressions.Items[m_nActiveIndex].LastData;
    //ƥ�䵱ǰ���ʽ
    result :=  m_Expressions.Items[m_nActiveIndex].Match(RecHead,RecRow,RowList);

    {$region '�����ƥ��������ƥ��'}
    //�����ƥ��������ƥ��
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
    {$endregion '�����ƥ��������ƥ��'}

    {$region '�����ƥ���򽫵�ǰ���ݴ��ݵ���һ�����ʽ�н���ƥ��'}
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
    {$endregion '�����ƥ���򽫵�ǰ���ݴ��ݵ���һ�����ʽ�н���ƥ��'}

    {$region '����ƥ��״̬���÷���ֵ'}
    //��������򷵻ؽ���
    if (Result = vscAccept)  then
    begin
      Result := vscAccept;
    end;
    //���ƥ�����ҵ�ǰΪ���һ���ڵ��򷵻�ƥ���У����򷵻ؽ���
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
    {$endregion '����ƥ��״̬���÷���ֵ'}
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
{$endregion 'TVSCombOrderExpression ʵ��'}

{$region 'TVSCombIntervalExpression ʵ��'}

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
    {$region '���Ҫ��ֻƥ���һ����Χ���Ѿ��������Χ���ٲμӱȶ�'}
    if m_bMatchFirst then
    begin
      if m_bIntervalEntered then
      begin
        Result := vscUnMatch;
        State := Result;
        exit;
      end;
    end;
    {$endregion '���Ҫ��ֻƥ���һ����Χ���Ѿ��������Χ���ٲμӱȶ�'}
    Result := vscUnMatch;
    {$region '�жϿ�ʼ���ʽ'}
    //���û�н��뷶Χ���뷶Χ�Ŀ�ʼ���ʽ�����ж�
    if not(m_bIsFit) then
    begin
        rlt := m_BeginExpression.Match(RecHead,RecRow,RowList);
      //���ƥ�俪ʼ���ʽ�������ܹ������־���������˳�
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
    {$endregion '�жϿ�ʼ���ʽ'}

    {$region '�ж��Ƿ񳬳���Χ'}
    if m_EndExpression <> nil then
    begin
      rlt := m_EndExpression.Match(RecHead,RecRow,RowList);
      //���һ����¼����Ȼ������ʽ�����жϣ���ǿ�ƽ�ʾ����ƥ��
      if RowList.Items[RowList.Count - 1] = RecRow then
      begin
        {$region '�����ǰƥ��Ϊͨ������Ҫ����ƥ�䣬����ֵ����ƥ��Ľ��'}
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
        {$endregion '�����ǰƥ��Ϊͨ������Ҫ����ƥ�䣬����ֵ����ƥ��Ľ��'}

        Result := rlt;
        State := Result;
        rlt := vscMatched;
      end;
      {$region '�˳���������'}
      if (rlt = vscMatching) or (rlt = vscMatched)  then
      begin

        if m_bMatchFirst then
        begin
          m_bIntervalEntered := true;
        end;
        Result := vscUnMatch;

        if (State = vscMatching) or (State = vscMatched) then
        begin
          {$region '���֮ǰƥ���'}
          if m_bMatchMatch then
          begin
            //����ƥ����Ҫ�󲶻�ƥ��
            Result := vscMatched;
            State := Result;
          end
          else
          begin
            //����ƥ����Ҫ�󲶻�ƥ��
            Result := vscUnMatch;
            State := Result;
            if not MatchFirst then
              Init;
          end;
          {$endregion '���֮ǰƥ���'}
        end
        else begin
          {$region '���֮ǰû��ƥ���'}
          if m_bMatchMatch then
          begin
            //������ƥ����Ҫ�󲶻�ƥ��
            Result := vscUnMatch;
            State := Result;
            if not MatchFirst then
              Init;
          end
          else
          begin
            //������ƥ����Ҫ�󲶻�ƥ��
            Result := vscMatched;
            State := Result;
          end;
          {$endregion '���֮ǰû��ƥ���'}
        end;
        exit;
      end;
      {$endregion '�˳���������'}

    end;
    {$endregion '�ж��Ƿ񳬳���Χ'}

    {$region '�ȶ�����'}
      {$region '�����ǰ�Ѿ�ƥ�����ֱ�ӷ���ƥ����'}
      if (State = vscMatching) or (State = vscMatched) then
      begin
        FitData := m_Expression.GetData;
        Result := vscMatching;
        State := Result;
        exit;
      end;
      {$endregion '�����ǰ�Ѿ�ƥ�����ֱ�ӷ���ƥ����'}

      {$region '�����ǰƥ��Ϊͨ������Ҫ����ƥ�䣬����ֵ����ƥ��Ľ��'}
      rlt := m_Expression.Match(RecHead,RecRow,RowList);
      if (rlt = vscUnMatch) or (rlt = vscAccept) then
      begin
        rlt := vscAccept;
      end
      else
      begin
        rlt := vscMatching;
      end;
      {$endregion '�����ǰƥ��Ϊͨ������Ҫ����ƥ�䣬����ֵ����ƥ��Ľ��'}
      if (rlt = vscMatching) or (rlt = vscMatched) then
      begin
        FitData := m_Expression.GetData;
      end;

      Result := rlt;
      State := Result;
      {$endregion '�ȶ�����'}
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

{$endregion 'TVSCombIntervalExpression ʵ��'}

{$region 'TVSCombNoIntervalExpression ʵ��'}

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
    //���Ҫ��ֻƥ���һ����Χ���Ѿ��������Χ���ٲμӱȶ�
    Result := vscUnMatch;
    {$region '�жϿ�ʼ���ʽ'}
    //���û�н��뷶Χ���뷶Χ�Ŀ�ʼ���ʽ�����ж�
    if not(m_bIsFit) then
    begin
      rlt := m_BeginExpression.Match(RecHead,RecRow,RowList);
      //���ƥ�俪ʼ���ʽ�������ܹ������־���������˳�
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
    {$endregion '�жϿ�ʼ���ʽ'}

    {$region '�жϽ������ʽ'}
    //�ж��Ƿ񳬳���Χ

    rlt := m_EndExpression.Match(RecHead,RecRow,RowList);
    //�����Ѿ�������Χ
    if (rlt = vscMatching) or (rlt = vscMatched)  then
    begin
      Result := vscUnMatch;
      //���֮ǰƥ�����������Χ��ƥ��
//      if (State = vscMatching) or (State = vscMatched) then
//      begin
//        m_bIsFit := false;
//        //��¼��Χ����ʱ��
////        m_IntervalEndTime := TLKJCommonRec(RecRow).CommonRec.DTEvent;
//      end;
      m_bIsFit := False;
      m_Expression.Reset();
      State := Result;
      exit;
    end;
   {$endregion '�жϽ������ʽ'}
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
{$endregion 'TVSCombNoIntervalExpression ʵ��'}

{$region 'TVSCombValidIntervalExpression ʵ��'}

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

    {$region '�жϿ�ʼ���ʽ,���ƥ������뷶Χ�ȶԣ��������˳�'}
    //���û�н��뷶Χ���뷶Χ�Ŀ�ʼ���ʽ�����ж�
    if not(m_bIsFit) then
    begin
      rlt := m_BeginExpression.Match(RecHead,RecRow,RowList);
      if RowList.Items[RowList.Count - 1] = RecRow then
      begin
        rlt := vscMatched;
      end;
      //���ƥ�俪ʼ���ʽ�������ܹ������־���������˳�
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
    {$endregion '�жϿ�ʼ���ʽ,���ƥ������뷶Χ�ȶԣ��������˳�'}

    {$region '�������ʽƥ��'}
    rlt := m_EndExpression.Match(RecHead,RecRow,RowList);
    //��Χ�Ѿ�����
    if (rlt = vscMatching) or (rlt = vscMatched)  then
    begin
      {$region '��Χ�������жϷ�Χ�Ƿ���Ч'}
      Result := vscUnMatch;
      //�жϷ�Χ�Ƿ���Ч
      rlt := m_ValidExpression.Match(RecHead,RecRow,RowList);
      {$region '�����Χ��Ч�򷵻�'}
      if (rlt = vscUnMatch) or (rlt = vscAccept) then
      begin
        State := Result;
        Reset;
        exit;
      end;
      {$endregion '�����Χ��Ч�򷵻�'}  

      {$region '�����Ч���ж�ƥ����ʽ�Ƿ�ƥ��,����ƥ����ʽ�Ľ������'}
      //���֮ǰƥ�����������Χ��ƥ��
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
      //����Χ���ʽ�ٽ�һ���жϣ��������жϽ��
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
      {$endregion '�����Ч���ж�ƥ����ʽ�Ƿ���Ч'}
      {$endregion '��Χ�������жϷ�Χ�Ƿ���Ч'}  
    end;
   {$endregion '�жϽ������ʽ'}

    //��Ч���ʽ��ȡ����
    m_ValidExpression.Match(RecHead,RecRow,RowList);
    
    //�����ǰ�Ѿ�ƥ�������
    if (State = vscMatching) or (State = vscMatched) then
    begin
      Result := vscMatching;
      State := Result;
      exit;
    end;

    //�����ǰû��ƥ�������ƥ��
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

{$endregion 'TVSCombValidIntervalExpression ʵ��'}

{$region 'TVSCombConditionExpression ʵ��'}

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
    //����Ѿ�ƥ�������ƥ��
    if m_bIsFit then
    begin
      Result := vscUnMatch;
      State := Result;
      exit;
    end;
    //��������������һ���ж�
    rlt := m_ConditionExpression.Match(RecHead,RecRow,RowList);
    if (rlt = vscMatching) or (rlt = vscMatched) then
    begin
      m_bIsFit := true;
      rlt := m_Expression.Match(RecHead,RecRow,RowList);
      //�����һ���жϸ��������򷵻��Ѳ���
      if (rlt = vscMatching) or (rlt= vscMatched) then
      begin
        Result := vscMatched;
        State := Result;
        exit;
      end;
      //���򷵻ز���ʧ��
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
{$endregion 'TVSCombConditionExpression ʵ��'}

{$region 'TVSCombIncludeExpression ʵ��'}
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
      //���ӱ��ʽ����û��ƥ����������½���ƥ��
      if (vscUnMatch = rlt) or (vscAccept = rlt) then
      begin
        rlt := Expressions[i].Match(RecHead,RecRow,RowList);
      end;
      //���ӱ��ʽƥ����ƥ�似����1
      if (vscMatching = rlt) or (vscMatched = rlt) then
      begin
        matchCount := matchCount + 1;
      end;
    end;
    //�������ӽڵ㶼ƥ���򷵻�ƥ�䣬���򷵻�δƥ��
    if matchCount = Expressions.Count then
    begin
      Result := vscMatched;
    end;
    State := Result;
  finally
    inherited Match(RecHead,RecRow,RowList);
  end;
end;
{$endregion 'TVSCombIncludeExpression ʵ��'}

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

    {$region '�жϿ�ʼ���ʽ,���ƥ������뷶Χ�ȶԣ��������˳�'}
    //���û�н��뷶Χ���뷶Χ�Ŀ�ʼ���ʽ�����ж�
    if not(m_bIsFit) then
    begin
      rlt := m_BeginExpression.Match(RecHead,RecRow,RowList);
      //���ƥ�俪ʼ���ʽ�������ܹ������־���������˳�
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
    {$endregion '�жϿ�ʼ���ʽ,���ƥ������뷶Χ�ȶԣ��������˳�'}

    {$region '�������ʽƥ��'}
    rlt := m_EndExpression.Match(RecHead,RecRow,RowList);
    if RowList.Items[RowList.Count - 1] = RecRow then
    begin
      rlt := vscMatched;
    end;
    //��Χ�Ѿ�����
    if (rlt = vscMatching) or (rlt = vscMatched)  then
    begin
      try
        //���֮ǰ�Ѿ�ƥ���򷵻�ƥ����
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
    {$endregion '�жϽ������ʽ'}

    {$region '���뷶Χ������ƥ��'}
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
    {$endregion '���뷶Χ������ƥ��'}
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
    //�ж�ͷ���ʽ���粻ƥ���򷵻أ���ƥ�������ƥ����ʽ�ж�
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
    {$region '�������������¹��ʼ����'}
    if (m_nActiveIndex > m_Expressions.Count -1) then
    begin
      m_nActiveIndex := 0;
    end;
    {$endregion '�������������¹��ʼ����'}
    //��ȡ��ǰ���ʽ��һ������
    p := m_Expressions.Items[m_nActiveIndex].LastData;
    //ƥ�䵱ǰ���ʽ
    result :=  m_Expressions.Items[m_nActiveIndex].Match(RecHead,RecRow,RowList);

    {$region '�����ƥ��������ƥ��'}
    //�����ƥ��������ƥ��
    if result = vscUnMatch then
    begin
      exit;
    end;
    {$endregion '�����ƥ��������ƥ��'}

    {$region '�����ƥ���򽫵�ǰ���ݴ��ݵ���һ�����ʽ�н���ƥ��'}
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
    {$endregion '�����ƥ���򽫵�ǰ���ݴ��ݵ���һ�����ʽ�н���ƥ��'}

    {$region '����ƥ��״̬���÷���ֵ'}
    //��������򷵻ؽ���
    if (Result = vscAccept)  then
    begin
      Result := vscAccept;
    end;
    //���ƥ�����ҵ�ǰΪ���һ���ڵ��򷵻�ƥ���У����򷵻ؽ���
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
    {$endregion '����ƥ��״̬���÷���ֵ'}
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
