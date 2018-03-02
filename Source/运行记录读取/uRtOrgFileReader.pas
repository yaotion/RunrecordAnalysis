//****************************************
//1、超长函数
//2、定义公式，以后有时间时考虑
//3、命名和注释
//4、尽量不要有重复的代码
//5、常量定义
//****************************************
unit uRtOrgFileReader;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Registry, DB, ADODB, IniFiles, DateUtils, StrUtils,uLKJRuntimeFile,uVSConst,
  uConvertDefine,uRtFileReaderBase;

const
  NULL_VALUE_MAXINT = $8000000;   //定义空值整数，若速度、限速等整数型变量为此值时，表示为空值
  NULL_VALUE_STRING = '@';        //定义空值字符串，@不常见，若信号机、工况状态等字符串型变量为此值时，表示为空值
  NULL_VALUE_DATE = 36525;        //36525=1999-12-31，定义此值，原因是转储原始文件中不可能出现1999年

type
  //为了和TmpTest.Ado兼容，和uLKJRuntimeFile中的RCommonRec兼容，特定义此记录
  ROrgCommonInfo = record
    //以下和TmpTest.Ado兼容，变量名与表格字段名一致
    Rec: Integer;             //全程记录行号
    Disp: string;             //事件描述，重点考虑
    Hms: string;              //=时分秒，重点考虑
    Glb: Integer;             //=公里标
    Xhj: string;              //=信号机
    Xht_code: Integer;        //=信号机类型
    Xhj_no: Integer;          //=信号机编号6244
    Xh_code: Integer;         //=信号（色灯或平调信号）
    Speed: Integer;           //=速度
    Shoub: Integer;           //=手柄状态（与工况状态取同一值）
    Hand: string;             //=工况状态
    Gya: Integer;             //=管压
    Rota: Integer;            //=转速（电流）
    S_lmt: Integer;           //=限速
    Jl: Integer;              //=距离
    Gangy: Integer;           //=闸压（缸压）
    OTHER: string;            //其它
    Signal: string;           //=信号（色灯或平调信号）
    Shuoming: string;
    Jg1: Integer;             //=均缸1
    Jg2: Integer;             //=均缸2
    JKZT: Integer;            //=

    //以下和uLKJRuntimeFile中的RCommonRec兼容，定义部分变量
    nJKLineID: Integer;           //当前交路号
    nDataLineID: Integer;         //当前数据交路号
    nStation : Integer;           //当前车站号

    //以下为处理方便，自己定义使用的变量
    strSpeedGrade: string;        //速度等级
    dtEventDate: TDateTime;       //事件发生日期
  end;

type
  TOrgFileReader = class(TRunTimeFileReaderBase)
  public
    constructor Create;
    destructor Destroy; override;
  private  
    m_tPreviousInfo: ROrgCommonInfo; //保存最新的ROrgCommonInfo完整数据，以便给翻译出来的事件空值字段赋值
  private
    function BCD2INT(src: byte): integer;
    function MoreBCD2INT(var Buf: array of byte; nBegin, nLen: integer): integer; 
    function GetTime(var Buf: array of byte; nBegin: integer): string;
    function GetGLB(var Buf: array of byte; nBegin: integer): integer;
    function GetJL(var Buf: array of byte; nBegin: integer): integer;    
    function GetSpeed(var Buf: array of byte; nBegin: integer): integer;
    function GetLimitSpeed(var Buf: array of byte; nBegin: integer): integer;
    function GetLieGuanPressure(var Buf: array of byte; nBegin: integer): integer;
    function GetGangPressure(var Buf: array of byte; nBegin: integer): integer;

    function FileRowToLkjRec(var Info: ROrgCommonInfo): TLKJCommonRec;
    procedure ReadHeadInfo(var Head: RLKJRTFileHeadInfo; var Buf: array of byte; Len: integer); //读文件头信息

    //初始化RCommonInfo
    procedure InitCommonInfo(var Info: ROrgCommonInfo);
    //调整RCommonInfo
    procedure AdjustCommonInfo(var Info: ROrgCommonInfo);
    //根据当前RCommonInfo，生成最新的RCommonInfo完整数据
    procedure MakePreviousInfo(var Info: ROrgCommonInfo; nType: byte);

    function GetLamp(nWord: word): string;    
    function GetLampType(strLamp: string): TLampSign;
    function GetXhjType(nxhj_type: byte): TLKJSignType;
    function GetSD(nWord: word): string;
    function GetInfo_GK(nType: byte): string;
    //功能：处理均缸数据，确定当前使用的为哪一个均缸
    procedure DealWithJgNumber(LkjFile:TLKJRuntimeFile); 
    //功能：处理车位调整记录
    procedure DealWithPosChance(LkjFile:TLKJRuntimeFile);
  protected
    function IsShowExceptInfo(nEvent, nEvent2: byte): boolean;
    procedure DealOneFileInfo(var Info: ROrgCommonInfo; Buf: array of byte; Len: integer);
  private
    {$REGION '记录处理函数'}
    procedure MakeOneLkjRec_C0(var Info: ROrgCommonInfo; var Buf: array of byte; Len: integer);
    procedure MakeOneLkjRec_C1(var Info: ROrgCommonInfo; var Buf: array of byte; Len: integer);
    procedure MakeOneLkjRec_C2(var Info: ROrgCommonInfo; var Buf: array of byte; Len: integer);
    procedure MakeOneLkjRec_C3(var Info: ROrgCommonInfo; var Buf: array of byte; Len: integer);
    procedure MakeOneLkjRec_C4(var Info: ROrgCommonInfo; var Buf: array of byte; Len: integer);
    procedure MakeOneLkjRec_C5(var Info: ROrgCommonInfo; var Buf: array of byte; Len: integer);
    procedure MakeOneLkjRec_C6(var Info: ROrgCommonInfo; var Buf: array of byte; Len: integer);
    procedure MakeOneLkjRec_C7(var Info: ROrgCommonInfo; var Buf: array of byte; Len: integer);
    procedure MakeOneLkjRec_C8(var Info: ROrgCommonInfo; var Buf: array of byte; Len: integer);
    procedure MakeOneLkjRec_C9(var Info: ROrgCommonInfo; var Buf: array of byte; Len: integer);
    procedure MakeOneLkjRec_CA(var Info: ROrgCommonInfo; var Buf: array of byte; Len: integer);
    procedure MakeOneLkjRec_CB(var Info: ROrgCommonInfo; var Buf: array of byte; Len: integer);
    procedure MakeOneLkjRec_CC(var Info: ROrgCommonInfo; var Buf: array of byte; Len: integer);
    procedure MakeOneLkjRec_CD(var Info: ROrgCommonInfo; var Buf: array of byte; Len: integer);
    procedure MakeOneLkjRec_CE(var Info: ROrgCommonInfo; var Buf: array of byte; Len: integer);
    procedure MakeOneLkjRec_CF(var Info: ROrgCommonInfo; var Buf: array of byte; Len: integer);
    procedure MakeOneLkjRec_D0(var Info: ROrgCommonInfo; var Buf: array of byte; Len: integer);
    procedure MakeOneLkjRec_D1(var Info: ROrgCommonInfo; var Buf: array of byte; Len: integer);
    procedure MakeOneLkjRec_D7(var Info: ROrgCommonInfo; var Buf: array of byte; Len: integer);
    procedure MakeOneLkjRec_E0(var Info: ROrgCommonInfo; var Buf: array of byte; Len: integer);
    procedure MakeOneLkjRec_E3(var Info: ROrgCommonInfo; var Buf: array of byte; Len: integer);
    procedure MakeOneLkjRec_E5(var Info: ROrgCommonInfo; var Buf: array of byte; Len: integer);
    procedure MakeOneLkjRec_E6(var Info: ROrgCommonInfo; var Buf: array of byte; Len: integer);
    procedure MakeOneLkjRec_E7(var Info: ROrgCommonInfo; var Buf: array of byte; Len: integer);
    procedure MakeOneLkjRec_EB(var Info: ROrgCommonInfo; var Buf: array of byte; Len: integer);
    procedure MakeOneLkjRec_EC(var Info: ROrgCommonInfo; var Buf: array of byte; Len: integer);
    procedure MakeOneLkjRec_ED(var Info: ROrgCommonInfo; var Buf: array of byte; Len: integer);
    procedure MakeOneLkjRec_EE(var Info: ROrgCommonInfo; var Buf: array of byte; Len: integer);
    procedure MakeOneLkjRec_EF(var Info: ROrgCommonInfo; var Buf: array of byte; Len: integer);
                                                                                        
    procedure MakeOneLkjRec_A0(var Info: ROrgCommonInfo; var Buf: array of byte; Len: integer);
    procedure MakeOneLkjRec_A4(var Info: ROrgCommonInfo; var Buf: array of byte; Len: integer);
    procedure MakeOneLkjRec_A8(var Info: ROrgCommonInfo; var Buf: array of byte; Len: integer);
    procedure MakeOneLkjRec_B1(var Info: ROrgCommonInfo; var Buf: array of byte; Len: integer);
    procedure MakeOneLkjRec_B4(var Info: ROrgCommonInfo; var Buf: array of byte; Len: integer);
    procedure MakeOneLkjRec_B6(var Info: ROrgCommonInfo; var Buf: array of byte; Len: integer);
    procedure MakeOneLkjRec_B7(var Info: ROrgCommonInfo; var Buf: array of byte; Len: integer);
    procedure MakeOneLkjRec_B8(var Info: ROrgCommonInfo; var Buf: array of byte; Len: integer);
    procedure MakeOneLkjRec_BE(var Info: ROrgCommonInfo; var Buf: array of byte; Len: integer);
    procedure MakeOneLkjRec_DA(var Info: ROrgCommonInfo; var Buf: array of byte; Len: integer);
    
    procedure MakeOneLkjRec_F0(var Info: ROrgCommonInfo; var Buf: array of byte; Len: integer);
    procedure MakeOneLkjRec_F1(var Info: ROrgCommonInfo; var Buf: array of byte; Len: integer);
    procedure MakeOneLkjRec_BA02(var Info: ROrgCommonInfo; var Buf: array of byte; Len: integer);
    {$ENDREGION '记录处理函数'}

  public
    {功能：读取原始运行记录文件，写入TLKJRuntimeFile}
    procedure LoadFromFile(FileName: string; RuntimeFile: TLKJRuntimeFile);override;
    {功能:根据传入参数获取文件的对应时间,使用了fmtdll}
    function GetFileTime(orgFileName: string; TimeType: TFileTimeType; var OutTime: TDateTime): Boolean;
  private
    m_FieldConvert: TFieldConvert;
  end;

implementation

{ TUntDev }

constructor TOrgFileReader.Create();
begin
  inherited Create;    
  m_FieldConvert := TFieldConvert.Create;
end;

destructor TOrgFileReader.Destroy;
begin
  m_FieldConvert.Free;
  inherited;
end;

procedure TOrgFileReader.LoadFromFile(FileName: string; RuntimeFile: TLKJRuntimeFile);
var
  msJsFile: TMemoryStream;     
  Info: ROrgCommonInfo;
  nEvent, nEvent2: byte;
  EventHead: array[0..256] of byte;
  T: array[0..64] of byte;
  i, nLen, nPos, nReadNum: integer;
  strTemp: string;
  blnJoin: boolean;
begin                                  
  RuntimeFile.Clear();
  InitCommonInfo(m_tPreviousInfo);
  if not FileExists(FileName) then exit;

  msJsFile := TMemoryStream.Create;
  try
    msJsFile.LoadFromFile(FileName);
    if msJsFile.Size < 256 then exit;
                        
    //读文件头256字节
    msJsFile.Position := 0;
    ZeroMemory(@EventHead[0], SizeOf(EventHead));
    msJsFile.ReadBuffer(EventHead[0], 256);
    if (EventHead[0] <> $B0) or (EventHead[1] <> $F0) then exit; //文件标志$B0F0

    ReadHeadInfo(RuntimeFile.HeadInfo, EventHead, 256);
    RuntimeFile.HeadInfo.strOrgFileName := ExtractFileName(FileName);  //原始文件名
    m_tPreviousInfo.nJKLineID := RuntimeFile.HeadInfo.nJKLineID; //监控交路号
    m_tPreviousInfo.nDataLineID := RuntimeFile.HeadInfo.nDataLineID; //数据交路号
    m_tPreviousInfo.nStation := RuntimeFile.HeadInfo.nStartStation; //车站号x
    m_tPreviousInfo.dtEventDate := DateOf(RuntimeFile.HeadInfo.dtKCDataTime); //事件发生日期

    //--------------------------------

    //读文件事件
    msJsFile.Position := 256;
    while msJsFile.Position < msJsFile.Size-3 do
    begin
      msJsFile.ReadBuffer(nEvent, 1);
      if nEvent <= $99 then continue;

      //初始化Info
      InitCommonInfo(Info);
      blnJoin := false;

      //提取行信息
      ZeroMemory(@T[0], SizeOf(T));
      T[0] := nEvent;
      nLen := 1;

      nPos := msJsFile.Position;
      nReadNum := msJsFile.Read(T[1], 64);
      nEvent2 := T[1];
      for i := 1 to nReadNum do
      begin
        if T[i] > $99 then
        begin
          //将事件与$F0合并成一条揭示
          if T[i] = $F0 then blnJoin := true;
          //将事件与$F1合并成一条揭示
          if T[i] = $F1 then blnJoin := true;
          //将事件$CE与$BA02合并成一条揭示
          if nEvent = $CE then if (T[i] = $BA) and (T[i+1] = $02) then blnJoin := true;

          //下列情况下，下一事件不处理
          if (nEvent = $A0) and (nEvent2 = $13) then if (T[i] = $A0) and (T[i+1] = $14) then nPos := nPos + 2;

          msJsFile.Position := nPos;
          break;
        end;
                  
        nPos := nPos + 1;
        nLen := nLen + 1;
      end;

      //处理行信息，事件类别1字节+内容+未知1字节+校验和1字节
      if nLen > 3 then DealOneFileInfo(Info, T, nLen);

      //------------------------------------------------

      //处理不单独翻译的事件
      while blnJoin do
      begin
        blnJoin := false;

        //提取行信息
        ZeroMemory(@T[0], SizeOf(T));
        msJsFile.ReadBuffer(T[0], 1);
        nLen := 1;

        nPos := msJsFile.Position;
        nReadNum := msJsFile.Read(T[1], 64);
        for i := 1 to nReadNum do
        begin
          if T[i] > $99 then
          begin
            //将事件与$F0合并成一条揭示
            if T[i] = $F0 then blnJoin := true;   
            //将事件与$F1合并成一条揭示
            if T[i] = $F1 then blnJoin := true;
            //将事件$CE与$BA02合并成一条揭示
            if nEvent = $CE then if (T[i] = $BA) and (T[i+1] = $02) then blnJoin := true;

            msJsFile.Position := nPos;
            break;
          end;   
          if (T[i] and $0F) in [$0A..$0F] then
          begin
            msJsFile.Position := nPos;
            break;
          end;

          nPos := nPos + 1;
          nLen := nLen + 1;
        end;

        //处理行信息，事件类别1字节+内容+未知1字节+校验和1字节
        if Info.Disp <> '' then if nLen > 3 then DealOneFileInfo(Info, T, nLen);
      end;

      //生成事件记录列表
      if Info.Disp <> '' then
      begin
        AdjustCommonInfo(Info); //调整Info

        //将车次拆分成两条翻译，前一条为车次,后条为本补客货
        if Info.Disp = '车次' then
        begin
          strTemp := Info.Shuoming;
          Info.Shuoming := '';
          Info.Rec := RuntimeFile.Records.Count+1;
          RuntimeFile.Records.Add(FileRowToLkjRec(Info));

          Info.Disp := '本补客货';
          Info.OTHER := strTemp;
          Info.Rec := RuntimeFile.Records.Count+1;
          RuntimeFile.Records.Add(FileRowToLkjRec(Info));
        end
        else
        begin
          Info.Rec := RuntimeFile.Records.Count+1;
          RuntimeFile.Records.Add(FileRowToLkjRec(Info));
        end;

        //根据Info，生成最近的历史数据FPreviousInfo
        if not (nEvent in [$D7]) then MakePreviousInfo(Info, nEvent);
      end
      else
      begin
        {*
        if IsShowExceptInfo(nEvent, nEvent2) then
        begin
          Info.Disp := Format('%.02x - %.02x', [nEvent, nEvent2]);
          Info.Rec := LkjFile.Records.Count+1;
          LkjFile.Records.Add(FileRowToLkjRec(Info));
        end;
        *}
      end;
    end;

    DealWithJgNumber(RuntimeFile);
    DealWithPosChance(RuntimeFile);
    //文件头-终点车站号
    if m_tPreviousInfo.nStation <> NULL_VALUE_MAXINT then RuntimeFile.HeadInfo.nEndStation := m_tPreviousInfo.nStation;
  finally
    msJsFile.Free;
  end;
