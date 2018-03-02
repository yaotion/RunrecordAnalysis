unit uConvertDefine;

interface
uses
  Classes,uVSConst,uLKJRuntimeFile,SysUtils,Windows;
type
  ////////////////////////////////////////////////////////////////////////////////
  ///TFieldConvert字段转换类，各字段的显示字符串转换为对应类型的值
  ////////////////////////////////////////////////////////////////////////////////
  TFieldConvert = class
  public
    constructor Create();
    destructor Destroy; override;
  private
    m_EventDisp : TStringList;
    {功能：初始化事件描述}
    procedure InitEventDisp();
  public
    {功能：获取事件代码}
    function GetnEvent(Disp: string): Integer;
    {功能：获取公里标信息}
    function GetnCoord(strCoord: string): Integer;
    {功能：公里标信息转化为显示字符串}
    function ConvertCoordToStr(nCoor: Integer): string;
    {功能：获取零位/非零手柄状态}
    function ConvertWorkZero(bHandle : byte) : TWorkZero;
    {功能：获取牵引/制动手柄状态}
    function ConvertWorkDrag(bHandle : byte) : TWorkDrag;
    {功能：获取前/后手柄状态}
    function ConvertHandPos(bHandle : byte) : THandPos;
    {功能：获取信号状态}
    function ConvertSignal(nSignal : byte) : TLampSign;
    {功能：获取信号机类型状态}
    function ConvertSignType(nxhj_type : byte) : TLKJSignType;
    {功能：获取车次信息}
    procedure GetCheCiInfo(FieldOther: string;var CheCi:Integer;TrainHead:string);
    {功能：获取客货、本补信息}
    procedure GetKeHuoBenBu(FieldOther: string;var TrainType:TLKJTrainType;var BenBu:TLKJBenBu);
    {功能：获取监控厂家信息}
    function  GetJkFactoryInfo(FieldOther: string): TLKJFactory;
    {功能：获取乘务员工号}
    function  GetDriverNo(FieldOther: string): Integer;
    {功能：获取机车号}
    function  GetLocalID(FieldOther: string): Integer;    
    //事件描述集
    property EventDsip : TStringList read m_EventDisp;
  end;
  //////////////////////////////////////////////////////////////////////////////
  ///TStationFormat车站解析类
  //////////////////////////////////////////////////////////////////////////////
  TStationFormat = class
  private
    {功能：从OTHER字段解析出交路号和站号}
    function DecodeStr(strOther: string;var nJiaoLu: Integer;var nStation: Integer): Boolean;
  public
    procedure Execute(LkjFile:TLKJRuntimeFile);
  end;

  
implementation

{ TFieldConvert }

function TFieldConvert.ConvertCoordToStr(nCoor: Integer): string;
begin
  Result := Format('%.3f',[nCoor / 1000]);
end;

function TFieldConvert.ConvertHandPos(bHandle: byte): THandPos;
begin
  result := hpForword;
  case ((bHandle div 2) mod 4) of    //D1D2
      0: Result := hpMiddle;
      1: Result := hpForword;
      2: Result := hpBack;
      3: Result := hpInvalid;
  end;
end;

function TFieldConvert.ConvertSignal(nSignal: byte): TLampSign;
var
  isSd: boolean;  //闪灯标志
