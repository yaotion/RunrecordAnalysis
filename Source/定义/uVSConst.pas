unit uVSConst;
{Υ�곣������}
interface
uses
  SysUtils;
const
  {$Region '����Υ�����'}
  //���м�¼ͷ����
  CommonRec_Head_KeHuo = 10003;           //�ͻ�
  CommonRec_Head_CheCi = 10004;           //����
  CommonRec_Head_TotalWeight=10005;       //����;
  CommonRec_Head_LiangShu = 10006;        //����
  CommonRec_Head_LocalType = 10007;       //����
  CommonRec_Head_LocalID = 10008;         //����
  CommonRec_Head_Factory = 10009;         //�������

  Custom_Head_ZongZai = 10010;            //�Ƿ�����
  Custom_Head_ZuHe = 10011;               //�Ƿ�����г�
  //��¼�¼����Ͷ���
  CommonRec_Event_Column = 20000;         //�¼��仯
  CommonRec_Event_BaoZha = 20001;         //������բ
  CommonRec_Event_PingDiaoChange = 35333;   //ƽ���źű仯
  CommonRec_Event_SignalChange = 35329;   //�����źű仯
  CommonRec_Event_XingHaoTuBian = 35332;  //�ź�ͻ��
  CommonRec_Event_GLBTuBian = 34563;      //�����ͻ��

  CommonRec_Event_TrainPosForward = 34306;//��λ��ǰ
  CommonRec_Event_TrainPosBack = 34307;   //��λ���
  CommonRec_Event_TrainPosReset = 34309;  //��λ����
  CommonRec_Event_CuDuan = 34321;         //����
  CommonRec_Event_RuDuan = 34322;         //���
  CommonRec_Event_EnsureGreenLight = 34433;//��/�̻�ȷ��
  
  CommonRec_Event_Pos = 34332;            //�����

  CommonRec_Event_Verify = 35904;         //IC����֤��
  CommonRec_Event_PushIC = 34356;         //����IC��
  CommonRec_Event_PopIC = 34357;          //�γ�IC��
  CommonRec_Event_ClearReveal = 35849;    //�����ʾ
  CommonRec_Event_KongZhuan = 34591;      //ת�Կ�ת
  CommonRec_Event_KongZhuanEnd = 34592;   //��ת����;

  
  CommonRec_Event_RevealQuery = 35846;    //��ʾ��ѯ
  CommonRec_Event_InputReveal = 33537;    //�����ʾ
  CommonRec_Event_MInputReveal = 33538;   //�ֹ���ʾ����
  CommonRec_Event_ReInputReveal = 33539;  //��ʾ��������

  CommonRec_Event_CeXian = 34317;         //���ߺ�����

  CommonRec_Event_DuiBiao = 34305;        //�����Ա�
  CommonRec_Event_EnterStation = 34575;   //��վ
  CommonRec_Event_SectionSignal = 34577;   //�������(���źŻ�)
  CommonRec_Event_InOutStation = 34656;   //����վ(���źŻ�)

  CommonRec_Event_SpeedChange = 35585;    //�ٶȱ仯
  CommonRec_Event_RotaChange  = 35586;    //ת�ٱ仯
  CommonRec_Event_GanYChange = 35590;     //��ѹ�仯
  CommonRec_Event_SpeedLmtChange = 35591; //���ٱ仯
  CommonRec_Event_GangYChange = 35600;    //��ѹ�仯


  CommonRec_Event_LSXSStart = 35843;      //��ʱ���ٿ�ʼ
  CommonRec_Event_LSXSEnd = 35844;      //��ʱ���ٽ���


  CommonRec_Event_LeaveStation = 34576;      //��վ
  CommonRec_Event_StartTrain = 34605;      //��
  CommonRec_Event_ZiTing = 34580;         //��ͣͣ��
  CommonRec_Event_StopInRect = 34583;     //����ͣ��
  CommonRec_Event_StartInRect = 34587;    //���俪��
  CommonRec_Event_StopInJiangJi = 34579; //����ͣ��
  CommonRec_Event_StopInStation = 34584;  //վ��ͣ��
  CommonRec_Event_StopOutSignal = 34585;  //����ͣ��
  CommonRec_Event_StartInStation = 34588; //վ�ڿ���
  CommonRec_Event_StartInJiangJi = 34586; //��������
  CommonRec_Event_GuoJiJiaoZheng = 34567; //����У��
  CommonRec_Event_JinRuJiangJi = 45104;   //���뽵��
  CommonRec_Event_FangLiuStart = 34571;   //���ﱨ����ʼ
  CommonRec_Event_FangLiuEnd = 34572;   //���ﱨ������
  CommonRec_Event_JinJiBrake = 35073;   //�����ƶ�
  CommonRec_Event_ChangYongBrake = 35074;//�����ƶ�
  CommonRec_Event_XieZai = 35075;        //ж�ض���






  CommonRec_Event_Diaoche = 34318;        //�������
  CommonRec_Event_DiaocheJS = 34319;      //�˳�����
  CommonRec_Event_DiaoCheStart = 34590;   //��������
  CommonRec_Event_DiaoCheStop = 34582;    //����ͣ��
  CommonRec_Event_JKStateChange = 33237;  //���״̬�仯
  CommonRec_Event_PingDiaoStart = 50001;  //�Զ���ƽ����ʼ
  CommonRec_Event_PingDiaoStop = 50002;  //�Զ���ƽ����ʼ

  CommonRec_Event_UnlockSucceed = 34310;  //�����ɹ�(������)
  CommonRec_Event_GuoFX = 34424;          //������



  CommonRec_Event_YDJS = 34464;          //���������ɹ�
  CommonRec_Event_TDYDJS = 34465;        //�ض���������
  CommonRec_Event_KBJS = 34466;          //��������ɹ�
  CommonRec_Event_FQZX = 34470;          //�������߽���
  CommonRec_Event_LPJS = 34472;          //·Ʊ�����ɹ�
  CommonRec_Event_LSLPJS = 34373;        //��ʱ·Ʊ����
  CommonRec_Event_LZJS = 34474;          //��֤�����ɹ�
  CommonRec_Event_LSLZJS = 34475;        //��ʱ��֤����
  CommonRec_Event_JSCG = 34310;          //�����ɹ�
  Commonrec_Event_GDWMTGQR = 34476;      //�ɵ�����ͨ��ȷ��
  Commonrec_Event_GDWMKCQR = 34477;      //�ɵ����뿪��ȷ��

  CommonRec_Event_TSQR = 34479;          //���ⷢ��ȷ��



  //�Զ����¼�
  Custom_Event_Revert    = 39001;           //��ת
  Custom_Event_Drop      = 39002;           //��ʼ�½�
  Custom_Event_Rise      = 39003;           //��ʼ����
  Custom_Event_DropValue = 39004;           //�ﵽ�½���
  Custom_Event_RiseValue = 39005;           //�ﵽ������
  Custom_Event_ReachValue= 39006;           //�ﵽָ��ֵ
  Custom_Event_DropFromValue = 39007;       //��ָ��ֵ��ʼ�½�
  Custom_Event_DropToValue   = 39008;       //�½���ָ��ֵ
  Custom_Event_RiseFromValue = 39009;       //��ָ��ֵ��ʼ����
  Custom_Event_RiseToValue = 39010;         //������ָ��ֵ

  //�Զ���VALUE
  Custom_Value_CFTime    = 999901;          //���ʱ��
  Custom_Value_StandardPressure = 999902;   //��ѹ
  Custom_Value_BrakeDistance = 999903;      //��բ����



  //��¼�䶯���ж���
  CommonRec_Column_GuanYa    = 30001;     //��ѹ;
  CommonRec_Column_Sudu      = 30002;     //�ٶ�;
  CommonRec_Column_WorkZero  = 30003;     //������λ;
  CommonRec_Column_HandPos   = 30004;     //ǰ��;
  CommonRec_Column_WorkDrag  = 30005;     //�ֱ�λ��;
  CommonRec_Column_DTEvent   = 30006;     //�¼�����ʱ��;
  CommonRec_Column_Distance  = 30007;     //�źŻ�����;
  CommonRec_Column_LampSign  = 30008;     //�źŵ�;
  CommonRec_Column_GangYa    = 30009;     //��ѹ;
  CommonRec_Column_SpeedLimit= 30010;      //����;

  CommonRec_Column_Coord      = 30011;     //�����;
  CommonRec_Column_Other      = 30012;     //�����ֶ�;
  CommonRec_Column_StartStation=30013;     //��ʼվ;
  CommonRec_Column_EndStation = 30014;     //��ʼվ;
  CommonRec_Column_JGPressure = 30015;     //����
  CommonRec_Column_LampNumber = 30017;     //�źŻ����
  CommonRec_Column_Rotate     = 30018;     //����

  CommonRec_Column_Acceleration = 30019;   //���ٶ�
  CommonRec_Column_ZT= 30022;      //���״̬;


  File_Headinfo_dtBegin = 5001;    //�ļ���ʼ
  File_Headinfo_Factory = 5002;    //���ұ�־
  File_Headinfo_KeHuo = 5003;      //�����ͻ�
  File_Headinfo_CheCi = 5004;      //����
  File_Headinfo_TotalWeight = 5005;//����
  File_Headinfo_DataJL = 5006;     //���ݽ�·
  File_Headinfo_JLH = 5007;        //��ؽ�·
  File_Headinfo_Driver = 5008;     //˾����
  File_Headinfo_SubDriver = 5009;  //��˾����
  File_Headinfo_LiangShu = 5010;   //����
  File_Headinfo_JiChang = 5011;    //�Ƴ�
  File_Headinfo_ZZhong = 5012;     //����
  File_Headinfo_TrainNo = 5013;    //������
  File_Headinfo_TrainType = 5014;  //��������
  File_Headinfo_LkjID = 5015;      //���װ�ú�
  File_Headinfo_StartStation = 5016;//��վ��



  {$endRegion '����Υ�����'}

  {$region '����ϵͳ����'}
  SYSTEM_STANDARDPRESSURE = 1000000;
  SYSTEM_STANDARDPRESSURE_HUO = 500;          //������׼ѹ��
  SYSTEM_STANDARDPRESSURE_XING = 600;         //�а���׼ѹ��
  SYSTEM_STANDARDPRESSURE_KE = 600;           //�ͳ���׼ѹ��
  {$endregion '����ϵͳ����'}
  
  {$REGION '���϶���'}
    CommonRec_Column_VscMatched = 30019;    //�Զ��峣�� ���ڱȽϱ��ʽ�̶�����Matched
  CommonRec_Column_VscUnMatch = 30020;    //�Զ��峣�� ���ڱȽϱ��ʽ�̶�����UnMatch

  {$ENDREGION '���϶���'}
  {$region '�쳣��Ϣ����'}
  WM_USER   =    1024; //0X0400
  WM_ERROR_GETVALUE = WM_USER + 1;
  {$endregion '�쳣��Ϣ����'}  

  {$region 'Htmlת�嶨��'}
  VS_AND = '&#38;';     // & , AND
  VS_OR  = '&#124;';    // | , OR
  VS_L   = '&#40;';     // ( , ������
  VS_R   = '&#41;';     // ) , ������
  VS_N   = '&gt;';      // > ������Ϊָ����һ�� ������ѭ����ʽ
  {$endregion 'Htmlת�嶨��'}