end;

//================================================================

function TOrgFileReader.BCD2INT(src: byte): integer;
begin
  result := (src div 16) * 10 + (src mod 16);
end;

function TOrgFileReader.MoreBCD2INT(var Buf: array of byte; nBegin, nLen: integer): integer;
var
  i: integer;
begin
  result := 0;
  for i := 0 to nLen-1 do
  begin
    result := result*100 + BCD2INT(Buf[nBegin+i]);
  end;
end;

function TOrgFileReader.GetTime(var Buf: array of byte; nBegin: integer): string;
var
  hh, nn, ss: byte;
begin
  result := NULL_VALUE_STRING;
  hh := BCD2INT(Buf[nBegin]);
  nn := BCD2INT(Buf[nBegin+1]);
  ss := BCD2INT(Buf[nBegin+2]);
  if (hh<=23) and (nn<=59) and (ss<=59) then result := Format('%.02d:%.02d:%.02d', [hh, nn, ss]);
end;
               
function TOrgFileReader.GetGLB(var Buf: array of byte; nBegin: integer): integer;
var
  nValue: integer;
begin
  nValue := MoreBCD2INT(Buf, nBegin, 4);

  if nValue >= 80000000 then nValue := -(nValue - 80000000);
  result := nValue mod 8388608;
  if ((nValue div 8388608) mod 2) <> 0 then result := -result;
end;

function TOrgFileReader.GetJL(var Buf: array of byte; nBegin: integer): integer;
var
  nValue: integer;
begin
  nValue := MoreBCD2INT(Buf, nBegin, 3);

  result := nValue mod 885678;
  if ((nValue div 885678) mod 2) <> 0 then result := -result;
end;

function TOrgFileReader.GetSpeed(var Buf: array of byte; nBegin: integer): integer;
begin
  result := MoreBCD2INT(Buf, nBegin, 2);
end;

function TOrgFileReader.GetLimitSpeed(var Buf: array of byte; nBegin: integer): integer;
begin
  result := MoreBCD2INT(Buf, nBegin, 2);
  //if result = 0 then result := 511;
  if result >= 1000 then result := 511;
end;

function TOrgFileReader.GetLieGuanPressure(var Buf: array of byte; nBegin: integer): integer;
begin
  result := MoreBCD2INT(Buf, nBegin, 2);
end;

function TOrgFileReader.GetFileTime(orgFileName: string;
  TimeType: TFileTimeType; var OutTime: TDateTime): Boolean;
var
  FileReader: TOrgFileReader;
  lkjFile: TLKJRuntimeFile;
  I: Integer;
  bFit: Boolean;
  dtResult: TDateTime;
begin
  bFit := False;
  dtResult := 0;
  Result := False;
  FileReader := TOrgFileReader.Create;
  lkjFile := TLKJRuntimeFile.Create;
  try
    FileReader.LoadFromFile(orgFileName,lkjFile);

    for I := 0 to lkjFile.Records.Count - 1 do
    begin
      case lkjFile.Records.Items[i].CommonRec.nEvent of
        CommonRec_Event_StopInStation: bFit := False;
        CommonRec_Event_RuDuan:
          begin
            bFit := True;
            dtResult := lkjFile.Records.Items[i].CommonRec.DTEvent;
          end;
      end;

    end;

    
    if bFit then
    begin
      OutTime := dtResult;
      Result := True;
    end;
  finally
    FileReader.Free;
    lkjFile.Free;
  end;
end;

function TOrgFileReader.GetGangPressure(var Buf: array of byte; nBegin: integer): integer;
begin
  result := MoreBCD2INT(Buf, nBegin, 2);
end;

//================================================================

//读文件头信息
procedure TOrgFileReader.ReadHeadInfo(var Head: RLKJRTFileHeadInfo; var Buf: array of byte; Len: integer);
var
  nByte: byte;
begin
  //解析赋值
  FillChar(Head, SizeOf(RLKJRTFileHeadInfo), 0);

  Head.nLocoType := MoreBCD2INT(Buf, 56, 3) and $FFFF; //机车类型号(DF11)代码[数字]
  Head.nLocoID := MoreBCD2INT(Buf, 60, 3) and $FFFF; //机车编号
  Head.strTrainHead := trim(chr(Buf[10])+ chr(Buf[11])+ chr(Buf[12])+ chr(Buf[13]));  //车次头
  Head.nTrainNo := MoreBCD2INT(Buf, 14, 3);  //车次号
  Head.nLunJing := MoreBCD2INT(Buf, 64, 3) and $FFFF;  //轮径
  //nDistance: Integer; //走行距离
  Head.nJKLineID := MoreBCD2INT(Buf, 18, 3) and $FFFF; //交路号
  Head.nDataLineID := MoreBCD2INT(Buf, 17, 1); //数据交路号
  Head.nFirstDriverNO := MoreBCD2INT(Buf, 24, 4); //司机工号
  Head.nSecondDriverNO := MoreBCD2INT(Buf, 28, 4); //副司机工号
  Head.nStartStation := MoreBCD2INT(Buf, 21, 3) and $FFFF; //始发站
  Head.nEndStation := Head.nStartStation; //终点站 //LkjFile.HeadInfo.nEndStation := LkjFile.Records[LkjFile.Records.Count - 1].CommonRec.nStation;
  //nLocoJie: string[10]; //机车单节等信息
  Head.nDeviceNo:= MoreBCD2INT(Buf, 89, 3) and $FFFF; //装置号
  Head.nTotalWeight := MoreBCD2INT(Buf, 34, 3) and $FFFF; //总重
  Head.nSum := MoreBCD2INT(Buf, 52, 2); //合计
  Head.nLoadWeight := MoreBCD2INT(Buf, 37, 3) and $FFFF; //载重
  Head.nJKVersion := MoreBCD2INT(Buf, 78,4); //监控版本
  Head.nDataVersion := MoreBCD2INT(Buf, 82,4); //数据版本
  Head.DTFileHeadDt := EncodeDate(2000+BCD2INT(Buf[2]), BCD2INT(Buf[3]), BCD2INT(Buf[4])) + EncodeTime(BCD2INT(Buf[5]), BCD2INT(Buf[6]), BCD2INT(Buf[7]), 0); //文件头时间

  //软件厂家
  nByte := Buf[86];
  if nByte = $53 then
    Head.Factory := sfSiWei
  else
    Head.Factory :=sfZhuZhou;

  //机车客货类别(货,客)代码[数字]
  nByte := BCD2INT(Buf[9]) mod 4;
  if (nByte mod 2) = 1 then
    Head.TrainType := ttPassenger
  else
    Head.TrainType := ttCargo;
  //本机、补机
  if (nByte div 2) = 1 then
    Head.BenBu := bbBu
  else
    Head.BenBu := bbBen;

  //nStandardPressure : Integer; //标准管压
  //nMaxLmtSpd : Integer;  //输入最高限速

  //===HeadInfo.strOrgFileName := ExtractFileName(orgFileName);  //原始文件名
  Head.dtKCDataTime := Head.DTFileHeadDt;
end;

function TOrgFileReader.FileRowToLkjRec(var Info: ROrgCommonInfo): TLKJCommonRec;
  function IIf(mBool: Boolean; TrueValue: Variant; FalseValue: Variant): Variant;
  begin
    if mBool then
      Result := TrueValue
    else
      Result := FalseValue;
  end;
begin
  Result := TLKJCommonRec.Create;

  with Result do
  begin
    CommonRec.nRow := Info.Rec;
    CommonRec.strDisp := Info.Disp;
    CommonRec.nEvent := m_FieldConvert.GetnEvent(Info.Disp);
    CommonRec.DTEvent := Info.dtEventDate + StrToTimeDef(Info.Hms, EncodeTime(0,0,0,0));
    CommonRec.strGK := IIf(Info.Hand <> NULL_VALUE_STRING, Info.Hand, '');;
    CommonRec.nCoord := IIf(Info.Glb <> NULL_VALUE_MAXINT, Info.Glb, 0);
    CommonRec.nDistance := IIf(Info.Jl <> NULL_VALUE_MAXINT, Info.Jl, 0);
    CommonRec.strXhj := IIf(Info.Xhj <> NULL_VALUE_STRING, Info.Xhj, '');
    CommonRec.strSignal := IIf(Info.Signal <> NULL_VALUE_STRING, Info.Signal, '');
    CommonRec.nLieGuanPressure := IIf(Info.Gya <> NULL_VALUE_MAXINT, Info.Gya, 0);
    CommonRec.nGangPressure := IIf(Info.Gangy <> NULL_VALUE_MAXINT, Info.Gangy, 0); 
    CommonRec.nJG1Pressure := IIf(Info.Jg1 <> NULL_VALUE_MAXINT, Info.Jg1, 0);
    CommonRec.nJG2Pressure := IIf(Info.Jg2 <> NULL_VALUE_MAXINT, Info.Jg2, 0);
    CommonRec.nSpeed := IIf(Info.Speed <> NULL_VALUE_MAXINT, Info.Speed, 0);   
    CommonRec.nLimitSpeed := IIf(Info.S_lmt <> NULL_VALUE_MAXINT, Info.S_lmt, 0);  
    CommonRec.nRotate := IIf(Info.Rota <> NULL_VALUE_MAXINT, Info.Rota, 0);   
    CommonRec.strOther := IIf(Info.OTHER <> NULL_VALUE_STRING, Info.OTHER, '');
    CommonRec.Shuoming := IIf(Info.Shuoming <> NULL_VALUE_STRING, Info.Shuoming, '');
    CommonRec.JKZT := IIf(Info.JKZT <> NULL_VALUE_MAXINT, Info.JKZT, 0);

    if Info.Signal <> NULL_VALUE_STRING then CommonRec.LampSign := GetLampType(Info.Signal);
    CommonRec.SignType := IIf(Info.Xht_code <> NULL_VALUE_MAXINT, GetXhjType(Info.Xht_code), stNone);
    CommonRec.nLampNo := IIf(Info.Xhj_no <> NULL_VALUE_MAXINT, Info.Xhj_no, 0);

    if Info.Shoub <> NULL_VALUE_MAXINT then
    begin
      CommonRec.nShoub := Info.Shoub;
      CommonRec.WorkZero := m_FieldConvert.ConvertWorkZero(CommonRec.nShoub);
      CommonRec.WorkDrag := m_FieldConvert.ConvertWorkDrag(CommonRec.nShoub);
      CommonRec.HandPos := m_FieldConvert.ConvertHandPos(CommonRec.nShoub);
    end;

    CommonRec.nJKLineID := IIf(Info.nJKLineID <> NULL_VALUE_MAXINT, Info.nJKLineID, 0);
    CommonRec.nDataLineID := IIf(Info.nDataLineID <> NULL_VALUE_MAXINT, Info.nDataLineID, 0);
    CommonRec.nStation := IIf(Info.nStation <> NULL_VALUE_MAXINT, Info.nStation, 0);
  end;
end;

procedure TOrgFileReader.InitCommonInfo(var Info: ROrgCommonInfo);
begin
  Info.Rec := 0;                            //全程记录行号
  Info.Disp := '';                          //事件描述
  Info.Hms := NULL_VALUE_STRING;            //时分秒
  Info.Glb := NULL_VALUE_MAXINT;            //公里标
  Info.Xhj := NULL_VALUE_STRING;            //信号机
  Info.Xht_code := NULL_VALUE_MAXINT;       //信号机类型
  Info.Xhj_no := NULL_VALUE_MAXINT;         //信号机编号6244
  Info.Xh_code := NULL_VALUE_MAXINT;        //信号（色灯或平调信号）
  Info.Speed := NULL_VALUE_MAXINT;          //速度
  Info.Shoub := NULL_VALUE_MAXINT;          //手柄状态（与工况状态取同一值）
  Info.Hand := NULL_VALUE_STRING;           //工况状态
  Info.Gya := NULL_VALUE_MAXINT;            //管压
  Info.Rota := NULL_VALUE_MAXINT;           //转速
  Info.S_lmt := NULL_VALUE_MAXINT;          //限度
  Info.Jl := NULL_VALUE_MAXINT;             //距离
  Info.Gangy := NULL_VALUE_MAXINT;          //闸压（缸压）
  Info.OTHER := NULL_VALUE_STRING;          //其它
  Info.Signal := NULL_VALUE_STRING;         //信号（色灯或平调信号）x
  Info.Shuoming := NULL_VALUE_STRING;
  Info.Jg1 := NULL_VALUE_MAXINT;            //均缸1
  Info.Jg2 := NULL_VALUE_MAXINT;            //均缸2
  Info.JKZT := NULL_VALUE_MAXINT;           //

  Info.nJKLineID := NULL_VALUE_MAXINT;      //当前交路号
  Info.nDataLineID := NULL_VALUE_MAXINT;    //当前数据交路号
  Info.nStation := NULL_VALUE_MAXINT;       //当前车站号

  Info.strSpeedGrade := NULL_VALUE_STRING;  //速度等级
  Info.dtEventDate := NULL_VALUE_DATE;      //事件发生日期
end;

//调整Info
procedure TOrgFileReader.AdjustCommonInfo(var Info: ROrgCommonInfo);
var
  dtNow, dtOld: TDateTime;
