unit uLKJRuntimeFile;
{LKJ���м�¼�ļ���Ԫ}

interface

uses
  Classes,Windows, Contnrs, SysUtils, uVSConst, DateUtils;

type
  {�����ź�}
  TLampSign = (
    lsGreen {�̵�}, lsGreenYellow {�̻�},
    lsYellow {��ɫ}, lsYellow2 {��2}, lsDoubleYellow {˫��}, lsYellow2S {��2��},
    lsDoubleYellowS {˫����}, lsRed {���}, lsRedYellow {���},
    lsRedYellowS {�����}, lsWhite {�׵�}, lsMulti {���}, lsClose {���},
    lsPDNone {00}, lsPDTingChe {ͣ��}, lsPDTuiJin {�ƽ�}, lsPDQiDong {����},
    lsPDLianJie {����}, lsPDLiuFang {���}, lsPDJianSu {����}, lsPDShiChe {ʮ��},
    lsPDWuChe {�峵}, lsPDSanChe {����}, lsPDQianChuShaoDong {ǣ���Զ�}, lsPDShouFangQuan {�շ�Ȩ},
    lsPD12 {12H}, lsPDTuiJinShaoDong {�ƽ��Զ�}, lsPDGuZhangTingChe {����ͣ��}, lsPD15 {15H},
    lsPDJinJiTingChe1 {����ͣ��1}, lsPDJinJiTingChe2 {����ͣ��2}, lsPDJinJiTingChe3 {����ͣ��3}, lsPDJinJiTingChe4 {����ͣ��4},
    lsPDJinJiTingChe5 {����ͣ��5}, lsPDJinJiTingChe6 {����ͣ��6}, lsPDJinJiTingChe7 {����ͣ��7}, lsPDJinJiTingChe8 {����ͣ��8},
    lsPDJieSuo1 {����1}, lsPDJieSuo2 {����2}, lsPDJieSuo3 {����3}, lsPDJieSuo4 {����4},
    lsPDJieSuo5 {����5}, lsPDJieSuo6 {����6}, lsPDJieSuo7 {����7}, lsPDJieSuo8 {����8},
    lsPDYiChe {һ��}
    );
    {ƽ���źŶ���
    00H	        	01H	ͣ��		02H	�ƽ�		03H	��
    04H	����		05H	���		06H	����		07H	ʮ��
    08H	�峵		09H	����		10H	ǣ���Զ�	11H	�շ�Ȩ
    12H				13H	�ƽ��Զ�	14H	����ͣ��	15H
    16H	����ͣ��1	17H	����ͣ��2	18H	����ͣ��3	19H	����ͣ��4
    20H	����ͣ��5	21H	����ͣ��6	22H	����ͣ��7	23H	����ͣ��8
    24H	����1		25H	����2		26H	����3		27H	����4
    28H	����5		29H	����6		30H	����7		31H	����8
    35H	һ��
    }

  {��λ�ͷ���λ}
  TWorkZero = (wAtZero {��λ}, wNotZero {����λ});

  {ǰ��}
  THandPos = (hpForword {��ǰ}, hpMiddle {��}, hpBack {���}, hpInvalid {��});

  {ǣ��}
  TWorkDrag = (wdDrag {ǣ}, wdMiddle {��}, wdBrake {�ƶ�}, wdInvalid {��});

  {�źŻ�����}
  //TLKJSignType = (stNormal {��ͨ}, stIn {��վ}, stOut {��վ}, stStation {����վ});
  TLKJSignType = (stNormal {ͨ��}, stPre {Ԥ��}, stInOut {����վ}, stIn {��վ}, stOut {��վ}, stStation {����վ}, stNone {��});

  {����豸����}
  TLKJFactory = (sfSiWei {˼ά}, sfZhuZhou {����});

  {�ͻ�����}
  TLKJTrainType = (ttPassenger {�ͳ�}, ttCargo {����}, ttAny {�ͳ������}); //ttany �����ڿͻ������ж�ʱ�����ж���

  {����������}
  TLKJBenBu = (bbBen {����}, bbBu {����}, bbAny {�����򲹻�});
  {��������}
  TDiaoCheType = (dcPingDiao {ƽ��}, dcDiaoChe {��ͨ����}, dcAll {ȫ��});
  {��֡���ͨ�г�}
  TLKJWorkType = (wtNormal {��ͨ�г�}, wtTenThousand {���}, wtTwentyThousand {�����});

  ////////////////////////////////////////////////////////////////////////////////
  //TLKJRuntimeFileRec LKJ���м�¼�ļ��м�¼���࣬�������͵ļ�¼���Ӵ�������}
  ////////////////////////////////////////////////////////////////////////////////
  TLKJRuntimeFileRec = class
  public
    {���ܣ������е�����ת��Ϊ�ַ���}
    function ToString(): string; virtual; abstract;
    {���ܣ������ַ����е������������и�����Ա��ֵ}
    procedure FromString(strText: string); virtual; abstract;
  end;


  {RCommonRec ȫ�̼�¼ͨ�ü�¼��Ϣ�ṹ��}
  RCommonRec = record
    nRow: Integer; //ȫ�̼�¼�к�
    strDisp: string; //�¼�����
    nEvent: Integer; //�¼����ִ���
    DTEvent: TDateTime; //�¼�����ʱ��
    nCoord: Integer; //�����
    nDistance: Integer; //���źŻ�����
    LampSign: TLampSign; //���ź�
    strSignal: string; //ɫ��
    nLampNo: Integer; //�źŻ����6244
    SignType: TLKJSignType; //�źŻ�����
    strXhj: string; //�źŻ�
    nSpeed: Integer; //�����ٶ�
    nLimitSpeed: Integer; //�����ٶ�
    nShoub: Byte; //�ֱ�״̬
    strGK: string; //����״̬
    WorkZero: TWorkZero; //��λ[��, ��]
    HandPos: THandPos; //ǰ��[ǰ, ��]
    WorkDrag: TWorkDrag; //ǣ��[ǣ, ��]
    nLieGuanPressure: Integer; //�й�ѹ��
    nGangPressure: Integer; //��ѹ��
    nRotate: Integer; //ת��
    nJG1Pressure: Integer; //����1ѹ��
    nJG2Pressure: Integer; //����2ѹ��
    strOther: string; //����
    nJKLineID: Integer; //��ǰ��·��
    nDataLineID: Integer; //��ǰ���ݽ�·��
    nStation: Integer; //�ѹ���վ��
    nToJKLineID: Integer; //��һ��վ�Ľ�·��
    nToDataLineID: Integer; //��һ��վ�����ݽ�·��
    nToStation: Integer; //��һ��վ���
    nStationIndex: Integer; //��ʼ��վ��ʼս����
    ShuoMing: string; //˵��
    JKZT: Integer; //���״̬  ��أ�1��ƽ����2�����ࣽ3
    bIsDiaoChe : boolean; //�Ƿ��ڵ���״̬ (�����Ϊ�����г���ƽ��)
    bIsJiangji : boolean; //�Ƿ��ڽ���״̬�������Ϊ������أ�
    bIsPingdiao : boolean;//�Ƿ���ƽ��״̬�������Ϊ�����г��������
    nValidJG: Integer; //��Ч���׺�
    //����������Ϣ
    strCheCi : string;
  end;

  {�����¼��Ϣ�ṹ��}
  RSprecialRec = record
    script: string; // ��¼�¼�����
    value: string; // ��¼����
  end;
  PSprecialRec = ^RSprecialRec;


  ///////////////////////////////////////////////////////////////////////////////
  //TLKJCommonRec ȫ�̼�¼ͨ�ü�¼��Ϣ
  ///////////////////////////////////////////////////////////////////////////////
  TLKJCommonRec = class(TLKJRuntimeFileRec)
  public
    function ToString(): string; override;
    procedure FromString(strText: string); override;
  public
    CommonRec: RCommonRec; //ȫ�̼�¼ͨ�ü�¼��Ϣ
    procedure Clone(Srouce: TLKJCommonRec);
  end;

  //////////////////////////////////////////////////////////////////////////////
  ///TLkjCommonRecLst ȫ�̼�¼ͨ�ü�¼��Ϣ�б�
  //////////////////////////////////////////////////////////////////////////////
  TLkjCommonRecLst = class(TObjectList)
  protected
    function GetItem(Index: Integer): TLKJCommonRec;
    procedure SetItem(Index: Integer; LKJCommonRec: TLKJCommonRec);
  public
    constructor Create;
    function Add(LKJCommonRec: TLKJCommonRec): Integer;
    procedure Clear; override;
    property Items[Index: Integer]: TLKJCommonRec read GetItem write SetItem; default;
  end;

  {RLKJRTFileHeadInfo  ���м�¼�ļ�ͷ��Ϣ}
  RLKJRTFileHeadInfo = record
    dtKCDataTime: TDateTime;
    nLocoType: Integer; //�������ͺ�(DF11)����[����]
    nLocoID: Integer; //�������
    strTrainHead: string[20]; //����ͷ
    nTrainNo: integer; //���κ�
    nLunJing: integer; //�־�
    nDistance: Integer; //���о���
    nJKLineID: Integer; //��·��
    nDataLineID: Integer; //���ݽ�·��
    nFirstDriverNO: Integer; //˾������
    nSecondDriverNO: Integer; //��˾������
    nStartStation: Integer; //ʼ��վ
    nEndStation: Integer; //�յ�վ
    nLocoJie: string[10]; //�������ڵ���Ϣ
    nDeviceNo: Integer; //װ�ú�
    nTotalWeight: Integer; //����
    nSum: Integer; //�ϼ�
    nLoadWeight: Integer; //����
    nJKVersion: Integer; //��ذ汾
    nDataVersion: Integer; //���ݰ汾
    DTFileHeadDt: TDateTime; //�ļ�ͷʱ��
    Factory: TLKJFactory; //�������
    TrainType: TLKJTrainType; //�����ͻ����(��,��)����[����]
    BenBu: TLKJBenBu; //����������
    nStandardPressure: Integer; //��׼��ѹ
    nMaxLmtSpd: Integer; //�����������
    strOrgFileName: string[255]; //ԭʼ�ļ���
  end;

  {�ļ�ʱ������}
  TFileTimeType = (fttBegin {�ļ���ʼʱ��}, fttEnd {�ļ�����ʱ��}, fttRuKu {������ʱ��});

  ////////////////////////////////////////////////////////////////////////////////
  /// ����:TLKJRuntimeFile
  /// ����:�������ʽ���ļ���Ϣ
  ////////////////////////////////////////////////////////////////////////////////
  TLKJRuntimeFile = class
  public
    constructor Create();
    destructor Destroy(); override;
  protected
    {ȫ�̼�¼�б�}
    m_Records: TLkjCommonRecLst;
  public
    {ͷ��Ϣ}
    HeadInfo : RLKJRTFileHeadInfo;
    {����:�����¼����}
    procedure Clear();
  public
    property Records: TLkjCommonRecLst read m_Records;
  end;

  ////////////////////////////////////////////////////////////////////////////////
  /// ����:TLkjRuntimeFileLst
  /// ����:�ļ���Ϣ�б�
  ////////////////////////////////////////////////////////////////////////////////
  TLkjRuntimeFileLst = class(TObjectList)
  protected
    function GetItem(Index: Integer): TLKJRuntimeFile;
    procedure SetItem(Index: Integer; LkjRuntimeFile: TLKJRuntimeFile);
  public
    function Add(LKJRuntimeFile: TLKJRuntimeFile): Integer;
    property Items[Index: Integer]: TLKJRuntimeFile read GetItem write SetItem; default;
  end;
