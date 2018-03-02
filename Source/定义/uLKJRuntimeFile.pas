unit uLKJRuntimeFile;
{LKJ运行记录文件单元}

interface

uses
  Classes,Windows, Contnrs, SysUtils, uVSConst, DateUtils;

type
  {机车信号}
  TLampSign = (
    lsGreen {绿灯}, lsGreenYellow {绿黄},
    lsYellow {黄色}, lsYellow2 {黄2}, lsDoubleYellow {双黄}, lsYellow2S {黄2闪},
    lsDoubleYellowS {双黄闪}, lsRed {红灯}, lsRedYellow {红黄},
    lsRedYellowS {红黄闪}, lsWhite {白灯}, lsMulti {多灯}, lsClose {灭灯},
    lsPDNone {00}, lsPDTingChe {停车}, lsPDTuiJin {推进}, lsPDQiDong {启动},
    lsPDLianJie {连接}, lsPDLiuFang {溜放}, lsPDJianSu {减速}, lsPDShiChe {十车},
    lsPDWuChe {五车}, lsPDSanChe {三车}, lsPDQianChuShaoDong {牵出稍动}, lsPDShouFangQuan {收放权},
    lsPD12 {12H}, lsPDTuiJinShaoDong {推进稍动}, lsPDGuZhangTingChe {故障停车}, lsPD15 {15H},
    lsPDJinJiTingChe1 {紧急停车1}, lsPDJinJiTingChe2 {紧急停车2}, lsPDJinJiTingChe3 {紧急停车3}, lsPDJinJiTingChe4 {紧急停车4},
    lsPDJinJiTingChe5 {紧急停车5}, lsPDJinJiTingChe6 {紧急停车6}, lsPDJinJiTingChe7 {紧急停车7}, lsPDJinJiTingChe8 {紧急停车8},
    lsPDJieSuo1 {解锁1}, lsPDJieSuo2 {解锁2}, lsPDJieSuo3 {解锁3}, lsPDJieSuo4 {解锁4},
    lsPDJieSuo5 {解锁5}, lsPDJieSuo6 {解锁6}, lsPDJieSuo7 {解锁7}, lsPDJieSuo8 {解锁8},
    lsPDYiChe {一车}
    );
    {平调信号定义
    00H	        	01H	停车		02H	推进		03H	起动
    04H	连接		05H	溜放		06H	减速		07H	十车
    08H	五车		09H	三车		10H	牵出稍动	11H	收放权
    12H				13H	推进稍动	14H	故障停车	15H
    16H	紧急停车1	17H	紧急停车2	18H	紧急停车3	19H	紧急停车4
    20H	紧急停车5	21H	紧急停车6	22H	紧急停车7	23H	紧急停车8
    24H	解锁1		25H	解锁2		26H	解锁3		27H	解锁4
    28H	解锁5		29H	解锁6		30H	解锁7		31H	解锁8
    35H	一车
    }

  {零位和非零位}
  TWorkZero = (wAtZero {零位}, wNotZero {非零位});

  {前后}
  THandPos = (hpForword {向前}, hpMiddle {中}, hpBack {向后}, hpInvalid {非});

  {牵制}
  TWorkDrag = (wdDrag {牵}, wdMiddle {中}, wdBrake {制动}, wdInvalid {非});

  {信号机类型}
  //TLKJSignType = (stNormal {普通}, stIn {进站}, stOut {出站}, stStation {中心站});
  TLKJSignType = (stNormal {通过}, stPre {预告}, stInOut {进出站}, stIn {进站}, stOut {出站}, stStation {中心站}, stNone {无});

  {监控设备厂商}
  TLKJFactory = (sfSiWei {思维}, sfZhuZhou {株洲});

  {客货类型}
  TLKJTrainType = (ttPassenger {客车}, ttCargo {货车}, ttAny {客车或货车}); //ttany 用作在客货类型判断时不作判断用

  {本机、补机}
  TLKJBenBu = (bbBen {本机}, bbBu {补机}, bbAny {本机或补机});
  {调车类型}
  TDiaoCheType = (dcPingDiao {平调}, dcDiaoChe {普通调车}, dcAll {全部});
  {万吨、普通列车}
  TLKJWorkType = (wtNormal {普通列车}, wtTenThousand {万吨}, wtTwentyThousand {两万吨});

  ////////////////////////////////////////////////////////////////////////////////
  //TLKJRuntimeFileRec LKJ运行记录文件中记录基类，所有类型的记录都从此类派生}
  ////////////////////////////////////////////////////////////////////////////////
  TLKJRuntimeFileRec = class
  public
    {功能：将类中的内容转化为字符串}
    function ToString(): string; virtual; abstract;
    {功能：根据字符串中的内容设置类中各个成员的值}
    procedure FromString(strText: string); virtual; abstract;
  end;


  {RCommonRec 全程记录通用记录信息结构体}
  RCommonRec = record
    nRow: Integer; //全程记录行号
    strDisp: string; //事件描述
    nEvent: Integer; //事件数字代码
    DTEvent: TDateTime; //事件发生时间
    nCoord: Integer; //公里标
    nDistance: Integer; //距信号机距离
    LampSign: TLampSign; //灯信号
    strSignal: string; //色灯
    nLampNo: Integer; //信号机编号6244
    SignType: TLKJSignType; //信号机类型
    strXhj: string; //信号机
    nSpeed: Integer; //运行速度
    nLimitSpeed: Integer; //限制速度
    nShoub: Byte; //手柄状态
    strGK: string; //工况状态
    WorkZero: TWorkZero; //零位[零, 非]
    HandPos: THandPos; //前后[前, 后]
    WorkDrag: TWorkDrag; //牵制[牵, 制]
    nLieGuanPressure: Integer; //列管压力
    nGangPressure: Integer; //缸压力
    nRotate: Integer; //转速
    nJG1Pressure: Integer; //均缸1压力
    nJG2Pressure: Integer; //均缸2压力
    strOther: string; //其他
    nJKLineID: Integer; //当前交路号
    nDataLineID: Integer; //当前数据交路号
    nStation: Integer; //已过车站号
    nToJKLineID: Integer; //上一个站的交路号
    nToDataLineID: Integer; //上一个站的数据交路号
    nToStation: Integer; //上一个站编号
    nStationIndex: Integer; //从始发站开始战间编号
    ShuoMing: string; //说明
    JKZT: Integer; //监控状态  监控＝1，平调＝2，调监＝3
    bIsDiaoChe : boolean; //是否处于调车状态 (如否则为正常行车或平调)
    bIsJiangji : boolean; //是否处于降级状态（如否则为正常监控）
    bIsPingdiao : boolean;//是否处于平调状态（如否则为正常行车或调车）
    nValidJG: Integer; //有效均缸号
    //所属车次信息
    strCheCi : string;
  end;

  {特殊记录信息结构体}
  RSprecialRec = record
    script: string; // 记录事件描述
    value: string; // 记录内容
  end;
  PSprecialRec = ^RSprecialRec;


  ///////////////////////////////////////////////////////////////////////////////
  //TLKJCommonRec 全程记录通用记录信息
  ///////////////////////////////////////////////////////////////////////////////
  TLKJCommonRec = class(TLKJRuntimeFileRec)
  public
    function ToString(): string; override;
    procedure FromString(strText: string); override;
  public
    CommonRec: RCommonRec; //全程记录通用记录信息
    procedure Clone(Srouce: TLKJCommonRec);
  end;

  //////////////////////////////////////////////////////////////////////////////
  ///TLkjCommonRecLst 全程记录通用记录信息列表
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

  {RLKJRTFileHeadInfo  运行记录文件头信息}
  RLKJRTFileHeadInfo = record
    dtKCDataTime: TDateTime;
    nLocoType: Integer; //机车类型号(DF11)代码[数字]
    nLocoID: Integer; //机车编号
    strTrainHead: string[20]; //车次头
    nTrainNo: integer; //车次号
    nLunJing: integer; //轮径
    nDistance: Integer; //走行距离
    nJKLineID: Integer; //交路号
    nDataLineID: Integer; //数据交路号
    nFirstDriverNO: Integer; //司机工号
    nSecondDriverNO: Integer; //副司机工号
    nStartStation: Integer; //始发站
    nEndStation: Integer; //终点站
    nLocoJie: string[10]; //机车单节等信息
    nDeviceNo: Integer; //装置号
    nTotalWeight: Integer; //总重
    nSum: Integer; //合计
    nLoadWeight: Integer; //载重
    nJKVersion: Integer; //监控版本
    nDataVersion: Integer; //数据版本
    DTFileHeadDt: TDateTime; //文件头时间
    Factory: TLKJFactory; //软件厂家
    TrainType: TLKJTrainType; //机车客货类别(货,客)代码[数字]
    BenBu: TLKJBenBu; //本机、补机
    nStandardPressure: Integer; //标准管压
    nMaxLmtSpd: Integer; //输入最高限速
    strOrgFileName: string[255]; //原始文件名
  end;

  {文件时间类型}
  TFileTimeType = (fttBegin {文件开始时间}, fttEnd {文件结束时间}, fttRuKu {最后入库时间});

  ////////////////////////////////////////////////////////////////////////////////
  /// 类名:TLKJRuntimeFile
  /// 功能:存贮解格式化文件信息
  ////////////////////////////////////////////////////////////////////////////////
  TLKJRuntimeFile = class
  public
    constructor Create();
    destructor Destroy(); override;
  protected
    {全程记录列表}
    m_Records: TLkjCommonRecLst;
  public
    {头信息}
    HeadInfo : RLKJRTFileHeadInfo;
    {功能:清除记录内容}
    procedure Clear();
  public
    property Records: TLkjCommonRecLst read m_Records;
  end;

  ////////////////////////////////////////////////////////////////////////////////
  /// 类名:TLkjRuntimeFileLst
  /// 功能:文件信息列表
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