begin
  if Info.Hms = NULL_VALUE_STRING then Info.Hms := m_tPreviousInfo.Hms;            //时分秒
  if Info.Glb = NULL_VALUE_MAXINT then Info.Glb := m_tPreviousInfo.Glb;             //公里标
  if Info.Xhj = NULL_VALUE_STRING then Info.Xhj := m_tPreviousInfo.Xhj;            //???信号机
  if Info.Xht_code = NULL_VALUE_MAXINT then Info.Xht_code := m_tPreviousInfo.Xht_code;        //???信号机类型
  if Info.Xhj_no = NULL_VALUE_MAXINT then Info.Xhj_no := m_tPreviousInfo.Xhj_no;          //???信号机编号6244
  if Info.Xh_code = NULL_VALUE_MAXINT then Info.Xh_code := m_tPreviousInfo.Xh_code;         //???信号（色灯或平调信号）
  if Info.Speed = NULL_VALUE_MAXINT then Info.Speed := m_tPreviousInfo.Speed;           //速度
  if Info.Shoub = NULL_VALUE_MAXINT then Info.Shoub := m_tPreviousInfo.Shoub;           //手柄状态（与工况状态取同一值）
  if Info.Hand = NULL_VALUE_STRING then Info.Hand := m_tPreviousInfo.Hand;           //工况状态
  if Info.Gya = NULL_VALUE_MAXINT then Info.Gya := m_tPreviousInfo.Gya;             //管压
  if Info.Rota = NULL_VALUE_MAXINT then Info.Rota := m_tPreviousInfo.Rota;            //转速
  if Info.S_lmt = NULL_VALUE_MAXINT then Info.S_lmt := m_tPreviousInfo.S_lmt;           //限度
  if Info.Jl = NULL_VALUE_MAXINT then Info.Jl := m_tPreviousInfo.Jl;              //距离
  if Info.Gangy = NULL_VALUE_MAXINT then Info.Gangy := m_tPreviousInfo.Gangy;           //闸压（缸压）
  if Info.Signal = NULL_VALUE_STRING then Info.Signal := m_tPreviousInfo.Signal;         //信号（色灯或平调信号）x
  if Info.Jg1 = NULL_VALUE_MAXINT then Info.Jg1 := m_tPreviousInfo.Jg1;             //均缸1
  if Info.Jg2 = NULL_VALUE_MAXINT then Info.Jg2 := m_tPreviousInfo.Jg2;             //均缸2
  if Info.JKZT = NULL_VALUE_MAXINT then Info.JKZT := m_tPreviousInfo.JKZT;            //

  if Info.nJKLineID = NULL_VALUE_MAXINT then Info.nJKLineID := m_tPreviousInfo.nJKLineID;   //监控交路号     
  if Info.nDataLineID = NULL_VALUE_MAXINT then Info.nDataLineID := m_tPreviousInfo.nDataLineID;   //数据交路号
  if Info.nStation = NULL_VALUE_MAXINT then Info.nStation := m_tPreviousInfo.nStation;   //车站号

  //事件发生日期
  if Info.dtEventDate = NULL_VALUE_DATE then
  begin
    Info.dtEventDate := m_tPreviousInfo.dtEventDate;

    if (Info.Hms <> NULL_VALUE_STRING) and (m_tPreviousInfo.Hms <> NULL_VALUE_STRING) then
    begin
      if Info.dtEventDate <> NULL_VALUE_DATE then
      begin
        dtNow := StrToDateTime(Info.Hms);
        dtOld := StrToDateTime(m_tPreviousInfo.Hms);
        if CompareTime(dtNow, dtOld) < 0 then IncDay(Info.dtEventDate, 1);
      end;
    end;
  end;
end;

//根据Info，生成最近的历史数据FPreviousInfo
procedure TOrgFileReader.MakePreviousInfo(var Info: ROrgCommonInfo; nType: byte);
begin
  if Info.Hms <> NULL_VALUE_STRING then m_tPreviousInfo.Hms := Info.Hms;            //时分秒
  if Info.Glb <> NULL_VALUE_MAXINT then m_tPreviousInfo.Glb := Info.Glb;             //公里标

  if nType <> $CE then
  begin
    if Info.Xhj <> NULL_VALUE_STRING then m_tPreviousInfo.Xhj := Info.Xhj;            //???信号机
    if Info.Xht_code <> NULL_VALUE_MAXINT then m_tPreviousInfo.Xht_code := Info.Xht_code;        //???信号机类型
    if Info.Xhj_no <> NULL_VALUE_MAXINT then m_tPreviousInfo.Xhj_no := Info.Xhj_no;          //???信号机编号6244
  end;
  
  if Info.Xh_code <> NULL_VALUE_MAXINT then m_tPreviousInfo.Xh_code := Info.Xh_code;         //???信号（色灯或平调信号）
  if Info.Speed <> NULL_VALUE_MAXINT then m_tPreviousInfo.Speed := Info.Speed;           //速度
  if Info.Shoub <> NULL_VALUE_MAXINT then m_tPreviousInfo.Shoub := Info.Shoub;           //手柄状态（与工况状态取同一值）
  if Info.Hand <> NULL_VALUE_STRING then m_tPreviousInfo.Hand := Info.Hand;           //工况状态
  if Info.Gya <> NULL_VALUE_MAXINT then m_tPreviousInfo.Gya := Info.Gya;             //管压
  if Info.Rota <> NULL_VALUE_MAXINT then m_tPreviousInfo.Rota := Info.Rota;            //转速
  if Info.S_lmt <> NULL_VALUE_MAXINT then m_tPreviousInfo.S_lmt := Info.S_lmt;           //限度
  if Info.Jl <> NULL_VALUE_MAXINT then m_tPreviousInfo.Jl := Info.Jl;              //距离
  if Info.Gangy <> NULL_VALUE_MAXINT then m_tPreviousInfo.Gangy := Info.Gangy;           //闸压（缸压）
  if Info.Signal <> NULL_VALUE_STRING then m_tPreviousInfo.Signal := Info.Signal;         //信号（色灯或平调信号）x
  if Info.Jg1 <> NULL_VALUE_MAXINT then m_tPreviousInfo.Jg1 := Info.Jg1;             //均缸1
  if Info.Jg2 <> NULL_VALUE_MAXINT then m_tPreviousInfo.Jg2 := Info.Jg2;             //均缸2
  if Info.JKZT <> NULL_VALUE_MAXINT then m_tPreviousInfo.JKZT := Info.JKZT;            //   

  if Info.nJKLineID <> NULL_VALUE_MAXINT then m_tPreviousInfo.nJKLineID := Info.nJKLineID;   //监控交路号
  if Info.nDataLineID <> NULL_VALUE_MAXINT then m_tPreviousInfo.nDataLineID := Info.nDataLineID;   //数据交路号
  if Info.nStation <> NULL_VALUE_MAXINT then m_tPreviousInfo.nStation := Info.nStation;   //车站号
           
  if Info.dtEventDate <> NULL_VALUE_DATE then m_tPreviousInfo.dtEventDate := Info.dtEventDate;   //事件发生日期
end;

//得到色灯类型
function TOrgFileReader.GetLamp(nWord: word): string;
var
  nType: byte;
  strLamp: string;
  intLampNum: integer;
  bSplash: boolean;
begin
  intLampNum := 0;
  strLamp := NULL_VALUE_STRING;
                                         
  nType := nWord and $00FF;
  bSplash := (nWord and $0800) = $0800;

  if (nType and $01) = $01 then
  begin
    strLamp := '绿灯';
    intLampNum := intLampNum + 1;
  end;
  if (nType and $02) = $02 then
  begin
    strLamp := '绿黄';
    intLampNum := intLampNum + 1;
  end;
  if (nType and $04) = $04 then
  begin
    strLamp := '黄灯';
    intLampNum := intLampNum + 1;
  end;
  if (nType and $08) = $08 then
  begin
    strLamp := '黄2'; //闪灯
    intLampNum := intLampNum + 1;
  end;
  if (nType and $10) = $10 then
  begin
    strLamp := '双黄'; //闪灯
    intLampNum := intLampNum + 1;
  end;
  if (nType and $20) = $20 then
  begin
    strLamp := '红黄'; //闪灯
    intLampNum := intLampNum + 1;
  end;
  if (nType and $40) = $40 then
  begin
    strLamp := '红灯';
    intLampNum := intLampNum + 1;
  end;
  if (nType and $80) = $80 then
  begin
    strLamp := '白灯'; //Xh_code=7
    intLampNum := intLampNum + 1;
  end;

  if bSplash then if nType in [$08, $10, $20] then strLamp := strLamp + '闪';  
  if intLampNum = 0 then strLamp := '灭灯'; //Xh_code=8
  if intLampNum > 1 then strLamp := '多灯';

  result := strLamp;
end;

//得到色灯类型
function TOrgFileReader.GetLampType(strLamp: string): TLampSign;
begin
  result := lsClose;
  if strLamp = '绿灯' then result := lsGreen
  else if strLamp = '绿黄' then result := lsGreenYellow
  else if strLamp = '黄灯' then result := lsYellow
  else if strLamp = '黄2' then result := lsYellow2
  else if strLamp = '双黄' then result := lsDoubleYellow
  else if strLamp = '红黄' then result := lsRedYellow
  else if strLamp = '红灯' then result := lsRed
  else if strLamp = '白灯' then result := lsWhite
  else if strLamp = '黄2闪' then result := lsYellow2S //闪灯
  else if strLamp = '双黄闪' then result := lsDoubleYellowS //闪灯
  else if strLamp = '红黄闪' then result := lsRedYellowS //闪灯
  else if strLamp = '灭灯' then result := lsClose
  else if strLamp = '多灯' then result := lsMulti;
end;

function TOrgFileReader.GetXhjType(nxhj_type: byte): TLKJSignType;
begin
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
  else
    Result := stNone;
  end;
end;

//得到速度等级
function TOrgFileReader.GetSD(nWord: word): string;
var
  strTemp: string;
begin
  result := NULL_VALUE_STRING;
  strTemp := '';
  if (nWord and $0100) = $0100 then strTemp := strTemp + '1';
  if (nWord and $0200) = $0200 then strTemp := strTemp + '2';
  if (nWord and $0400) = $0400 then strTemp := strTemp + '3';
  if strTemp <> '' then result := 'SD'+strTemp;
end;

//得到工况信息
function TOrgFileReader.GetInfo_GK(nType: byte): string;
var
  strInfo: string;
begin
  strInfo := '';

  nType := nType and $1F;
  case nType of
    0: strInfo := '加载'; //灭灯
    1: strInfo := '卸载';
    2: strInfo := '加前'; //灭灯
    3: strInfo := '卸前';
    4: strInfo := '加后'; //灭灯
    5: strInfo := '卸后';
    6: strInfo := '加'; //灭灯
    7: strInfo := '卸  ';
    8: strInfo := '加  牵'; //灭灯
    9: strInfo := '卸  牵';
    10: strInfo := '加前牵'; //灭灯
    11: strInfo := '卸前牵';
    12: strInfo := '加后牵'; //灭灯
    13: strInfo := '卸后牵';
    14: strInfo := '加牵'; //灭灯
    15: strInfo := '卸牵';
    16: strInfo := '加  制'; //灭灯
    17: strInfo := '卸  制';
    18: strInfo := '加前制'; //灭灯
    19: strInfo := '卸前制';
    20: strInfo := '加后制'; //灭灯
    21: strInfo := '卸后制';
    22: strInfo := '加制'; //灭灯
    23: strInfo := '卸制';
    24: strInfo := '加  '; //灭灯
    25: strInfo := '卸  ';
    26: strInfo := '加前'; //灭灯
    27: strInfo := '卸前';
    28: strInfo := '加后'; //灭灯
    29: strInfo := '卸后';        
    30: strInfo := '加载'; //灭灯
    31: strInfo := '卸载';
    32: strInfo := '加  '; //灭灯
  end;

  result := strInfo;
end;

procedure TOrgFileReader.DealWithJgNumber(LkjFile: TLKJRuntimeFile);
var
  i : Integer;
  CurrentValue1, CurrentValue2: Integer;
  bFit1, bFit2: Boolean;
  nIndex: Integer;
begin
  nIndex := -1;
  for I := 0 to LkjFile.Records.Count - 1 do
  begin
    LkjFile.Records[i].CommonRec.nValidJG := 0;
    CurrentValue1 := LkjFile.Records[i].CommonRec.nJG1Pressure;
    CurrentValue2 := LkjFile.Records[i].CommonRec.nJG2Pressure;
    if LkjFile.Records[i].CommonRec.nLieGuanPressure >= 500 then
    begin
      if CurrentValue1 >= LkjFile.Records[i].CommonRec.nLieGuanPressure  then
        bFit1 := True
      else
        bFit1 := False;
      if CurrentValue2 >= LkjFile.Records[i].CommonRec.nLieGuanPressure  then
        bFit2 := True
      else
        bFit2 := False;

      if (bFit1 and bFit2) or (not bFit1 and not bFit2) then
      begin
        if (i > 0) and (LkjFile.Records[i - 1].CommonRec.nValidJG <> 0) then
          LkjFile.Records[i].CommonRec.nValidJG := LkjFile.Records[i - 1].CommonRec.nValidJG;        
      end;

      if bFit1 then
      begin
        if nIndex = -1 then
          nIndex := i;
        LkjFile.Records[i].CommonRec.nValidJG := 1;
      end;


      if bFit2 then
      begin
        if nIndex = -1 then
          nIndex := i;
        LkjFile.Records[i].CommonRec.nValidJG := 2;
      end;
    end
    else
    begin
      if i > 0 then        
        LkjFile.Records[i].CommonRec.nValidJG := LkjFile.Records[i - 1].CommonRec.nValidJG;
    end;

  end;

  if nIndex >= LkjFile.Records.Count - 1 then
    Exit;
  
  for I := nIndex downto 0 do
  begin
    LkjFile.Records[i].CommonRec.nValidJG := LkjFile.Records[i + 1].CommonRec.nValidJG;
  end;
end;

procedure TOrgFileReader.DealWithPosChance(LkjFile: TLKJRuntimeFile);
var
  i : Integer;
  nSignalDistance : Integer;
begin
  nSignalDistance := 0;
  for i := 0 to LkjFile.Records.Count - 1 do
  begin
    case LkjFile.Records[i].CommonRec.nEvent of
      CommonRec_Event_TrainPosForward :
        begin
          LkjFile.Records[i].CommonRec.strOther := IntToStr(LkjFile.Records[i].CommonRec.nDistance);
        end;
      CommonRec_Event_TrainPosBack :
        begin
          LkjFile.Records[i].CommonRec.strOther :=
            IntToStr(nSignalDistance - LkjFile.Records[i].CommonRec.nDistance);
        end;
      CommonRec_Event_TrainPosReset :
        begin
          if (LkjFile.Records[i].CommonRec.nDistance < 300)
            or (nSignalDistance - LkjFile.Records[i].CommonRec.nDistance < 300) then
          begin
            if LkjFile.Records[i].CommonRec.nDistance <
              nSignalDistance - LkjFile.Records[i].CommonRec.nDistance then
              LkjFile.Records[i].CommonRec.strOther := IntToStr(LkjFile.Records[i].CommonRec.nDistance)
            else
              LkjFile.Records[i].CommonRec.strOther := IntToStr(nSignalDistance - LkjFile.Records[i].CommonRec.nDistance);
          end;
        end;
      CommonRec_Event_SectionSignal :
        begin
          nSignalDistance := LkjFile.Records[i].CommonRec.nDistance;
        end;
      CommonRec_Event_InOutStation :
        begin
          nSignalDistance := LkjFile.Records[i].CommonRec.nDistance;
        end;
      CommonRec_Event_EnterStation :
        begin
          nSignalDistance := LkjFile.Records[i].CommonRec.nDistance;
        end;
      CommonRec_Event_LeaveStation :
        begin
          nSignalDistance := LkjFile.Records[i].CommonRec.nDistance;
        end;
    end;

  end;
end;

//================================================================

function TOrgFileReader.IsShowExceptInfo(nEvent, nEvent2: byte): boolean;
begin
  result := true;
  
  //过滤已知不显示的事件
  //if nEvent = $A0 then if nEvent2 in [$14] then result := false;
  if nEvent = $A1 then if nEvent2 in [$17] then result := false;
  if nEvent = $A8 then if nEvent2 in [$58, $89] then result := false;
  if nEvent = $A9 then if nEvent2 in [$01] then result := false;
  if nEvent = $B1 then if nEvent2 in [$17] then result := false;
  if nEvent = $B4 then if nEvent2 in [$05, $07, $55, $56, $57, $58, $59, $61, $62] then result := false;
  if nEvent = $B6 then if nEvent2 in [$46, $54] then result := false;
  if nEvent = $B7 then if nEvent2 in [$01, $02, $91] then result := false;
  if nEvent = $B8 then if nEvent2 in [$43] then result := false;
  if nEvent = $BA then if nEvent2 in [$01] then result := false;
  if nEvent = $BF then if nEvent2 in [$02, $03, $84, $85, $90, $93, $94, $95, $96, $97, $99] then result := false;    
  if nEvent = $FF then result := false;
end;

procedure TOrgFileReader.DealOneFileInfo(var Info: ROrgCommonInfo; Buf: array of byte; Len: integer);
var
  i, n: integer;
