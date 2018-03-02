//****************************************
//1����������
//2�����幫ʽ���Ժ���ʱ��ʱ����
//3��������ע��
//4��������Ҫ���ظ��Ĵ���
//5����������
//****************************************
unit uRtOrgFileReader;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Registry, DB, ADODB, IniFiles, DateUtils, StrUtils,uLKJRuntimeFile,uVSConst,
  uConvertDefine,uRtFileReaderBase;

const
  NULL_VALUE_MAXINT = $8000000;   //�����ֵ���������ٶȡ����ٵ������ͱ���Ϊ��ֵʱ����ʾΪ��ֵ
  NULL_VALUE_STRING = '@';        //�����ֵ�ַ�����@�����������źŻ�������״̬���ַ����ͱ���Ϊ��ֵʱ����ʾΪ��ֵ
  NULL_VALUE_DATE = 36525;        //36525=1999-12-31�������ֵ��ԭ����ת��ԭʼ�ļ��в����ܳ���1999��

type
  //Ϊ�˺�TmpTest.Ado���ݣ���uLKJRuntimeFile�е�RCommonRec���ݣ��ض���˼�¼
  ROrgCommonInfo = record
    //���º�TmpTest.Ado���ݣ������������ֶ���һ��
    Rec: Integer;             //ȫ�̼�¼�к�
    Disp: string;             //�¼��������ص㿼��
    Hms: string;              //=ʱ���룬�ص㿼��
    Glb: Integer;             //=�����
    Xhj: string;              //=�źŻ�
    Xht_code: Integer;        //=�źŻ�����
    Xhj_no: Integer;          //=�źŻ����6244
    Xh_code: Integer;         //=�źţ�ɫ�ƻ�ƽ���źţ�
    Speed: Integer;           //=�ٶ�
    Shoub: Integer;           //=�ֱ�״̬���빤��״̬ȡͬһֵ��
    Hand: string;             //=����״̬
    Gya: Integer;             //=��ѹ
    Rota: Integer;            //=ת�٣�������
    S_lmt: Integer;           //=����
    Jl: Integer;              //=����
    Gangy: Integer;           //=բѹ����ѹ��
    OTHER: string;            //����
    Signal: string;           //=�źţ�ɫ�ƻ�ƽ���źţ�
    Shuoming: string;
    Jg1: Integer;             //=����1
    Jg2: Integer;             //=����2
    JKZT: Integer;            //=

    //���º�uLKJRuntimeFile�е�RCommonRec���ݣ����岿�ֱ���
    nJKLineID: Integer;           //��ǰ��·��
    nDataLineID: Integer;         //��ǰ���ݽ�·��
    nStation : Integer;           //��ǰ��վ��

    //����Ϊ�����㣬�Լ�����ʹ�õı���
    strSpeedGrade: string;        //�ٶȵȼ�
    dtEventDate: TDateTime;       //�¼���������
  end;

type
  TOrgFileReader = class(TRunTimeFileReaderBase)
  public
    constructor Create;
    destructor Destroy; override;
  private  
    m_tPreviousInfo: ROrgCommonInfo; //�������µ�ROrgCommonInfo�������ݣ��Ա������������¼���ֵ�ֶθ�ֵ
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
    procedure ReadHeadInfo(var Head: RLKJRTFileHeadInfo; var Buf: array of byte; Len: integer); //���ļ�ͷ��Ϣ

    //��ʼ��RCommonInfo
    procedure InitCommonInfo(var Info: ROrgCommonInfo);
    //����RCommonInfo
    procedure AdjustCommonInfo(var Info: ROrgCommonInfo);
    //���ݵ�ǰRCommonInfo���������µ�RCommonInfo��������
    procedure MakePreviousInfo(var Info: ROrgCommonInfo; nType: byte);

    function GetLamp(nWord: word): string;    
    function GetLampType(strLamp: string): TLampSign;
    function GetXhjType(nxhj_type: byte): TLKJSignType;
    function GetSD(nWord: word): string;
    function GetInfo_GK(nType: byte): string;
    //���ܣ�����������ݣ�ȷ����ǰʹ�õ�Ϊ��һ������
    procedure DealWithJgNumber(LkjFile:TLKJRuntimeFile); 
    //���ܣ�����λ������¼
    procedure DealWithPosChance(LkjFile:TLKJRuntimeFile);
  protected
    function IsShowExceptInfo(nEvent, nEvent2: byte): boolean;
    procedure DealOneFileInfo(var Info: ROrgCommonInfo; Buf: array of byte; Len: integer);
  private
    {$REGION '��¼������'}
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
    {$ENDREGION '��¼������'}

  public
    {���ܣ���ȡԭʼ���м�¼�ļ���д��TLKJRuntimeFile}
    procedure LoadFromFile(FileName: string; RuntimeFile: TLKJRuntimeFile);override;
    {����:���ݴ��������ȡ�ļ��Ķ�Ӧʱ��,ʹ����fmtdll}
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
                        
    //���ļ�ͷ256�ֽ�
    msJsFile.Position := 0;
    ZeroMemory(@EventHead[0], SizeOf(EventHead));
    msJsFile.ReadBuffer(EventHead[0], 256);
    if (EventHead[0] <> $B0) or (EventHead[1] <> $F0) then exit; //�ļ���־$B0F0

    ReadHeadInfo(RuntimeFile.HeadInfo, EventHead, 256);
    RuntimeFile.HeadInfo.strOrgFileName := ExtractFileName(FileName);  //ԭʼ�ļ���
    m_tPreviousInfo.nJKLineID := RuntimeFile.HeadInfo.nJKLineID; //��ؽ�·��
    m_tPreviousInfo.nDataLineID := RuntimeFile.HeadInfo.nDataLineID; //���ݽ�·��
    m_tPreviousInfo.nStation := RuntimeFile.HeadInfo.nStartStation; //��վ��x
    m_tPreviousInfo.dtEventDate := DateOf(RuntimeFile.HeadInfo.dtKCDataTime); //�¼���������

    //--------------------------------

    //���ļ��¼�
    msJsFile.Position := 256;
    while msJsFile.Position < msJsFile.Size-3 do
    begin
      msJsFile.ReadBuffer(nEvent, 1);
      if nEvent <= $99 then continue;

      //��ʼ��Info
      InitCommonInfo(Info);
      blnJoin := false;

      //��ȡ����Ϣ
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
          //���¼���$F0�ϲ���һ����ʾ
          if T[i] = $F0 then blnJoin := true;
          //���¼���$F1�ϲ���һ����ʾ
          if T[i] = $F1 then blnJoin := true;
          //���¼�$CE��$BA02�ϲ���һ����ʾ
          if nEvent = $CE then if (T[i] = $BA) and (T[i+1] = $02) then blnJoin := true;

          //��������£���һ�¼�������
          if (nEvent = $A0) and (nEvent2 = $13) then if (T[i] = $A0) and (T[i+1] = $14) then nPos := nPos + 2;

          msJsFile.Position := nPos;
          break;
        end;
                  
        nPos := nPos + 1;
        nLen := nLen + 1;
      end;

      //��������Ϣ���¼����1�ֽ�+����+δ֪1�ֽ�+У���1�ֽ�
      if nLen > 3 then DealOneFileInfo(Info, T, nLen);

      //------------------------------------------------

      //��������������¼�
      while blnJoin do
      begin
        blnJoin := false;

        //��ȡ����Ϣ
        ZeroMemory(@T[0], SizeOf(T));
        msJsFile.ReadBuffer(T[0], 1);
        nLen := 1;

        nPos := msJsFile.Position;
        nReadNum := msJsFile.Read(T[1], 64);
        for i := 1 to nReadNum do
        begin
          if T[i] > $99 then
          begin
            //���¼���$F0�ϲ���һ����ʾ
            if T[i] = $F0 then blnJoin := true;   
            //���¼���$F1�ϲ���һ����ʾ
            if T[i] = $F1 then blnJoin := true;
            //���¼�$CE��$BA02�ϲ���һ����ʾ
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

        //��������Ϣ���¼����1�ֽ�+����+δ֪1�ֽ�+У���1�ֽ�
        if Info.Disp <> '' then if nLen > 3 then DealOneFileInfo(Info, T, nLen);
      end;

      //�����¼���¼�б�
      if Info.Disp <> '' then
      begin
        AdjustCommonInfo(Info); //����Info

        //�����β�ֳ��������룬ǰһ��Ϊ����,����Ϊ�����ͻ�
        if Info.Disp = '����' then
        begin
          strTemp := Info.Shuoming;
          Info.Shuoming := '';
          Info.Rec := RuntimeFile.Records.Count+1;
          RuntimeFile.Records.Add(FileRowToLkjRec(Info));

          Info.Disp := '�����ͻ�';
          Info.OTHER := strTemp;
          Info.Rec := RuntimeFile.Records.Count+1;
          RuntimeFile.Records.Add(FileRowToLkjRec(Info));
        end
        else
        begin
          Info.Rec := RuntimeFile.Records.Count+1;
          RuntimeFile.Records.Add(FileRowToLkjRec(Info));
        end;

        //����Info�������������ʷ����FPreviousInfo
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
    //�ļ�ͷ-�յ㳵վ��
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

//���ļ�ͷ��Ϣ
procedure TOrgFileReader.ReadHeadInfo(var Head: RLKJRTFileHeadInfo; var Buf: array of byte; Len: integer);
var
  nByte: byte;
begin
  //������ֵ
  FillChar(Head, SizeOf(RLKJRTFileHeadInfo), 0);

  Head.nLocoType := MoreBCD2INT(Buf, 56, 3) and $FFFF; //�������ͺ�(DF11)����[����]
  Head.nLocoID := MoreBCD2INT(Buf, 60, 3) and $FFFF; //�������
  Head.strTrainHead := trim(chr(Buf[10])+ chr(Buf[11])+ chr(Buf[12])+ chr(Buf[13]));  //����ͷ
  Head.nTrainNo := MoreBCD2INT(Buf, 14, 3);  //���κ�
  Head.nLunJing := MoreBCD2INT(Buf, 64, 3) and $FFFF;  //�־�
  //nDistance: Integer; //���о���
  Head.nJKLineID := MoreBCD2INT(Buf, 18, 3) and $FFFF; //��·��
  Head.nDataLineID := MoreBCD2INT(Buf, 17, 1); //���ݽ�·��
  Head.nFirstDriverNO := MoreBCD2INT(Buf, 24, 4); //˾������
  Head.nSecondDriverNO := MoreBCD2INT(Buf, 28, 4); //��˾������
  Head.nStartStation := MoreBCD2INT(Buf, 21, 3) and $FFFF; //ʼ��վ
  Head.nEndStation := Head.nStartStation; //�յ�վ //LkjFile.HeadInfo.nEndStation := LkjFile.Records[LkjFile.Records.Count - 1].CommonRec.nStation;
  //nLocoJie: string[10]; //�������ڵ���Ϣ
  Head.nDeviceNo:= MoreBCD2INT(Buf, 89, 3) and $FFFF; //װ�ú�
  Head.nTotalWeight := MoreBCD2INT(Buf, 34, 3) and $FFFF; //����
  Head.nSum := MoreBCD2INT(Buf, 52, 2); //�ϼ�
  Head.nLoadWeight := MoreBCD2INT(Buf, 37, 3) and $FFFF; //����
  Head.nJKVersion := MoreBCD2INT(Buf, 78,4); //��ذ汾
  Head.nDataVersion := MoreBCD2INT(Buf, 82,4); //���ݰ汾
  Head.DTFileHeadDt := EncodeDate(2000+BCD2INT(Buf[2]), BCD2INT(Buf[3]), BCD2INT(Buf[4])) + EncodeTime(BCD2INT(Buf[5]), BCD2INT(Buf[6]), BCD2INT(Buf[7]), 0); //�ļ�ͷʱ��

  //�������
  nByte := Buf[86];
  if nByte = $53 then
    Head.Factory := sfSiWei
  else
    Head.Factory :=sfZhuZhou;

  //�����ͻ����(��,��)����[����]
  nByte := BCD2INT(Buf[9]) mod 4;
  if (nByte mod 2) = 1 then
    Head.TrainType := ttPassenger
  else
    Head.TrainType := ttCargo;
  //����������
  if (nByte div 2) = 1 then
    Head.BenBu := bbBu
  else
    Head.BenBu := bbBen;

  //nStandardPressure : Integer; //��׼��ѹ
  //nMaxLmtSpd : Integer;  //�����������

  //===HeadInfo.strOrgFileName := ExtractFileName(orgFileName);  //ԭʼ�ļ���
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
  Info.Rec := 0;                            //ȫ�̼�¼�к�
  Info.Disp := '';                          //�¼�����
  Info.Hms := NULL_VALUE_STRING;            //ʱ����
  Info.Glb := NULL_VALUE_MAXINT;            //�����
  Info.Xhj := NULL_VALUE_STRING;            //�źŻ�
  Info.Xht_code := NULL_VALUE_MAXINT;       //�źŻ�����
  Info.Xhj_no := NULL_VALUE_MAXINT;         //�źŻ����6244
  Info.Xh_code := NULL_VALUE_MAXINT;        //�źţ�ɫ�ƻ�ƽ���źţ�
  Info.Speed := NULL_VALUE_MAXINT;          //�ٶ�
  Info.Shoub := NULL_VALUE_MAXINT;          //�ֱ�״̬���빤��״̬ȡͬһֵ��
  Info.Hand := NULL_VALUE_STRING;           //����״̬
  Info.Gya := NULL_VALUE_MAXINT;            //��ѹ
  Info.Rota := NULL_VALUE_MAXINT;           //ת��
  Info.S_lmt := NULL_VALUE_MAXINT;          //�޶�
  Info.Jl := NULL_VALUE_MAXINT;             //����
  Info.Gangy := NULL_VALUE_MAXINT;          //բѹ����ѹ��
  Info.OTHER := NULL_VALUE_STRING;          //����
  Info.Signal := NULL_VALUE_STRING;         //�źţ�ɫ�ƻ�ƽ���źţ�x
  Info.Shuoming := NULL_VALUE_STRING;
  Info.Jg1 := NULL_VALUE_MAXINT;            //����1
  Info.Jg2 := NULL_VALUE_MAXINT;            //����2
  Info.JKZT := NULL_VALUE_MAXINT;           //

  Info.nJKLineID := NULL_VALUE_MAXINT;      //��ǰ��·��
  Info.nDataLineID := NULL_VALUE_MAXINT;    //��ǰ���ݽ�·��
  Info.nStation := NULL_VALUE_MAXINT;       //��ǰ��վ��

  Info.strSpeedGrade := NULL_VALUE_STRING;  //�ٶȵȼ�
  Info.dtEventDate := NULL_VALUE_DATE;      //�¼���������
