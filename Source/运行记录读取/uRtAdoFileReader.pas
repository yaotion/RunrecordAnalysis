unit uRtAdoFileReader;

interface
uses
  Classes,ADODB,Windows,SysUtils,Math, Variants, ActiveX,DateUtils,
  uLKJRuntimeFile, uVSConst,uConvertDefine,uRtFileReaderBase;
type
  //////////////////////////////////////////////////////////////////////////////
  ///LKJRuntimeFile��ԭʼ�ļ���д��
  //////////////////////////////////////////////////////////////////////////////
  TAdoFileReader = class(TRunTimeFileReaderBase)
  public
    constructor Create();
    destructor  Destroy();override;
  public
    {����:ͨ��˼ά��ʽ����ADO�ļ������ļ���Ϣ}
    procedure LoadFromFile(orgFile : string;RuntimeFile : TLKJRuntimeFile);override;
  private
    m_FieldConvert : TFieldConvert;
    m_StationFormat : TStationFormat;
    m_Query: TADOQuery;
    //-------------------------------------------------------------------------
    //���ܣ�����ADO�ļ�
    procedure LoadAdoFile(FileName: string);
    //���ܣ�ת��ADO�ļ�һ��Ϊ TLKJCommonRec
    function DBRowToLkjRec(PreRec: TLKJCommonRec;Query: TADOQuery):TLKJCommonRec;
    //���ܣ������������ݣ���ֻ���¼� ��������Ϊ�յ�����
    procedure DealSpecailData(PreCommonRec,LKJCommonRec:TLKJCommonRec;Query: TADOQuery);
    //���ܣ�����һ������
    procedure DealNormalData(PreCommonRec,LKJCommonRec:TLKJCommonRec;Query: TADOQuery);
    //���ܣ��ж��Ƿ�Ϊ�����¼
    function IsSpecialRow(Query: TADOQuery): Boolean;
    //���ܣ�����������ݣ�ȷ����ǰʹ�õ�Ϊ��һ������
    procedure DealWithJgNumber(LkjFile:TLKJRuntimeFile);
    //���ܣ�����λ������¼
    procedure DealWithPosChance(LkjFile:TLKJRuntimeFile);
    //��ʽ����һ��վ����Ϣ
    procedure FormatToStation(LkjFile:TLKJRuntimeFile);    
  end;

  ////////////////////////////////////////////////////////////////////////////////
  ///TOrgToAdofile ���ܣ���ԭʼ�ļ�ת��ΪADO�ļ� ,����ִ��Ŀ¼�µġ�TmpTest.Ado���ļ�
  ////////////////////////////////////////////////////////////////////////////////
  TOrgToAdofile = class
  public
    {���ܣ�����fmtFile.dll��testdll.dll����TmpTest.Ado}
    procedure Execute(const orgFileName:string);
  end;
implementation


{ TAdoFileReader }

constructor TAdoFileReader.Create();
begin
  inherited Create;
  m_FieldConvert := TFieldConvert.Create;
  m_StationFormat := TStationFormat.Create;
  m_Query := TADOQuery.Create(nil);
end;

destructor TAdoFileReader.Destroy;
begin
  m_FieldConvert.Free;
  m_StationFormat.Free;
  m_Query.Free;
  inherited;
end;

procedure TAdoFileReader.LoadFromFile(orgFile: string;
  RuntimeFile: TLKJRuntimeFile);
{����:ͨ��˼ά��ʽ����ADO�ļ������ļ���Ϣ}
var
  i,tempStation,nStationIndex: Integer;
  OrgToAdofile: TOrgToAdofile;
  dt,tm : TDateTime;
  rec,preRec : TLKJCommonRec;
  bJiangji,bDiaoche : boolean;
  bInPingdiao : boolean;