begin
  //过滤结尾的不合法字符
  n := Len - 1;
  for i := n downto 0 do
  begin
    if (Buf[i] and $0F) in [$0A..$0F] then
      Len := Len - 1
    else
      break;
  end;
  if Len <= 3 then exit;
  
  //根据事件类型，分类处理
  case Buf[0] of
    $C0: MakeOneLkjRec_C0(Info, Buf, Len); //关机
    $C1: MakeOneLkjRec_C1(Info, Buf, Len); //开机
    $C2: MakeOneLkjRec_C2(Info, Buf, Len); //公里标突变
    $C3: MakeOneLkjRec_C3(Info, Buf, Len); //座标增
    $C4: MakeOneLkjRec_C4(Info, Buf, Len); //座标减
    $C5: MakeOneLkjRec_C5(Info, Buf, Len); //过机不校
    $C6: MakeOneLkjRec_C6(Info, Buf, Len); //过机校正
    $C7: MakeOneLkjRec_C7(Info, Buf, Len); //过站中心
    $C8: MakeOneLkjRec_C8(Info, Buf, Len); //报警开始
    $C9: MakeOneLkjRec_C9(Info, Buf, Len); //报警结束
    $CA: MakeOneLkjRec_CA(Info, Buf, Len); //手柄防溜报警开始
    $CB: MakeOneLkjRec_CB(Info, Buf, Len); //手柄防溜报警结束
    $CC: MakeOneLkjRec_CC(Info, Buf, Len); //进站道岔 出站道岔
    $CD: MakeOneLkjRec_CD(Info, Buf, Len); //日期变化
    $CE: MakeOneLkjRec_CE(Info, Buf, Len); //过信号机
    $CF: MakeOneLkjRec_CF(Info, Buf, Len); //正线终止
    $D0: MakeOneLkjRec_D0(Info, Buf, Len); //站内停车
    $D1: MakeOneLkjRec_D1(Info, Buf, Len); //站内开车
    $D7: MakeOneLkjRec_D7(Info, Buf, Len); //轮径修正
    $E0: MakeOneLkjRec_E0(Info, Buf, Len); //机车信号变化
    $E3: MakeOneLkjRec_E3(Info, Buf, Len); //机车工况变化
    $E5: MakeOneLkjRec_E5(Info, Buf, Len); //平调信号变化
    $E6: MakeOneLkjRec_E6(Info, Buf, Len); //速度变化
    $E7: MakeOneLkjRec_E7(Info, Buf, Len); //转速变化
    $EB: MakeOneLkjRec_EB(Info, Buf, Len); //管压变化
    $EC: MakeOneLkjRec_EC(Info, Buf, Len); //限速变化
    $ED: MakeOneLkjRec_ED(Info, Buf, Len); //定量记录
    $EE: MakeOneLkjRec_EE(Info, Buf, Len); //闸缸压力变化
    $EF: MakeOneLkjRec_EF(Info, Buf, Len); //均缸压力变化

    $A0: MakeOneLkjRec_A0(Info, Buf, Len); //A机模块通讯故障...
    $A4: MakeOneLkjRec_A4(Info, Buf, Len); //A机模块通讯恢复...
    $A8: MakeOneLkjRec_A8(Info, Buf, Len); //日期修改...       
    $B1: MakeOneLkjRec_B1(Info, Buf, Len); //提示更新...
    $B4: MakeOneLkjRec_B4(Info, Buf, Len); //A主B备...
    $B6: MakeOneLkjRec_B6(Info, Buf, Len); //+++文档没有，分析补充  
    $B7: MakeOneLkjRec_B7(Info, Buf, Len);
    $B8: MakeOneLkjRec_B8(Info, Buf, Len);    
    $BE: MakeOneLkjRec_BE(Info, Buf, Len);
    $DA: MakeOneLkjRec_DA(Info, Buf, Len);

    //下面不单独翻译
    $BA: if Buf[1] = $02 then MakeOneLkjRec_BA02(Info, Buf, Len);  
    $F0: MakeOneLkjRec_F0(Info, Buf, Len);
    $F1: MakeOneLkjRec_F1(Info, Buf, Len);
  end;
end;
    
procedure TOrgFileReader.MakeOneLkjRec_C0(var Info: ROrgCommonInfo; var Buf: array of byte; Len: integer);
begin
  //解析赋值
  Info.Disp := '关机';
  Info.Hms := GetTime(Buf, 1);
  Info.Glb := GetGLB(Buf, 4);
  Info.Jl := GetJL(Buf, 8);
  Info.OTHER := m_tPreviousInfo.strSpeedGrade;
end;

procedure TOrgFileReader.MakeOneLkjRec_C1(var Info: ROrgCommonInfo; var Buf: array of byte; Len: integer);
begin
  //解析赋值
  Info.Disp := '开机';
  Info.Hms := GetTime(Buf, 1);
  Info.OTHER := m_tPreviousInfo.strSpeedGrade;

  //开机日期
  TryEncodeDate(2000+BCD2INT(Buf[4]), BCD2INT(Buf[5]), BCD2INT(Buf[6]), m_tPreviousInfo.dtEventDate);
end;
            
procedure TOrgFileReader.MakeOneLkjRec_C2(var Info: ROrgCommonInfo; var Buf: array of byte; Len: integer);
begin
  //解析赋值
  Info.Disp := '公里标突变';
  Info.Hms := GetTime(Buf, 1);
  Info.Glb := GetGLB(Buf, 4);
  Info.Jl := GetJL(Buf, 8);
  Info.OTHER := m_tPreviousInfo.strSpeedGrade;
end;

procedure TOrgFileReader.MakeOneLkjRec_C3(var Info: ROrgCommonInfo; var Buf: array of byte; Len: integer);
begin
  //解析赋值
  Info.Disp := '坐标增';
  Info.Hms := GetTime(Buf, 1);
  Info.OTHER := m_tPreviousInfo.strSpeedGrade;
end;

procedure TOrgFileReader.MakeOneLkjRec_C4(var Info: ROrgCommonInfo; var Buf: array of byte; Len: integer);
begin
  //解析赋值
  Info.Disp := '坐标减';
  Info.Hms := GetTime(Buf, 1);
  Info.OTHER := m_tPreviousInfo.strSpeedGrade;
end;

procedure TOrgFileReader.MakeOneLkjRec_C5(var Info: ROrgCommonInfo; var Buf: array of byte; Len: integer);
begin
  //解析赋值
  Info.Disp := '过机不校';
  Info.Hms := GetTime(Buf, 1);
  Info.Glb := GetGLB(Buf, 4);
  Info.Jl := GetJL(Buf, 8);
  Info.OTHER := m_tPreviousInfo.strSpeedGrade;
end;

procedure TOrgFileReader.MakeOneLkjRec_C6(var Info: ROrgCommonInfo; var Buf: array of byte; Len: integer);
var
  intTemp: integer;
begin
  //解析赋值
  Info.Disp := '过机校正';
  Info.Hms := GetTime(Buf, 1);
  Info.Glb := GetGLB(Buf, 4);
  Info.Jl := GetJL(Buf, 8);

  intTemp := MoreBCD2INT(Buf, 11, 2);
  if intTemp > 999 then intTemp := -(intTemp mod 1000);
  Info.OTHER := Format('%d', [intTemp]);
  Info.Shuoming := Format('轮径值：%.01f', [MoreBCD2INT(Buf, 14, 3) / 10]);
end;

procedure TOrgFileReader.MakeOneLkjRec_C7(var Info: ROrgCommonInfo; var Buf: array of byte; Len: integer);
begin
  //解析赋值
  Info.Disp := '过站中心';
  Info.Hms := GetTime(Buf, 1);
  Info.Glb := GetGLB(Buf, 4);
  Info.Jl := GetJL(Buf, 8);
  Info.Speed := GetSpeed(Buf, 11);     
  Info.S_lmt := GetLimitSpeed(Buf, 13);
  Info.OTHER := m_tPreviousInfo.strSpeedGrade;
end;

procedure TOrgFileReader.MakeOneLkjRec_C8(var Info: ROrgCommonInfo; var Buf: array of byte; Len: integer);
var
  nWord: word;
begin
  //解析赋值
  Info.Disp := '报警开始';
  Info.Hms := GetTime(Buf, 1);
  Info.Glb := GetGLB(Buf, 4);
  Info.Jl := GetJL(Buf, 8);
  Info.Speed := GetSpeed(Buf, 11);
  Info.S_lmt := GetLimitSpeed(Buf, 13);

  //色灯信号
  nWord := MoreBCD2INT(Buf, 15, 2);
  Info.Signal := GetLamp(nWord);
  Info.OTHER := GetSD(nWord);
  m_tPreviousInfo.strSpeedGrade := Info.OTHER;
end;

procedure TOrgFileReader.MakeOneLkjRec_C9(var Info: ROrgCommonInfo; var Buf: array of byte; Len: integer);
var
  nWord: word;
begin
  //解析赋值
  Info.Disp := '报警结束';
  Info.Hms := GetTime(Buf, 1);
  Info.Glb := GetGLB(Buf, 4);
  Info.Jl := GetJL(Buf, 8);
  Info.Speed := GetSpeed(Buf, 11);
  Info.S_lmt := GetLimitSpeed(Buf, 13);

  //色灯信号
  nWord := MoreBCD2INT(Buf, 15, 2);
  Info.Signal := GetLamp(nWord);
  Info.OTHER := GetSD(nWord);
  m_tPreviousInfo.strSpeedGrade := Info.OTHER;
end;
        
procedure TOrgFileReader.MakeOneLkjRec_CA(var Info: ROrgCommonInfo; var Buf: array of byte; Len: integer);
var
  nWord: word;
begin
  //解析赋值
  Info.Disp := '手柄防溜报警开始';
  Info.Hms := GetTime(Buf, 1);
  Info.Glb := GetGLB(Buf, 4);
  Info.Jl := GetJL(Buf, 8);
  Info.Speed := GetSpeed(Buf, 11);
  Info.S_lmt := GetLimitSpeed(Buf, 13);

  //色灯信号
  nWord := MoreBCD2INT(Buf, 15, 2);
  Info.Signal := GetLamp(nWord);
  Info.OTHER := GetSD(nWord);
  m_tPreviousInfo.strSpeedGrade := Info.OTHER;
end;
     
procedure TOrgFileReader.MakeOneLkjRec_CB(var Info: ROrgCommonInfo; var Buf: array of byte; Len: integer);
var
  nWord: word;
begin
  //解析赋值
  Info.Disp := '手柄防溜报警结束';
  Info.Hms := GetTime(Buf, 1);
  Info.Glb := GetGLB(Buf, 4);
  Info.Jl := GetJL(Buf, 8);
  Info.Speed := GetSpeed(Buf, 11);
  Info.Speed := GetLimitSpeed(Buf, 13);

  //色灯信号
  nWord := MoreBCD2INT(Buf, 15, 2);
  Info.Signal := GetLamp(nWord);
  Info.OTHER := GetSD(nWord);
  m_tPreviousInfo.strSpeedGrade := Info.OTHER;
end;

procedure TOrgFileReader.MakeOneLkjRec_CC(var Info: ROrgCommonInfo; var Buf: array of byte; Len: integer);
var
  nByte: byte;
begin
  //解析赋值
  Info.Disp := '道岔';
  Info.Hms := GetTime(Buf, 1);
  Info.Glb := GetGLB(Buf, 4);
  Info.Jl := GetJL(Buf, 8);
  Info.Speed := GetSpeed(Buf, 11);
  Info.S_lmt := GetLimitSpeed(Buf, 13);
  Info.OTHER := m_tPreviousInfo.strSpeedGrade;

  nByte := BCD2INT(Buf[15]);    
  if nByte = 1 then Info.Disp := '出站道岔'
  else if nByte = 2 then Info.Disp := '出站道岔';
end;
          
procedure TOrgFileReader.MakeOneLkjRec_CD(var Info: ROrgCommonInfo; var Buf: array of byte; Len: integer);
begin
  //解析赋值
  Info.Disp := '日期变化';
  Info.Hms := GetTime(Buf, 1);

  //日期
  if TryEncodeDate(2000+BCD2INT(Buf[4]), BCD2INT(Buf[5]), BCD2INT(Buf[6]), m_tPreviousInfo.dtEventDate) then
  begin
    Info.OTHER := FormatDateTime('YY-MM-DD', m_tPreviousInfo.dtEventDate);
  end;
end;

procedure TOrgFileReader.MakeOneLkjRec_CE(var Info: ROrgCommonInfo; var Buf: array of byte; Len: integer);
var
  nByte: byte;
  nWord: word;
  strTemp: string;
begin
  //解析赋值
  Info.Disp := '过信号机';
  Info.Hms := GetTime(Buf, 1);
  Info.Glb := GetGLB(Buf, 4);
  Info.Jl := GetJL(Buf, 8);
  Info.Speed := GetSpeed(Buf, 11);
  Info.S_lmt := GetLimitSpeed(Buf, 13);

  //已过机编号[3]注48 已过机类型[1]注17
  strTemp := '';
  nByte := BCD2INT(Buf[18]);
  if nByte = 1 then strTemp := '进出站'
  else if nByte = 2 then strTemp := '出站'
  else if nByte = 3 then strTemp := '进站'
  else if nByte = 4 then strTemp := '通过'
  else if nByte = 5 then strTemp := '预告'
  else if nByte = 6 then strTemp := '容许'
  else if nByte = 7 then strTemp := '分割';
  if nByte in [1, 2, 3] then Info.Disp := strTemp;
  Info.Xhj_no := MoreBCD2INT(Buf, 15, 3) mod 100000;
  Info.Xht_code := nByte;
  Info.Xhj := Format('%s%d', [strTemp, Info.Xhj_no]);

  //前方机编号[3] 前方机类型[1]注17
  strTemp := '';
  nByte := BCD2INT(Buf[22]);
  if nByte = 1 then strTemp := '进出站'
  else if nByte = 2 then strTemp := '出站'
  else if nByte = 3 then strTemp := '进站'
  else if nByte = 4 then strTemp := '通过'
  else if nByte = 5 then strTemp := '预告'
  else if nByte = 6 then strTemp := '容许'
  else if nByte = 7 then strTemp := '分割';
  m_tPreviousInfo.Xhj_no := MoreBCD2INT(Buf, 19, 3) mod 100000;
  m_tPreviousInfo.Xht_code := nByte;
  m_tPreviousInfo.Xhj := Format('%s%d', [strTemp, m_tPreviousInfo.Xhj_no]);
  
  //色灯信号
  nWord := MoreBCD2INT(Buf, 23, 2);
  Info.Signal := GetLamp(nWord);
  Info.OTHER := GetSD(nWord);
  m_tPreviousInfo.strSpeedGrade := Info.OTHER;

  //自闭类型
  if Info.Disp = '过信号机' then
  begin
    nByte := BCD2INT(Buf[25]);
    if nByte = 0 then Info.Shuoming := '自闭类型：自闭'
    else if nByte = 1 then Info.Shuoming := '自闭类型：半自闭';
  end;

  //特别处理进站信号机
  if (Info.Disp = '进站') then
  begin
    Info.Xhj := Format('%d-%d', [m_tPreviousInfo.nDataLineID, m_tPreviousInfo.nStation]);
    m_tPreviousInfo.Xhj := Info.Xhj;
  end;
  if (Info.Disp = '进出站') then
  begin
    Info.Xhj := Format('%d-%d', [m_tPreviousInfo.nDataLineID, m_tPreviousInfo.nStation]);
  end;
end;
    
procedure TOrgFileReader.MakeOneLkjRec_CF(var Info: ROrgCommonInfo; var Buf: array of byte; Len: integer);
begin
  //解析赋值
  Info.Disp := '正线终止';
  Info.Hms := GetTime(Buf, 1);
  Info.OTHER := m_tPreviousInfo.strSpeedGrade;

  //信号机
  Info.Xht_code := m_tPreviousInfo.Xht_code;  
  Info.Xhj_no := m_tPreviousInfo.Xhj_no;
  Info.Xhj := Format('出站%d', [Info.Xhj_no]);
end;

procedure TOrgFileReader.MakeOneLkjRec_D0(var Info: ROrgCommonInfo; var Buf: array of byte; Len: integer);
var
  nWord: word;
  nByte: byte;
  strTemp: string;