end;

//����Info
procedure TOrgFileReader.AdjustCommonInfo(var Info: ROrgCommonInfo);
var
  dtNow, dtOld: TDateTime;
begin
  if Info.Hms = NULL_VALUE_STRING then Info.Hms := m_tPreviousInfo.Hms;            //ʱ����
  if Info.Glb = NULL_VALUE_MAXINT then Info.Glb := m_tPreviousInfo.Glb;             //�����
  if Info.Xhj = NULL_VALUE_STRING then Info.Xhj := m_tPreviousInfo.Xhj;            //???�źŻ�
  if Info.Xht_code = NULL_VALUE_MAXINT then Info.Xht_code := m_tPreviousInfo.Xht_code;        //???�źŻ�����
  if Info.Xhj_no = NULL_VALUE_MAXINT then Info.Xhj_no := m_tPreviousInfo.Xhj_no;          //???�źŻ����6244
  if Info.Xh_code = NULL_VALUE_MAXINT then Info.Xh_code := m_tPreviousInfo.Xh_code;         //???�źţ�ɫ�ƻ�ƽ���źţ�
  if Info.Speed = NULL_VALUE_MAXINT then Info.Speed := m_tPreviousInfo.Speed;           //�ٶ�
  if Info.Shoub = NULL_VALUE_MAXINT then Info.Shoub := m_tPreviousInfo.Shoub;           //�ֱ�״̬���빤��״̬ȡͬһֵ��
  if Info.Hand = NULL_VALUE_STRING then Info.Hand := m_tPreviousInfo.Hand;           //����״̬
  if Info.Gya = NULL_VALUE_MAXINT then Info.Gya := m_tPreviousInfo.Gya;             //��ѹ
  if Info.Rota = NULL_VALUE_MAXINT then Info.Rota := m_tPreviousInfo.Rota;            //ת��
  if Info.S_lmt = NULL_VALUE_MAXINT then Info.S_lmt := m_tPreviousInfo.S_lmt;           //�޶�
  if Info.Jl = NULL_VALUE_MAXINT then Info.Jl := m_tPreviousInfo.Jl;              //����
  if Info.Gangy = NULL_VALUE_MAXINT then Info.Gangy := m_tPreviousInfo.Gangy;           //բѹ����ѹ��
  if Info.Signal = NULL_VALUE_STRING then Info.Signal := m_tPreviousInfo.Signal;         //�źţ�ɫ�ƻ�ƽ���źţ�x
  if Info.Jg1 = NULL_VALUE_MAXINT then Info.Jg1 := m_tPreviousInfo.Jg1;             //����1
  if Info.Jg2 = NULL_VALUE_MAXINT then Info.Jg2 := m_tPreviousInfo.Jg2;             //����2
  if Info.JKZT = NULL_VALUE_MAXINT then Info.JKZT := m_tPreviousInfo.JKZT;            //

  if Info.nJKLineID = NULL_VALUE_MAXINT then Info.nJKLineID := m_tPreviousInfo.nJKLineID;   //��ؽ�·��     
  if Info.nDataLineID = NULL_VALUE_MAXINT then Info.nDataLineID := m_tPreviousInfo.nDataLineID;   //���ݽ�·��
  if Info.nStation = NULL_VALUE_MAXINT then Info.nStation := m_tPreviousInfo.nStation;   //��վ��

  //�¼���������
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

//����Info�������������ʷ����FPreviousInfo
procedure TOrgFileReader.MakePreviousInfo(var Info: ROrgCommonInfo; nType: byte);
begin
  if Info.Hms <> NULL_VALUE_STRING then m_tPreviousInfo.Hms := Info.Hms;            //ʱ����
  if Info.Glb <> NULL_VALUE_MAXINT then m_tPreviousInfo.Glb := Info.Glb;             //�����

  if nType <> $CE then
  begin
    if Info.Xhj <> NULL_VALUE_STRING then m_tPreviousInfo.Xhj := Info.Xhj;            //???�źŻ�
    if Info.Xht_code <> NULL_VALUE_MAXINT then m_tPreviousInfo.Xht_code := Info.Xht_code;        //???�źŻ�����
    if Info.Xhj_no <> NULL_VALUE_MAXINT then m_tPreviousInfo.Xhj_no := Info.Xhj_no;          //???�źŻ����6244
  end;
  
  if Info.Xh_code <> NULL_VALUE_MAXINT then m_tPreviousInfo.Xh_code := Info.Xh_code;         //???�źţ�ɫ�ƻ�ƽ���źţ�
  if Info.Speed <> NULL_VALUE_MAXINT then m_tPreviousInfo.Speed := Info.Speed;           //�ٶ�
  if Info.Shoub <> NULL_VALUE_MAXINT then m_tPreviousInfo.Shoub := Info.Shoub;           //�ֱ�״̬���빤��״̬ȡͬһֵ��
  if Info.Hand <> NULL_VALUE_STRING then m_tPreviousInfo.Hand := Info.Hand;           //����״̬
  if Info.Gya <> NULL_VALUE_MAXINT then m_tPreviousInfo.Gya := Info.Gya;             //��ѹ
  if Info.Rota <> NULL_VALUE_MAXINT then m_tPreviousInfo.Rota := Info.Rota;            //ת��
  if Info.S_lmt <> NULL_VALUE_MAXINT then m_tPreviousInfo.S_lmt := Info.S_lmt;           //�޶�
  if Info.Jl <> NULL_VALUE_MAXINT then m_tPreviousInfo.Jl := Info.Jl;              //����
  if Info.Gangy <> NULL_VALUE_MAXINT then m_tPreviousInfo.Gangy := Info.Gangy;           //բѹ����ѹ��
  if Info.Signal <> NULL_VALUE_STRING then m_tPreviousInfo.Signal := Info.Signal;         //�źţ�ɫ�ƻ�ƽ���źţ�x
  if Info.Jg1 <> NULL_VALUE_MAXINT then m_tPreviousInfo.Jg1 := Info.Jg1;             //����1
  if Info.Jg2 <> NULL_VALUE_MAXINT then m_tPreviousInfo.Jg2 := Info.Jg2;             //����2
  if Info.JKZT <> NULL_VALUE_MAXINT then m_tPreviousInfo.JKZT := Info.JKZT;            //   

  if Info.nJKLineID <> NULL_VALUE_MAXINT then m_tPreviousInfo.nJKLineID := Info.nJKLineID;   //��ؽ�·��
  if Info.nDataLineID <> NULL_VALUE_MAXINT then m_tPreviousInfo.nDataLineID := Info.nDataLineID;   //���ݽ�·��
  if Info.nStation <> NULL_VALUE_MAXINT then m_tPreviousInfo.nStation := Info.nStation;   //��վ��
           
  if Info.dtEventDate <> NULL_VALUE_DATE then m_tPreviousInfo.dtEventDate := Info.dtEventDate;   //�¼���������
end;

//�õ�ɫ������
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
    strLamp := '�̵�';
    intLampNum := intLampNum + 1;
  end;
  if (nType and $02) = $02 then
  begin
    strLamp := '�̻�';
    intLampNum := intLampNum + 1;
  end;
  if (nType and $04) = $04 then
  begin
    strLamp := '�Ƶ�';
    intLampNum := intLampNum + 1;
  end;
  if (nType and $08) = $08 then
  begin
    strLamp := '��2'; //����
    intLampNum := intLampNum + 1;
  end;
  if (nType and $10) = $10 then
  begin
    strLamp := '˫��'; //����
    intLampNum := intLampNum + 1;
  end;
  if (nType and $20) = $20 then
  begin
    strLamp := '���'; //����
    intLampNum := intLampNum + 1;
  end;
  if (nType and $40) = $40 then
  begin
    strLamp := '���';
    intLampNum := intLampNum + 1;
  end;
  if (nType and $80) = $80 then
  begin
    strLamp := '�׵�'; //Xh_code=7
    intLampNum := intLampNum + 1;
  end;

  if bSplash then if nType in [$08, $10, $20] then strLamp := strLamp + '��';  
  if intLampNum = 0 then strLamp := '���'; //Xh_code=8
  if intLampNum > 1 then strLamp := '���';

  result := strLamp;
end;

//�õ�ɫ������
function TOrgFileReader.GetLampType(strLamp: string): TLampSign;
begin
  result := lsClose;
  if strLamp = '�̵�' then result := lsGreen
  else if strLamp = '�̻�' then result := lsGreenYellow
  else if strLamp = '�Ƶ�' then result := lsYellow
  else if strLamp = '��2' then result := lsYellow2
  else if strLamp = '˫��' then result := lsDoubleYellow
  else if strLamp = '���' then result := lsRedYellow
  else if strLamp = '���' then result := lsRed
  else if strLamp = '�׵�' then result := lsWhite
  else if strLamp = '��2��' then result := lsYellow2S //����
  else if strLamp = '˫����' then result := lsDoubleYellowS //����
  else if strLamp = '�����' then result := lsRedYellowS //����
  else if strLamp = '���' then result := lsClose
  else if strLamp = '���' then result := lsMulti;
end;

function TOrgFileReader.GetXhjType(nxhj_type: byte): TLKJSignType;
begin
  case nxhj_type of
    01: Result := stInOut;
    02: Result := stOut;
    03: Result := stIn;
    04: Result := stNormal;
    05: Result := stPre;
    06: Result := stNormal; //'����';
    07: Result := stNormal;  //'�ָ�';
    09: Result := stPre;     //'1Ԥ��';

    10: Result := stPre;  //'�ӽ�';
   // $80: Result := 'ƽ��';
  else
    Result := stNone;
  end;
end;

//�õ��ٶȵȼ�
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

//�õ�������Ϣ
function TOrgFileReader.GetInfo_GK(nType: byte): string;
var
  strInfo: string;