begin
  OrgToAdofile := TOrgToAdofile.Create;
  try
    //��ȡͷ��Ϣ
    ReadHead(orgFile,RuntimeFile.HeadInfo);

    //����ADO�ļ�
    OrgToAdofile.Execute(orgFile);

    //����ADO����
    LoadAdoFile(ExtractFilePath(ParamStr(0))+'TmpTest.Ado');
    //��ʼ��������ݵ�����
    dt := DateOf(RuntimeFile.HeadInfo.dtKCDataTime);
    //��ʼ�������������ı�־
    bJiangji := false;
    bDiaoche := false;
    bInPingdiao := false;
    //��ʼ��������Ϣ
    tm := -1;
    tempStation := 0;
    preRec := nil;
    nStationIndex := 1;


    //ѭ��������������Ϣ
    for I := 0 to m_Query.RecordCount - 1 do
    begin
      //�������м�¼��
      rec := DBRowToLkjRec(preRec,m_Query);
      RuntimeFile.Records.Add(rec);
      rec.CommonRec.strCheCi := IntToStr(RuntimeFile.HeadInfo.nTrainNo); 
      //����վ���
      if i = 0 then
        tempStation :=  rec.CommonRec.nStation
      else begin
        preRec := RuntimeFile.Records[RuntimeFile.Records.Count - 1];
        if (rec.CommonRec.nStation <>tempStation) then
        begin
          nStationIndex := nStationIndex + 1;
          tempStation := rec.CommonRec.nStation;
        end;
      end;
      rec.CommonRec.nStationIndex := nStationIndex;
      

      //��ʽ�����м�¼�еļ��״̬��Ϣ
      if rec.CommonRec.nEvent = CommonRec_Event_JKStateChange then
      begin
        if Pos('����',rec.CommonRec.strOther) > 0 then
        begin
          bJiangji := true;
        end else begin
          bJiangji := false;
        end;

        if Pos('����',rec.CommonRec.strOther) > 0 then
        begin
          bDiaoche := true;
        end else begin
          bDiaoche := false;
        end;
        if Pos('ƽ��',rec.CommonRec.strOther) > 0 then
        begin
          bInPingdiao := true;
        end else begin
          bInPingdiao := false;
        end;
      end;
      rec.CommonRec.bIsDiaoChe := bDiaoche;
      rec.CommonRec.bIsJiangji := bJiangji;
      rec.CommonRec.bIsPingdiao := bInPingdiao;
      
      //��ʽ�����м�¼�е�ʱ����Ϣ(��������)          
      if tm < 0 then
      begin
        tm := rec.CommonRec.DTEvent;
        rec.CommonRec.DTEvent := dt + tm;
      end else begin
        if (FormatDateTime('HHnnss',rec.CommonRec.DTEvent) < FormatDateTime('HHnnss',tm))
          and  (rec.CommonRec.DTEvent <> 0) then
        begin
          dt := dt + 1;
          tm := rec.CommonRec.DTEvent;
          rec.CommonRec.DTEvent := dt + tm;
        end else begin
          if rec.CommonRec.DTEvent > 0 then          
            tm := rec.CommonRec.DTEvent;
          rec.CommonRec.DTEvent := dt + tm;
        end;
      end;
      //��ʽ��ƽ����Ϣ
      
      m_Query.Next;
    end;
    

    DealWithJgNumber(RuntimeFile);
    //��ʽ����λ����
    DealWithPosChance(RuntimeFile);
    //��ʽ����ǰ�Ľ�·�����ݽ�·����վ��
    m_StationFormat.Execute(RuntimeFile);
    FormatToStation(RuntimeFile);
  finally
    OrgToAdofile.Free;
  end;
end;

function TAdoFileReader.DBRowToLkjRec(PreRec: TLKJCommonRec;Query: TADOQuery): TLKJCommonRec;
begin
  Result := TLKJCommonRec.Create;
  if IsSpecialRow(Query) then
    DealSpecailData(PreRec,Result,Query)
  else
    DealNormalData(PreRec,Result,Query);