begin
  Result := lsPDNone;
   { lyj 2011.8.11 增加平调信号处理，在事件E5平调信号变化时，nSignal值在原来基础上+100进行区分}
   if nSignal >= 100 then  //平调信号变化
   begin
     case nSignal mod 100 of
       0: Result := lsPDNone;
       1: Result := lsPDTingChe;
       $2: Result := lsPDTuiJin;
       $3: Result := lsPDQiDong;
       $4: Result := lsPDLianJie;
       $5: Result := lsPDLiuFang;
       $6: Result := lsPDJianSu;
       $7: Result := lsPDShiChe;
       $8: Result := lsPDWuChe;
       $9: Result := lsPDSanChe;
       $10: Result := lsPDQianChuShaoDong;
       $11: Result := lsPDShouFangQuan;
       $12: Result := lsPD12;
       $13: Result := lsPDTuiJinShaoDong;
       $14: Result := lsPDGuZhangTingChe;
       $15: Result := lsPD15;
       $16: Result := lsPDJinJiTingChe1;
       $17: Result := lsPDJinJiTingChe2;
       $18: Result := lsPDJinJiTingChe3;
       $19: Result := lsPDJinJiTingChe4;
       $20: Result := lsPDJinJiTingChe5;
       $21: Result := lsPDJinJiTingChe6;
       $22: Result := lsPDJinJiTingChe7;
       $23: Result := lsPDJinJiTingChe8;
       $24: Result := lsPDJieSuo1;
       $25: Result := lsPDJieSuo2;
       $26: Result := lsPDJieSuo3;
       $27: Result := lsPDJieSuo4;
       $28: Result := lsPDJieSuo5;
       $29: Result := lsPDJieSuo6;
       $30: Result := lsPDJieSuo7;
       $31: Result := lsPDJieSuo8;
       $35: Result := lsPDYiChe;
       else
            Result := lsPDNone;
     end;

     Exit;
   end;
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
   if (((nSignal div 10) and $08) = $08) then
        isSd := true
   else
        isSd := false;


   case nSignal mod 10 of
        $00: Result := lsGreen;
        $01: Result := lsYellow;
        $02:
             begin
                  if isSd then
                       Result := lsYellow2S
                  else
                       Result := lsYellow2;

             end;
        $03: Result := lsGreenYellow;
        $04:
             begin
                  if isSd then
                       Result := lsDoubleYellowS
                  else
                       Result := lsDoubleYellow;
             end;
        $05: Result := lsRed;
        $06:
             begin
                  if isSd then
                       Result := lsRedYellowS
                  else
                       Result := lsRedYellow;
             end;
        $07: Result := lsWhite;
        $08: Result := lsClose;
        $09: Result := lsMulti;
   end;
end;
function TFieldConvert.ConvertSignType(nxhj_type: byte): TLKJSignType;
begin
  Result := stNone;
  case nxhj_type of
    01: Result := stInOut;
    02: Result := stOut;
    03: Result := stIn;
    04: Result := stNormal;
    05: Result := stPre;
    06: Result := stNormal; //'容许';
    07: Result := stNormal;  //'分割';
    09: Result := stPre;     //'1预告';

    10: Result := stPre;  //'接近';
   // $80: Result := '平调';
  end;
end;

function TFieldConvert.ConvertWorkDrag(bHandle: byte): TWorkDrag;
begin
  Result := wdInvalid;
  case ((bHandle div 8) mod 4) of   //D3D4
      0: Result := wdMiddle;
      1: Result := wdDrag;
      2: Result := wdBrake;
      3: Result := wdInvalid;
  end;
end;

function TFieldConvert.ConvertWorkZero(bHandle: byte): TWorkZero;
begin
  if bHandle mod 2 = 1 then   //D0
     Result := wAtZero
  else
     Result := wNotZero;
end;

constructor TFieldConvert.Create;
begin
  m_EventDisp := TStringList.Create;
  InitEventDisp();
end;

destructor TFieldConvert.Destroy;
begin
  m_EventDisp.Free;
  inherited;
end;

procedure TFieldConvert.GetCheCiInfo(FieldOther: string; var CheCi: Integer;
  TrainHead: string);
var
  i : Integer;
  strCheCi: string;
begin
  for I := 1 to Length(FieldOther) do
  begin
    if FieldOther[i] in ['0'..'9'] then
      Break;
  end;
  TrainHead := Copy(FieldOther,0,i - 1);
  strCheCi := Copy(FieldOther,i,Length(FieldOther) - i + 1);
  if strCheCi <> '' then
    CheCi := StrToInt(strCheCi);
end;

function TFieldConvert.GetDriverNo(FieldOther: string): Integer;
var
  i: Integer;
  strResult : string;
begin
  for I := 1 to Length(FieldOther) do
  begin
    if not (FieldOther[i] in ['0'..'9']) then
    begin
      Break;
    end;    
  end;
  strResult := Copy(FieldOther,0,i - 1);
  Result := StrToInt(strResult);
end;

function TFieldConvert.GetJkFactoryInfo(FieldOther: string): TLKJFactory;
begin
  result := sfSiWei;
  if Pos('思维',FieldOther) <> -1 then
  begin
    Result := sfSiWei;
  end;
  if Pos('株州',FieldOther) <> -1 then
  begin
    Result := sfZhuZhou;
  end;
