unit uVSConst;
{违标常量定义}
interface
uses
  SysUtils;
const
  {$Region '定义违标参数'}
  //运行记录头定义
  CommonRec_Head_KeHuo = 10003;           //客货
  CommonRec_Head_CheCi = 10004;           //车次
  CommonRec_Head_TotalWeight=10005;       //总重;
  CommonRec_Head_LiangShu = 10006;        //辆数
  CommonRec_Head_LocalType = 10007;       //车型
  CommonRec_Head_LocalID = 10008;         //车号
  CommonRec_Head_Factory = 10009;         //软件厂家

  Custom_Head_ZongZai = 10010;            //是否重载
  Custom_Head_ZuHe = 10011;               //是否组合列车
  //记录事件类型定义
  CommonRec_Event_Column = 20000;         //事件变化
  CommonRec_Event_BaoZha = 20001;         //机车抱闸
  CommonRec_Event_PingDiaoChange = 35333;   //平调信号变化
  CommonRec_Event_SignalChange = 35329;   //机车信号变化
  CommonRec_Event_XingHaoTuBian = 35332;  //信号突变
  CommonRec_Event_GLBTuBian = 34563;      //公里标突变

  CommonRec_Event_TrainPosForward = 34306;//车位向前
  CommonRec_Event_TrainPosBack = 34307;   //车位向后
  CommonRec_Event_TrainPosReset = 34309;  //车位对中
  CommonRec_Event_CuDuan = 34321;         //出段
  CommonRec_Event_RuDuan = 34322;         //入段
  CommonRec_Event_EnsureGreenLight = 34433;//绿/绿黄确认
  
  CommonRec_Event_Pos = 34332;            //定标键

  CommonRec_Event_Verify = 35904;         //IC卡验证码
  CommonRec_Event_PushIC = 34356;         //插入IC卡
  CommonRec_Event_PopIC = 34357;          //拔出IC卡
  CommonRec_Event_ClearReveal = 35849;    //清除揭示
  CommonRec_Event_KongZhuan = 34591;      //转对空转
  CommonRec_Event_KongZhuanEnd = 34592;   //空转结束;

  
  CommonRec_Event_RevealQuery = 35846;    //揭示查询
  CommonRec_Event_InputReveal = 33537;    //输入揭示
  CommonRec_Event_MInputReveal = 33538;   //手工揭示输入
  CommonRec_Event_ReInputReveal = 33539;  //揭示重新输入

  CommonRec_Event_CeXian = 34317;         //侧线号输入

  CommonRec_Event_DuiBiao = 34305;        //开车对标
  CommonRec_Event_EnterStation = 34575;   //进站
  CommonRec_Event_SectionSignal = 34577;   //区间过机(过信号机)
  CommonRec_Event_InOutStation = 34656;   //进出站(过信号机)

  CommonRec_Event_SpeedChange = 35585;    //速度变化
  CommonRec_Event_RotaChange  = 35586;    //转速变化
  CommonRec_Event_GanYChange = 35590;     //管压变化
  CommonRec_Event_SpeedLmtChange = 35591; //限速变化
  CommonRec_Event_GangYChange = 35600;    //缸压变化


  CommonRec_Event_LSXSStart = 35843;      //临时限速开始
  CommonRec_Event_LSXSEnd = 35844;      //临时限速结束


  CommonRec_Event_LeaveStation = 34576;      //出站
  CommonRec_Event_StartTrain = 34605;      //起车
  CommonRec_Event_ZiTing = 34580;         //自停停车
  CommonRec_Event_StopInRect = 34583;     //区间停车
  CommonRec_Event_StartInRect = 34587;    //区间开车
  CommonRec_Event_StopInJiangJi = 34579; //降级停车
  CommonRec_Event_StopInStation = 34584;  //站内停车
  CommonRec_Event_StopOutSignal = 34585;  //机外停车
  CommonRec_Event_StartInStation = 34588; //站内开车
  CommonRec_Event_StartInJiangJi = 34586; //降级开车
  CommonRec_Event_GuoJiJiaoZheng = 34567; //过机校正
  CommonRec_Event_JinRuJiangJi = 45104;   //进入降级
  CommonRec_Event_FangLiuStart = 34571;   //防溜报警开始
  CommonRec_Event_FangLiuEnd = 34572;   //防溜报警结束
  CommonRec_Event_JinJiBrake = 35073;   //紧急制动
  CommonRec_Event_ChangYongBrake = 35074;//常用制动
  CommonRec_Event_XieZai = 35075;        //卸载动作






  CommonRec_Event_Diaoche = 34318;        //进入调车
  CommonRec_Event_DiaocheJS = 34319;      //退出调车
  CommonRec_Event_DiaoCheStart = 34590;   //调车开车
  CommonRec_Event_DiaoCheStop = 34582;    //调车停车
  CommonRec_Event_JKStateChange = 33237;  //监控状态变化
  CommonRec_Event_PingDiaoStart = 50001;  //自定义平调开始
  CommonRec_Event_PingDiaoStop = 50002;  //自定义平调开始

  CommonRec_Event_UnlockSucceed = 34310;  //解锁成功(解锁键)
  CommonRec_Event_GuoFX = 34424;          //过分相



  CommonRec_Event_YDJS = 34464;          //引导解锁成功
  CommonRec_Event_TDYDJS = 34465;        //特定引导解锁
  CommonRec_Event_KBJS = 34466;          //靠标解锁成功
  CommonRec_Event_FQZX = 34470;          //防侵正线解锁
  CommonRec_Event_LPJS = 34472;          //路票解锁成功
  CommonRec_Event_LSLPJS = 34373;        //临时路票解锁
  CommonRec_Event_LZJS = 34474;          //绿证解锁成功
  CommonRec_Event_LSLZJS = 34475;        //临时绿证解锁
  CommonRec_Event_JSCG = 34310;          //解锁成功
  Commonrec_Event_GDWMTGQR = 34476;      //股道无码通过确认
  Commonrec_Event_GDWMKCQR = 34477;      //股道无码开车确认

  CommonRec_Event_TSQR = 34479;          //特殊发码确认



  //自定义事件
  Custom_Event_Revert    = 39001;           //返转
  Custom_Event_Drop      = 39002;           //开始下降
  Custom_Event_Rise      = 39003;           //开始上升
  Custom_Event_DropValue = 39004;           //达到下降量
  Custom_Event_RiseValue = 39005;           //达到上升量
  Custom_Event_ReachValue= 39006;           //达到指定值
  Custom_Event_DropFromValue = 39007;       //从指定值开始下降
  Custom_Event_DropToValue   = 39008;       //下降到指定值
  Custom_Event_RiseFromValue = 39009;       //从指定值开始上升
  Custom_Event_RiseToValue = 39010;         //上升到指定值

  //自定义VALUE
  Custom_Value_CFTime    = 999901;          //冲风时间
  Custom_Value_StandardPressure = 999902;   //标压
  Custom_Value_BrakeDistance = 999903;      //带闸距离



  //记录变动类行定义
  CommonRec_Column_GuanYa    = 30001;     //管压;
  CommonRec_Column_Sudu      = 30002;     //速度;
  CommonRec_Column_WorkZero  = 30003;     //工况零位;
  CommonRec_Column_HandPos   = 30004;     //前后;
  CommonRec_Column_WorkDrag  = 30005;     //手柄位置;
  CommonRec_Column_DTEvent   = 30006;     //事件发生时间;
  CommonRec_Column_Distance  = 30007;     //信号机距离;
  CommonRec_Column_LampSign  = 30008;     //信号灯;
  CommonRec_Column_GangYa    = 30009;     //缸压;
  CommonRec_Column_SpeedLimit= 30010;      //限速;

  CommonRec_Column_Coord      = 30011;     //公里标;
  CommonRec_Column_Other      = 30012;     //其它字段;
  CommonRec_Column_StartStation=30013;     //起始站;
  CommonRec_Column_EndStation = 30014;     //起始站;
  CommonRec_Column_JGPressure = 30015;     //均缸
  CommonRec_Column_LampNumber = 30017;     //信号机编号
  CommonRec_Column_Rotate     = 30018;     //柴速

  CommonRec_Column_Acceleration = 30019;   //加速度
  CommonRec_Column_ZT= 30022;      //监控状态;


  File_Headinfo_dtBegin = 5001;    //文件开始
  File_Headinfo_Factory = 5002;    //厂家标志
  File_Headinfo_KeHuo = 5003;      //本补客货
  File_Headinfo_CheCi = 5004;      //车次
  File_Headinfo_TotalWeight = 5005;//总重
  File_Headinfo_DataJL = 5006;     //数据交路
  File_Headinfo_JLH = 5007;        //监控交路
  File_Headinfo_Driver = 5008;     //司机号
  File_Headinfo_SubDriver = 5009;  //副司机号
  File_Headinfo_LiangShu = 5010;   //辆数
  File_Headinfo_JiChang = 5011;    //计长
  File_Headinfo_ZZhong = 5012;     //载重
  File_Headinfo_TrainNo = 5013;    //机车号
  File_Headinfo_TrainType = 5014;  //机车类型
  File_Headinfo_LkjID = 5015;      //监控装置号
  File_Headinfo_StartStation = 5016;//车站号



  {$endRegion '定义违标参数'}

  {$region '定义系统常量'}
  SYSTEM_STANDARDPRESSURE = 1000000;
  SYSTEM_STANDARDPRESSURE_HUO = 500;          //货车标准压力
  SYSTEM_STANDARDPRESSURE_XING = 600;         //行包标准压力
  SYSTEM_STANDARDPRESSURE_KE = 600;           //客车标准压力
  {$endregion '定义系统常量'}
  
  {$REGION '集合定义'}
    CommonRec_Column_VscMatched = 30019;    //自定义常量 用在比较表达式固定返回Matched
  CommonRec_Column_VscUnMatch = 30020;    //自定义常量 用在比较表达式固定返回UnMatch

  {$ENDREGION '集合定义'}
  {$region '异常消息定义'}
  WM_USER   =    1024; //0X0400
  WM_ERROR_GETVALUE = WM_USER + 1;
  {$endregion '异常消息定义'}  

  {$region 'Html转义定义'}
  VS_AND = '&#38;';     // & , AND
  VS_OR  = '&#124;';    // | , OR
  VS_L   = '&#40;';     // ( , 左括号
  VS_R   = '&#41;';     // ) , 右括号
  VS_N   = '&gt;';      // > ，这里为指向下一个 ，用于循序表达式
  {$endregion 'Html转义定义'}