begin
  //解析赋值
  Info.Disp := '停车';
  Info.Hms := GetTime(Buf, 1);
  Info.Glb := GetGLB(Buf, 4);
  Info.Jl := GetJL(Buf, 8);

  //前方机编号[3] 前方机类型[1]
  Info.Xhj_no := MoreBCD2INT(Buf, 11, 3);
  Info.Xht_code := BCD2INT(Buf[14]);

  //色灯信号
  nWord := MoreBCD2INT(Buf, 15, 2);
  Info.Signal := GetLamp(nWord);
  Info.OTHER := GetSD(nWord);
  m_tPreviousInfo.strSpeedGrade := Info.OTHER;

  //开车  4 20 60=站内   10 30 50 2 6 10 12 14 18 22=调车     40 00 08 16 =降级
  strTemp := '';
  nByte := BCD2INT(Buf[21]) and $07;
  if nByte = 4 then strTemp := '站内';
  if nByte = 2 then strTemp := '调车';
  if nByte = 6 then strTemp := '调车';
  if nByte = 0 then strTemp := '降级';

  if nByte = 1 then strTemp := '调车'; //红黄SD1
  if nByte = 3 then strTemp := '调车';
  if nByte = 5 then strTemp := '调车';
  Info.Disp := strTemp + Info.Disp;
end;

procedure TOrgFileReader.MakeOneLkjRec_D1(var Info: ROrgCommonInfo; var Buf: array of byte; Len: integer);
var
  nWord: word;
  nByte: byte;
  strTemp: string;
begin
  //解析赋值
  Info.Disp := '开车';
  Info.Hms := GetTime(Buf, 1);
  Info.Glb := GetGLB(Buf, 4);
  Info.Jl := GetJL(Buf, 8);
  Info.Speed := GetSpeed(Buf, 11);
  Info.S_lmt := GetLimitSpeed(Buf, 13);

  //前方编号[3] 前方机类型[1]
  Info.Xhj_no := MoreBCD2INT(Buf, 15, 3);
  Info.Xht_code := BCD2INT(Buf[18]);

  //色灯信号
  nWord := MoreBCD2INT(Buf, 19, 2);
  Info.Signal := GetLamp(nWord);
  Info.OTHER := GetSD(nWord);
  m_tPreviousInfo.strSpeedGrade := Info.OTHER;
  
  Info.Gya := GetLieGuanPressure(Buf, 21);
  Info.Gangy := GetGangPressure(Buf, 23);

  //开车  4 20 60=站内   10 30 50 2 6 10 12 14 18 22=调车     40 00 08 16 =降级
  strTemp := '';
  nByte := BCD2INT(Buf[25]) and $07;
  if nByte = 4 then strTemp := '站内';
  if nByte = 2 then strTemp := '调车';
  if nByte = 6 then strTemp := '调车';
  if nByte = 0 then strTemp := '降级';

  if nByte = 1 then strTemp := '调车'; //红黄SD1
  if nByte = 3 then strTemp := '调车';
  if nByte = 5 then strTemp := '调车';
  Info.Disp := strTemp + Info.Disp;
  
  //信号机
  //if m_tPreviousInfo.Xhj = NULL_VALUE_STRING then Info.Xhj := Format('出站%d', [Info.Xhj_no]);
  //if (Info.Disp = '站内开车') or (Info.Disp = '降级开车') then Info.Xhj := Format('出站%d', [Info.Xhj_no]);
  if m_tPreviousInfo.Xhj = NULL_VALUE_STRING then
    if (m_tPreviousInfo.nDataLineID <> NULL_VALUE_MAXINT) and (m_tPreviousInfo.nStation <> NULL_VALUE_MAXINT) then
      Info.Xhj := Format('%d-%d', [m_tPreviousInfo.nDataLineID, m_tPreviousInfo.nStation]);
  if (Info.Disp = '降级开车') or (Info.Disp = '调车开车') then Info.Xhj := Format('出站%d', [Info.Xhj_no]);
end;
                    
procedure TOrgFileReader.MakeOneLkjRec_D7(var Info: ROrgCommonInfo; var Buf: array of byte; Len: integer);
begin
  //解析赋值
  Info.Disp := '轮径修正';
  Info.Xhj := Format('%.01f', [MoreBCD2INT(Buf, 1, 3) / 10]);
end;

procedure TOrgFileReader.MakeOneLkjRec_E0(var Info: ROrgCommonInfo; var Buf: array of byte; Len: integer);
var
  nWord: word;
begin
  //解析赋值
  Info.Disp := '机车信号变化';
  Info.Hms := GetTime(Buf, 1);
  Info.Glb := GetGLB(Buf, 4);
  Info.Jl := GetJL(Buf, 8);
  Info.Speed := GetSpeed(Buf, 11);
  Info.S_lmt := GetLimitSpeed(Buf, 13);
  Info.OTHER := m_tPreviousInfo.strSpeedGrade;

  //色灯信号
  nWord := MoreBCD2INT(Buf, 15, 2);
  Info.Signal := GetLamp(nWord);
  Info.OTHER := GetSD(nWord);
  m_tPreviousInfo.strSpeedGrade := Info.OTHER;
end;

procedure TOrgFileReader.MakeOneLkjRec_E3(var Info: ROrgCommonInfo; var Buf: array of byte; Len: integer);
var
  nWord: word;
  nByte: byte;
begin
  //解析赋值
  Info.Disp := '机车工况变化';
  Info.Hms := GetTime(Buf, 1);
  Info.Glb := GetGLB(Buf, 4);
  Info.Jl := GetJL(Buf, 8);
  Info.Speed := GetSpeed(Buf, 11);
  Info.S_lmt := GetLimitSpeed(Buf, 13);
  Info.OTHER := m_tPreviousInfo.strSpeedGrade;

  //???工况状态，与文档不一致，有待总结规律
  nWord := MoreBCD2INT(Buf, 15, 2);
  nByte := nWord and $FF;
  Info.Shoub := nByte;
  Info.Hand := GetInfo_GK(nByte and $1F);
end;

procedure TOrgFileReader.MakeOneLkjRec_E5(var Info: ROrgCommonInfo; var Buf: array of byte; Len: integer);
var
  nByte: byte;
  strTemp: string;
begin
  //解析赋值
  Info.Disp := '调车灯显变化';
  Info.Hms := GetTime(Buf, 1);
  Info.Glb := GetGLB(Buf, 4);
  Info.Jl := GetJL(Buf, 8);
  Info.Speed := GetSpeed(Buf, 11);
  Info.S_lmt := GetLimitSpeed(Buf, 13);

  strTemp := '';
  nByte := BCD2INT(Buf[15]);
  if nByte = 0 then strTemp := '平调0' //无定义
  else if nByte = 1 then strTemp := '停车'
  else if nByte = 2 then strTemp := '推进'
  else if nByte = 3 then strTemp := '起动'
  else if nByte = 4 then strTemp := '连接'
  else if nByte = 5 then strTemp := '溜放'
  else if nByte = 6 then strTemp := '减速'
  else if nByte = 7 then strTemp := '十车'
  else if nByte = 8 then strTemp := '五车'
  else if nByte = 9 then strTemp := '三车'
  else if nByte = 10 then strTemp := '牵出稍动'
  else if nByte = 11 then strTemp := '收放权'
  else if nByte = 12 then strTemp := '平调12' //无定义
  else if nByte = 13 then strTemp := '推进稍动'
  else if nByte = 14 then strTemp := '故障停车'
  else if nByte = 15 then strTemp := '平调15' //无定义
  else if nByte = 16 then strTemp := '紧急停车1'
  else if nByte = 17 then strTemp := '紧急停车2'
  else if nByte = 18 then strTemp := '紧急停车3'
  else if nByte = 19 then strTemp := '紧急停车4'
  else if nByte = 20 then strTemp := '紧急停车5'
  else if nByte = 21 then strTemp := '紧急停车6'
  else if nByte = 22 then strTemp := '紧急停车7'
  else if nByte = 23 then strTemp := '紧急停车8'
  else if nByte = 24 then strTemp := '解锁1'
  else if nByte = 25 then strTemp := '解锁2'
  else if nByte = 26 then strTemp := '解锁3'
  else if nByte = 27 then strTemp := '解锁4'
  else if nByte = 28 then strTemp := '解锁5'
  else if nByte = 29 then strTemp := '解锁6'
  else if nByte = 30 then strTemp := '解锁7'
  else if nByte = 31 then strTemp := '解锁8'
  else if nByte = 35 then strTemp := '一车'
  else if nByte = 40 then strTemp := '平调开始'
  else if nByte = 41 then strTemp := '平调结束';
  if strTemp <> '' then Info.Signal := strTemp;

  if strTemp = '' then Info.Disp := ''; //===测试用，正式时删除
end;

procedure TOrgFileReader.MakeOneLkjRec_E6(var Info: ROrgCommonInfo; var Buf: array of byte; Len: integer);
begin
  //解析赋值
  Info.Disp := '速度变化';
  Info.Hms := GetTime(Buf, 1);
  Info.Glb := GetGLB(Buf, 4);
  Info.Jl := GetJL(Buf, 8);
  Info.Speed := GetSpeed(Buf, 11);
  Info.S_lmt := GetLimitSpeed(Buf, 13);
  Info.OTHER := m_tPreviousInfo.strSpeedGrade;
end;

procedure TOrgFileReader.MakeOneLkjRec_E7(var Info: ROrgCommonInfo; var Buf: array of byte; Len: integer);
begin
  //解析赋值
  Info.Disp := '转速变化';
  Info.Hms := GetTime(Buf, 1);
  Info.Glb := GetGLB(Buf, 4);
  Info.Jl := GetJL(Buf, 8);
  Info.Rota := MoreBCD2INT(Buf, 11, 2);
end;

procedure TOrgFileReader.MakeOneLkjRec_EB(var Info: ROrgCommonInfo; var Buf: array of byte; Len: integer);
begin
  //解析赋值
  Info.Disp := '管压变化';
  Info.Hms := GetTime(Buf, 1);
  Info.Glb := GetGLB(Buf, 4);
  Info.Jl := GetJL(Buf, 8);
  Info.Gya := GetLieGuanPressure(Buf, 11);
  Info.OTHER := m_tPreviousInfo.strSpeedGrade;
end;

procedure TOrgFileReader.MakeOneLkjRec_EC(var Info: ROrgCommonInfo; var Buf: array of byte; Len: integer);
begin
  //解析赋值
  Info.Disp := '限速变化';
  Info.Hms := GetTime(Buf, 1);
  Info.Glb := GetGLB(Buf, 4);
  Info.Jl := GetJL(Buf, 8);
  Info.Speed := GetSpeed(Buf, 11);
  Info.S_lmt := GetLimitSpeed(Buf, 13);
  Info.OTHER := m_tPreviousInfo.strSpeedGrade;
end;

procedure TOrgFileReader.MakeOneLkjRec_ED(var Info: ROrgCommonInfo; var Buf: array of byte; Len: integer);
var
  nWord: word;
  nByte: byte;
begin
  //解析赋值
  Info.Disp := '定量记录';
  Info.Hms := GetTime(Buf, 1);
  Info.Glb := GetGLB(Buf, 4);
  Info.Jl := GetJL(Buf, 8);
  Info.Speed := GetSpeed(Buf, 11);
  Info.S_lmt := GetLimitSpeed(Buf, 13);

  //色灯信号
  nWord := MoreBCD2INT(Buf, 15, 2);
  Info.Signal := GetLamp(nWord);
  Info.OTHER := GetSD(nWord);
  m_tPreviousInfo.strSpeedGrade := Info.OTHER;

  //???工况状态，与文档不一致，有待总结规律
  nWord := MoreBCD2INT(Buf, 17, 2);
  nByte := nWord and $FF;
  Info.Shoub := nByte;
  Info.Hand := GetInfo_GK(nByte and $1F);

  Info.Gya := GetLieGuanPressure(Buf, 19);
  Info.Gangy := GetGangPressure(Buf, 21);
  //Info.Jg1 := MoreBCD2INT(Buf, 23, 2); //思维分析软件中，此内容未处理显示
  //Info.Jg2 := MoreBCD2INT(Buf, 25, 2); //思维分析软件中，此内容未处理显示
  Info.Rota := MoreBCD2INT(Buf, 35, 2);
end;

procedure TOrgFileReader.MakeOneLkjRec_EE(var Info: ROrgCommonInfo; var Buf: array of byte; Len: integer);
begin
  //解析赋值
  Info.Disp := '闸缸压力变化';
  Info.Hms := GetTime(Buf, 1);
  Info.Glb := GetGLB(Buf, 4);
  Info.Jl := GetJL(Buf, 8);
  Info.Gangy := GetGangPressure(Buf, 11);
  Info.OTHER := m_tPreviousInfo.strSpeedGrade;
end;
        
procedure TOrgFileReader.MakeOneLkjRec_EF(var Info: ROrgCommonInfo; var Buf: array of byte; Len: integer);
begin
  //解析赋值
  Info.Disp := '均缸压力变化';
  Info.Hms := GetTime(Buf, 1);
  Info.Glb := GetGLB(Buf, 4);
  Info.Jl := GetJL(Buf, 8);
  Info.Jg1 := MoreBCD2INT(Buf, 11, 2);   
  Info.Jg2 := MoreBCD2INT(Buf, 13, 2);
  Info.OTHER := m_tPreviousInfo.strSpeedGrade;
end;

//解析类型A0
procedure TOrgFileReader.MakeOneLkjRec_A0(var Info: ROrgCommonInfo; var Buf: array of byte; Len: integer);
var
  nType, nByte: byte;
  strTemp: string;
begin       
  //解析时间
  Info.Hms := GetTime(Buf, 2);

  //解析其它
  nType := Buf[1];
  case nType of 
    $13:
      if Len = 16 then
      begin
        Info.Disp := '速度通道切换';
        Info.Glb := GetGLB(Buf, 5);
        Info.Jl := GetJL(Buf, 9);
        Info.OTHER := Format('%d->%d', [BCD2INT(Buf[12]), BCD2INT(Buf[13])]);
      end;
    $14:
      if Len = 8 then
      begin
        Info.Disp := '速度通道号';
        Info.OTHER := IntToStr(BCD2INT(Buf[5]));
      end;       
    $26, $27:
      if Len = 15 then
      begin
        if nType = $26 then Info.Disp := 'A数字入检测'
        else if nType = $27 then Info.Disp := 'B数字入检测';

        Info.Glb := GetGLB(Buf, 5);
        Info.Jl := GetJL(Buf, 9);

        strTemp := '';
        nByte := BCD2INT(Buf[12]);
        if nByte = 0 then strTemp := '绿灯'
        else if nByte = 1 then strTemp := '绿黄'
        else if nByte = 2 then strTemp := '黄灯'
        else if nByte = 3 then strTemp := '黄2灯'
        else if nByte = 4 then strTemp := '双黄灯'
        else if nByte = 5 then strTemp := '红黄灯'
        else if nByte = 6 then strTemp := '红灯'
        else if nByte = 7 then strTemp := '白灯'
        else if nByte = 8 then strTemp := '速度0'
        else if nByte = 9 then strTemp := '速度1'
        else if nByte = 10 then strTemp := '速度2'
        else if nByte = 11 then strTemp := 'UM71制式'
        else if nByte = 12 then strTemp := '电平信号'
        else if nByte = 13 then strTemp := '备用1'
        else if nByte = 14 then strTemp := '备用2'
        else if nByte = 15 then strTemp := '备用3';
        if strTemp <> '' then Info.Shuoming := Format('%d-%s', [nByte, strTemp])
        else Info.Shuoming := Format('保留%.02xH', [nByte, strTemp]);
      end;    
    $30, $31:
      if Len = 15 then
      begin
        if nType = $30 then Info.Disp := 'A数字出检测'
        else if nType = $31 then Info.Disp := 'B数字出检测';
                  
        Info.Glb := GetGLB(Buf, 5);
        Info.Jl := GetJL(Buf, 9);

        strTemp := '';
        nByte := BCD2INT(Buf[12]);
        if nByte = 0 then strTemp := '卸载'
        else if nByte = 1 then strTemp := '减压'
        else if nByte = 2 then strTemp := '关风'
        else if nByte = 3 then strTemp := '备用1'
        else if nByte = 4 then strTemp := '备用2'
        else if nByte = 5 then strTemp := '备用3'
        else if nByte = 6 then strTemp := '紧急';

        if strTemp <> '' then Info.Shuoming := Format('%d-%s', [nByte, strTemp])
        else Info.Shuoming := Format('保留%.02xH', [nByte, strTemp]);
      end;
    $34, $35:
      if Len = 15 then
      begin
        if nType = $34 then Info.Disp := 'A模块故障'
        else if nType = $35 then Info.Disp := 'B模块故障';

        Info.Glb := GetGLB(Buf, 5);
        Info.Jl := GetJL(Buf, 9);

        strTemp := '';
        nByte := BCD2INT(Buf[12]);
        if nByte = 0 then strTemp := '信息处理板A'
        else if nByte = 1 then strTemp := '信息处理板B'
        else if nByte = 2 then strTemp := '通讯板A'
        else if nByte = 3 then strTemp := '通讯板B'
        else if nByte = 4 then strTemp := '一端显示器'
        else if nByte = 5 then strTemp := '二端显示器'
        else if nByte = 6 then strTemp := '黑匣子'
        else if nByte = 7 then strTemp := '串行机车信号'
        else if nByte = 8 then strTemp := '扩展通信板A'
        else if nByte = 9 then strTemp := '扩展通信板B'
        else if nByte = 10 then strTemp := '无线数传';

        if strTemp <> '' then Info.Shuoming := Format('%d-%s', [nByte, strTemp])
        else Info.Shuoming := Format('保留%.02xH', [nByte, strTemp]);
      end;
  end;