begin
  strInfo := '';

  nType := nType and $1F;
  case nType of
    0: strInfo := '����'; //���
    1: strInfo := 'ж��';
    2: strInfo := '��ǰ'; //���
    3: strInfo := 'жǰ';
    4: strInfo := '�Ӻ�'; //���
    5: strInfo := 'ж��';
    6: strInfo := '��'; //���
    7: strInfo := 'ж  ';
    8: strInfo := '��  ǣ'; //���
    9: strInfo := 'ж  ǣ';
    10: strInfo := '��ǰǣ'; //���
    11: strInfo := 'жǰǣ';
    12: strInfo := '�Ӻ�ǣ'; //���
    13: strInfo := 'ж��ǣ';
    14: strInfo := '��ǣ'; //���
    15: strInfo := 'жǣ';
    16: strInfo := '��  ��'; //���
    17: strInfo := 'ж  ��';
    18: strInfo := '��ǰ��'; //���
    19: strInfo := 'жǰ��';
    20: strInfo := '�Ӻ���'; //���
    21: strInfo := 'ж����';
    22: strInfo := '����'; //���
    23: strInfo := 'ж��';
    24: strInfo := '��  '; //���
    25: strInfo := 'ж  ';
    26: strInfo := '��ǰ'; //���
    27: strInfo := 'жǰ';
    28: strInfo := '�Ӻ�'; //���
    29: strInfo := 'ж��';        
    30: strInfo := '����'; //���
    31: strInfo := 'ж��';
    32: strInfo := '��  '; //���
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
  
  //������֪����ʾ���¼�
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
  //���˽�β�Ĳ��Ϸ��ַ�
  n := Len - 1;
  for i := n downto 0 do
  begin
    if (Buf[i] and $0F) in [$0A..$0F] then
      Len := Len - 1
    else
      break;
  end;
  if Len <= 3 then exit;
  
  //�����¼����ͣ����ദ��
  case Buf[0] of
    $C0: MakeOneLkjRec_C0(Info, Buf, Len); //�ػ�
    $C1: MakeOneLkjRec_C1(Info, Buf, Len); //����
    $C2: MakeOneLkjRec_C2(Info, Buf, Len); //�����ͻ��
    $C3: MakeOneLkjRec_C3(Info, Buf, Len); //������
    $C4: MakeOneLkjRec_C4(Info, Buf, Len); //�����
    $C5: MakeOneLkjRec_C5(Info, Buf, Len); //������У
    $C6: MakeOneLkjRec_C6(Info, Buf, Len); //����У��
    $C7: MakeOneLkjRec_C7(Info, Buf, Len); //��վ����
    $C8: MakeOneLkjRec_C8(Info, Buf, Len); //������ʼ
    $C9: MakeOneLkjRec_C9(Info, Buf, Len); //��������
    $CA: MakeOneLkjRec_CA(Info, Buf, Len); //�ֱ����ﱨ����ʼ
    $CB: MakeOneLkjRec_CB(Info, Buf, Len); //�ֱ����ﱨ������
    $CC: MakeOneLkjRec_CC(Info, Buf, Len); //��վ���� ��վ����
    $CD: MakeOneLkjRec_CD(Info, Buf, Len); //���ڱ仯
    $CE: MakeOneLkjRec_CE(Info, Buf, Len); //���źŻ�
    $CF: MakeOneLkjRec_CF(Info, Buf, Len); //������ֹ
    $D0: MakeOneLkjRec_D0(Info, Buf, Len); //վ��ͣ��
    $D1: MakeOneLkjRec_D1(Info, Buf, Len); //վ�ڿ���
    $D7: MakeOneLkjRec_D7(Info, Buf, Len); //�־�����
    $E0: MakeOneLkjRec_E0(Info, Buf, Len); //�����źű仯
    $E3: MakeOneLkjRec_E3(Info, Buf, Len); //���������仯
    $E5: MakeOneLkjRec_E5(Info, Buf, Len); //ƽ���źű仯
    $E6: MakeOneLkjRec_E6(Info, Buf, Len); //�ٶȱ仯
    $E7: MakeOneLkjRec_E7(Info, Buf, Len); //ת�ٱ仯
    $EB: MakeOneLkjRec_EB(Info, Buf, Len); //��ѹ�仯
    $EC: MakeOneLkjRec_EC(Info, Buf, Len); //���ٱ仯
    $ED: MakeOneLkjRec_ED(Info, Buf, Len); //������¼
    $EE: MakeOneLkjRec_EE(Info, Buf, Len); //բ��ѹ���仯
    $EF: MakeOneLkjRec_EF(Info, Buf, Len); //����ѹ���仯

    $A0: MakeOneLkjRec_A0(Info, Buf, Len); //A��ģ��ͨѶ����...
    $A4: MakeOneLkjRec_A4(Info, Buf, Len); //A��ģ��ͨѶ�ָ�...
    $A8: MakeOneLkjRec_A8(Info, Buf, Len); //�����޸�...       
    $B1: MakeOneLkjRec_B1(Info, Buf, Len); //��ʾ����...
    $B4: MakeOneLkjRec_B4(Info, Buf, Len); //A��B��...
    $B6: MakeOneLkjRec_B6(Info, Buf, Len); //+++�ĵ�û�У���������  
    $B7: MakeOneLkjRec_B7(Info, Buf, Len);
    $B8: MakeOneLkjRec_B8(Info, Buf, Len);    
    $BE: MakeOneLkjRec_BE(Info, Buf, Len);
    $DA: MakeOneLkjRec_DA(Info, Buf, Len);

    //���治��������
    $BA: if Buf[1] = $02 then MakeOneLkjRec_BA02(Info, Buf, Len);  
    $F0: MakeOneLkjRec_F0(Info, Buf, Len);
    $F1: MakeOneLkjRec_F1(Info, Buf, Len);
  end;
end;
    
procedure TOrgFileReader.MakeOneLkjRec_C0(var Info: ROrgCommonInfo; var Buf: array of byte; Len: integer);
begin
  //������ֵ
  Info.Disp := '�ػ�';
  Info.Hms := GetTime(Buf, 1);
  Info.Glb := GetGLB(Buf, 4);
  Info.Jl := GetJL(Buf, 8);
  Info.OTHER := m_tPreviousInfo.strSpeedGrade;
end;

procedure TOrgFileReader.MakeOneLkjRec_C1(var Info: ROrgCommonInfo; var Buf: array of byte; Len: integer);
begin
  //������ֵ
  Info.Disp := '����';
  Info.Hms := GetTime(Buf, 1);
  Info.OTHER := m_tPreviousInfo.strSpeedGrade;

  //��������
  TryEncodeDate(2000+BCD2INT(Buf[4]), BCD2INT(Buf[5]), BCD2INT(Buf[6]), m_tPreviousInfo.dtEventDate);
end;
            
procedure TOrgFileReader.MakeOneLkjRec_C2(var Info: ROrgCommonInfo; var Buf: array of byte; Len: integer);
begin
  //������ֵ
  Info.Disp := '�����ͻ��';
  Info.Hms := GetTime(Buf, 1);
  Info.Glb := GetGLB(Buf, 4);
  Info.Jl := GetJL(Buf, 8);
  Info.OTHER := m_tPreviousInfo.strSpeedGrade;
end;

procedure TOrgFileReader.MakeOneLkjRec_C3(var Info: ROrgCommonInfo; var Buf: array of byte; Len: integer);
begin
  //������ֵ
  Info.Disp := '������';
  Info.Hms := GetTime(Buf, 1);
  Info.OTHER := m_tPreviousInfo.strSpeedGrade;
end;

procedure TOrgFileReader.MakeOneLkjRec_C4(var Info: ROrgCommonInfo; var Buf: array of byte; Len: integer);
begin
  //������ֵ
  Info.Disp := '�����';
  Info.Hms := GetTime(Buf, 1);
  Info.OTHER := m_tPreviousInfo.strSpeedGrade;
end;

procedure TOrgFileReader.MakeOneLkjRec_C5(var Info: ROrgCommonInfo; var Buf: array of byte; Len: integer);
begin
  //������ֵ
  Info.Disp := '������У';
  Info.Hms := GetTime(Buf, 1);
  Info.Glb := GetGLB(Buf, 4);
  Info.Jl := GetJL(Buf, 8);
  Info.OTHER := m_tPreviousInfo.strSpeedGrade;
end;

procedure TOrgFileReader.MakeOneLkjRec_C6(var Info: ROrgCommonInfo; var Buf: array of byte; Len: integer);
var
  intTemp: integer;
begin
  //������ֵ
  Info.Disp := '����У��';
  Info.Hms := GetTime(Buf, 1);
  Info.Glb := GetGLB(Buf, 4);
  Info.Jl := GetJL(Buf, 8);

  intTemp := MoreBCD2INT(Buf, 11, 2);
  if intTemp > 999 then intTemp := -(intTemp mod 1000);
  Info.OTHER := Format('%d', [intTemp]);
  Info.Shuoming := Format('�־�ֵ��%.01f', [MoreBCD2INT(Buf, 14, 3) / 10]);
end;

procedure TOrgFileReader.MakeOneLkjRec_C7(var Info: ROrgCommonInfo; var Buf: array of byte; Len: integer);
begin
  //������ֵ
  Info.Disp := '��վ����';
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
  //������ֵ
  Info.Disp := '������ʼ';
  Info.Hms := GetTime(Buf, 1);
  Info.Glb := GetGLB(Buf, 4);
  Info.Jl := GetJL(Buf, 8);
  Info.Speed := GetSpeed(Buf, 11);
  Info.S_lmt := GetLimitSpeed(Buf, 13);

  //ɫ���ź�
  nWord := MoreBCD2INT(Buf, 15, 2);
  Info.Signal := GetLamp(nWord);
  Info.OTHER := GetSD(nWord);
  m_tPreviousInfo.strSpeedGrade := Info.OTHER;
end;

procedure TOrgFileReader.MakeOneLkjRec_C9(var Info: ROrgCommonInfo; var Buf: array of byte; Len: integer);
var
  nWord: word;
begin
  //������ֵ
  Info.Disp := '��������';
  Info.Hms := GetTime(Buf, 1);
  Info.Glb := GetGLB(Buf, 4);
  Info.Jl := GetJL(Buf, 8);
  Info.Speed := GetSpeed(Buf, 11);
  Info.S_lmt := GetLimitSpeed(Buf, 13);

  //ɫ���ź�
  nWord := MoreBCD2INT(Buf, 15, 2);
  Info.Signal := GetLamp(nWord);
  Info.OTHER := GetSD(nWord);
  m_tPreviousInfo.strSpeedGrade := Info.OTHER;
end;
        
procedure TOrgFileReader.MakeOneLkjRec_CA(var Info: ROrgCommonInfo; var Buf: array of byte; Len: integer);
var
  nWord: word;
begin
  //������ֵ
  Info.Disp := '�ֱ����ﱨ����ʼ';
  Info.Hms := GetTime(Buf, 1);
  Info.Glb := GetGLB(Buf, 4);
  Info.Jl := GetJL(Buf, 8);
  Info.Speed := GetSpeed(Buf, 11);
  Info.S_lmt := GetLimitSpeed(Buf, 13);

  //ɫ���ź�
  nWord := MoreBCD2INT(Buf, 15, 2);
  Info.Signal := GetLamp(nWord);
  Info.OTHER := GetSD(nWord);
  m_tPreviousInfo.strSpeedGrade := Info.OTHER;
end;
     
procedure TOrgFileReader.MakeOneLkjRec_CB(var Info: ROrgCommonInfo; var Buf: array of byte; Len: integer);
var
  nWord: word;
begin
  //������ֵ
  Info.Disp := '�ֱ����ﱨ������';
  Info.Hms := GetTime(Buf, 1);
  Info.Glb := GetGLB(Buf, 4);
  Info.Jl := GetJL(Buf, 8);
  Info.Speed := GetSpeed(Buf, 11);
  Info.Speed := GetLimitSpeed(Buf, 13);

  //ɫ���ź�
  nWord := MoreBCD2INT(Buf, 15, 2);
  Info.Signal := GetLamp(nWord);
  Info.OTHER := GetSD(nWord);
  m_tPreviousInfo.strSpeedGrade := Info.OTHER;
end;

procedure TOrgFileReader.MakeOneLkjRec_CC(var Info: ROrgCommonInfo; var Buf: array of byte; Len: integer);
var
  nByte: byte;
begin
  //������ֵ
  Info.Disp := '����';
  Info.Hms := GetTime(Buf, 1);
  Info.Glb := GetGLB(Buf, 4);
  Info.Jl := GetJL(Buf, 8);
  Info.Speed := GetSpeed(Buf, 11);
  Info.S_lmt := GetLimitSpeed(Buf, 13);
  Info.OTHER := m_tPreviousInfo.strSpeedGrade;

  nByte := BCD2INT(Buf[15]);    
  if nByte = 1 then Info.Disp := '��վ����'
  else if nByte = 2 then Info.Disp := '��վ����';
end;
          
procedure TOrgFileReader.MakeOneLkjRec_CD(var Info: ROrgCommonInfo; var Buf: array of byte; Len: integer);
begin
  //������ֵ
  Info.Disp := '���ڱ仯';
  Info.Hms := GetTime(Buf, 1);

  //����
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
  //������ֵ
  Info.Disp := '���źŻ�';
  Info.Hms := GetTime(Buf, 1);
  Info.Glb := GetGLB(Buf, 4);
  Info.Jl := GetJL(Buf, 8);
  Info.Speed := GetSpeed(Buf, 11);
  Info.S_lmt := GetLimitSpeed(Buf, 13);

  //�ѹ������[3]ע48 �ѹ�������[1]ע17
  strTemp := '';
  nByte := BCD2INT(Buf[18]);
  if nByte = 1 then strTemp := '����վ'
  else if nByte = 2 then strTemp := '��վ'
  else if nByte = 3 then strTemp := '��վ'
  else if nByte = 4 then strTemp := 'ͨ��'
  else if nByte = 5 then strTemp := 'Ԥ��'
  else if nByte = 6 then strTemp := '����'
  else if nByte = 7 then strTemp := '�ָ�';
  if nByte in [1, 2, 3] then Info.Disp := strTemp;
  Info.Xhj_no := MoreBCD2INT(Buf, 15, 3) mod 100000;
  Info.Xht_code := nByte;
  Info.Xhj := Format('%s%d', [strTemp, Info.Xhj_no]);

  //ǰ�������[3] ǰ��������[1]ע17
  strTemp := '';
  nByte := BCD2INT(Buf[22]);
  if nByte = 1 then strTemp := '����վ'
  else if nByte = 2 then strTemp := '��վ'
  else if nByte = 3 then strTemp := '��վ'
  else if nByte = 4 then strTemp := 'ͨ��'
  else if nByte = 5 then strTemp := 'Ԥ��'
  else if nByte = 6 then strTemp := '����'
  else if nByte = 7 then strTemp := '�ָ�';
  m_tPreviousInfo.Xhj_no := MoreBCD2INT(Buf, 19, 3) mod 100000;
  m_tPreviousInfo.Xht_code := nByte;
  m_tPreviousInfo.Xhj := Format('%s%d', [strTemp, m_tPreviousInfo.Xhj_no]);
  
  //ɫ���ź�
  nWord := MoreBCD2INT(Buf, 23, 2);
  Info.Signal := GetLamp(nWord);
  Info.OTHER := GetSD(nWord);
  m_tPreviousInfo.strSpeedGrade := Info.OTHER;

  //�Ա�����
  if Info.Disp = '���źŻ�' then
  begin
    nByte := BCD2INT(Buf[25]);
    if nByte = 0 then Info.Shuoming := '�Ա����ͣ��Ա�'
    else if nByte = 1 then Info.Shuoming := '�Ա����ͣ����Ա�';
  end;

  //�ر����վ�źŻ�
  if (Info.Disp = '��վ') then
  begin
    Info.Xhj := Format('%d-%d', [m_tPreviousInfo.nDataLineID, m_tPreviousInfo.nStation]);
    m_tPreviousInfo.Xhj := Info.Xhj;
  end;
  if (Info.Disp = '����վ') then
  begin
    Info.Xhj := Format('%d-%d', [m_tPreviousInfo.nDataLineID, m_tPreviousInfo.nStation]);
  end;