type
  {$region '枚举定义'}
  {违标条件枚举}
  TVSCState = (vscAccept {接受状态},vscMatching,vscMatched{匹配状态},vscUnMatch{不匹配状态});

  {操作符枚举}
  TVSDataType = (vsdtAccept{第一次接受的数据},vsdtMatcing{第一次匹配中的数据},vsdtLast{上一条数据});

  {操作符枚举}
  TVSOperator = (vspMore{大于},vspLess{小于},vspEqual{等于},vspNoMore{不大于},
                vspNoLess{不小于},vspNoEqual{不等于},vspLeftLike{左侧等：以左侧开头以问号指定字符},
                vspLeftNotLike{左侧不等},vspChaZhi{差值});
  {顺序枚举}
  TVSOrder = (vsoArc{上升},vsoDesc{下降});
  {数据返回类型}
  TVSReturnType = (vsrBegin{范围开始},vsrEnd{范围结束},vsrMatched{匹配记录});
  {取值位置}
  TVSPositionType = (vsptCrest{波峰},vsptTrough{波谷});
  {坡道类型}
  TVSSlopeType = (stUp{上坡},stDown{下坡});
  {制动机试验类型}
  TBrakeTestType = (bttNotDone{未做},bbtLessTime{试验时间不足},bbtLeak{泄漏量超标});
  {$endregion '枚举定义'}

  {$REGION '结构定义'}
  //车次信息
  RCheCiInfo = record
    strCheCi : string;         //车次
    dZaiZong : Double;         //载重
    bZZaiLieChe : Boolean;     //重载
    bZuHe : Boolean;           //组合列车
  end;
  TCheCiInfo = array of RCheCiInfo;
  PCheCiInfo = ^RCheCiInfo;

  //坡度信息
  RSlopeInfo = record
    nBeginPos : Integer;             //开始公里标
    nEndPos : Integer;               //结束公里标
    nStation : Integer;              //车站号
    nJiaoLu : Integer ;              //交路号
    nUpDownType : Integer;           //上下行，0上行、1下行
    nSlopeType : Integer;            //上下坡，0上坡、1下坡
  end;

  TSlopeInfo = array of RSlopeInfo;

  //试闸点信息
  RSZDInfo = record
    nBeginPos : Integer;             //开始公里标
    nEndPos : Integer;               //结束公里标
    nStation : Integer;              //车站号
    nJiaoLu : Integer ;              //交路号
    nUpDownType : Integer;           //上下行，0上行、1下行
  end;
  TSZDInfo = array of RSZDInfo;

  //配置信息结构
  RConfigInfo = record
    dAcceleration : Double;                    //加速度
    dSlipAcceperation : Double;                //滑行加速度门限
    nSampleSpeed : Integer;                    //计算加速度采样速度差
    nBrakeDistance : Integer;                  //带闸距离
    nStandardPressure : Integer;               //标压
    bZZaiLieChe : Boolean;                     //重载列车
    bTwentyThousand : Boolean;                 //两万吨列车
    SlopeInfo : TSlopeInfo;                    //坡道配置
    SZDInfo : TSZDInfo;                        //试闸点信息
    nCFTime50 : Integer;                       //减压50kpa冲风时间
    nCFTime70 : Integer;                       //减压70kpa冲风时间
    nCFTime100 : Integer;                      //减压100kpa冲风时间
    nCFTime170 : Integer;                      //减压170kpa冲风时间
    nPFTime50 : Integer;                       //减压50kpa排风时间
    nPFTime70 : Integer;                       //减压70kpa排风时间
    nPFTime100 : Integer;                      //减压100kpa排风时间
    nPFTime170 : Integer;                      //减压170kpa排风时间
    nBrakePressure : Integer;                  //制动时管压最低值
  end;

  RRulesInfo = record
    strName : string;             //规则名称
    strDescription : string;      //规则描述
    strJudgeCondition : string;   //判定条件
  end;
  TRulesInfo = array of RRulesInfo;


  RRecordFmt = record
    ID: integer;               //序号
    Disp: string;               //事件描述
    Time: TDateTime;            //时间
    glb: string;                //公里标
    xhj: string;                //信号机
    nDistance: integer;         //距离
    nGuanYa: Integer;           //管压
    nGangYa: Integer;           //缸压
    nJG1: Integer;              //均缸1
    nJG2: Integer;              //均缸2
    nSignal: Integer;           //机车信号
    nSignalType: Integer;       //信号机类型
    nSignalNo: Integer;         //信号机编号
    nHandle: Integer;           //手柄状态
    nRota: Integer;             //柴速
    nSpeed: Integer;            //速度
    nSpeed_lmt: Integer;        //限速
    lsxs: Integer;              //临时限速
    strOther: string;           //其它
    Shuoming: string;           //说明
    JKZT : Integer;             //记录信号所处的监控状态；监控＝1，平调＝2，调监＝3
  end;

  TRecordFmt = array of RRecordFmt;


   //////////////////////////////////////////////////////////////////////////////
  ///乘务员作业时间
  ///内含时间为0时代表取不出来
  //////////////////////////////////////////////////////////////////////////////
  ROperationTime = record
    //入库时间
    inhousetime : TDateTime;
    //出勤车次接车时间
    jctime : TDateTime;
    //出库时间
    outhousetime : TDateTime;
    //退勤车次到站时间
    tqarrivetime : TDateTime;
    //退勤车次开点
    tqdat : TDateTime;
    //计划退勤时间
    jhtqtime : TDateTime;
  end;

  {$ENDREGION '结构定义'}

  {$REGION 'DLL函数定义'}
  function NewFmtFile(aPath, OrgFileName, FmtFileName: string): integer; stdcall; external 'fmtFile.dll';
  procedure Fmttotable(var tablefilename,fmtfilename,curpath: PChar;userid:Byte); stdcall; external 'testdll.dll';

  {$ENDREGION 'DLL函数定义'}

 

//二分法查找信号机
function IsExistInt(TArray: array of Integer;LowIndex,HighIndex,Value : Integer):Integer;
//组合日期时间
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
