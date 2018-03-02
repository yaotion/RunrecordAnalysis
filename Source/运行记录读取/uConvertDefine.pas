unit uConvertDefine;

interface
uses
  Classes,uVSConst,uLKJRuntimeFile,SysUtils,Windows;
type
  ////////////////////////////////////////////////////////////////////////////////
  ///TFieldConvert�ֶ�ת���࣬���ֶε���ʾ�ַ���ת��Ϊ��Ӧ���͵�ֵ
  ////////////////////////////////////////////////////////////////////////////////
  TFieldConvert = class
  public
    constructor Create();
    destructor Destroy; override;
  private
    m_EventDisp : TStringList;
    {���ܣ���ʼ���¼�����}
    procedure InitEventDisp();
  public
    {���ܣ���ȡ�¼�����}
    function GetnEvent(Disp: string): Integer;
    {���ܣ���ȡ�������Ϣ}
    function GetnCoord(strCoord: string): Integer;
    {���ܣ��������Ϣת��Ϊ��ʾ�ַ���}
    function ConvertCoordToStr(nCoor: Integer): string;
    {���ܣ���ȡ��λ/�����ֱ�״̬}
    function ConvertWorkZero(bHandle : byte) : TWorkZero;
    {���ܣ���ȡǣ��/�ƶ��ֱ�״̬}
    function ConvertWorkDrag(bHandle : byte) : TWorkDrag;
    {���ܣ���ȡǰ/���ֱ�״̬}
    function ConvertHandPos(bHandle : byte) : THandPos;
    {���ܣ���ȡ�ź�״̬}
    function ConvertSignal(nSignal : byte) : TLampSign;
    {���ܣ���ȡ�źŻ�����״̬}
    function ConvertSignType(nxhj_type : byte) : TLKJSignType;
    {���ܣ���ȡ������Ϣ}
    procedure GetCheCiInfo(FieldOther: string;var CheCi:Integer;TrainHead:string);
    {���ܣ���ȡ�ͻ���������Ϣ}
    procedure GetKeHuoBenBu(FieldOther: string;var TrainType:TLKJTrainType;var BenBu:TLKJBenBu);
    {���ܣ���ȡ��س�����Ϣ}
    function  GetJkFactoryInfo(FieldOther: string): TLKJFactory;
    {���ܣ���ȡ����Ա����}
    function  GetDriverNo(FieldOther: string): Integer;
    {���ܣ���ȡ������}
    function  GetLocalID(FieldOther: string): Integer;    
    //�¼�������
    property EventDsip : TStringList read m_EventDisp;
  end;
  //////////////////////////////////////////////////////////////////////////////
  ///TStationFormat��վ������
  //////////////////////////////////////////////////////////////////////////////
  TStationFormat = class
  private
    {���ܣ���OTHER�ֶν�������·�ź�վ��}
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
  isSd: boolean;  //���Ʊ�־
begin
  Result := lsPDNone;
   { lyj 2011.8.11 ����ƽ���źŴ������¼�E5ƽ���źű仯ʱ��nSignalֵ��ԭ��������+100��������}
   if nSignal >= 100 then  //ƽ���źű仯
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
    06: Result := stNormal; //'����';
    07: Result := stNormal;  //'�ָ�';
    09: Result := stPre;     //'1Ԥ��';

    10: Result := stPre;  //'�ӽ�';
   // $80: Result := 'ƽ��';
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
  if Pos('˼ά',FieldOther) <> -1 then
  begin
    Result := sfSiWei;
  end;
  if Pos('����',FieldOther) <> -1 then
  begin
    Result := sfZhuZhou;
  end;
end;

procedure TFieldConvert.GetKeHuoBenBu(FieldOther: string;
  var TrainType: TLKJTrainType; var BenBu: TLKJBenBu);