end;
    
procedure TOrgFileReader.MakeOneLkjRec_CF(var Info: ROrgCommonInfo; var Buf: array of byte; Len: integer);
begin
  //������ֵ
  Info.Disp := '������ֹ';
  Info.Hms := GetTime(Buf, 1);
  Info.OTHER := m_tPreviousInfo.strSpeedGrade;

  //�źŻ�
  Info.Xht_code := m_tPreviousInfo.Xht_code;  
  Info.Xhj_no := m_tPreviousInfo.Xhj_no;
  Info.Xhj := Format('��վ%d', [Info.Xhj_no]);
end;

procedure TOrgFileReader.MakeOneLkjRec_D0(var Info: ROrgCommonInfo; var Buf: array of byte; Len: integer);
var
  nWord: word;
  nByte: byte;
  strTemp: string;
begin
  //������ֵ
  Info.Disp := 'ͣ��';
  Info.Hms := GetTime(Buf, 1);
  Info.Glb := GetGLB(Buf, 4);
  Info.Jl := GetJL(Buf, 8);

  //ǰ�������[3] ǰ��������[1]
  Info.Xhj_no := MoreBCD2INT(Buf, 11, 3);
  Info.Xht_code := BCD2INT(Buf[14]);

  //ɫ���ź�
  nWord := MoreBCD2INT(Buf, 15, 2);
  Info.Signal := GetLamp(nWord);
  Info.OTHER := GetSD(nWord);
  m_tPreviousInfo.strSpeedGrade := Info.OTHER;

  //����  4 20 60=վ��   10 30 50 2 6 10 12 14 18 22=����     40 00 08 16 =����
  strTemp := '';
  nByte := BCD2INT(Buf[21]) and $07;
  if nByte = 4 then strTemp := 'վ��';
  if nByte = 2 then strTemp := '����';
  if nByte = 6 then strTemp := '����';
  if nByte = 0 then strTemp := '����';

  if nByte = 1 then strTemp := '����'; //���SD1
  if nByte = 3 then strTemp := '����';
  if nByte = 5 then strTemp := '����';
  Info.Disp := strTemp + Info.Disp;
end;

procedure TOrgFileReader.MakeOneLkjRec_D1(var Info: ROrgCommonInfo; var Buf: array of byte; Len: integer);
var
  nWord: word;
  nByte: byte;
  strTemp: string;
begin
  //������ֵ
  Info.Disp := '����';
  Info.Hms := GetTime(Buf, 1);
  Info.Glb := GetGLB(Buf, 4);
  Info.Jl := GetJL(Buf, 8);
  Info.Speed := GetSpeed(Buf, 11);
  Info.S_lmt := GetLimitSpeed(Buf, 13);

  //ǰ�����[3] ǰ��������[1]
  Info.Xhj_no := MoreBCD2INT(Buf, 15, 3);
  Info.Xht_code := BCD2INT(Buf[18]);

  //ɫ���ź�
  nWord := MoreBCD2INT(Buf, 19, 2);
  Info.Signal := GetLamp(nWord);
  Info.OTHER := GetSD(nWord);
  m_tPreviousInfo.strSpeedGrade := Info.OTHER;
  
  Info.Gya := GetLieGuanPressure(Buf, 21);
  Info.Gangy := GetGangPressure(Buf, 23);

  //����  4 20 60=վ��   10 30 50 2 6 10 12 14 18 22=����     40 00 08 16 =����
  strTemp := '';
  nByte := BCD2INT(Buf[25]) and $07;
  if nByte = 4 then strTemp := 'վ��';
  if nByte = 2 then strTemp := '����';
  if nByte = 6 then strTemp := '����';
  if nByte = 0 then strTemp := '����';

  if nByte = 1 then strTemp := '����'; //���SD1
  if nByte = 3 then strTemp := '����';
  if nByte = 5 then strTemp := '����';
  Info.Disp := strTemp + Info.Disp;
  
  //�źŻ�
  //if m_tPreviousInfo.Xhj = NULL_VALUE_STRING then Info.Xhj := Format('��վ%d', [Info.Xhj_no]);
  //if (Info.Disp = 'վ�ڿ���') or (Info.Disp = '��������') then Info.Xhj := Format('��վ%d', [Info.Xhj_no]);
  if m_tPreviousInfo.Xhj = NULL_VALUE_STRING then
    if (m_tPreviousInfo.nDataLineID <> NULL_VALUE_MAXINT) and (m_tPreviousInfo.nStation <> NULL_VALUE_MAXINT) then
      Info.Xhj := Format('%d-%d', [m_tPreviousInfo.nDataLineID, m_tPreviousInfo.nStation]);
  if (Info.Disp = '��������') or (Info.Disp = '��������') then Info.Xhj := Format('��վ%d', [Info.Xhj_no]);
end;
                    
procedure TOrgFileReader.MakeOneLkjRec_D7(var Info: ROrgCommonInfo; var Buf: array of byte; Len: integer);
begin
  //������ֵ
  Info.Disp := '�־�����';
  Info.Xhj := Format('%.01f', [MoreBCD2INT(Buf, 1, 3) / 10]);
end;

procedure TOrgFileReader.MakeOneLkjRec_E0(var Info: ROrgCommonInfo; var Buf: array of byte; Len: integer);
var
  nWord: word;
begin
  //������ֵ
  Info.Disp := '�����źű仯';
  Info.Hms := GetTime(Buf, 1);
  Info.Glb := GetGLB(Buf, 4);
  Info.Jl := GetJL(Buf, 8);
  Info.Speed := GetSpeed(Buf, 11);
  Info.S_lmt := GetLimitSpeed(Buf, 13);
  Info.OTHER := m_tPreviousInfo.strSpeedGrade;

  //ɫ���ź�
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
  //������ֵ
  Info.Disp := '���������仯';
  Info.Hms := GetTime(Buf, 1);
  Info.Glb := GetGLB(Buf, 4);
  Info.Jl := GetJL(Buf, 8);
  Info.Speed := GetSpeed(Buf, 11);
  Info.S_lmt := GetLimitSpeed(Buf, 13);
  Info.OTHER := m_tPreviousInfo.strSpeedGrade;

  //???����״̬�����ĵ���һ�£��д��ܽ����
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
  //������ֵ
  Info.Disp := '�������Ա仯';
  Info.Hms := GetTime(Buf, 1);
  Info.Glb := GetGLB(Buf, 4);
  Info.Jl := GetJL(Buf, 8);
  Info.Speed := GetSpeed(Buf, 11);
  Info.S_lmt := GetLimitSpeed(Buf, 13);

  strTemp := '';
  nByte := BCD2INT(Buf[15]);
  if nByte = 0 then strTemp := 'ƽ��0' //�޶���
  else if nByte = 1 then strTemp := 'ͣ��'
  else if nByte = 2 then strTemp := '�ƽ�'
  else if nByte = 3 then strTemp := '��'
  else if nByte = 4 then strTemp := '����'
  else if nByte = 5 then strTemp := '���'
  else if nByte = 6 then strTemp := '����'
  else if nByte = 7 then strTemp := 'ʮ��'
  else if nByte = 8 then strTemp := '�峵'
  else if nByte = 9 then strTemp := '����'
  else if nByte = 10 then strTemp := 'ǣ���Զ�'
  else if nByte = 11 then strTemp := '�շ�Ȩ'
  else if nByte = 12 then strTemp := 'ƽ��12' //�޶���
  else if nByte = 13 then strTemp := '�ƽ��Զ�'
  else if nByte = 14 then strTemp := '����ͣ��'
  else if nByte = 15 then strTemp := 'ƽ��15' //�޶���
  else if nByte = 16 then strTemp := '����ͣ��1'
  else if nByte = 17 then strTemp := '����ͣ��2'
  else if nByte = 18 then strTemp := '����ͣ��3'
  else if nByte = 19 then strTemp := '����ͣ��4'
  else if nByte = 20 then strTemp := '����ͣ��5'
  else if nByte = 21 then strTemp := '����ͣ��6'
  else if nByte = 22 then strTemp := '����ͣ��7'
  else if nByte = 23 then strTemp := '����ͣ��8'
  else if nByte = 24 then strTemp := '����1'
  else if nByte = 25 then strTemp := '����2'
  else if nByte = 26 then strTemp := '����3'
  else if nByte = 27 then strTemp := '����4'
  else if nByte = 28 then strTemp := '����5'
  else if nByte = 29 then strTemp := '����6'
  else if nByte = 30 then strTemp := '����7'
  else if nByte = 31 then strTemp := '����8'
  else if nByte = 35 then strTemp := 'һ��'
  else if nByte = 40 then strTemp := 'ƽ����ʼ'
  else if nByte = 41 then strTemp := 'ƽ������';
  if strTemp <> '' then Info.Signal := strTemp;

  if strTemp = '' then Info.Disp := ''; //===�����ã���ʽʱɾ��
end;

procedure TOrgFileReader.MakeOneLkjRec_E6(var Info: ROrgCommonInfo; var Buf: array of byte; Len: integer);
begin
  //������ֵ
  Info.Disp := '�ٶȱ仯';
  Info.Hms := GetTime(Buf, 1);
  Info.Glb := GetGLB(Buf, 4);
  Info.Jl := GetJL(Buf, 8);
  Info.Speed := GetSpeed(Buf, 11);
  Info.S_lmt := GetLimitSpeed(Buf, 13);
  Info.OTHER := m_tPreviousInfo.strSpeedGrade;
end;

procedure TOrgFileReader.MakeOneLkjRec_E7(var Info: ROrgCommonInfo; var Buf: array of byte; Len: integer);
begin
  //������ֵ
  Info.Disp := 'ת�ٱ仯';
  Info.Hms := GetTime(Buf, 1);
  Info.Glb := GetGLB(Buf, 4);
  Info.Jl := GetJL(Buf, 8);
  Info.Rota := MoreBCD2INT(Buf, 11, 2);
end;

procedure TOrgFileReader.MakeOneLkjRec_EB(var Info: ROrgCommonInfo; var Buf: array of byte; Len: integer);
begin
  //������ֵ
  Info.Disp := '��ѹ�仯';
  Info.Hms := GetTime(Buf, 1);
  Info.Glb := GetGLB(Buf, 4);
  Info.Jl := GetJL(Buf, 8);
  Info.Gya := GetLieGuanPressure(Buf, 11);
  Info.OTHER := m_tPreviousInfo.strSpeedGrade;
end;

procedure TOrgFileReader.MakeOneLkjRec_EC(var Info: ROrgCommonInfo; var Buf: array of byte; Len: integer);
begin
  //������ֵ
  Info.Disp := '���ٱ仯';
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
  //������ֵ
  Info.Disp := '������¼';
  Info.Hms := GetTime(Buf, 1);
  Info.Glb := GetGLB(Buf, 4);
  Info.Jl := GetJL(Buf, 8);
  Info.Speed := GetSpeed(Buf, 11);
  Info.S_lmt := GetLimitSpeed(Buf, 13);

  //ɫ���ź�
  nWord := MoreBCD2INT(Buf, 15, 2);
  Info.Signal := GetLamp(nWord);
  Info.OTHER := GetSD(nWord);
  m_tPreviousInfo.strSpeedGrade := Info.OTHER;

  //???����״̬�����ĵ���һ�£��д��ܽ����
  nWord := MoreBCD2INT(Buf, 17, 2);
  nByte := nWord and $FF;
  Info.Shoub := nByte;
  Info.Hand := GetInfo_GK(nByte and $1F);

  Info.Gya := GetLieGuanPressure(Buf, 19);
  Info.Gangy := GetGangPressure(Buf, 21);
  //Info.Jg1 := MoreBCD2INT(Buf, 23, 2); //˼ά��������У�������δ������ʾ
  //Info.Jg2 := MoreBCD2INT(Buf, 25, 2); //˼ά��������У�������δ������ʾ
  Info.Rota := MoreBCD2INT(Buf, 35, 2);