end;
            
//解析类型A4
procedure TOrgFileReader.MakeOneLkjRec_A4(var Info: ROrgCommonInfo; var Buf: array of byte; Len: integer);
var
  nType, nByte: byte;
  strTemp: string;
begin       
  //解析时间
  Info.Hms := GetTime(Buf, 2);

  //解析其它
  nType := Buf[1];
  case nType of  
    $26, $27:
      if Len = 15 then
      begin
        if nType = $26 then Info.Disp := 'A数字入恢复'
        else if nType = $27 then Info.Disp := 'B数字入恢复';
                  
        Info.Glb := GetGLB(Buf, 5);
        Info.Jl := GetJL(Buf, 9);

        strTemp := '';
        nByte := BCD2INT(Buf[12]);
        if nByte = 0 then strTemp := '绿灯'
        else if nByte = 1 then strTemp := '绿黄'
        else if nByte = 2 then strTemp := '黄灯'
        else if nByte = 3 then strTemp := '黄2灯'
        else if nByte = 4 then strTemp := '双黄灯'
        else if nByte = 5 then strTemp := '红黄灯'
        else if nByte = 6 then strTemp := '红灯'
        else if nByte = 7 then strTemp := '白灯'
        else if nByte = 8 then strTemp := '速度0'
        else if nByte = 9 then strTemp := '速度1'
        else if nByte = 10 then strTemp := '速度2'
        else if nByte = 11 then strTemp := 'UM71制式'
        else if nByte = 12 then strTemp := '电平信号'
        else if nByte = 13 then strTemp := '备用1'
        else if nByte = 14 then strTemp := '备用2'
        else if nByte = 15 then strTemp := '备用3';
        if strTemp <> '' then Info.Shuoming := Format('%d-%s', [nByte, strTemp])
        else Info.Shuoming := Format('保留%.02xH', [nByte, strTemp]);
      end;    
    $30, $31:
      if Len = 15 then
      begin
        if nType = $30 then Info.Disp := 'A数字出恢复'
        else if nType = $31 then Info.Disp := 'B数字出恢复';
                  
        Info.Glb := GetGLB(Buf, 5);
        Info.Jl := GetJL(Buf, 9);

        strTemp := '';
        nByte := BCD2INT(Buf[12]);
        if nByte = 0 then strTemp := '卸载'
        else if nByte = 1 then strTemp := '减压'
        else if nByte = 2 then strTemp := '关风'
        else if nByte = 3 then strTemp := '备用1'
        else if nByte = 4 then strTemp := '备用2'
        else if nByte = 5 then strTemp := '备用3'
        else if nByte = 6 then strTemp := '紧急';

        if strTemp <> '' then Info.Shuoming := Format('%d-%s', [nByte, strTemp])
        else Info.Shuoming := Format('保留%.02xH', [nByte, strTemp]);
      end;
    $34, $35:
      if Len = 15 then
      begin
        if nType = $34 then Info.Disp := 'A模块恢复'
        else if nType = $35 then Info.Disp := 'B模块恢复';

        Info.Glb := GetGLB(Buf, 5);
        Info.Jl := GetJL(Buf, 9);

        strTemp := '';
        nByte := BCD2INT(Buf[12]);
        if nByte = 0 then strTemp := '信息处理板A'
        else if nByte = 1 then strTemp := '信息处理板B'
        else if nByte = 2 then strTemp := '通讯板A'
        else if nByte = 3 then strTemp := '通讯板B'
        else if nByte = 4 then strTemp := '一端显示器'
        else if nByte = 5 then strTemp := '二端显示器'
        else if nByte = 6 then strTemp := '黑匣子'
        else if nByte = 7 then strTemp := '串行机车信号'
        else if nByte = 8 then strTemp := '扩展通信板A'
        else if nByte = 9 then strTemp := '扩展通信板B'
        else if nByte = 10 then strTemp := '无线数传';

        if strTemp <> '' then Info.Shuoming := Format('%d-%s', [nByte, strTemp])
        else Info.Shuoming := Format('保留%.02xH', [nByte, strTemp]);
      end;
  end;
end;

//解析类型A8
procedure TOrgFileReader.MakeOneLkjRec_A8(var Info: ROrgCommonInfo; var Buf: array of byte; Len: integer);
var
  nType, nByte: byte;
  nWord: word; 
  strTemp: string;
begin       
  //解析时间
  Info.Hms := GetTime(Buf, 2);

  //解析其它
  nType := Buf[1];
  case nType of  
    $05:
      if Len = 10 then
      begin
        Info.Disp := '交路号'; //监控交路号
        Info.OTHER := IntToStr(MoreBCD2INT(Buf, 5, 3));
        Info.nJKLineID := MoreBCD2INT(Buf, 5, 3);
      end;       
    $18:
      if Len = 8 then
      begin
        Info.Disp := '数据交路号';
        Info.OTHER := IntToStr(BCD2INT(Buf[5]));
        m_tPreviousInfo.nDataLineID := BCD2INT(Buf[5]);
      end;
    $09, $10, $11, $12, $13, $14, $15, $17:
      if Len = 9 then
      begin
        if nType = $09 then Info.Disp := '客车'
        else if nType = $10 then Info.Disp := '重车'
        else if nType = $11 then Info.Disp := '空车'
        else if nType = $12 then Info.Disp := '非运用车'
        else if nType = $13 then Info.Disp := '代客车'
        else if nType = $14 then Info.Disp := '守车'  
        else if nType = $15 then Info.Disp := '辆数'
        else if nType = $17 then Info.Disp := '调车批号';

        Info.OTHER := IntToStr(MoreBCD2INT(Buf, 5, 2));
      end;
    $06, $27, $29:
      if Len = 10 then
      begin
        if nType = $06 then Info.Disp := '车站号'
        else if nType = $27 then Info.Disp := '总重'
        else if nType = $29 then Info.Disp := '载重';

        Info.OTHER := IntToStr(MoreBCD2INT(Buf, 5, 3));

        if Info.Disp = '车站号' then
        begin                 
          m_tPreviousInfo.nStation := MoreBCD2INT(Buf, 5, 3);
          Info.Xhj := Format('%d-%d', [m_tPreviousInfo.nDataLineID, m_tPreviousInfo.nStation]);
        end;
      end;
    $04, $21:
      if Len = 11 then
      begin
        if nType = $21 then Info.Disp := '司机号'
        else if nType = $04 then Info.Disp := '副司机号';

        Info.OTHER := IntToStr(MoreBCD2INT(Buf, 5, 4));
      end;
    $16:
      if Len = 9 then
      begin
        Info.Disp := '计长';
        Info.OTHER := Format('%0.1f', [MoreBCD2INT(Buf, 5, 2) / 10]);
      end;
    $20:
      if Len = 16 then
      begin
        Info.Disp := '车次'; //如果是车次，拆分成两条记录
        strTemp := trim(chr(Buf[7])+ chr(Buf[8])+ chr(Buf[9])+ chr(Buf[10]));
        Info.OTHER := strTemp + IntToStr(MoreBCD2INT(Buf, 11, 3));
        //--------------------------------
        //nByte := Buf[5]; //客货类型[1]
        nByte := Buf[6]; //客货本补[1]
        if nByte = 0 then Info.Shuoming := '货本'
        else if nByte = 1 then Info.Shuoming := '客本'
        else if nByte = 2 then Info.Shuoming := '货补'
        else if nByte = 3 then Info.Shuoming := '客补';
      end;
    $24:
      if Len = 8 then
      begin
        Info.Disp := '本补客货';

        nByte := Buf[5];
        if nByte = 0 then Info.OTHER := '货本'
        else if nByte = 1 then Info.OTHER := '客本'
        else if nByte = 2 then Info.OTHER := '货补'
        else if nByte = 3 then Info.OTHER := '客补';
      end;
    $43:
      if Len = 10 then
      begin
        Info.Disp := '防撞辆数变化';
        Info.OTHER := '???';
      end;
    $22, $23, $90, $91, $94, $95, $96, $97, $98, $99:
      //if Len >= 15 then
      begin
        if nType = $22 then Info.Disp := '输入支线无效'
        else if nType = $23 then Info.Disp := '输入侧线无效'
        else if nType = $90 then Info.Disp := '上电装置号'
        else if nType = $91 then Info.Disp := '上电机车型号'
        else if nType = $94 then Info.Disp := '显示器1通信超时'
        else if nType = $95 then Info.Disp := '显示器1通信超时恢复'
        else if nType = $96 then Info.Disp := '显示器2通信超时'
        else if nType = $97 then Info.Disp := '显示器2通信超时恢复'
        else if nType = $98 then Info.Disp := '显示器1版本号变化'
        else if nType = $99 then Info.Disp := '显示器2版本号变化';

        Info.OTHER := '???';
      end;
    $01, $02, $03, $28, $30, $31, $32, $34, $36, $37, $38, $39, $40, $42, $45:
      //if Len >= 15 then
      begin
        if nType = $01 then Info.Disp := '日期修改'
        else if nType = $02 then Info.Disp := '时间修改'
        else if nType = $03 then Info.Disp := '轮径修改'
        else if nType = $28 then Info.Disp := '备用轮径修改'
        else if nType = $30 then Info.Disp := '机车号修改'
        else if nType = $31 then Info.Disp := '装置号修改'
        else if nType = $32 then Info.Disp := '机车型号修改' 
        else if nType = $34 then Info.Disp := '默认辆数修改' 
        else if nType = $36 then Info.Disp := '默认计长修改'
        else if nType = $37 then Info.Disp := '机车类型修改'
        else if nType = $38 then Info.Disp := '机车AB节修改'
        else if nType = $39 then Info.Disp := '柴机脉冲数修改'
        else if nType = $40 then Info.Disp := '速度表量程修改'
        else if nType = $42 then Info.Disp := 'GPS校时'
        else if nType = $45 then Info.Disp := '默认总重修改';

        Info.OTHER := '???';
      end;
    $54: //文档没有，分析补充
      if Len = 9 then
      begin
        Info.Disp := '输入车站错误';
        Info.OTHER := IntToStr(MoreBCD2INT(Buf, 5, 2)); //原始存储文件存储有问题，与$06不统一
      end;    
    $55: //文档没有，分析补充
      if Len = 24 then
      begin
        Info.Disp := '输入最高限速';
        Info.Glb := GetGLB(Buf, 5);
        Info.Jl := GetJL(Buf, 9);
        Info.Speed := GetSpeed(Buf, 12);
        Info.S_lmt := GetLimitSpeed(Buf, 14);

        //色灯信号
        nWord := MoreBCD2INT(Buf, 16, 2);
        Info.Signal := GetLamp(nWord);
        Info.OTHER := GetSD(nWord);
        m_tPreviousInfo.strSpeedGrade := Info.OTHER;

        //???工况状态 原始文件没有相关字节，D:\上海运行记录文件\55302-10121.0629如何求得
        Info.Hand := '???';

        Info.Shuoming := Format('原输入限速：%d    输入限速：%d', [MoreBCD2INT(Buf, 18, 2), MoreBCD2INT(Buf, 20, 2)]);
      end; 
    $58: //文档没有，分析补充
      if Len = 19 then
      begin
        Info.Disp := 'IC卡验证码';
        
        nWord := MoreBCD2INT(Buf, 5, 2);
        if nWord = 101 then Info.OTHER := '512K未加密IC卡'
        else if nWord = 102 then Info.OTHER := '2M未加密IC卡'
        else if nWord = 103 then Info.OTHER := '2M加密IC卡'
        else if nWord = 104 then Info.OTHER := '4M加密IC卡'
        else if nWord = 105 then Info.OTHER := '8M加密IC卡';

        nWord := MoreBCD2INT(Buf, 7, 2);     
        if nWord = 1 then strTemp := ' 株洲所'
        else if nWord = 2 then strTemp := '思维公司'
        else strTemp := '未知';
        Info.Shuoming := Format('生产厂家: %s;   生产日期：%d%.02d%.02d   生产序号：%d', [strTemp, 2000+BCD2INT(Buf[11]), BCD2INT(Buf[12]), BCD2INT(Buf[13]), MoreBCD2INT(Buf, 14, 3)]);
      end;
    $87: //文档没有，分析补充
      if Len = 55 then
      begin
        Info.Disp := '软件版本';
        Info.Shuoming := Format('监控A程序版本：%.02d-%.02d-%.02d；', [2000+BCD2INT(Buf[5]), BCD2INT(Buf[6]), BCD2INT(Buf[7])]);
        Info.Shuoming := Info.Shuoming + Format('监控B程序版本：%.02d-%.02d-%.02d；', [2000+BCD2INT(Buf[8]), BCD2INT(Buf[9]), BCD2INT(Buf[10])]);
        Info.Shuoming := Info.Shuoming + Format('监控A数据版本：%.02d-%.02d-%.02d；', [2000+BCD2INT(Buf[11]), BCD2INT(Buf[12]), BCD2INT(Buf[13])]);
        Info.Shuoming := Info.Shuoming + Format('监控B数据版本：%.02d-%.02d-%.02d；', [2000+BCD2INT(Buf[14]), BCD2INT(Buf[15]), BCD2INT(Buf[16])]);
        Info.Shuoming := Info.Shuoming + Format('A机通信版本：%.02d-%.02d-%.02d；', [2000+BCD2INT(Buf[17]), BCD2INT(Buf[18]), BCD2INT(Buf[19])]);
        Info.Shuoming := Info.Shuoming + Format('B机通信版本：%.02d-%.02d-%.02d；', [2000+BCD2INT(Buf[20]), BCD2INT(Buf[21]), BCD2INT(Buf[22])]);
        Info.Shuoming := Info.Shuoming + Format('A机扩展通信版本：%.02d-%.02d-%.02d；', [2000+BCD2INT(Buf[23]), BCD2INT(Buf[24]), BCD2INT(Buf[25])]);
        Info.Shuoming := Info.Shuoming + Format('B机扩展通信版本：%.02d-%.02d-%.02d；', [2000+BCD2INT(Buf[26]), BCD2INT(Buf[27]), BCD2INT(Buf[28])]);
        Info.Shuoming := Info.Shuoming + Format('A机地面信息版本：%.02d-%.02d-%.02d；', [2000+BCD2INT(Buf[29]), BCD2INT(Buf[30]), BCD2INT(Buf[31])]);
        Info.Shuoming := Info.Shuoming + Format('B机地面信息版本：%.02d-%.02d-%.02d；', [2000+BCD2INT(Buf[32]), BCD2INT(Buf[33]), BCD2INT(Buf[34])]);
        Info.Shuoming := Info.Shuoming + Format('监控A参数版本：%.02d-%.02d-%.02d；', [2000+BCD2INT(Buf[35]), BCD2INT(Buf[36]), BCD2INT(Buf[37])]);
        Info.Shuoming := Info.Shuoming + Format('监控B参数版本：%.02d-%.02d-%.02d；', [2000+BCD2INT(Buf[38]), BCD2INT(Buf[39]), BCD2INT(Buf[40])]);
      end;
  end;