begin
  if Pos('��',FieldOther) > 0 then
  begin
    TrainType := ttCargo;
  end;
  if Pos('��',FieldOther) > 0 then
  begin
    TrainType := ttPassenger;
  end;
  if Pos('��',FieldOther) > 0 then
  begin
    BenBu := bbBu;
  end;
  if Pos('��',FieldOther) > 0 then
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
  {$REGION '�ļ�ͷ��Ϣ'}
  m_EventDisp.Values['�ļ���ʼ'] := IntToStr(File_Headinfo_dtBegin);
  m_EventDisp.Values['���ұ�־'] := IntToStr(File_Headinfo_Factory);
  m_EventDisp.Values['�����ͻ�'] := IntToStr(File_Headinfo_KeHuo);
  m_EventDisp.Values['����'] := IntToStr(File_Headinfo_CheCi);
  m_EventDisp.Values['���ݽ�·��'] := IntToStr(File_Headinfo_DataJL);
  m_EventDisp.Values['��·��'] := IntToStr(File_Headinfo_JLH);
  m_EventDisp.Values['˾����'] := IntToStr(File_Headinfo_Driver);
  m_EventDisp.Values['��˾����'] := IntToStr(File_Headinfo_SubDriver);
  m_EventDisp.Values['����'] := IntToStr(File_Headinfo_LiangShu);
  m_EventDisp.Values['�Ƴ�'] := IntToStr(File_Headinfo_JiChang);
  m_EventDisp.Values['��¼������'] := IntToStr(File_Headinfo_TrainNo);
  m_EventDisp.Values['��¼�����ͺ�'] := IntToStr(File_Headinfo_TrainType);
  m_EventDisp.Values['��¼װ�ú�'] := IntToStr(File_Headinfo_LkjID);
  m_EventDisp.Values['����'] := IntToStr(File_Headinfo_TotalWeight);
  m_EventDisp.Values['����'] := IntToStr(File_Headinfo_ZZhong);
  m_EventDisp.Values['��վ��'] := IntToStr(File_Headinfo_StartStation);
  {$ENDREGION '�ļ�ͷ��Ϣ'}

  m_EventDisp.Values['���ٱ仯'] := IntToStr(CommonRec_Event_SpeedLmtChange);
  m_EventDisp.Values['��ʾ����'] := IntToStr(CommonRec_Event_InputReveal);
  m_EventDisp.Values['��ʾ��ѯ'] := IntToStr(CommonRec_Event_RevealQuery);
  m_EventDisp.Values['IC���γ�'] := IntToStr(CommonRec_Event_PopIC);
  m_EventDisp.Values['IC������'] := IntToStr(CommonRec_Event_PushIC);
  m_EventDisp.Values['IC����֤��'] := IntToStr(CommonRec_Event_Verify);
  m_EventDisp.Values['��ѹ�仯'] := IntToStr(CommonRec_Event_GanYChange);
  m_EventDisp.Values['բ��ѹ���仯'] := IntToStr(CommonRec_Event_GangYChange);
  m_EventDisp.Values['�����'] := IntToStr(CommonRec_Event_Pos);
  m_EventDisp.Values['����ѡ��'] := IntToStr(CommonRec_Event_CeXian);
  m_EventDisp.Values['�ź�ͻ��'] := IntToStr(CommonRec_Event_XingHaoTuBian);

  m_EventDisp.Values['����'] := IntToStr(CommonRec_Event_CuDuan);
  m_EventDisp.Values['���'] := IntToStr(CommonRec_Event_RuDuan);
  m_EventDisp.Values['�ٶȱ仯'] := IntToStr(CommonRec_Event_SpeedChange);
  m_EventDisp.Values['�����źű仯'] := IntToStr(CommonRec_Event_SignalChange);
  m_EventDisp.Values['��λ��ǰ'] := IntToStr(CommonRec_Event_TrainPosForward);
  m_EventDisp.Values['��λ���'] := IntToStr(CommonRec_Event_TrainPosBack);
  m_EventDisp.Values['��λ����'] := IntToStr(CommonRec_Event_TrainPosReset);
  m_EventDisp.Values['����У��'] := IntToStr(CommonRec_Event_GuoJiJiaoZheng);

  m_EventDisp.Values['�����ƶ�'] := IntToStr(CommonRec_Event_ChangYongBrake);
  m_EventDisp.Values['�����ƶ�'] := IntToStr(CommonRec_Event_JinJiBrake);
  m_EventDisp.Values['ж�ض���'] := IntToStr(CommonRec_Event_XieZai);
  m_EventDisp.Values['�����ͻ��'] := IntToStr(CommonRec_Event_GLBTuBian);

  m_EventDisp.Values['���״̬'] := IntToStr(CommonRec_Event_JKStateChange);
  m_EventDisp.Values['��/�̻�ȷ��'] := IntToStr(CommonRec_Event_EnsureGreenLight);
  m_EventDisp.Values['������У'] := '';
  //�汾TESTDLL
  m_EventDisp.Values['�ֱ����ﱨ����ʼ'] := IntToStr(CommonRec_Event_FangLiuStart);
  m_EventDisp.Values['�ֱ����ﱨ������'] := IntToStr(CommonRec_Event_FangLiuEnd);
  m_EventDisp.Values['��λ���ﱨ����ʼ'] := IntToStr(CommonRec_Event_FangLiuStart);
  m_EventDisp.Values['��λ���ﱨ������'] := IntToStr(CommonRec_Event_FangLiuEnd);
  m_EventDisp.Values['��ѹ���ﱨ����ʼ'] := IntToStr(CommonRec_Event_FangLiuStart);
  m_EventDisp.Values['��ѹ���ﱨ������'] := IntToStr(CommonRec_Event_FangLiuEnd);
  //�ɰ汾TESTDLL
  m_EventDisp.Values['���ﱨ����ʼ'] := IntToStr(CommonRec_Event_FangLiuStart);
  m_EventDisp.Values['���ﱨ������'] := IntToStr(CommonRec_Event_FangLiuEnd);
  m_EventDisp.Values['������'] := IntToStr(CommonRec_Event_GuoFX);
  m_EventDisp.Values['���źŻ�'] := IntToStr(CommonRec_Event_SectionSignal);
  m_EventDisp.Values['��ʱ���ٿ�ʼ'] := IntToStr(CommonRec_Event_LSXSStart);
  m_EventDisp.Values['����ʾ���'] := '';
  m_EventDisp.Values['��ʱ���ٽ���'] := IntToStr(CommonRec_Event_LSXSEnd);
  m_EventDisp.Values['�����Ա�'] := IntToStr(CommonRec_Event_DuiBiao);
  m_EventDisp.Values['��վ'] := IntToStr(CommonRec_Event_EnterStation);
  m_EventDisp.Values['��վ'] := IntToStr(CommonRec_Event_LeaveStation);
  m_EventDisp.Values['��վ����'] := '';
  m_EventDisp.Values['�ֶԿ�ת'] := IntToStr(CommonRec_Event_KongZhuan);
  m_EventDisp.Values['��ת����'] := IntToStr(CommonRec_Event_KongZhuanEnd);
  m_EventDisp.Values['��ͣͣ��'] := IntToStr(CommonRec_Event_ZiTing);
  m_EventDisp.Values['����ͣ��'] := IntToStr(CommonRec_Event_StopInRect);
  m_EventDisp.Values['���俪��'] := IntToStr(CommonRec_Event_StartInRect);
  m_EventDisp.Values['����ͣ��'] := IntToStr(CommonRec_Event_StopOutSignal);
  m_EventDisp.Values['վ��ͣ��'] := IntToStr(CommonRec_Event_StopInStation);
  m_EventDisp.Values['վ�ڿ���'] := IntToStr(CommonRec_Event_StartInStation);
  m_EventDisp.Values['���뽵��'] := IntToStr(CommonRec_Event_JinRuJiangJi);
  m_EventDisp.Values['����ͣ��'] := IntToStr(CommonRec_Event_DiaoCheStop);
  m_EventDisp.Values['��������'] := IntToStr(CommonRec_Event_DiaoCheStart);
  m_EventDisp.Values['��������'] := IntToStr(CommonRec_Event_StartInJiangJi);
  m_EventDisp.Values['����ͣ��'] := IntToStr(CommonRec_Event_StopInJiangJi);
  m_EventDisp.Values['�������'] := IntToStr(CommonRec_Event_Diaoche);
  m_EventDisp.Values['�˳�����'] := IntToStr(CommonRec_Event_DiaocheJS);
  m_EventDisp.Values['��λ��ǰ'] := IntToStr(CommonRec_Event_TrainPosForward);
  m_EventDisp.Values['��λ���'] := IntToStr(CommonRec_Event_TrainPosBack);
  m_EventDisp.Values['��λ����'] := IntToStr(CommonRec_Event_TrainPosReset);
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