end;

procedure TAdoFileReader.DealNormalData(PreCommonRec,LKJCommonRec: TLKJCommonRec;
  Query: TADOQuery);
begin
  with LKJCommonRec,Query do
  begin
    CommonRec.nRow := Query.FieldByName('Rec').AsInteger;
    CommonRec.nEvent:= m_FieldConvert.GetnEvent(Query.FieldByName('Disp').AsString);
    CommonRec.strDisp := Query.FieldByName('Disp').AsString;
    CommonRec.strGK := Query.FieldByName('Hand').AsString;
      if (FieldByName('T_h').AsString = '') or (FieldByName('T_h').AsInteger > 23)
        or (FieldByName('T_m').AsInteger > 59) or (FieldByName('T_s').AsInteger > 59) then
      begin
        if PreCommonRec <> nil then
          CommonRec.DTEvent := TimeOf(PreCommonRec.CommonRec.DTEvent);
      end
      else
      begin
        CommonRec.DTEvent :=

        EncodeTime(FieldByName('T_h').AsInteger,FieldByName('T_m').AsInteger,FieldByName('T_s').AsInteger,0)
      end;



    if FieldByName('glb').IsNull and (PreCommonRec <> nil) then
      CommonRec.nCoord := PreCommonRec.CommonRec.nCoord
    else
      CommonRec.nCoord := m_FieldConvert.GetnCoord(FieldByName('glb').AsString);


    CommonRec.strXhj := FieldByName('xhj').AsString;
    CommonRec.strSignal := FieldByName('Signal').AsString;

    if FieldByName('Jl').IsNull and (PreCommonRec <> nil) then
      CommonRec.nDistance := PreCommonRec.CommonRec.nDistance
    else
      CommonRec.nDistance := FieldByName('Jl').AsInteger;

    if FieldByName('Gya').IsNull and (PreCommonRec <> nil) then
      CommonRec.nLieGuanPressure := PreCommonRec.CommonRec.nLieGuanPressure
    else
      CommonRec.nLieGuanPressure := FieldByName('Gya').AsInteger;

    if FieldByName('GangY').IsNull and (PreCommonRec <> nil) then
      CommonRec.nGangPressure := PreCommonRec.CommonRec.nGangPressure
    else
      CommonRec.nGangPressure := FieldByName('GangY').AsInteger;

    if FieldByName('Jg1').IsNull and (PreCommonRec <> nil) then
      CommonRec.nJG1Pressure := PreCommonRec.CommonRec.nJG1Pressure
    else
      CommonRec.nJG1Pressure := FieldByName('Jg1').AsInteger;

    if FieldByName('Jg2').IsNull and (PreCommonRec <> nil) then
      CommonRec.nJG2Pressure := PreCommonRec.CommonRec.nJG2Pressure
    else
      CommonRec.nJG2Pressure := FieldByName('Jg2').AsInteger;

    if FieldByName('xh_code').IsNull and (PreCommonRec <> nil) then
      CommonRec.LampSign := PreCommonRec.CommonRec.LampSign
    else
      CommonRec.LampSign := m_FieldConvert.ConvertSignal(FieldByName('xh_code').AsInteger);

    if FieldByName('xht_code').IsNull and (PreCommonRec <> nil) then
      CommonRec.SignType := PreCommonRec.CommonRec.SignType
    else
      CommonRec.SignType := m_FieldConvert.ConvertSignType(FieldByName('xht_code').AsInteger);

    if FieldByName('xhj_no').IsNull and (PreCommonRec <> nil) then
      CommonRec.nLampNo := PreCommonRec.CommonRec.nLampNo
    else
      CommonRec.nLampNo := FieldByName('xhj_no').AsInteger;

    if FieldByName('Shoub').IsNull and (PreCommonRec <> nil) then
    begin
      CommonRec.nShoub := PreCommonRec.CommonRec.nShoub;
      CommonRec.WorkZero := PreCommonRec.CommonRec.WorkZero;
      CommonRec.WorkDrag := PreCommonRec.CommonRec.WorkDrag;
      CommonRec.HandPos := PreCommonRec.CommonRec.HandPos;
    end
    else
    begin
      CommonRec.nShoub := FieldByName('Shoub').AsInteger;
      CommonRec.WorkZero := m_FieldConvert.ConvertWorkZero(CommonRec.nShoub);
      CommonRec.WorkDrag := m_FieldConvert.ConvertWorkDrag(CommonRec.nShoub);
      CommonRec.HandPos := m_FieldConvert.ConvertHandPos(CommonRec.nShoub);
    end;


    if FieldByName('Rota').IsNull and (PreCommonRec <> nil) then
      CommonRec.nRotate := PreCommonRec.CommonRec.nRotate
    else
      CommonRec.nRotate := FieldByName('Rota').AsInteger;

    if FieldByName('Speed').IsNull and (PreCommonRec <> nil) then
      CommonRec.nSpeed := PreCommonRec.CommonRec.nSpeed
    else
      CommonRec.nSpeed := FieldByName('Speed').AsInteger;

    if FieldByName('S_lmt').IsNull and (PreCommonRec <> nil) then
      CommonRec.nLimitSpeed := PreCommonRec.CommonRec.nLimitSpeed
    else
      CommonRec.nLimitSpeed  := FieldByName('S_lmt').AsInteger;

    if FieldByName('JKZT').IsNull and (PreCommonRec <> nil) then
      CommonRec.JKZT := PreCommonRec.CommonRec.JKZT
    else
      CommonRec.JKZT := FieldByName('JKZT').AsInteger;

    CommonRec.strOther := FieldByName('OTHER').AsString;
    CommonRec.Shuoming := FieldByName('Shuoming').AsString;

  end;