end;

//解析类型B1
procedure TOrgFileReader.MakeOneLkjRec_B1(var Info: ROrgCommonInfo; var Buf: array of byte; Len: integer);
var
  nType, nByte: byte;
  nJSType: word;
  strTemp, strLine: string;
begin       
  //解析时间、公里标
  Info.Hms := GetTime(Buf, 2);

  //解析其它
  nType := Buf[1];
  case nType of
    $01, $10:
      if Len = 48 then
      begin
        if nType = $01 then Info.Disp := '揭示输入'
        else if nType = $10 then Info.Disp := '揭示重新输入';

        Info.OTHER := Format('命令%d', [MoreBCD2INT(Buf, 42, 4)]);
        Info.Shuoming := Format('序号：%d；', [MoreBCD2INT(Buf, 5, 2)]);

        nJSType := MoreBCD2INT(Buf, 8, 2) and $FF; //揭示类型
        if nJSType = 0 then strTemp := ''
        else if nJSType = 1 then strTemp := '临时限速'
        else if nJSType = 2 then strTemp := '站间停用每日'      //非公里标，显示TMIS站名  //特殊揭示  //电话闭塞临时
        else if nJSType = 3 then strTemp := '车站限速每日'      //非公里标，显示TMIS站名
        else if nJSType = 4 then strTemp := '侧线限速每日'      //非公里标，显示TMIS站名
        else if nJSType = 5 then strTemp := '乘降所限速每日'
        else if nJSType = 6 then strTemp := '绿色许可证每日'    //非公里标，显示TMIS站名  //特殊揭示 //绿色凭证临时
        else if nJSType = 7 then strTemp := '特定引导每日'      //非公里标，显示TMIS站名  //特殊揭示
        else if nJSType = 129 then strTemp := '昼夜限速'
        else if nJSType = 130 then strTemp := '站间停用昼夜'    //非公里标，显示TMIS站名  //特殊揭示  //电话闭塞昼夜
        else if nJSType = 131 then strTemp := '车站限速昼夜'    //非公里标，显示TMIS站名
        else if nJSType = 132 then strTemp := '侧线限速昼夜'    //非公里标，显示TMIS站名
        else if nJSType = 133 then strTemp := '乘降所限速昼夜'
        else if nJSType = 134 then strTemp := '绿色许可证昼夜'  //非公里标，显示TMIS站名  //特殊揭示 //绿色凭证昼夜
        else if nJSType = 135 then strTemp := '特定引导昼夜'    //非公里标，显示TMIS站名  //特殊揭示
        else if nJSType = 30 then strTemp := '施工揭示'
        else if nJSType = 31 then strTemp := '防汛揭示每日'
        else if nJSType = 32 then strTemp := '降弓提示揭示'
        else if nJSType = 159 then strTemp := '防汛揭示'
        else strTemp := IntToStr(nJSType);
        Info.Shuoming := Info.Shuoming + Format('揭示类型：%s；', [strTemp]);

        nByte := BCD2INT(Buf[14]); //上下行
        if nByte = 1 then strTemp := '下行'
        else if nByte = 2 then strTemp := '上行'
        else if nByte = 3 then strTemp := '上下行'
        else strTemp := '未知上下行';
        strLine := strTemp;

        nByte := BCD2INT(Buf[13]) and $01; //主线/三线
        if nByte = 0 then strTemp := '主线'
        else if nByte = 1 then strTemp := '三线'
        else strTemp := '';
        strLine := strLine + '/' + strTemp;
                                 
        nByte := (BCD2INT(Buf[13]) div 10) and $01; //正向/反向
        if nByte = 0 then strTemp := '正向'
        else if nByte = 1 then strTemp := '反向'
        else strTemp := '';   
        strLine := strLine + '/' + strTemp;

        Info.Shuoming := Info.Shuoming + Format('从%.02d-%.02d %.02d:%.02d始到%.02d-%.02d %.02d:%.02d止；', [BCD2INT(Buf[15]), BCD2INT(Buf[16]), BCD2INT(Buf[17]), BCD2INT(Buf[18]), BCD2INT(Buf[19]), BCD2INT(Buf[20]), BCD2INT(Buf[21]), BCD2INT(Buf[22])]);
        Info.Shuoming := Info.Shuoming + Format('工务线号:%d；', [MoreBCD2INT(Buf, 10, 3)]);
        Info.Shuoming := Info.Shuoming + strLine + '；';

        //非公里标，显示TMIS站名，别的显示起止公里标
        if nJSType in [2,3,4,6,7,130,131,132,134,135] then
        begin
          Info.Shuoming := Info.Shuoming + Format('TIMS站号：%d；', [MoreBCD2INT(Buf, 23, 4)]);
        end
        else
        begin
          Info.Shuoming := Info.Shuoming + Format('坐标范围:%.03fKm -- %.03fKm；', [MoreBCD2INT(Buf, 23, 4)/1000, MoreBCD2INT(Buf, 29, 4)/1000]);
          nByte := BCD2INT(Buf[27]) and $07; //起始重复公里标序号
          if nByte in [0, 3, 4, 7] then Info.Shuoming := Info.Shuoming + Format('起始重复公里标序号：%d；', [nByte*4 + BCD2INT(Buf[28])])
          else Info.Shuoming := Info.Shuoming + Format('起始重复公里标序号：长链地段%d；', [nByte*4 + BCD2INT(Buf[28])]);
          nByte := BCD2INT(Buf[33]) and $07; //结束重复标公里标序号
          if nByte in [0, 3, 4, 7] then Info.Shuoming := Info.Shuoming + Format('结束重复标公里标序号：%d；', [nByte*4 + BCD2INT(Buf[34])])
          else Info.Shuoming := Info.Shuoming + Format('结束重复标公里标序号：长链地段%d；', [nByte*4 + BCD2INT(Buf[34])]);
          Info.Shuoming := Info.Shuoming + Format('限速长度：%dm；', [MoreBCD2INT(Buf, 39, 3)]);
        end;
        Info.Shuoming := Info.Shuoming + Format('限速:%d(客)/%d(货)', [MoreBCD2INT(Buf, 35, 2), MoreBCD2INT(Buf, 37, 2)]);
      end; 
    $02, $03, $15, $16:
      if Len = 18 then
      begin
        if nType = $02 then Info.Disp := '限速开始'
        else if nType = $03 then Info.Disp := '揭示结束'
        else if nType = $15 then Info.Disp := '过揭示起点'
        else if nType = $16 then Info.Disp := '过揭示终点';

        Info.Glb := GetGLB(Buf, 5);
        Info.Jl := GetJL(Buf, 9);
        Info.OTHER := Format('命令%d', [MoreBCD2INT(Buf, 12, 4)]);
      end;
    $11, $12:
      if Len = 16 then
      begin
        if nType = $11 then Info.Disp := '揭示查询'
        else if nType = $12 then Info.Disp := '揭示更新';

        Info.Glb := GetGLB(Buf, 5);
        Info.Jl := GetJL(Buf, 9);
        Info.OTHER := Format('%d条', [MoreBCD2INT(Buf, 12, 2)]);
      end;
  end;
end;
          
//解析类型B4
procedure TOrgFileReader.MakeOneLkjRec_B4(var Info: ROrgCommonInfo; var Buf: array of byte; Len: integer);
var
  nType: byte;
begin       
  //解析时间、公里标
  Info.Hms := GetTime(Buf, 2);
  Info.Glb := GetGLB(Buf, 5);

  //解析其它
  nType := Buf[1];
  case nType of
    $01, $02, $03, $04:
      if Len = 16 then
      begin
        if nType = $01 then Info.Disp := 'A机单机'
        else if nType = $02 then Info.Disp := 'B机单机'
        else if nType = $03 then Info.Disp := 'A主B备'
        else if nType = $04 then Info.Disp := 'A备B主';

        Info.Jl := GetJL(Buf, 9);
        Info.OTHER := m_tPreviousInfo.strSpeedGrade;
      end;
    $05, $06:
      if Len = 22 then
      begin

        if nType = $05 then Info.Disp := '主机发送控制同步'
        else if nType = $06 then Info.Disp := '主机发送揭示同步';

        Info.Jl := GetJL(Buf, 9);
        Info.OTHER := '???';
      end;
    $07:
      if Len = 21 then
      begin
        Info.Disp := '主机发送按键';
        Info.Jl := GetJL(Buf, 9);
        Info.OTHER := '???';
      end;
    $08, $09, $10, $11, $12:
      if Len = 18 then
      begin
        if nType = $08 then Info.Disp := '主机发送校正'
        else if nType = $09 then Info.Disp := '发送揭示更新'
        else if nType = $10 then Info.Disp := '主机发送支线'
        else if nType = $11 then Info.Disp := '主机发送侧线'
        else if nType = $12 then Info.Disp := '对方制动';

        Info.Jl := GetJL(Buf, 9);
        Info.OTHER := '???';
      end;
    $13:
      if Len = 34 then
      begin
        Info.Disp := '制动原因';
        Info.Jl := GetJL(Buf, 9);
        Info.OTHER := '???';
      end;
    $14:
      if Len = 15 then
      begin
        Info.Disp := '实际开关输出';
        Info.OTHER := '???';
      end;
  end;
end;

//解析类型B6，文档没有，分析补充
procedure TOrgFileReader.MakeOneLkjRec_B6(var Info: ROrgCommonInfo; var Buf: array of byte; Len: integer);
var
  nType, nByte: byte;
  intTemp: integer;
begin       
  //解析时间
  Info.Hms := GetTime(Buf, 2);
  Info.Glb := GetGLB(Buf, 5);
  Info.Jl := GetJL(Buf, 9);

  //解析其它
  nType := Buf[1];
  case nType of
    $33, $40, $41, $42, $43:
      if Len = 14 then
      begin
        if nType = $33 then Info.Disp := 'EMU通讯中断'
        else if nType = $40 then Info.Disp := 'ATP控制结束'
        else if nType = $41 then Info.Disp := 'ATP控制开始'
        else if nType = $42 then Info.Disp := '监控隔离位'
        else if nType = $43 then Info.Disp := '监控正常位';
      end;
    $35, $36, $37:
      if Len = 20 then
      begin
        if nType = $35 then Info.Disp := 'ATP速度变化'
        else if nType = $36 then Info.Disp := 'ATP限速变化'
        else if nType = $37 then Info.Disp := 'ATP目标限速变化';

        Info.Speed := GetSpeed(Buf, 12);
        Info.S_lmt := GetLimitSpeed(Buf, 14);
        intTemp := MoreBCD2INT(Buf, 16, 2);
        Info.Shuoming := Format('ATP速度：%d ATP限速：%d 目标限速:%d', [Info.Speed, Info.S_lmt, intTemp]);
      end;   
    $38:
      if Len = 15 then
      begin
        Info.Disp := 'ATP等级变化';

        nByte := BCD2INT(Buf[12]);
        if nByte = 0 then Info.Shuoming := '控制等级：CTCS0/1'
        else if nByte = 1 then Info.Shuoming := '控制等级：01(备用)'
        else if nByte = 2 then Info.Shuoming := '控制等级：CTCS2'
        else if nByte = 3 then Info.Shuoming := '控制等级：CTCS3'
        else if nByte = 4 then Info.Shuoming := '控制等级：CTCS4'
        else if nByte = 5 then Info.Shuoming := '控制等级：05(保留)'
        else if nByte = 6 then Info.Shuoming := '控制等级：06(备用)'
        else if nByte = 7 then Info.Shuoming := '控制等级：07(未知)'
        else Info.Shuoming := '';
      end;
    $39:
      if Len = 15 then
      begin
        Info.Disp := 'ATP模式变化';

        nByte := BCD2INT(Buf[12]);          
        if nByte = 0 then Info.Shuoming := '控制模式：00(未知)'
        else if nByte = 1 then Info.Shuoming := '控制模式：FS'
        else if nByte = 2 then Info.Shuoming := '控制模式：PS'
        else if nByte = 3 then Info.Shuoming := '控制模式：IS'
        else if nByte = 4 then Info.Shuoming := '控制模式：OS'
        else if nByte = 5 then Info.Shuoming := '控制模式：SH'
        else if nByte = 6 then Info.Shuoming := '控制模式：SB'
        else if nByte = 7 then Info.Shuoming := '控制模式：CS' 
        else if nByte = 8 then Info.Shuoming := '控制模式：RO'
        else if nByte = 9 then Info.Shuoming := '控制模式：CO'
        else if nByte = 10 then Info.Shuoming := '控制模式：BF'   
        else if (nByte >= 11) and (nByte <= 15) then Info.Shuoming := Format('%d(无定义)', [nByte])
        else Info.Shuoming := '';
      end;
    $50:
      if Len = 15 then
      begin
        Info.Disp := 'ATP传输状态';

        nByte := BCD2INT(Buf[12]);                 
        if nByte = 0 then Info.OTHER := 'INIT'
        else if nByte = 1 then Info.OTHER := 'FFFE_ERR'
        else if nByte = 2 then Info.OTHER := 'CRC_ERROR'
        else if nByte = 3 then Info.OTHER := 'DYN'
        else if nByte = 4 then Info.OTHER := 'MSG_LOSS'
        else if nByte = 5 then Info.OTHER := 'DELAY'
        else if nByte = 6 then Info.OTHER := 'OK'
        else if nByte = 7 then Info.OTHER := 'LOCK'
        else Info.OTHER := '备用';
      end;
    $51:
      if Len = 25 then
      begin
        Info.Disp := 'ATP应答器信息';
      end;
    $52:
      if Len = 18 then
      begin
        Info.Disp := 'ATP轨道回路编号';
        Info.Shuoming := Format('ATP速度等级：%d；当前轨道回路编号：%d', [BCD2INT(Buf[13]), MoreBCD2INT(Buf, 14, 2)]);
      end;
    $54:
      if Len = 15 then
      begin
        Info.Disp := 'ATP司机操作';

        nByte := BCD2INT(Buf[12]);
        if nByte = 0 then Info.OTHER := '备用'
        else if nByte = 5 then Info.OTHER := '下行指定'
        else if nByte = 6 then Info.OTHER := '上行指定'
        else if nByte = 7 then Info.OTHER := 'CTCS2->CTCS0切换'     
        else if nByte = 8 then Info.OTHER := 'CTCS0->CTCS2切换'
        else if nByte = 12 then Info.OTHER := '起动'
        else if nByte = 13 then Info.OTHER := '目视'
        else if nByte = 14 then Info.OTHER := '调车'  
        else if nByte = 15 then Info.OTHER := '缓解'    
        else if nByte = 16 then Info.OTHER := '预警'
        else Info.OTHER := '备用';
      end;
    $55:
      if Len = 25 then
      begin
        Info.Disp := '已过应答器';
      end;      
    $56:
      if Len = 15 then
      begin
        Info.Disp := 'ATP紧急变化';
        
        nByte := BCD2INT(Buf[12]);
        if nByte = 0 then Info.OTHER := '非动作'
        else if nByte = 1 then Info.OTHER := '动作';
      end;          
    $57:
      if Len = 15 then
      begin
        Info.Disp := 'ATP常用变化';

        nByte := BCD2INT(Buf[12]);        
        if nByte = 0 then Info.OTHER := '常用未动作'
        else if nByte = 1 then Info.OTHER := '常用1动作'
        else if nByte = 2 then Info.OTHER := '备用'
        else if nByte = 3 then Info.OTHER := '备用'
        else if nByte = 4 then Info.OTHER := '常用4动作'
        else if nByte = 5 then Info.OTHER := '备用'
        else if nByte = 6 then Info.OTHER := '常用7动作'
        else if nByte = 7 then Info.OTHER := '备用';
      end;       
    $58:
      if Len = 15 then
      begin
        Info.Disp := 'ATP卸载变化';
        
        nByte := BCD2INT(Buf[12]);
        if nByte = 0 then Info.OTHER := '非动作'
        else if nByte = 1 then Info.OTHER := '卸载';
      end;            
    $59:
      if Len = 17 then
      begin
        Info.Disp := 'ATP报警状态';
      end;             
    $60:
      if Len = 18 then
      begin
        Info.Disp := 'ATP目标距离';
      end;
    $64:
      if Len = 15 then
      begin
        Info.Disp := 'ATP地面故障';

        nByte := BCD2INT(Buf[12]);
        if nByte = 0 then Info.OTHER := '列车信号正常'
        else if nByte = 1 then Info.OTHER := '列车信号故障'
        else if (nByte >= 2) and (nByte <= 15) then Info.OTHER := '备用'
        else Info.OTHER := '';
      end;    
    $69:
      if Len = 15 then
      begin
        Info.Disp := 'ATP机车信号';
      end;
    $79:
      if Len = 15 then
      begin
        Info.Disp := '隔离开关状态';

        nByte := BCD2INT(Buf[12]);
        if nByte = 0 then Info.OTHER := '正常位'
        else if nByte = 1 then Info.OTHER := '隔离位';
      end;
  end;