end;

procedure TOrgFileReader.MakeOneLkjRec_EE(var Info: ROrgCommonInfo; var Buf: array of byte; Len: integer);
begin
  //������ֵ
  Info.Disp := 'բ��ѹ���仯';
  Info.Hms := GetTime(Buf, 1);
  Info.Glb := GetGLB(Buf, 4);
  Info.Jl := GetJL(Buf, 8);
  Info.Gangy := GetGangPressure(Buf, 11);
  Info.OTHER := m_tPreviousInfo.strSpeedGrade;
end;
        
procedure TOrgFileReader.MakeOneLkjRec_EF(var Info: ROrgCommonInfo; var Buf: array of byte; Len: integer);
begin
  //������ֵ
  Info.Disp := '����ѹ���仯';
  Info.Hms := GetTime(Buf, 1);
  Info.Glb := GetGLB(Buf, 4);
  Info.Jl := GetJL(Buf, 8);
  Info.Jg1 := MoreBCD2INT(Buf, 11, 2);   
  Info.Jg2 := MoreBCD2INT(Buf, 13, 2);
  Info.OTHER := m_tPreviousInfo.strSpeedGrade;
end;

//��������A0
procedure TOrgFileReader.MakeOneLkjRec_A0(var Info: ROrgCommonInfo; var Buf: array of byte; Len: integer);
var
  nType, nByte: byte;
  strTemp: string;
begin       
  //����ʱ��
  Info.Hms := GetTime(Buf, 2);

  //��������
  nType := Buf[1];
  case nType of 
    $13:
      if Len = 16 then
      begin
        Info.Disp := '�ٶ�ͨ���л�';
        Info.Glb := GetGLB(Buf, 5);
        Info.Jl := GetJL(Buf, 9);
        Info.OTHER := Format('%d->%d', [BCD2INT(Buf[12]), BCD2INT(Buf[13])]);
      end;
    $14:
      if Len = 8 then
      begin
        Info.Disp := '�ٶ�ͨ����';
        Info.OTHER := IntToStr(BCD2INT(Buf[5]));
      end;       
    $26, $27:
      if Len = 15 then
      begin
        if nType = $26 then Info.Disp := 'A��������'
        else if nType = $27 then Info.Disp := 'B��������';

        Info.Glb := GetGLB(Buf, 5);
        Info.Jl := GetJL(Buf, 9);

        strTemp := '';
        nByte := BCD2INT(Buf[12]);
        if nByte = 0 then strTemp := '�̵�'
        else if nByte = 1 then strTemp := '�̻�'
        else if nByte = 2 then strTemp := '�Ƶ�'
        else if nByte = 3 then strTemp := '��2��'
        else if nByte = 4 then strTemp := '˫�Ƶ�'
        else if nByte = 5 then strTemp := '��Ƶ�'
        else if nByte = 6 then strTemp := '���'
        else if nByte = 7 then strTemp := '�׵�'
        else if nByte = 8 then strTemp := '�ٶ�0'
        else if nByte = 9 then strTemp := '�ٶ�1'
        else if nByte = 10 then strTemp := '�ٶ�2'
        else if nByte = 11 then strTemp := 'UM71��ʽ'
        else if nByte = 12 then strTemp := '��ƽ�ź�'
        else if nByte = 13 then strTemp := '����1'
        else if nByte = 14 then strTemp := '����2'
        else if nByte = 15 then strTemp := '����3';
        if strTemp <> '' then Info.Shuoming := Format('%d-%s', [nByte, strTemp])
        else Info.Shuoming := Format('����%.02xH', [nByte, strTemp]);
      end;    
    $30, $31:
      if Len = 15 then
      begin
        if nType = $30 then Info.Disp := 'A���ֳ����'
        else if nType = $31 then Info.Disp := 'B���ֳ����';
                  
        Info.Glb := GetGLB(Buf, 5);
        Info.Jl := GetJL(Buf, 9);

        strTemp := '';
        nByte := BCD2INT(Buf[12]);
        if nByte = 0 then strTemp := 'ж��'
        else if nByte = 1 then strTemp := '��ѹ'
        else if nByte = 2 then strTemp := '�ط�'
        else if nByte = 3 then strTemp := '����1'
        else if nByte = 4 then strTemp := '����2'
        else if nByte = 5 then strTemp := '����3'
        else if nByte = 6 then strTemp := '����';

        if strTemp <> '' then Info.Shuoming := Format('%d-%s', [nByte, strTemp])
        else Info.Shuoming := Format('����%.02xH', [nByte, strTemp]);
      end;
    $34, $35:
      if Len = 15 then
      begin
        if nType = $34 then Info.Disp := 'Aģ�����'
        else if nType = $35 then Info.Disp := 'Bģ�����';

        Info.Glb := GetGLB(Buf, 5);
        Info.Jl := GetJL(Buf, 9);

        strTemp := '';
        nByte := BCD2INT(Buf[12]);
        if nByte = 0 then strTemp := '��Ϣ�����A'
        else if nByte = 1 then strTemp := '��Ϣ�����B'
        else if nByte = 2 then strTemp := 'ͨѶ��A'
        else if nByte = 3 then strTemp := 'ͨѶ��B'
        else if nByte = 4 then strTemp := 'һ����ʾ��'
        else if nByte = 5 then strTemp := '������ʾ��'
        else if nByte = 6 then strTemp := '��ϻ��'
        else if nByte = 7 then strTemp := '���л����ź�'
        else if nByte = 8 then strTemp := '��չͨ�Ű�A'
        else if nByte = 9 then strTemp := '��չͨ�Ű�B'
        else if nByte = 10 then strTemp := '��������';

        if strTemp <> '' then Info.Shuoming := Format('%d-%s', [nByte, strTemp])
        else Info.Shuoming := Format('����%.02xH', [nByte, strTemp]);
      end;
  end;
end;
            
//��������A4
procedure TOrgFileReader.MakeOneLkjRec_A4(var Info: ROrgCommonInfo; var Buf: array of byte; Len: integer);
var
  nType, nByte: byte;
  strTemp: string;
begin       
  //����ʱ��
  Info.Hms := GetTime(Buf, 2);

  //��������
  nType := Buf[1];
  case nType of  
    $26, $27:
      if Len = 15 then
      begin
        if nType = $26 then Info.Disp := 'A������ָ�'
        else if nType = $27 then Info.Disp := 'B������ָ�';
                  
        Info.Glb := GetGLB(Buf, 5);
        Info.Jl := GetJL(Buf, 9);

        strTemp := '';
        nByte := BCD2INT(Buf[12]);
        if nByte = 0 then strTemp := '�̵�'
        else if nByte = 1 then strTemp := '�̻�'
        else if nByte = 2 then strTemp := '�Ƶ�'
        else if nByte = 3 then strTemp := '��2��'
        else if nByte = 4 then strTemp := '˫�Ƶ�'
        else if nByte = 5 then strTemp := '��Ƶ�'
        else if nByte = 6 then strTemp := '���'
        else if nByte = 7 then strTemp := '�׵�'
        else if nByte = 8 then strTemp := '�ٶ�0'
        else if nByte = 9 then strTemp := '�ٶ�1'
        else if nByte = 10 then strTemp := '�ٶ�2'
        else if nByte = 11 then strTemp := 'UM71��ʽ'
        else if nByte = 12 then strTemp := '��ƽ�ź�'
        else if nByte = 13 then strTemp := '����1'
        else if nByte = 14 then strTemp := '����2'
        else if nByte = 15 then strTemp := '����3';
        if strTemp <> '' then Info.Shuoming := Format('%d-%s', [nByte, strTemp])
        else Info.Shuoming := Format('����%.02xH', [nByte, strTemp]);
      end;    
    $30, $31:
      if Len = 15 then
      begin
        if nType = $30 then Info.Disp := 'A���ֳ��ָ�'
        else if nType = $31 then Info.Disp := 'B���ֳ��ָ�';
                  
        Info.Glb := GetGLB(Buf, 5);
        Info.Jl := GetJL(Buf, 9);

        strTemp := '';
        nByte := BCD2INT(Buf[12]);
        if nByte = 0 then strTemp := 'ж��'
        else if nByte = 1 then strTemp := '��ѹ'
        else if nByte = 2 then strTemp := '�ط�'
        else if nByte = 3 then strTemp := '����1'
        else if nByte = 4 then strTemp := '����2'
        else if nByte = 5 then strTemp := '����3'
        else if nByte = 6 then strTemp := '����';

        if strTemp <> '' then Info.Shuoming := Format('%d-%s', [nByte, strTemp])
        else Info.Shuoming := Format('����%.02xH', [nByte, strTemp]);
      end;
    $34, $35:
      if Len = 15 then
      begin
        if nType = $34 then Info.Disp := 'Aģ��ָ�'
        else if nType = $35 then Info.Disp := 'Bģ��ָ�';

        Info.Glb := GetGLB(Buf, 5);
        Info.Jl := GetJL(Buf, 9);

        strTemp := '';
        nByte := BCD2INT(Buf[12]);
        if nByte = 0 then strTemp := '��Ϣ�����A'
        else if nByte = 1 then strTemp := '��Ϣ�����B'
        else if nByte = 2 then strTemp := 'ͨѶ��A'
        else if nByte = 3 then strTemp := 'ͨѶ��B'
        else if nByte = 4 then strTemp := 'һ����ʾ��'
        else if nByte = 5 then strTemp := '������ʾ��'
        else if nByte = 6 then strTemp := '��ϻ��'
        else if nByte = 7 then strTemp := '���л����ź�'
        else if nByte = 8 then strTemp := '��չͨ�Ű�A'
        else if nByte = 9 then strTemp := '��չͨ�Ű�B'
        else if nByte = 10 then strTemp := '��������';

        if strTemp <> '' then Info.Shuoming := Format('%d-%s', [nByte, strTemp])
        else Info.Shuoming := Format('����%.02xH', [nByte, strTemp]);
      end;
  end;
end;

//��������A8
procedure TOrgFileReader.MakeOneLkjRec_A8(var Info: ROrgCommonInfo; var Buf: array of byte; Len: integer);
var
  nType, nByte: byte;
  nWord: word; 
  strTemp: string;