type
  {$region 'ö�ٶ���'}
  {Υ������ö��}
  TVSCState = (vscAccept {����״̬},vscMatching,vscMatched{ƥ��״̬},vscUnMatch{��ƥ��״̬});

  {������ö��}
  TVSDataType = (vsdtAccept{��һ�ν��ܵ�����},vsdtMatcing{��һ��ƥ���е�����},vsdtLast{��һ������});

  {������ö��}
  TVSOperator = (vspMore{����},vspLess{С��},vspEqual{����},vspNoMore{������},
                vspNoLess{��С��},vspNoEqual{������},vspLeftLike{���ȣ�����࿪ͷ���ʺ�ָ���ַ�},
                vspLeftNotLike{��಻��},vspChaZhi{��ֵ});
  {˳��ö��}
  TVSOrder = (vsoArc{����},vsoDesc{�½�});
  {���ݷ�������}
  TVSReturnType = (vsrBegin{��Χ��ʼ},vsrEnd{��Χ����},vsrMatched{ƥ���¼});
  {ȡֵλ��}
  TVSPositionType = (vsptCrest{����},vsptTrough{����});
  {�µ�����}
  TVSSlopeType = (stUp{����},stDown{����});
  {�ƶ�����������}
  TBrakeTestType = (bttNotDone{δ��},bbtLessTime{����ʱ�䲻��},bbtLeak{й©������});
  {$endregion 'ö�ٶ���'}

  {$REGION '�ṹ����'}
  //������Ϣ
  RCheCiInfo = record
    strCheCi : string;         //����
    dZaiZong : Double;         //����
    bZZaiLieChe : Boolean;     //����
    bZuHe : Boolean;           //����г�
  end;
  TCheCiInfo = array of RCheCiInfo;
  PCheCiInfo = ^RCheCiInfo;

  //�¶���Ϣ
  RSlopeInfo = record
    nBeginPos : Integer;             //��ʼ�����
    nEndPos : Integer;               //���������
    nStation : Integer;              //��վ��
    nJiaoLu : Integer ;              //��·��
    nUpDownType : Integer;           //�����У�0���С�1����
    nSlopeType : Integer;            //�����£�0���¡�1����
  end;

  TSlopeInfo = array of RSlopeInfo;

  //��բ����Ϣ
  RSZDInfo = record
    nBeginPos : Integer;             //��ʼ�����
    nEndPos : Integer;               //���������
    nStation : Integer;              //��վ��
    nJiaoLu : Integer ;              //��·��
    nUpDownType : Integer;           //�����У�0���С�1����
  end;
  TSZDInfo = array of RSZDInfo;

  //������Ϣ�ṹ
  RConfigInfo = record
    dAcceleration : Double;                    //���ٶ�
    dSlipAcceperation : Double;                //���м��ٶ�����
    nSampleSpeed : Integer;                    //������ٶȲ����ٶȲ�
    nBrakeDistance : Integer;                  //��բ����
    nStandardPressure : Integer;               //��ѹ
    bZZaiLieChe : Boolean;                     //�����г�
    bTwentyThousand : Boolean;                 //������г�
    SlopeInfo : TSlopeInfo;                    //�µ�����
    SZDInfo : TSZDInfo;                        //��բ����Ϣ
    nCFTime50 : Integer;                       //��ѹ50kpa���ʱ��
    nCFTime70 : Integer;                       //��ѹ70kpa���ʱ��
    nCFTime100 : Integer;                      //��ѹ100kpa���ʱ��
    nCFTime170 : Integer;                      //��ѹ170kpa���ʱ��
    nPFTime50 : Integer;                       //��ѹ50kpa�ŷ�ʱ��
    nPFTime70 : Integer;                       //��ѹ70kpa�ŷ�ʱ��
    nPFTime100 : Integer;                      //��ѹ100kpa�ŷ�ʱ��
    nPFTime170 : Integer;                      //��ѹ170kpa�ŷ�ʱ��
    nBrakePressure : Integer;                  //�ƶ�ʱ��ѹ���ֵ
  end;

  RRulesInfo = record
    strName : string;             //��������
    strDescription : string;      //��������
    strJudgeCondition : string;   //�ж�����
  end;
  TRulesInfo = array of RRulesInfo;


  RRecordFmt = record
    ID: integer;               //���
    Disp: string;               //�¼�����
    Time: TDateTime;            //ʱ��
    glb: string;                //�����
    xhj: string;                //�źŻ�
    nDistance: integer;         //����
    nGuanYa: Integer;           //��ѹ
    nGangYa: Integer;           //��ѹ
    nJG1: Integer;              //����1
    nJG2: Integer;              //����2
    nSignal: Integer;           //�����ź�
    nSignalType: Integer;       //�źŻ�����
    nSignalNo: Integer;         //�źŻ����
    nHandle: Integer;           //�ֱ�״̬
    nRota: Integer;             //����
    nSpeed: Integer;            //�ٶ�
    nSpeed_lmt: Integer;        //����
    lsxs: Integer;              //��ʱ����
    strOther: string;           //����
    Shuoming: string;           //˵��
    JKZT : Integer;             //��¼�ź������ļ��״̬����أ�1��ƽ����2�����ࣽ3
  end;

  TRecordFmt = array of RRecordFmt;


   //////////////////////////////////////////////////////////////////////////////
  ///����Ա��ҵʱ��
  ///�ں�ʱ��Ϊ0ʱ����ȡ������
  //////////////////////////////////////////////////////////////////////////////
  ROperationTime = record
    //���ʱ��
    inhousetime : TDateTime;
    //���ڳ��νӳ�ʱ��
    jctime : TDateTime;
    //����ʱ��
    outhousetime : TDateTime;
    //���ڳ��ε�վʱ��
    tqarrivetime : TDateTime;
    //���ڳ��ο���
    tqdat : TDateTime;
    //�ƻ�����ʱ��
    jhtqtime : TDateTime;
  end;

  {$ENDREGION '�ṹ����'}

  {$REGION 'DLL��������'}
  function NewFmtFile(aPath, OrgFileName, FmtFileName: string): integer; stdcall; external 'fmtFile.dll';
  procedure Fmttotable(var tablefilename,fmtfilename,curpath: PChar;userid:Byte); stdcall; external 'testdll.dll';

  {$ENDREGION 'DLL��������'}

 

//���ַ������źŻ�
function IsExistInt(TArray: array of Integer;LowIndex,HighIndex,Value : Integer):Integer;
//�������ʱ��
function CombineDateTime(dtDate,dtTime: TDateTime): TDateTime;

implementation
function CombineDateTime(dtDate,dtTime: TDateTime): TDateTime;
begin
  Result := 0;
  ReplaceDate(Result, dtDate);
  ReplaceTime(Result, dtTime);
end;

function IsExistInt(TArray: array of Integer;LowIndex,HighIndex,Value : Integer):Integer;
var
  TmpIndex : Integer;
begin
  TmpIndex := (LowIndex + HighIndex) div 2;
  if TArray[TmpIndex] = Value then
    Result := TmpIndex
  else
  begin
    if TArray[TmpIndex] < Value then
    begin
      if (TmpIndex + 1) > HighIndex then
        Result := -1
      else
        Result := IsExistInt(TArray,TmpIndex + 1,HighIndex,Value);
    end
    else
    begin
      if (TmpIndex - 1) < LowIndex then
        Result := -1
      else
        Result := IsExistInt(TArray,LowIndex,TmpIndex - 1,Value);
    end;
  end;
end;

end.