end;

procedure TAdoFileReader.DealSpecailData(PreCommonRec,LKJCommonRec: TLKJCommonRec;
  Query: TADOQuery);
begin
 with LKJCommonRec,Query do
  begin
    CommonRec.nRow := Query.FieldByName('Rec').AsInteger;
    CommonRec.nEvent:= m_FieldConvert.GetnEvent(Query.FieldByName('Disp').AsString);
    CommonRec.strDisp := Query.FieldByName('Disp').AsString;
    CommonRec.strGK := PreCommonRec.CommonRec.strGK;
    CommonRec.DTEvent := TimeOf(PreCommonRec.CommonRec.DTEvent);
    CommonRec.nCoord := PreCommonRec.CommonRec.nCoord;
    CommonRec.strXhj := PreCommonRec.CommonRec.strXhj;
    CommonRec.strSignal := PreCommonRec.CommonRec.strSignal;
    CommonRec.nDistance := PreCommonRec.CommonRec.nDistance;
    CommonRec.nLieGuanPressure := PreCommonRec.CommonRec.nLieGuanPressure;
    CommonRec.nGangPressure := PreCommonRec.CommonRec.nGangPressure;
    CommonRec.nJG1Pressure := PreCommonRec.CommonRec.nJG1Pressure;
    CommonRec.nJG2Pressure := PreCommonRec.CommonRec.nJG2Pressure;
    CommonRec.LampSign := PreCommonRec.CommonRec.LampSign;
    CommonRec.SignType := PreCommonRec.CommonRec.SignType;
    CommonRec.nLampNo := PreCommonRec.CommonRec.nLampNo;
    CommonRec.nShoub := PreCommonRec.CommonRec.nShoub;
    CommonRec.WorkZero := PreCommonRec.CommonRec.WorkZero;
    CommonRec.WorkDrag := PreCommonRec.CommonRec.WorkDrag;
    CommonRec.HandPos := PreCommonRec.CommonRec.HandPos;
    CommonRec.nRotate := PreCommonRec.CommonRec.nRotate;
    CommonRec.nSpeed := PreCommonRec.CommonRec.nSpeed;
    CommonRec.nLimitSpeed := PreCommonRec.CommonRec.nLimitSpeed;
    CommonRec.JKZT := PreCommonRec.CommonRec.JKZT;
    CommonRec.strOther := FieldByName('OTHER').AsString;
    CommonRec.Shuoming := FieldByName('Shuoming').AsString;

  end;