end;
   
//解析类型B7
procedure TOrgFileReader.MakeOneLkjRec_B7(var Info: ROrgCommonInfo; var Buf: array of byte; Len: integer);
var
  nType: byte;
begin       
  //解析时间
  Info.Hms := GetTime(Buf, 2);

  //解析其它
  nType := Buf[1];
  case nType of  
    $04:
      if Len = 16 then
      begin
        Info.Disp := '过分相';
        Info.Glb := GetGLB(Buf, 5);
        Info.Jl := GetJL(Buf, 9);
        Info.OTHER := m_tPreviousInfo.strSpeedGrade;
      end;       
    $06, $07:
      if Len = 14 then
      begin
        if nType = $06 then Info.Disp := '调用反向数据'
        else if nType = $07 then Info.Disp := '退出反向数据';
        Info.Glb := GetGLB(Buf, 5);
        Info.Jl := GetJL(Buf, 9);
        Info.OTHER := m_tPreviousInfo.strSpeedGrade;
      end;
    $08:
      if Len = 9 then
      begin
        Info.Disp := '进入降级';

        Info.Glb := m_tPreviousInfo.Glb;
        Info.Xhj := m_tPreviousInfo.Xhj;
        Info.Xht_code := m_tPreviousInfo.Xht_code;
        Info.Xhj_no := m_tPreviousInfo.Xhj_no;      
        Info.Xh_code := m_tPreviousInfo.Xh_code;
        Info.Speed := m_tPreviousInfo.Speed;
        Info.Shoub := m_tPreviousInfo.Shoub;
        Info.Hand := m_tPreviousInfo.Hand;
        Info.Gya := m_tPreviousInfo.Gya;
        Info.Rota := m_tPreviousInfo.Rota;
        Info.S_lmt := m_tPreviousInfo.S_lmt;  
        Info.Jl := m_tPreviousInfo.Jl;
        Info.Gangy := m_tPreviousInfo.Gangy;
        Info.Signal := m_tPreviousInfo.Signal;     
        Info.Jg1 := m_tPreviousInfo.Jg1;
        Info.Jg2 := m_tPreviousInfo.Jg2;
        Info.JKZT := m_tPreviousInfo.JKZT;
      end;
  end;
end;

//解析类型B8
procedure TOrgFileReader.MakeOneLkjRec_B8(var Info: ROrgCommonInfo; var Buf: array of byte; Len: integer);
var
  nType, nByte: byte;
  nWord: word;
  strTemp: string;
begin       
  //解析时间
  Info.Hms := GetTime(Buf, 2);

  //解析其它
  nType := Buf[1];
  case nType of   
    $01:
      if Len = 22 then
      begin
        Info.Disp := '开车对标';
        Info.Glb := GetGLB(Buf, 5);
        Info.Jl := GetJL(Buf, 9);

        //前方机编号[3] 前方机类型[1]
        Info.Xhj_no := MoreBCD2INT(Buf, 12, 3);
        Info.Xht_code := BCD2INT(Buf[15]);
        Info.Xhj := Format('%d-%d', [m_tPreviousInfo.nDataLineID, m_tPreviousInfo.nStation]);
        Info.OTHER := m_tPreviousInfo.strSpeedGrade;
      end;          
    $02, $03, $04:
      if Len = 21 then
      begin
        if nType = $02 then Info.Disp := '车位向前'
        else if nType = $03 then Info.Disp := '车位向后'
        else if nType = $04 then Info.Disp := '车位对中';
        
        Info.Glb := GetGLB(Buf, 5);
        Info.Jl := GetJL(Buf, 9);

        //前方机编号[3] 前方机类型[1]
        strTemp := '';
        nByte := BCD2INT(Buf[15]);
        if nByte = 1 then strTemp := '进出站';
        if nByte = 2 then strTemp := '出站';
        if nByte = 3 then strTemp := '进站';
        if nByte = 4 then strTemp := '通过';
        if nByte = 5 then strTemp := '预告';
        if nByte = 6 then strTemp := '容许';
        if nByte = 7 then strTemp := '分割';
        Info.Xhj_no := MoreBCD2INT(Buf, 12, 3) mod 100000;
        Info.Xht_code := nByte;
        Info.Xhj := Format('%s%d', [strTemp, Info.Xhj_no]);

        Info.OTHER := Format('调整距离：%d', [Info.Jl]);
      end;
    $10, $11:
      if Len = 22 then
      begin
        if nType = $10 then Info.Disp := '支线选择'
        else if nType = $11 then Info.Disp := '侧线选择';
        
        Info.Glb := GetGLB(Buf, 5);
        Info.Jl := GetJL(Buf, 9);
        Info.Speed := GetSpeed(Buf, 12);
        Info.S_lmt := GetLimitSpeed(Buf, 14);

        //色灯信号
        nWord := MoreBCD2INT(Buf, 16, 2);
        Info.Signal := GetLamp(nWord);
        Info.OTHER := GetSD(nWord);
        m_tPreviousInfo.strSpeedGrade := Info.OTHER;

        Info.OTHER := IntToStr(MoreBCD2INT(Buf, 18, 2));
      end;
    $14, $15, $18:
      if Len = 20 then
      begin
        if nType = $14 then Info.Disp := '进入调车'
        else if nType = $15 then Info.Disp := '退出调车'
        else if nType = $18 then Info.Disp := '警惕键';
        
        Info.Glb := GetGLB(Buf, 5);
        Info.Jl := GetJL(Buf, 9);
        Info.Speed := GetSpeed(Buf, 12);
        Info.S_lmt := GetLimitSpeed(Buf, 14);

        //色灯信号
        nWord := MoreBCD2INT(Buf, 16, 2);
        Info.Signal := GetLamp(nWord);
        Info.OTHER := GetSD(nWord);
        m_tPreviousInfo.strSpeedGrade := Info.OTHER;
      end;         
    $19, $20, $21:
      if Len = 18 then
      begin
        if nType = $19 then Info.Disp := '前端巡检1'
        else if nType = $20 then Info.Disp := '后端巡检'
        else if nType = $21 then Info.Disp := '前端巡检2';
        
        Info.Glb := GetGLB(Buf, 5);
        Info.Jl := GetJL(Buf, 9);

        //前方机编号[3] 前方机类型[1]
        strTemp := '';
        nByte := BCD2INT(Buf[15]);
        if nByte = 1 then strTemp := '进出站';
        if nByte = 2 then strTemp := '出站';
        if nByte = 3 then strTemp := '进站';
        if nByte = 4 then strTemp := '通过';
        if nByte = 5 then strTemp := '预告';
        if nByte = 6 then strTemp := '容许';
        if nByte = 7 then strTemp := '分割';
        Info.Xhj_no := MoreBCD2INT(Buf, 12, 3) mod 100000;
        Info.Xht_code := nByte;
        Info.Xhj := Format('%s%d', [strTemp, Info.Xhj_no]);
      end;
    $16, $17, $39, $40:
      if Len = 11 then
      begin
        if nType = $16 then Info.Disp := '出段'
        else if nType = $17 then Info.Disp := '入段'
        else if nType = $39 then Info.Disp := '退出出段'
        else if nType = $40 then Info.Disp := '退出入段';

        Info.Speed := GetSpeed(Buf, 5);
        Info.S_lmt := GetLimitSpeed(Buf, 7);
        Info.OTHER := m_tPreviousInfo.strSpeedGrade;
      end;
    $27:
      if Len = 18 then
      begin
        Info.Disp := '定标键';
        Info.Glb := GetGLB(Buf, 5);
        Info.Jl := GetJL(Buf, 9);
        Info.Speed := GetSpeed(Buf, 12);
        Info.S_lmt := GetLimitSpeed(Buf, 14);
        Info.OTHER := m_tPreviousInfo.strSpeedGrade;
      end;
    $34, $35, $41:
      if Len = 14 then
      begin                   
        if nType = $34 then
        begin
          Info.Disp := 'IC卡插入';
          Info.OTHER := m_tPreviousInfo.strSpeedGrade;
        end
        else if nType = $35 then Info.Disp := 'IC卡拔出'
        else if nType = $41 then Info.Disp := '参数确认';
        
        Info.Glb := GetGLB(Buf, 5);
        Info.Jl := GetJL(Buf, 9);
      end;
  end;
end;
       
//解析类型BE
procedure TOrgFileReader.MakeOneLkjRec_BE(var Info: ROrgCommonInfo; var Buf: array of byte; Len: integer);
var
  nType: byte;
begin       
  //解析时间
  Info.Hms := GetTime(Buf, 2);

  //解析其它
  nType := Buf[1];
  case nType of
    $02:
      if Len = 13 then
      begin
        Info.Disp := '各通道速度';
        Info.OTHER := Format('v0=5,v1=5,v2=5', [MoreBCD2INT(Buf, 5, 2), MoreBCD2INT(Buf, 7, 2), MoreBCD2INT(Buf, 9, 2)]);
        Info.Shuoming := Info.OTHER;
      end;
  end;
end;
     
//解析类型DA
procedure TOrgFileReader.MakeOneLkjRec_DA(var Info: ROrgCommonInfo; var Buf: array of byte; Len: integer);
var
  nType, nByte: byte;
  strTemp: string;
begin       
  //解析时间
  Info.Hms := GetTime(Buf, 2);
  Info.Glb := GetGLB(Buf, 5);
  Info.Jl := GetJL(Buf, 9);

  //解析其它
  nType := Buf[1];
  case nType of
    $01:
      if Len = 20 then
      begin
        Info.Disp := '工务线路信息';
        Info.OTHER := m_tPreviousInfo.strSpeedGrade;
                                            
        strTemp := '';
        nByte := BCD2INT(Buf[15]) and $0F;
        if (nByte and $03) = $00 then strTemp := strTemp + '方向-0；'
        else if (nByte and $03) = $01 then strTemp := strTemp + '下行；'
        else if (nByte and $03) = $02 then strTemp := strTemp + '上行；'
        else if (nByte and $03) = $03 then strTemp := strTemp + '上下行；';
        if (nByte and $04) = $04 then strTemp := strTemp + '三线；'
        else strTemp := strTemp + '主线；';
        if (nByte and $08) = $08 then strTemp := strTemp + '反向'
        else strTemp := strTemp + '正向';
        Info.Shuoming := Format('工务线路号: %d;  %s;  重复公里标序号：%d', [MoreBCD2INT(Buf, 12, 3), strTemp, BCD2INT(Buf[16])]);

        nByte := BCD2INT(Buf[17]);
        if nByte = 1 then Info.Shuoming := Info.Shuoming + ';  长链标志a';
      end;   
    $03:
      if Len = 19 then
      begin
        Info.Disp := '机车信号序号';
        
        Info.Speed := GetSpeed(Buf, 12);
        Info.S_lmt := GetLimitSpeed(Buf, 14);
        Info.OTHER := m_tPreviousInfo.strSpeedGrade;
                                 
        strTemp := '';
        nByte := BCD2INT(Buf[16]);
        if nByte = 1 then strTemp := '信号序号；L3码'
        else if nByte = 2 then strTemp := '信号序号；L2码'
        else if nByte = 3 then strTemp := '信号序号；L码'
        else if nByte = 4 then strTemp := '信号序号；LU码'
        else if nByte = 5 then strTemp := '信号序号；LU2码'
        else if nByte = 6 then strTemp := '信号序号；U码'
        else if nByte = 7 then strTemp := '信号序号；U2S码'
        else if nByte = 8 then strTemp := '信号序号；U2码'
        else if nByte = 9 then strTemp := '信号序号；U3码'
        else strTemp := Format('信号序号；%d', [nByte]);
        Info.Shuoming := strTemp;
      end;
  end;
end;

//定长记录
procedure TOrgFileReader.MakeOneLkjRec_F0(var Info: ROrgCommonInfo; var Buf: array of byte; Len: integer);
begin
  if Len <> 13 then exit;

  //解析赋值
  Info.Speed := GetSpeed(Buf, 1);
  Info.S_lmt := GetLimitSpeed(Buf, 3);
  Info.Gya := GetLieGuanPressure(Buf, 5);
  Info.Gangy := GetGangPressure(Buf, 7);
  Info.Rota := MoreBCD2INT(Buf, 9, 2);
end;

//定长记录
procedure TOrgFileReader.MakeOneLkjRec_F1(var Info: ROrgCommonInfo; var Buf: array of byte; Len: integer);
begin
  if Len <> 15 then exit;

  //解析赋值
  Info.Speed := GetSpeed(Buf, 1);
  Info.S_lmt := GetLimitSpeed(Buf, 3);
  Info.Gya := GetLieGuanPressure(Buf, 5);
  Info.Gangy := GetGangPressure(Buf, 7);
  //Info.Rota := MoreBCD2INT(Buf, 9, 2); //电流，思维分析软件中，此内容未处理显示
  //MoreBCD2INT(Buf, 11, 2); //电压
end;

//车站号
procedure TOrgFileReader.MakeOneLkjRec_BA02(var Info: ROrgCommonInfo; var Buf: array of byte; Len: integer);
begin
  if Len <> 14 then exit;
  
  //解析赋值
  m_tPreviousInfo.nDataLineID := BCD2INT(Buf[7]);
  m_tPreviousInfo.nStation := MoreBCD2INT(Buf, 8, 2);
  Info.OTHER := Format('%d %d-%d', [m_tPreviousInfo.nStation, m_tPreviousInfo.nDataLineID, m_tPreviousInfo.nStation]);

  //特别处理进站信号机
  if (Info.Disp = '进站') then
  begin
    Info.Xhj := Format('%d-%d', [m_tPreviousInfo.nDataLineID, m_tPreviousInfo.nStation]);
    m_tPreviousInfo.Xhj := Info.Xhj;
  end;
  if (Info.Disp = '进出站') then
  begin
    Info.Xhj := Format('%d-%d', [m_tPreviousInfo.nDataLineID, m_tPreviousInfo.nStation]);
  end;
end;

end.