end;

procedure TFieldConvert.GetKeHuoBenBu(FieldOther: string;
  var TrainType: TLKJTrainType; var BenBu: TLKJBenBu);
begin
  if Pos('货',FieldOther) > 0 then
  begin
    TrainType := ttCargo;
  end;
  if Pos('客',FieldOther) > 0 then
  begin
    TrainType := ttPassenger;
  end;
  if Pos('补',FieldOther) > 0 then
  begin
    BenBu := bbBu;
  end;
  if Pos('本',FieldOther) > 0 then
  begin
    BenBu := bbBen;
  end;
end;

function TFieldConvert.GetLocalID(FieldOther: string): Integer;
var
  i : Integer;
begin
  if FieldOther = '' then
  begin
    Result := 0;
    Exit;
  end;

  for I := 1 to Length(FieldOther) do
  begin
    if not (FieldOther[i] in ['0'..'9']) then
    begin
      Break;    
    end;
  end;
    
  Result := StrToInt(Copy(FieldOther,0,i - 1));
end;

function TFieldConvert.GetnCoord(strCoord: string): Integer;
var
  I : Integer;
begin
  i := Pos('.',strCoord);
  if i > 0 then
  begin
    Result := StrToInt(StringReplace(strCoord,'.','',[rfReplaceAll]));
  end
  else
    Result := 0;
end;

function TFieldConvert.GetnEvent(Disp: string): Integer;
var
  strEvent : string;
begin
  strEvent :=  m_EventDisp.Values[Disp];
  if strEvent <> '' then
    Result := StrToInt(strEvent)
  else
    Result := 0;
end;