begin       
  //����ʱ��
  Info.Hms := GetTime(Buf, 2);

  //��������
  nType := Buf[1];
  case nType of  
    $05:
      if Len = 10 then
      begin
        Info.Disp := '��·��'; //��ؽ�·��
        Info.OTHER := IntToStr(MoreBCD2INT(Buf, 5, 3));
        Info.nJKLineID := MoreBCD2INT(Buf, 5, 3);
      end;       
    $18:
      if Len = 8 then
      begin
        Info.Disp := '���ݽ�·��';
        Info.OTHER := IntToStr(BCD2INT(Buf[5]));
        m_tPreviousInfo.nDataLineID := BCD2INT(Buf[5]);
      end;
    $09, $10, $11, $12, $13, $14, $15, $17:
      if Len = 9 then
      begin
        if nType = $09 then Info.Disp := '�ͳ�'
        else if nType = $10 then Info.Disp := '�س�'
        else if nType = $11 then Info.Disp := '�ճ�'
        else if nType = $12 then Info.Disp := '�����ó�'
        else if nType = $13 then Info.Disp := '���ͳ�'
        else if nType = $14 then Info.Disp := '�س�'  
        else if nType = $15 then Info.Disp := '����'
        else if nType = $17 then Info.Disp := '��������';

        Info.OTHER := IntToStr(MoreBCD2INT(Buf, 5, 2));
      end;
    $06, $27, $29:
      if Len = 10 then
      begin
        if nType = $06 then Info.Disp := '��վ��'
        else if nType = $27 then Info.Disp := '����'
        else if nType = $29 then Info.Disp := '����';

        Info.OTHER := IntToStr(MoreBCD2INT(Buf, 5, 3));

        if Info.Disp = '��վ��' then
        begin                 
          m_tPreviousInfo.nStation := MoreBCD2INT(Buf, 5, 3);
          Info.Xhj := Format('%d-%d', [m_tPreviousInfo.nDataLineID, m_tPreviousInfo.nStation]);
        end;
      end;
    $04, $21:
      if Len = 11 then
      begin
        if nType = $21 then Info.Disp := '˾����'
        else if nType = $04 then Info.Disp := '��˾����';

        Info.OTHER := IntToStr(MoreBCD2INT(Buf, 5, 4));
      end;
    $16:
      if Len = 9 then
      begin
        Info.Disp := '�Ƴ�';
        Info.OTHER := Format('%0.1f', [MoreBCD2INT(Buf, 5, 2) / 10]);
      end;
    $20:
      if Len = 16 then
      begin
        Info.Disp := '����'; //����ǳ��Σ���ֳ�������¼
        strTemp := trim(chr(Buf[7])+ chr(Buf[8])+ chr(Buf[9])+ chr(Buf[10]));
        Info.OTHER := strTemp + IntToStr(MoreBCD2INT(Buf, 11, 3));
        //--------------------------------
        //nByte := Buf[5]; //�ͻ�����[1]
        nByte := Buf[6]; //�ͻ�����[1]
        if nByte = 0 then Info.Shuoming := '����'
        else if nByte = 1 then Info.Shuoming := '�ͱ�'
        else if nByte = 2 then Info.Shuoming := '����'
        else if nByte = 3 then Info.Shuoming := '�Ͳ�';
      end;
    $24:
      if Len = 8 then
      begin
        Info.Disp := '�����ͻ�';

        nByte := Buf[5];
        if nByte = 0 then Info.OTHER := '����'
        else if nByte = 1 then Info.OTHER := '�ͱ�'
        else if nByte = 2 then Info.OTHER := '����'
        else if nByte = 3 then Info.OTHER := '�Ͳ�';
      end;
    $43:
      if Len = 10 then
      begin
        Info.Disp := '��ײ�����仯';
        Info.OTHER := '???';
      end;
    $22, $23, $90, $91, $94, $95, $96, $97, $98, $99:
      //if Len >= 15 then
      begin
        if nType = $22 then Info.Disp := '����֧����Ч'
        else if nType = $23 then Info.Disp := '���������Ч'
        else if nType = $90 then Info.Disp := '�ϵ�װ�ú�'
        else if nType = $91 then Info.Disp := '�ϵ�����ͺ�'
        else if nType = $94 then Info.Disp := '��ʾ��1ͨ�ų�ʱ'
        else if nType = $95 then Info.Disp := '��ʾ��1ͨ�ų�ʱ�ָ�'
        else if nType = $96 then Info.Disp := '��ʾ��2ͨ�ų�ʱ'
        else if nType = $97 then Info.Disp := '��ʾ��2ͨ�ų�ʱ�ָ�'
        else if nType = $98 then Info.Disp := '��ʾ��1�汾�ű仯'
        else if nType = $99 then Info.Disp := '��ʾ��2�汾�ű仯';

        Info.OTHER := '???';
      end;
    $01, $02, $03, $28, $30, $31, $32, $34, $36, $37, $38, $39, $40, $42, $45:
      //if Len >= 15 then
      begin
        if nType = $01 then Info.Disp := '�����޸�'
        else if nType = $02 then Info.Disp := 'ʱ���޸�'
        else if nType = $03 then Info.Disp := '�־��޸�'
        else if nType = $28 then Info.Disp := '�����־��޸�'
        else if nType = $30 then Info.Disp := '�������޸�'
        else if nType = $31 then Info.Disp := 'װ�ú��޸�'
        else if nType = $32 then Info.Disp := '�����ͺ��޸�' 
        else if nType = $34 then Info.Disp := 'Ĭ�������޸�' 
        else if nType = $36 then Info.Disp := 'Ĭ�ϼƳ��޸�'
        else if nType = $37 then Info.Disp := '���������޸�'
        else if nType = $38 then Info.Disp := '����AB���޸�'
        else if nType = $39 then Info.Disp := '����������޸�'
        else if nType = $40 then Info.Disp := '�ٶȱ������޸�'
        else if nType = $42 then Info.Disp := 'GPSУʱ'
        else if nType = $45 then Info.Disp := 'Ĭ�������޸�';

        Info.OTHER := '???';
      end;
    $54: //�ĵ�û�У���������
      if Len = 9 then
      begin
        Info.Disp := '���복վ����';
        Info.OTHER := IntToStr(MoreBCD2INT(Buf, 5, 2)); //ԭʼ�洢�ļ��洢�����⣬��$06��ͳһ
      end;    
    $55: //�ĵ�û�У���������
      if Len = 24 then
      begin
        Info.Disp := '�����������';
        Info.Glb := GetGLB(Buf, 5);
        Info.Jl := GetJL(Buf, 9);
        Info.Speed := GetSpeed(Buf, 12);
        Info.S_lmt := GetLimitSpeed(Buf, 14);

        //ɫ���ź�
        nWord := MoreBCD2INT(Buf, 16, 2);
        Info.Signal := GetLamp(nWord);
        Info.OTHER := GetSD(nWord);
        m_tPreviousInfo.strSpeedGrade := Info.OTHER;

        //???����״̬ ԭʼ�ļ�û������ֽڣ�D:\�Ϻ����м�¼�ļ�\55302-10121.0629������
        Info.Hand := '???';

        Info.Shuoming := Format('ԭ�������٣�%d    �������٣�%d', [MoreBCD2INT(Buf, 18, 2), MoreBCD2INT(Buf, 20, 2)]);
      end; 
    $58: //�ĵ�û�У���������
      if Len = 19 then
      begin
        Info.Disp := 'IC����֤��';
        
        nWord := MoreBCD2INT(Buf, 5, 2);
        if nWord = 101 then Info.OTHER := '512Kδ����IC��'
        else if nWord = 102 then Info.OTHER := '2Mδ����IC��'
        else if nWord = 103 then Info.OTHER := '2M����IC��'
        else if nWord = 104 then Info.OTHER := '4M����IC��'
        else if nWord = 105 then Info.OTHER := '8M����IC��';

        nWord := MoreBCD2INT(Buf, 7, 2);     
        if nWord = 1 then strTemp := ' ������'
        else if nWord = 2 then strTemp := '˼ά��˾'
        else strTemp := 'δ֪';
        Info.Shuoming := Format('��������: %s;   �������ڣ�%d%.02d%.02d   ������ţ�%d', [strTemp, 2000+BCD2INT(Buf[11]), BCD2INT(Buf[12]), BCD2INT(Buf[13]), MoreBCD2INT(Buf, 14, 3)]);
      end;
    $87: //�ĵ�û�У���������
      if Len = 55 then
      begin
        Info.Disp := '����汾';
        Info.Shuoming := Format('���A����汾��%.02d-%.02d-%.02d��', [2000+BCD2INT(Buf[5]), BCD2INT(Buf[6]), BCD2INT(Buf[7])]);
        Info.Shuoming := Info.Shuoming + Format('���B����汾��%.02d-%.02d-%.02d��', [2000+BCD2INT(Buf[8]), BCD2INT(Buf[9]), BCD2INT(Buf[10])]);
        Info.Shuoming := Info.Shuoming + Format('���A���ݰ汾��%.02d-%.02d-%.02d��', [2000+BCD2INT(Buf[11]), BCD2INT(Buf[12]), BCD2INT(Buf[13])]);
        Info.Shuoming := Info.Shuoming + Format('���B���ݰ汾��%.02d-%.02d-%.02d��', [2000+BCD2INT(Buf[14]), BCD2INT(Buf[15]), BCD2INT(Buf[16])]);
        Info.Shuoming := Info.Shuoming + Format('A��ͨ�Ű汾��%.02d-%.02d-%.02d��', [2000+BCD2INT(Buf[17]), BCD2INT(Buf[18]), BCD2INT(Buf[19])]);
        Info.Shuoming := Info.Shuoming + Format('B��ͨ�Ű汾��%.02d-%.02d-%.02d��', [2000+BCD2INT(Buf[20]), BCD2INT(Buf[21]), BCD2INT(Buf[22])]);
        Info.Shuoming := Info.Shuoming + Format('A����չͨ�Ű汾��%.02d-%.02d-%.02d��', [2000+BCD2INT(Buf[23]), BCD2INT(Buf[24]), BCD2INT(Buf[25])]);
        Info.Shuoming := Info.Shuoming + Format('B����չͨ�Ű汾��%.02d-%.02d-%.02d��', [2000+BCD2INT(Buf[26]), BCD2INT(Buf[27]), BCD2INT(Buf[28])]);
        Info.Shuoming := Info.Shuoming + Format('A��������Ϣ�汾��%.02d-%.02d-%.02d��', [2000+BCD2INT(Buf[29]), BCD2INT(Buf[30]), BCD2INT(Buf[31])]);
        Info.Shuoming := Info.Shuoming + Format('B��������Ϣ�汾��%.02d-%.02d-%.02d��', [2000+BCD2INT(Buf[32]), BCD2INT(Buf[33]), BCD2INT(Buf[34])]);
        Info.Shuoming := Info.Shuoming + Format('���A�����汾��%.02d-%.02d-%.02d��', [2000+BCD2INT(Buf[35]), BCD2INT(Buf[36]), BCD2INT(Buf[37])]);
        Info.Shuoming := Info.Shuoming + Format('���B�����汾��%.02d-%.02d-%.02d��', [2000+BCD2INT(Buf[38]), BCD2INT(Buf[39]), BCD2INT(Buf[40])]);
      end;
  end;
end;

//��������B1
procedure TOrgFileReader.MakeOneLkjRec_B1(var Info: ROrgCommonInfo; var Buf: array of byte; Len: integer);
var
  nType, nByte: byte;
  nJSType: word;
  strTemp, strLine: string;
begin       
  //����ʱ�䡢�����
  Info.Hms := GetTime(Buf, 2);

  //��������
  nType := Buf[1];
  case nType of
    $01, $10:
      if Len = 48 then
      begin
        if nType = $01 then Info.Disp := '��ʾ����'
        else if nType = $10 then Info.Disp := '��ʾ��������';

        Info.OTHER := Format('����%d', [MoreBCD2INT(Buf, 42, 4)]);
        Info.Shuoming := Format('��ţ�%d��', [MoreBCD2INT(Buf, 5, 2)]);

        nJSType := MoreBCD2INT(Buf, 8, 2) and $FF; //��ʾ����
        if nJSType = 0 then strTemp := ''
        else if nJSType = 1 then strTemp := '��ʱ����'
        else if nJSType = 2 then strTemp := 'վ��ͣ��ÿ��'      //�ǹ���꣬��ʾTMISվ��  //�����ʾ  //�绰������ʱ
        else if nJSType = 3 then strTemp := '��վ����ÿ��'      //�ǹ���꣬��ʾTMISվ��
        else if nJSType = 4 then strTemp := '��������ÿ��'      //�ǹ���꣬��ʾTMISվ��
        else if nJSType = 5 then strTemp := '�˽�������ÿ��'
        else if nJSType = 6 then strTemp := '��ɫ���֤ÿ��'    //�ǹ���꣬��ʾTMISվ��  //�����ʾ //��ɫƾ֤��ʱ
        else if nJSType = 7 then strTemp := '�ض�����ÿ��'      //�ǹ���꣬��ʾTMISվ��  //�����ʾ
        else if nJSType = 129 then strTemp := '��ҹ����'
        else if nJSType = 130 then strTemp := 'վ��ͣ����ҹ'    //�ǹ���꣬��ʾTMISվ��  //�����ʾ  //�绰������ҹ
        else if nJSType = 131 then strTemp := '��վ������ҹ'    //�ǹ���꣬��ʾTMISվ��
        else if nJSType = 132 then strTemp := '����������ҹ'    //�ǹ���꣬��ʾTMISվ��
        else if nJSType = 133 then strTemp := '�˽���������ҹ'
        else if nJSType = 134 then strTemp := '��ɫ���֤��ҹ'  //�ǹ���꣬��ʾTMISվ��  //�����ʾ //��ɫƾ֤��ҹ
        else if nJSType = 135 then strTemp := '�ض�������ҹ'    //�ǹ���꣬��ʾTMISվ��  //�����ʾ
        else if nJSType = 30 then strTemp := 'ʩ����ʾ'
        else if nJSType = 31 then strTemp := '��Ѵ��ʾÿ��'
        else if nJSType = 32 then strTemp := '������ʾ��ʾ'
        else if nJSType = 159 then strTemp := '��Ѵ��ʾ'
        else strTemp := IntToStr(nJSType);
        Info.Shuoming := Info.Shuoming + Format('��ʾ���ͣ�%s��', [strTemp]);

        nByte := BCD2INT(Buf[14]); //������
        if nByte = 1 then strTemp := '����'
        else if nByte = 2 then strTemp := '����'
        else if nByte = 3 then strTemp := '������'
        else strTemp := 'δ֪������';
        strLine := strTemp;

        nByte := BCD2INT(Buf[13]) and $01; //����/����
        if nByte = 0 then strTemp := '����'
        else if nByte = 1 then strTemp := '����'
        else strTemp := '';
        strLine := strLine + '/' + strTemp;
                                 
        nByte := (BCD2INT(Buf[13]) div 10) and $01; //����/����
        if nByte = 0 then strTemp := '����'
        else if nByte = 1 then strTemp := '����'
        else strTemp := '';   
        strLine := strLine + '/' + strTemp;

        Info.Shuoming := Info.Shuoming + Format('��%.02d-%.02d %.02d:%.02dʼ��%.02d-%.02d %.02d:%.02dֹ��', [BCD2INT(Buf[15]), BCD2INT(Buf[16]), BCD2INT(Buf[17]), BCD2INT(Buf[18]), BCD2INT(Buf[19]), BCD2INT(Buf[20]), BCD2INT(Buf[21]), BCD2INT(Buf[22])]);
        Info.Shuoming := Info.Shuoming + Format('�����ߺ�:%d��', [MoreBCD2INT(Buf, 10, 3)]);
        Info.Shuoming := Info.Shuoming + strLine + '��';

        //�ǹ���꣬��ʾTMISվ���������ʾ��ֹ�����
        if nJSType in [2,3,4,6,7,130,131,132,134,135] then
        begin
          Info.Shuoming := Info.Shuoming + Format('TIMSվ�ţ�%d��', [MoreBCD2INT(Buf, 23, 4)]);
        end
        else
        begin
          Info.Shuoming := Info.Shuoming + Format('���귶Χ:%.03fKm -- %.03fKm��', [MoreBCD2INT(Buf, 23, 4)/1000, MoreBCD2INT(Buf, 29, 4)/1000]);
          nByte := BCD2INT(Buf[27]) and $07; //��ʼ�ظ���������
          if nByte in [0, 3, 4, 7] then Info.Shuoming := Info.Shuoming + Format('��ʼ�ظ��������ţ�%d��', [nByte*4 + BCD2INT(Buf[28])])
          else Info.Shuoming := Info.Shuoming + Format('��ʼ�ظ��������ţ������ض�%d��', [nByte*4 + BCD2INT(Buf[28])]);
          nByte := BCD2INT(Buf[33]) and $07; //�����ظ��깫������
          if nByte in [0, 3, 4, 7] then Info.Shuoming := Info.Shuoming + Format('�����ظ��깫�����ţ�%d��', [nByte*4 + BCD2INT(Buf[34])])
          else Info.Shuoming := Info.Shuoming + Format('�����ظ��깫�����ţ������ض�%d��', [nByte*4 + BCD2INT(Buf[34])]);
          Info.Shuoming := Info.Shuoming + Format('���ٳ��ȣ�%dm��', [MoreBCD2INT(Buf, 39, 3)]);
        end;
        Info.Shuoming := Info.Shuoming + Format('����:%d(��)/%d(��)', [MoreBCD2INT(Buf, 35, 2), MoreBCD2INT(Buf, 37, 2)]);
      end; 
    $02, $03, $15, $16:
      if Len = 18 then
      begin
        if nType = $02 then Info.Disp := '���ٿ�ʼ'
        else if nType = $03 then Info.Disp := '��ʾ����'
        else if nType = $15 then Info.Disp := '����ʾ���'
        else if nType = $16 then Info.Disp := '����ʾ�յ�';

        Info.Glb := GetGLB(Buf, 5);
        Info.Jl := GetJL(Buf, 9);
        Info.OTHER := Format('����%d', [MoreBCD2INT(Buf, 12, 4)]);
      end;
    $11, $12:
      if Len = 16 then
      begin
        if nType = $11 then Info.Disp := '��ʾ��ѯ'
        else if nType = $12 then Info.Disp := '��ʾ����';

        Info.Glb := GetGLB(Buf, 5);
        Info.Jl := GetJL(Buf, 9);
        Info.OTHER := Format('%d��', [MoreBCD2INT(Buf, 12, 2)]);
      end;
  end;
