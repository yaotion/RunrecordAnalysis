unit uVSRules;

interface
uses
  classes, Windows, SysUtils, Forms, Contnrs, DateUtils, xmldom, XMLIntf, msxmldom, XMLDoc,
  uVSConst, uVSSimpleExpress, uVSCombExpress, uLKJRuntimeFile,uVSAnalysisResultList;
type
   //////////////////////////////////////////////////////////////////////////////
  //TVSRule Υ�����
  //////////////////////////////////////////////////////////////////////////////
  TVSRule = class
    public
      constructor Create(); virtual;
      destructor Destroy(); override;
    protected
      m_nSortID: Integer;                    //����������
      m_nID: Integer;                        //������
      m_strTitle: string;                    //����˵��
      m_HeadExpression: TVSExpression;       //ͷ���ʽ
      m_RootExpression: TVSExpression;       //�����ʽ
      m_bIsVS: bool;                         //��/����Υ��((�м�¼Υ�� (IsVs=False)���޼�¼Υ�� (IsVs=True)))
      m_RecHead: RLKJRTFileHeadInfo;         //���м�¼�ļ�ͷ
      m_RecList: TList;                      //���м�¼
      m_Description : string;                //��������
      m_nBeforeSeconds : integer;
      m_nAfterSeconds : integer;
      m_bIsRange : boolean;
    public
      //��ȡ��ǰ��ֵ
      function GetData: Pointer; virtual;
      //����
      procedure Reset; virtual;
      //���³�ʼ��
      procedure Init; virtual;
      //����ļ��Ƿ��ʺϱ������ʺ��򷵻�true�����ʺ��򷵻�false
      function Check(RecHead: RLKJRTFileHeadInfo; RecList: TList): boolean; virtual;
      //�ȶ�һ�����м�¼�������رȶ�״̬
      function MatchLKJRec(RecHead: RLKJRTFileHeadInfo; RecRow: TLKJRuntimeFileRec; RewList: TList): TVSCState; virtual;
      //��ȡ���򲶻��ʱ�䷶Χ��
      function GetCaptureRange : TLKJEventDetail;
    public
      //������
      property ID: integer read m_nID write m_nID;
      //����������
      property SortID: Integer read m_nSortID write m_nSortID;
      //�������
      property Title: string read m_strTitle write m_strTitle;
      //��ȡ���������
      property Description: string read m_Description write m_Description;
      //��/����Υ��
      property IsVS: bool read m_bIsVS write m_bIsVS;
      //�����ʽ
      property RootExpression: TVSExpression read m_RootExpression write m_RootExpression;
      //ͷ���ʽ
      property HeadExpression: TVSExpression read m_HeadExpression write m_HeadExpression;

      //�Ƿ�Ϊ��Χѡ��
      property IsRange : boolean read m_bIsRange write m_bIsRange;
      //ȡ��Χǰ������
      property BeforeSeconds : integer read m_nBeforeSeconds write m_nBeforeSeconds;
      //ȡ��Χ�������
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

//�����й���ȶ�һ�����м�¼
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