end;

procedure TAdoFileReader.DealWithJgNumber(LkjFile: TLKJRuntimeFile);
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
        if (LkjFile.Records[i - 1].CommonRec.nValidJG <> 0) and (i > 0) then
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


procedure TAdoFileReader.DealWithPosChance(LkjFile: TLKJRuntimeFile);
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

procedure TAdoFileReader.FormatToStation(LkjFile: TLKJRuntimeFile);
var
  i : Integer;
  recData : TLKJCommonRec;
  tempLineID,tempDataLineID,tempStation : Integer;
begin
  recData := TLKJCommonRec(lkjFile.Records[lkjFile.Records.Count - 1]);
  tempLineID := recData.CommonRec.nJKLineID;
  tempDataLineID := recData.CommonRec.nDataLineID;
  tempStation := recData.CommonRec.nStation;
  for i := lkjFile.Records.Count - 1 downto 0 do
  begin
    recData := TLKJCommonRec(lkjFile.Records[i]);
    if (recData.CommonRec.nJKLineID <> tempLineID)
      or (recData.CommonRec.nStation <>tempStation) then
    begin
      recData.CommonRec.nToStation :=  tempStation;
      recData.CommonRec.nToJKLineID := tempLineID;
      recData.CommonRec.nToDataLineID := tempDataLineID;
      tempStation := recData.CommonRec.nStation;
      tempLineID := recData.CommonRec.nToJKLineID;
      tempDataLineID := recData.CommonRec.nToDataLineID;
    end;
  end;

  tempLineID := 0;
  tempDataLineID := 0;
  tempStation := 0;
  for i := lkjFile.Records.Count - 1 downto 0 do
  begin
    recData := TLKJCommonRec(lkjFile.Records[i]);
    if (recData.CommonRec.nToJKLineID > 0)
      or (recData.CommonRec.nToStation > 0) then
    begin
      tempLineID := recData.CommonRec.nToJKLineID;
      tempDataLineID := recData.CommonRec.nToDataLineID;
      tempStation := recData.CommonRec.nToStation;
    end
    else begin
      recData.CommonRec.nToJKLineID := tempLineID;
      recData.CommonRec.nToDataLineID := tempDataLineID;
      recData.CommonRec.nToStation := tempStation;
    end;
  end;
end;




function TAdoFileReader.IsSpecialRow(Query: TADOQuery): Boolean;
begin
  if Trim(Query.FieldByName('Disp').AsString) ='��ʾ��ѯ' then
    Result := True
  else
    Result := False;
end;

procedure TAdoFileReader.LoadAdoFile(FileName: string);
begin
  m_Query.Close;
  m_Query.LoadFromFile(FileName);
  m_Query.Open();
end;


{ TOrgToAdofile }

procedure TOrgToAdofile.Execute(const orgFileName: string);
var
  strFormatFile,strDBPath : string;
  pcharFormatFile,pcharDBPath,pcharDBName : pchar;
begin
  strDBPath := ExtractFilePath(ParamStr(0));
  pcharDBName :=  PChar(strDBPath + 'test.db');
  pcharDBPath := pchar(strDBPath);
  try
    strFormatFile := FmtLkjOrgFile(orgFileName);
    pcharFormatFile := PChar(strFormatFile);
    Fmttotable(pcharDBName,pcharFormatFile,pcharDBPath, 1);
  finally
    if FileExists(strFormatFile) then
      DeleteFile(PChar(strFormatFile));
  end;
end;


end.