end;
          
//��������B4
procedure TOrgFileReader.MakeOneLkjRec_B4(var Info: ROrgCommonInfo; var Buf: array of byte; Len: integer);
var
  nType: byte;
begin       
  //����ʱ�䡢�����
  Info.Hms := GetTime(Buf, 2);
  Info.Glb := GetGLB(Buf, 5);

  //��������
  nType := Buf[1];
  case nType of
    $01, $02, $03, $04:
      if Len = 16 then
      begin
        if nType = $01 then Info.Disp := 'A������'
        else if nType = $02 then Info.Disp := 'B������'
        else if nType = $03 then Info.Disp := 'A��B��'
        else if nType = $04 then Info.Disp := 'A��B��';

        Info.Jl := GetJL(Buf, 9);
        Info.OTHER := m_tPreviousInfo.strSpeedGrade;
      end;
    $05, $06:
      if Len = 22 then
      begin

        if nType = $05 then Info.Disp := '�������Ϳ���ͬ��'
        else if nType = $06 then Info.Disp := '�������ͽ�ʾͬ��';

        Info.Jl := GetJL(Buf, 9);
        Info.OTHER := '???';
      end;
    $07:
      if Len = 21 then
      begin
        Info.Disp := '�������Ͱ���';
        Info.Jl := GetJL(Buf, 9);
        Info.OTHER := '???';
      end;
    $08, $09, $10, $11, $12:
      if Len = 18 then
      begin
        if nType = $08 then Info.Disp := '��������У��'
        else if nType = $09 then Info.Disp := '���ͽ�ʾ����'
        else if nType = $10 then Info.Disp := '��������֧��'
        else if nType = $11 then Info.Disp := '�������Ͳ���'
        else if nType = $12 then Info.Disp := '�Է��ƶ�';

        Info.Jl := GetJL(Buf, 9);
        Info.OTHER := '???';
      end;
    $13:
      if Len = 34 then
      begin
        Info.Disp := '�ƶ�ԭ��';
        Info.Jl := GetJL(Buf, 9);
        Info.OTHER := '???';
      end;
    $14:
      if Len = 15 then
      begin
        Info.Disp := 'ʵ�ʿ������';
        Info.OTHER := '???';
      end;
  end;
end;

//��������B6���ĵ�û�У���������
procedure TOrgFileReader.MakeOneLkjRec_B6(var Info: ROrgCommonInfo; var Buf: array of byte; Len: integer);
var
  nType, nByte: byte;
  intTemp: integer;
begin       
  //����ʱ��
  Info.Hms := GetTime(Buf, 2);
  Info.Glb := GetGLB(Buf, 5);
  Info.Jl := GetJL(Buf, 9);

  //��������
  nType := Buf[1];
  case nType of
    $33, $40, $41, $42, $43:
      if Len = 14 then
      begin
        if nType = $33 then Info.Disp := 'EMUͨѶ�ж�'
        else if nType = $40 then Info.Disp := 'ATP���ƽ���'
        else if nType = $41 then Info.Disp := 'ATP���ƿ�ʼ'
        else if nType = $42 then Info.Disp := '��ظ���λ'
        else if nType = $43 then Info.Disp := '�������λ';
      end;
    $35, $36, $37:
      if Len = 20 then
      begin
        if nType = $35 then Info.Disp := 'ATP�ٶȱ仯'
        else if nType = $36 then Info.Disp := 'ATP���ٱ仯'
        else if nType = $37 then Info.Disp := 'ATPĿ�����ٱ仯';

        Info.Speed := GetSpeed(Buf, 12);
        Info.S_lmt := GetLimitSpeed(Buf, 14);
        intTemp := MoreBCD2INT(Buf, 16, 2);
        Info.Shuoming := Format('ATP�ٶȣ�%d ATP���٣�%d Ŀ������:%d', [Info.Speed, Info.S_lmt, intTemp]);
      end;   
    $38:
      if Len = 15 then
      begin
        Info.Disp := 'ATP�ȼ��仯';

        nByte := BCD2INT(Buf[12]);
        if nByte = 0 then Info.Shuoming := '���Ƶȼ���CTCS0/1'
        else if nByte = 1 then Info.Shuoming := '���Ƶȼ���01(����)'
        else if nByte = 2 then Info.Shuoming := '���Ƶȼ���CTCS2'
        else if nByte = 3 then Info.Shuoming := '���Ƶȼ���CTCS3'
        else if nByte = 4 then Info.Shuoming := '���Ƶȼ���CTCS4'
        else if nByte = 5 then Info.Shuoming := '���Ƶȼ���05(����)'
        else if nByte = 6 then Info.Shuoming := '���Ƶȼ���06(����)'
        else if nByte = 7 then Info.Shuoming := '���Ƶȼ���07(δ֪)'
        else Info.Shuoming := '';
      end;
    $39:
      if Len = 15 then
      begin
        Info.Disp := 'ATPģʽ�仯';

        nByte := BCD2INT(Buf[12]);          
        if nByte = 0 then Info.Shuoming := '����ģʽ��00(δ֪)'
        else if nByte = 1 then Info.Shuoming := '����ģʽ��FS'
        else if nByte = 2 then Info.Shuoming := '����ģʽ��PS'
        else if nByte = 3 then Info.Shuoming := '����ģʽ��IS'
        else if nByte = 4 then Info.Shuoming := '����ģʽ��OS'
        else if nByte = 5 then Info.Shuoming := '����ģʽ��SH'
        else if nByte = 6 then Info.Shuoming := '����ģʽ��SB'
        else if nByte = 7 then Info.Shuoming := '����ģʽ��CS' 
        else if nByte = 8 then Info.Shuoming := '����ģʽ��RO'
        else if nByte = 9 then Info.Shuoming := '����ģʽ��CO'
        else if nByte = 10 then Info.Shuoming := '����ģʽ��BF'   
        else if (nByte >= 11) and (nByte <= 15) then Info.Shuoming := Format('%d(�޶���)', [nByte])
        else Info.Shuoming := '';
      end;
    $50:
      if Len = 15 then
      begin
        Info.Disp := 'ATP����״̬';

        nByte := BCD2INT(Buf[12]);                 
        if nByte = 0 then Info.OTHER := 'INIT'
        else if nByte = 1 then Info.OTHER := 'FFFE_ERR'
        else if nByte = 2 then Info.OTHER := 'CRC_ERROR'
        else if nByte = 3 then Info.OTHER := 'DYN'
        else if nByte = 4 then Info.OTHER := 'MSG_LOSS'
        else if nByte = 5 then Info.OTHER := 'DELAY'
        else if nByte = 6 then Info.OTHER := 'OK'
        else if nByte = 7 then Info.OTHER := 'LOCK'
        else Info.OTHER := '����';
      end;
    $51:
      if Len = 25 then
      begin
        Info.Disp := 'ATPӦ������Ϣ';
      end;
    $52:
      if Len = 18 then
      begin
        Info.Disp := 'ATP�����·���';
        Info.Shuoming := Format('ATP�ٶȵȼ���%d����ǰ�����·��ţ�%d', [BCD2INT(Buf[13]), MoreBCD2INT(Buf, 14, 2)]);
      end;
    $54:
      if Len = 15 then
      begin
        Info.Disp := 'ATP˾������';

        nByte := BCD2INT(Buf[12]);
        if nByte = 0 then Info.OTHER := '����'
        else if nByte = 5 then Info.OTHER := '����ָ��'
        else if nByte = 6 then Info.OTHER := '����ָ��'
        else if nByte = 7 then Info.OTHER := 'CTCS2->CTCS0�л�'     
        else if nByte = 8 then Info.OTHER := 'CTCS0->CTCS2�л�'
        else if nByte = 12 then Info.OTHER := '��'
        else if nByte = 13 then Info.OTHER := 'Ŀ��'
        else if nByte = 14 then Info.OTHER := '����'  
        else if nByte = 15 then Info.OTHER := '����'    
        else if nByte = 16 then Info.OTHER := 'Ԥ��'
        else Info.OTHER := '����';
      end;
    $55:
      if Len = 25 then
      begin
        Info.Disp := '�ѹ�Ӧ����';
      end;      
    $56:
      if Len = 15 then
      begin
        Info.Disp := 'ATP�����仯';
        
        nByte := BCD2INT(Buf[12]);
        if nByte = 0 then Info.OTHER := '�Ƕ���'
        else if nByte = 1 then Info.OTHER := '����';
      end;          
    $57:
      if Len = 15 then
      begin
        Info.Disp := 'ATP���ñ仯';

        nByte := BCD2INT(Buf[12]);        
        if nByte = 0 then Info.OTHER := '����δ����'
        else if nByte = 1 then Info.OTHER := '����1����'
        else if nByte = 2 then Info.OTHER := '����'
        else if nByte = 3 then Info.OTHER := '����'
        else if nByte = 4 then Info.OTHER := '����4����'
        else if nByte = 5 then Info.OTHER := '����'
        else if nByte = 6 then Info.OTHER := '����7����'
        else if nByte = 7 then Info.OTHER := '����';
      end;       
    $58:
      if Len = 15 then
      begin
        Info.Disp := 'ATPж�ر仯';
        
        nByte := BCD2INT(Buf[12]);
        if nByte = 0 then Info.OTHER := '�Ƕ���'
        else if nByte = 1 then Info.OTHER := 'ж��';
      end;            
    $59:
      if Len = 17 then
      begin
        Info.Disp := 'ATP����״̬';
      end;             
    $60:
      if Len = 18 then
      begin
        Info.Disp := 'ATPĿ�����';
      end;
    $64:
      if Len = 15 then
      begin
        Info.Disp := 'ATP�������';

        nByte := BCD2INT(Buf[12]);
        if nByte = 0 then Info.OTHER := '�г��ź�����'
        else if nByte = 1 then Info.OTHER := '�г��źŹ���'
        else if (nByte >= 2) and (nByte <= 15) then Info.OTHER := '����'
        else Info.OTHER := '';
      end;    
    $69:
      if Len = 15 then
      begin
        Info.Disp := 'ATP�����ź�';
      end;
    $79:
      if Len = 15 then
      begin
        Info.Disp := '���뿪��״̬';

        nByte := BCD2INT(Buf[12]);
        if nByte = 0 then Info.OTHER := '����λ'
        else if nByte = 1 then Info.OTHER := '����λ';
      end;
  end;