implementation
//==============================================================================
{ TLKJRuntimeFile }
//==============================================================================

procedure TLKJRuntimeFile.Clear;
begin
  m_Records.Clear();
end;


constructor TLKJRuntimeFile.Create();
begin
  m_Records := TLkjCommonRecLst.Create();
end;

destructor TLKJRuntimeFile.Destroy;
begin
  m_Records.Free;
  inherited;
end;


//==============================================================================
// TLKJCommonRec
//==============================================================================

procedure TLKJCommonRec.Clone(Srouce: TLKJCommonRec);
begin
    Self.CommonRec.nRow := Srouce.CommonRec.nRow;
    Self.CommonRec.strDisp := Srouce.CommonRec.strDisp;
    Self.CommonRec.nEvent := Srouce.CommonRec.nEvent;
    Self.CommonRec.DTEvent := Srouce.CommonRec.DTEvent;
    Self.CommonRec.nCoord := Srouce.CommonRec.nCoord;
    Self.CommonRec.nDistance := Srouce.CommonRec.nDistance;
    Self.CommonRec.LampSign := Srouce.CommonRec.LampSign;
    Self.CommonRec.strSignal := Srouce.CommonRec.strSignal;
    Self.CommonRec.nLampNo := Srouce.CommonRec.nLampNo;
    Self.CommonRec.SignType := Srouce.CommonRec.SignType;
    Self.CommonRec.strXhj := Srouce.CommonRec.strXhj;
    Self.CommonRec.nSpeed := Srouce.CommonRec.nSpeed;
    Self.CommonRec.nLimitSpeed := Srouce.CommonRec.nLimitSpeed;
    Self.CommonRec.nShoub := Srouce.CommonRec.nShoub;
    Self.CommonRec.strGK := Srouce.CommonRec.strGK;
    Self.CommonRec.WorkZero := Srouce.CommonRec.WorkZero;
    Self.CommonRec.HandPos := Srouce.CommonRec.HandPos;
    Self.CommonRec.WorkDrag := Srouce.CommonRec.WorkDrag;
    Self.CommonRec.nLieGuanPressure := Srouce.CommonRec.nLieGuanPressure;
    Self.CommonRec.nGangPressure := Srouce.CommonRec.nGangPressure;
    Self.CommonRec.nRotate := Srouce.CommonRec.nRotate;
    Self.CommonRec.nJG1Pressure := Srouce.CommonRec.nJG1Pressure;
    Self.CommonRec.nJG2Pressure := Srouce.CommonRec.nJG2Pressure;
    Self.CommonRec.strOther := Srouce.CommonRec.strOther;
    Self.CommonRec.nJKLineID := Srouce.CommonRec.nJKLineID;
    Self.CommonRec.nDataLineID := Srouce.CommonRec.nDataLineID;
    Self.CommonRec.nStation := Srouce.CommonRec.nStation;
    Self.CommonRec.nToJKLineID := Srouce.CommonRec.nToJKLineID;
    Self.CommonRec.nToDataLineID := Srouce.CommonRec.nToDataLineID;
    Self.CommonRec.nToStation := Srouce.CommonRec.nToStation;
    Self.CommonRec.nStationIndex := Srouce.CommonRec.nStationIndex;
    Self.CommonRec.ShuoMing := Srouce.CommonRec.ShuoMing;
    Self.CommonRec.JKZT := Srouce.CommonRec.JKZT;
    Self.CommonRec.bIsDiaoChe := Srouce.CommonRec.bIsDiaoChe;
    Self.CommonRec.bIsJiangji := Srouce.CommonRec.bIsJiangji;
    Self.CommonRec.bIsPingdiao := Srouce.CommonRec.bIsPingdiao;
    Self.CommonRec.nValidJG := Srouce.CommonRec.nValidJG;
    Self.CommonRec.strCheCi := Srouce.CommonRec.strCheCi;