procedure TFieldConvert.InitEventDisp;
begin
  {$REGION '文件头信息'}
  m_EventDisp.Values['文件开始'] := IntToStr(File_Headinfo_dtBegin);
  m_EventDisp.Values['厂家标志'] := IntToStr(File_Headinfo_Factory);
  m_EventDisp.Values['本补客货'] := IntToStr(File_Headinfo_KeHuo);
  m_EventDisp.Values['车次'] := IntToStr(File_Headinfo_CheCi);
  m_EventDisp.Values['数据交路号'] := IntToStr(File_Headinfo_DataJL);
  m_EventDisp.Values['交路号'] := IntToStr(File_Headinfo_JLH);
  m_EventDisp.Values['司机号'] := IntToStr(File_Headinfo_Driver);
  m_EventDisp.Values['副司机号'] := IntToStr(File_Headinfo_SubDriver);
  m_EventDisp.Values['辆数'] := IntToStr(File_Headinfo_LiangShu);
  m_EventDisp.Values['计长'] := IntToStr(File_Headinfo_JiChang);
  m_EventDisp.Values['记录机车号'] := IntToStr(File_Headinfo_TrainNo);
  m_EventDisp.Values['记录机车型号'] := IntToStr(File_Headinfo_TrainType);
  m_EventDisp.Values['记录装置号'] := IntToStr(File_Headinfo_LkjID);
  m_EventDisp.Values['总重'] := IntToStr(File_Headinfo_TotalWeight);
  m_EventDisp.Values['载重'] := IntToStr(File_Headinfo_ZZhong);
  m_EventDisp.Values['车站号'] := IntToStr(File_Headinfo_StartStation);
  {$ENDREGION '文件头信息'}

  m_EventDisp.Values['限速变化'] := IntToStr(CommonRec_Event_SpeedLmtChange);
  m_EventDisp.Values['揭示输入'] := IntToStr(CommonRec_Event_InputReveal);
  m_EventDisp.Values['揭示查询'] := IntToStr(CommonRec_Event_RevealQuery);
  m_EventDisp.Values['IC卡拔出'] := IntToStr(CommonRec_Event_PopIC);
  m_EventDisp.Values['IC卡插入'] := IntToStr(CommonRec_Event_PushIC);
  m_EventDisp.Values['IC卡验证码'] := IntToStr(CommonRec_Event_Verify);
  m_EventDisp.Values['管压变化'] := IntToStr(CommonRec_Event_GanYChange);
  m_EventDisp.Values['闸缸压力变化'] := IntToStr(CommonRec_Event_GangYChange);
  m_EventDisp.Values['定标键'] := IntToStr(CommonRec_Event_Pos);
  m_EventDisp.Values['侧线选择'] := IntToStr(CommonRec_Event_CeXian);
  m_EventDisp.Values['信号突变'] := IntToStr(CommonRec_Event_XingHaoTuBian);

  m_EventDisp.Values['出段'] := IntToStr(CommonRec_Event_CuDuan);
  m_EventDisp.Values['入段'] := IntToStr(CommonRec_Event_RuDuan);
  m_EventDisp.Values['速度变化'] := IntToStr(CommonRec_Event_SpeedChange);
  m_EventDisp.Values['机车信号变化'] := IntToStr(CommonRec_Event_SignalChange);
  m_EventDisp.Values['车位向前'] := IntToStr(CommonRec_Event_TrainPosForward);
  m_EventDisp.Values['车位向后'] := IntToStr(CommonRec_Event_TrainPosBack);
  m_EventDisp.Values['车位对中'] := IntToStr(CommonRec_Event_TrainPosReset);
  m_EventDisp.Values['过机校正'] := IntToStr(CommonRec_Event_GuoJiJiaoZheng);

  m_EventDisp.Values['常用制动'] := IntToStr(CommonRec_Event_ChangYongBrake);
  m_EventDisp.Values['紧急制动'] := IntToStr(CommonRec_Event_JinJiBrake);
  m_EventDisp.Values['卸载动作'] := IntToStr(CommonRec_Event_XieZai);
  m_EventDisp.Values['公里标突变'] := IntToStr(CommonRec_Event_GLBTuBian);

  m_EventDisp.Values['监控状态'] := IntToStr(CommonRec_Event_JKStateChange);
  m_EventDisp.Values['绿/绿黄确认'] := IntToStr(CommonRec_Event_EnsureGreenLight);
  m_EventDisp.Values['过机不校'] := '';
  //版本TESTDLL
  m_EventDisp.Values['手柄防溜报警开始'] := IntToStr(CommonRec_Event_FangLiuStart);
  m_EventDisp.Values['手柄防溜报警结束'] := IntToStr(CommonRec_Event_FangLiuEnd);
  m_EventDisp.Values['相位防溜报警开始'] := IntToStr(CommonRec_Event_FangLiuStart);
  m_EventDisp.Values['相位防溜报警结束'] := IntToStr(CommonRec_Event_FangLiuEnd);
  m_EventDisp.Values['管压防溜报警开始'] := IntToStr(CommonRec_Event_FangLiuStart);
  m_EventDisp.Values['管压防溜报警结束'] := IntToStr(CommonRec_Event_FangLiuEnd);
  //旧版本TESTDLL
  m_EventDisp.Values['防溜报警开始'] := IntToStr(CommonRec_Event_FangLiuStart);
  m_EventDisp.Values['防溜报警结束'] := IntToStr(CommonRec_Event_FangLiuEnd);
  m_EventDisp.Values['过分相'] := IntToStr(CommonRec_Event_GuoFX);
  m_EventDisp.Values['过信号机'] := IntToStr(CommonRec_Event_SectionSignal);
  m_EventDisp.Values['临时限速开始'] := IntToStr(CommonRec_Event_LSXSStart);
  m_EventDisp.Values['过揭示起点'] := '';
  m_EventDisp.Values['临时限速结束'] := IntToStr(CommonRec_Event_LSXSEnd);
  m_EventDisp.Values['开车对标'] := IntToStr(CommonRec_Event_DuiBiao);
  m_EventDisp.Values['进站'] := IntToStr(CommonRec_Event_EnterStation);
  m_EventDisp.Values['出站'] := IntToStr(CommonRec_Event_LeaveStation);
  m_EventDisp.Values['过站中心'] := '';
  m_EventDisp.Values['轮对空转'] := IntToStr(CommonRec_Event_KongZhuan);
  m_EventDisp.Values['空转结束'] := IntToStr(CommonRec_Event_KongZhuanEnd);
  m_EventDisp.Values['自停停车'] := IntToStr(CommonRec_Event_ZiTing);
  m_EventDisp.Values['区间停车'] := IntToStr(CommonRec_Event_StopInRect);
  m_EventDisp.Values['区间开车'] := IntToStr(CommonRec_Event_StartInRect);
  m_EventDisp.Values['机外停车'] := IntToStr(CommonRec_Event_StopOutSignal);
  m_EventDisp.Values['站内停车'] := IntToStr(CommonRec_Event_StopInStation);
  m_EventDisp.Values['站内开车'] := IntToStr(CommonRec_Event_StartInStation);
  m_EventDisp.Values['进入降级'] := IntToStr(CommonRec_Event_JinRuJiangJi);
  m_EventDisp.Values['调车停车'] := IntToStr(CommonRec_Event_DiaoCheStop);
  m_EventDisp.Values['调车开车'] := IntToStr(CommonRec_Event_DiaoCheStart);
  m_EventDisp.Values['降级开车'] := IntToStr(CommonRec_Event_StartInJiangJi);
  m_EventDisp.Values['降级停车'] := IntToStr(CommonRec_Event_StopInJiangJi);
  m_EventDisp.Values['进入调车'] := IntToStr(CommonRec_Event_Diaoche);
  m_EventDisp.Values['退出调车'] := IntToStr(CommonRec_Event_DiaocheJS);
  m_EventDisp.Values['车位向前'] := IntToStr(CommonRec_Event_TrainPosForward);
  m_EventDisp.Values['车位向后'] := IntToStr(CommonRec_Event_TrainPosBack);
  m_EventDisp.Values['车位对中'] := IntToStr(CommonRec_Event_TrainPosReset);