end;
   
//��������B7
procedure TOrgFileReader.MakeOneLkjRec_B7(var Info: ROrgCommonInfo; var Buf: array of byte; Len: integer);
var
  nType: byte;
begin       
  //����ʱ��
  Info.Hms := GetTime(Buf, 2);

  //��������
  nType := Buf[1];
  case nType of  
    $04:
      if Len = 16 then
      begin
        Info.Disp := '������';
        Info.Glb := GetGLB(Buf, 5);
        Info.Jl := GetJL(Buf, 9);
        Info.OTHER := m_tPreviousInfo.strSpeedGrade;
      end;       
    $06, $07:
      if Len = 14 then
      begin
        if nType = $06 then Info.Disp := '���÷�������'
        else if nType = $07 then Info.Disp := '�˳���������';
        Info.Glb := GetGLB(Buf, 5);
        Info.Jl := GetJL(Buf, 9);
        Info.OTHER := m_tPreviousInfo.strSpeedGrade;
      end;
    $08:
      if Len = 9 then
      begin
        Info.Disp := '���뽵��';

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

//��������B8
procedure TOrgFileReader.MakeOneLkjRec_B8(var Info: ROrgCommonInfo; var Buf: array of byte; Len: integer);
var
  nType, nByte: byte;
  nWord: word;
  strTemp: string;
begin       
  //����ʱ��
  Info.Hms := GetTime(Buf, 2);

  //��������
  nType := Buf[1];
  case nType of   
    $01:
      if Len = 22 then
      begin
        Info.Disp := '�����Ա�';
        Info.Glb := GetGLB(Buf, 5);
        Info.Jl := GetJL(Buf, 9);

        //ǰ�������[3] ǰ��������[1]
        Info.Xhj_no := MoreBCD2INT(Buf, 12, 3);
        Info.Xht_code := BCD2INT(Buf[15]);
        Info.Xhj := Format('%d-%d', [m_tPreviousInfo.nDataLineID, m_tPreviousInfo.nStation]);
        Info.OTHER := m_tPreviousInfo.strSpeedGrade;
      end;          
    $02, $03, $04:
      if Len = 21 then
      begin
        if nType = $02 then Info.Disp := '��λ��ǰ'
        else if nType = $03 then Info.Disp := '��λ���'
        else if nType = $04 then Info.Disp := '��λ����';
        
        Info.Glb := GetGLB(Buf, 5);
        Info.Jl := GetJL(Buf, 9);

        //ǰ�������[3] ǰ��������[1]
        strTemp := '';
        nByte := BCD2INT(Buf[15]);
        if nByte = 1 then strTemp := '����վ';
        if nByte = 2 then strTemp := '��վ';
        if nByte = 3 then strTemp := '��վ';
        if nByte = 4 then strTemp := 'ͨ��';
        if nByte = 5 then strTemp := 'Ԥ��';
        if nByte = 6 then strTemp := '����';
        if nByte = 7 then strTemp := '�ָ�';
        Info.Xhj_no := MoreBCD2INT(Buf, 12, 3) mod 100000;
        Info.Xht_code := nByte;
        Info.Xhj := Format('%s%d', [strTemp, Info.Xhj_no]);

        Info.OTHER := Format('�������룺%d', [Info.Jl]);
      end;
    $10, $11:
      if Len = 22 then
      begin
        if nType = $10 then Info.Disp := '֧��ѡ��'
        else if nType = $11 then Info.Disp := '����ѡ��';
        
        Info.Glb := GetGLB(Buf, 5);
        Info.Jl := GetJL(Buf, 9);
        Info.Speed := GetSpeed(Buf, 12);
        Info.S_lmt := GetLimitSpeed(Buf, 14);

        //ɫ���ź�
        nWord := MoreBCD2INT(Buf, 16, 2);
        Info.Signal := GetLamp(nWord);
        Info.OTHER := GetSD(nWord);
        m_tPreviousInfo.strSpeedGrade := Info.OTHER;

        Info.OTHER := IntToStr(MoreBCD2INT(Buf, 18, 2));
      end;
    $14, $15, $18:
      if Len = 20 then
      begin
        if nType = $14 then Info.Disp := '�������'
        else if nType = $15 then Info.Disp := '�˳�����'
        else if nType = $18 then Info.Disp := '�����';
        
        Info.Glb := GetGLB(Buf, 5);
        Info.Jl := GetJL(Buf, 9);
        Info.Speed := GetSpeed(Buf, 12);
        Info.S_lmt := GetLimitSpeed(Buf, 14);

        //ɫ���ź�
        nWord := MoreBCD2INT(Buf, 16, 2);
        Info.Signal := GetLamp(nWord);
        Info.OTHER := GetSD(nWord);
        m_tPreviousInfo.strSpeedGrade := Info.OTHER;
      end;         
    $19, $20, $21:
      if Len = 18 then
      begin
        if nType = $19 then Info.Disp := 'ǰ��Ѳ��1'
        else if nType = $20 then Info.Disp := '���Ѳ��'
        else if nType = $21 then Info.Disp := 'ǰ��Ѳ��2';
        
        Info.Glb := GetGLB(Buf, 5);
        Info.Jl := GetJL(Buf, 9);

        //ǰ�������[3] ǰ��������[1]
        strTemp := '';
        nByte := BCD2INT(Buf[15]);
        if nByte = 1 then strTemp := '����վ';
        if nByte = 2 then strTemp := '��վ';
        if nByte = 3 then strTemp := '��վ';
        if nByte = 4 then strTemp := 'ͨ��';
        if nByte = 5 then strTemp := 'Ԥ��';
        if nByte = 6 then strTemp := '����';
        if nByte = 7 then strTemp := '�ָ�';
        Info.Xhj_no := MoreBCD2INT(Buf, 12, 3) mod 100000;
        Info.Xht_code := nByte;
        Info.Xhj := Format('%s%d', [strTemp, Info.Xhj_no]);
      end;
    $16, $17, $39, $40:
      if Len = 11 then
      begin
        if nType = $16 then Info.Disp := '����'
        else if nType = $17 then Info.Disp := '���'
        else if nType = $39 then Info.Disp := '�˳�����'
        else if nType = $40 then Info.Disp := '�˳����';

        Info.Speed := GetSpeed(Buf, 5);
        Info.S_lmt := GetLimitSpeed(Buf, 7);
        Info.OTHER := m_tPreviousInfo.strSpeedGrade;
      end;
    $27:
      if Len = 18 then
      begin
        Info.Disp := '�����';
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
          Info.Disp := 'IC������';
          Info.OTHER := m_tPreviousInfo.strSpeedGrade;
        end
        else if nType = $35 then Info.Disp := 'IC���γ�'
        else if nType = $41 then Info.Disp := '����ȷ��';
        
        Info.Glb := GetGLB(Buf, 5);
        Info.Jl := GetJL(Buf, 9);
      end;
  end;
end;
       
//��������BE
procedure TOrgFileReader.MakeOneLkjRec_BE(var Info: ROrgCommonInfo; var Buf: array of byte; Len: integer);
var
  nType: byte;
begin       
  //����ʱ��
  Info.Hms := GetTime(Buf, 2);

  //��������
  nType := Buf[1];
  case nType of
    $02:
      if Len = 13 then
      begin
        Info.Disp := '��ͨ���ٶ�';
        Info.OTHER := Format('v0=5,v1=5,v2=5', [MoreBCD2INT(Buf, 5, 2), MoreBCD2INT(Buf, 7, 2), MoreBCD2INT(Buf, 9, 2)]);
        Info.Shuoming := Info.OTHER;
      end;
  end;
end;
     
//��������DA
procedure TOrgFileReader.MakeOneLkjRec_DA(var Info: ROrgCommonInfo; var Buf: array of byte; Len: integer);
var
  nType, nByte: byte;
  strTemp: string;
begin       
  //����ʱ��
  Info.Hms := GetTime(Buf, 2);
  Info.Glb := GetGLB(Buf, 5);
  Info.Jl := GetJL(Buf, 9);

  //��������
  nType := Buf[1];
  case nType of
    $01:
      if Len = 20 then
      begin
        Info.Disp := '������·��Ϣ';
        Info.OTHER := m_tPreviousInfo.strSpeedGrade;
                                            
        strTemp := '';
        nByte := BCD2INT(Buf[15]) and $0F;
        if (nByte and $03) = $00 then strTemp := strTemp + '����-0��'
        else if (nByte and $03) = $01 then strTemp := strTemp + '���У�'
        else if (nByte and $03) = $02 then strTemp := strTemp + '���У�'
        else if (nByte and $03) = $03 then strTemp := strTemp + '�����У�';
        if (nByte and $04) = $04 then strTemp := strTemp + '���ߣ�'
        else strTemp := strTemp + '���ߣ�';
        if (nByte and $08) = $08 then strTemp := strTemp + '����'
        else strTemp := strTemp + '����';
        Info.Shuoming := Format('������·��: %d;  %s;  �ظ��������ţ�%d', [MoreBCD2INT(Buf, 12, 3), strTemp, BCD2INT(Buf[16])]);

        nByte := BCD2INT(Buf[17]);
        if nByte = 1 then Info.Shuoming := Info.Shuoming + ';  ������־a';
      end;   
    $03:
      if Len = 19 then
      begin
        Info.Disp := '�����ź����';
        
        Info.Speed := GetSpeed(Buf, 12);
        Info.S_lmt := GetLimitSpeed(Buf, 14);
        Info.OTHER := m_tPreviousInfo.strSpeedGrade;
                                 
        strTemp := '';
        nByte := BCD2INT(Buf[16]);
        if nByte = 1 then strTemp := '�ź���ţ�L3��'
        else if nByte = 2 then strTemp := '�ź���ţ�L2��'
        else if nByte = 3 then strTemp := '�ź���ţ�L��'
        else if nByte = 4 then strTemp := '�ź���ţ�LU��'
        else if nByte = 5 then strTemp := '�ź���ţ�LU2��'
        else if nByte = 6 then strTemp := '�ź���ţ�U��'
        else if nByte = 7 then strTemp := '�ź���ţ�U2S��'
        else if nByte = 8 then strTemp := '�ź���ţ�U2��'
        else if nByte = 9 then strTemp := '�ź���ţ�U3��'
        else strTemp := Format('�ź���ţ�%d', [nByte]);
        Info.Shuoming := strTemp;
      end;
  end;
end;

//������¼
procedure TOrgFileReader.MakeOneLkjRec_F0(var Info: ROrgCommonInfo; var Buf: array of byte; Len: integer);
begin
  if Len <> 13 then exit;

  //������ֵ
  Info.Speed := GetSpeed(Buf, 1);
  Info.S_lmt := GetLimitSpeed(Buf, 3);
  Info.Gya := GetLieGuanPressure(Buf, 5);
  Info.Gangy := GetGangPressure(Buf, 7);
  Info.Rota := MoreBCD2INT(Buf, 9, 2);
end;

//������¼
procedure TOrgFileReader.MakeOneLkjRec_F1(var Info: ROrgCommonInfo; var Buf: array of byte; Len: integer);
begin
  if Len <> 15 then exit;

  //������ֵ
  Info.Speed := GetSpeed(Buf, 1);
  Info.S_lmt := GetLimitSpeed(Buf, 3);
  Info.Gya := GetLieGuanPressure(Buf, 5);
  Info.Gangy := GetGangPressure(Buf, 7);
  //Info.Rota := MoreBCD2INT(Buf, 9, 2); //������˼ά��������У�������δ������ʾ
  //MoreBCD2INT(Buf, 11, 2); //��ѹ
end;

//��վ��
procedure TOrgFileReader.MakeOneLkjRec_BA02(var Info: ROrgCommonInfo; var Buf: array of byte; Len: integer);
begin
  if Len <> 14 then exit;
  
  //������ֵ
  m_tPreviousInfo.nDataLineID := BCD2INT(Buf[7]);
  m_tPreviousInfo.nStation := MoreBCD2INT(Buf, 8, 2);
  Info.OTHER := Format('%d %d-%d', [m_tPreviousInfo.nStation, m_tPreviousInfo.nDataLineID, m_tPreviousInfo.nStation]);

  //�ر����վ�źŻ�
  if (Info.Disp = '��վ') then
  begin
    Info.Xhj := Format('%d-%d', [m_tPreviousInfo.nDataLineID, m_tPreviousInfo.nStation]);
    m_tPreviousInfo.Xhj := Info.Xhj;
  end;
  if (Info.Disp = '����վ') then
  begin
    Info.Xhj := Format('%d-%d', [m_tPreviousInfo.nDataLineID, m_tPreviousInfo.nStation]);
  end;
end;

end.