end;

procedure TLKJCommonRec.FromString(strText: string);
begin

end;


function TLKJCommonRec.ToString: string;
begin

  Result := inttostr(self.CommonRec.nRow) + '  ' +
    DateTimeToStr(self.CommonRec.DTEvent) + '  ' +
    inttostr(self.CommonRec.nEvent) + '  ' +
    inttostr(self.CommonRec.nCoord) + '  ' +
    inttostr(self.CommonRec.nDistance) + '  ' +
    inttostr(self.CommonRec.nLampNo) + '  ' +
    inttostr(self.CommonRec.nSpeed) + '  ' +
    inttostr(self.CommonRec.nLimitSpeed) + '  ' +
    inttostr(self.CommonRec.nLieGuanPressure) + '  ' +
    BoolToStr((self.CommonRec.WorkZero = wAtZero)) + '  ' +
    inttostr(self.CommonRec.nRotate) + '  ' +
    inttostr(self.CommonRec.nJG1Pressure) + '  ' +
    inttostr(self.CommonRec.nJG2Pressure);
end;


{ TLkjCommonRecLst }

function TLkjCommonRecLst.Add(LKJCommonRec: TLKJCommonRec): Integer;
begin
  Result := inherited Add(LKJCommonRec);
end;

procedure TLkjCommonRecLst.Clear;
var
  i: Integer;
begin
  for I := 0 to Count - 1 do
  begin
    Items[i].Free;
  end;
  inherited;
end;

constructor TLkjCommonRecLst.Create;
begin
  inherited Create(False);
end;

function TLkjCommonRecLst.GetItem(Index: Integer): TLKJCommonRec;
begin
  Result := TLKJCommonRec(inherited GetItem(Index));
end;

procedure TLkjCommonRecLst.SetItem(Index: Integer; LKJCommonRec: TLKJCommonRec);
begin
  inherited SetItem(Index, LKJCommonRec);
end;

{ TLkjRuntimeFileLst }

function TLkjRuntimeFileLst.Add(LKJRuntimeFile: TLKJRuntimeFile): Integer;
begin
  Result := inherited Add(LKJRuntimeFile);
end;

function TLkjRuntimeFileLst.GetItem(Index: Integer): TLKJRuntimeFile;
begin
  Result := TLKJRuntimeFile(inherited GetItem(Index));        
end;

procedure TLkjRuntimeFileLst.SetItem(Index: Integer;
  LkjRuntimeFile: TLKJRuntimeFile);
begin
  inherited SetItem(Index, LkjRuntimeFile);
end;

end.