end;

{ TStationFormat }

function TStationFormat.DecodeStr(strOther: string; var nJiaoLu,
  nStation: Integer): Boolean;
var
  DelimiterIndex: Integer;
  SpaceIndex : Integer;
  strStation : string;
  strJiaoLu : string;
begin
  Result := False;
  if Pos('SD',strOther) > 0then
    Exit;

  DelimiterIndex := Pos('-',strOther);
  if DelimiterIndex > 0 then
  begin
      strStation := Trim(Copy(strOther,DelimiterIndex + 1, Length(strOther) - DelimiterIndex));
      SpaceIndex := Pos(' ',strOther);
      strJiaoLu := Trim(Copy(strOther,1,DelimiterIndex - 1));
      strJiaoLu := Trim(Copy(strJiaoLu,SpaceIndex + 1, Length(strOther) - SpaceIndex));

      TryStrToInt(strJiaoLu,nJiaoLu);
      TryStrToInt(strStation,nStation);
      Result := True;                        
  end;
end;

procedure TStationFormat.Execute(LkjFile: TLKJRuntimeFile);
var
  i : Integer;
  nStation,nJiaoLu: Integer;
  bFlag: Boolean;
begin
  bFlag := False;

  for I := 0 to LkjFile.Records.Count - 1 do
  begin
    LkjFile.Records[i].CommonRec.nStation := -1;
    LkjFile.Records[i].CommonRec.nDataLineID := -1;
    if (LkjFile.Records[i].CommonRec.nEvent = CommonRec_Event_EnterStation) or
      (LkjFile.Records[i].CommonRec.nEvent = CommonRec_Event_LeaveStation) then
    begin
      if DecodeStr(Trim(LkjFile.Records[i].CommonRec.strOther),nJiaoLu,nStation) then
      begin
        bFlag := True;
        LkjFile.Records[i].CommonRec.nStation := nStation;
        LkjFile.Records[i].CommonRec.nDataLineID := nJiaoLu;
      end
      else
      begin
        LkjFile.Records[i].CommonRec.nStation := LkjFile.Records[i - 1].CommonRec.nStation;
        LkjFile.Records[i].CommonRec.nDataLineID := LkjFile.Records[i - 1].CommonRec.nDataLineID;
      end;
    end
    else
    begin
      if (i > 0) then
      begin
        LkjFile.Records[i].CommonRec.nStation := LkjFile.Records[i - 1].CommonRec.nStation;
        LkjFile.Records[i].CommonRec.nDataLineID := LkjFile.Records[i - 1].CommonRec.nDataLineID;
      end;
    end;
    if not bFlag then
    begin
      LkjFile.Records[i].CommonRec.nStation := LkjFile.HeadInfo.nStartStation;
      LkjFile.Records[i].CommonRec.nDataLineID := LkjFile.HeadInfo.nDataLineID;
    end;
  end;
  LkjFile.HeadInfo.nEndStation := LkjFile.Records[LkjFile.Records.Count - 1].CommonRec.nStation;
end;
end.
