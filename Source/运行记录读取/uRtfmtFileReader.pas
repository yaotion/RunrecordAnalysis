unit uRtfmtFileReader;

interface
uses
  Classes,SysUtils,Contnrs, DateUtils,uLKJRuntimeFile,uVSConst,
  Windows,uRtFileReaderBase;
const
  FILEHEAD_LENGTH = 3;                 //�ļ�ͷ����

  FLAG_SETINFO_TRIANTYPE = $8121;      //���ͱ�־ (�趨)
  FLAG_SETINFO_TRIANTYPE_IC = $8221;   //���ͱ�־ (IC�趨)
  FLAG_SETINFO_TRIANTYPE_JIAN = $8421; //���ͱ�־ (�����趨)

  FLAG_CHECI_HEAD = $B0F0;             //����ͷ��־
  FLAG_FILE_BEGIN = $B001;             //�ļ���ʼ
  FLAG_SETTING_JL = $8105;             //�趨��·
  FLAG_SETTING_STATION = $8106;        //�趨��վ

  FLAG_STATIONINFO = $20F0;            //��վ��Ϣ
  


type
  {TFileRec���м�¼��һ�м�¼}
  TFileRec = array[0..25] of byte; 

  //////////////////////////////////////////////////////////////////////////////
  ///  ����:TFileInfoReader
  ///  ����:�Ӹ�ʽ���ļ����ȡ�ļ���Ϣ
  //////////////////////////////////////////////////////////////////////////////
  TfmtFileReader = class(TRunTimeFileReaderBase)
  private
    m_LastRecordTime: TDateTime;
  protected
    {���ܣ���ȡ����}
    procedure ReadCheCi(fmtFile: TMemoryStream;var HeadInfo : RLKJRTFileHeadInfo);
    {���ܣ���ȡ����Ա��Ϣ}
    procedure ReadDriver(fmtFile: TMemoryStream;var HeadInfo : RLKJRTFileHeadInfo);
    {���ܣ���ȡ�����ͺ�}
    procedure ReadTrainType(fmtFile: TMemoryStream;var HeadInfo : RLKJRTFileHeadInfo);
    {���ܣ���ȡ������}
    procedure ReadTrainNo(fmtFile: TMemoryStream;var HeadInfo : RLKJRTFileHeadInfo);
    {���ܣ���ȡ�ļ�ʱ��}
    procedure ReadFileTime(fmtFile: TMemoryStream;var HeadInfo : RLKJRTFileHeadInfo);
    {���ܣ���ȡ����ʱ��}
    procedure ReadKCTime(fmtFile: TMemoryStream;var HeadInfo : RLKJRTFileHeadInfo);
    {���ܣ���ȡ�ͻ�״̬}
    procedure ReadKeHuo(fmtFile: TMemoryStream;var HeadInfo : RLKJRTFileHeadInfo);
  protected
    m_FileDateTime: TDateTime;
    procedure ReadFileHead(fmtFile: TMemoryStream;RuntimeFile : TLKJRuntimeFile);
    {���ܣ�������һ����¼���̳���һ����¼������}
    function NewLKJCommonRec(RuntimeFile : TLKJRuntimeFile): TLKJCommonRec;
    {���ܣ���ȡ�¼�����}
    class function GetEventCode(FileRec: TFileRec): Integer;
    {���ܣ�Byte����ת��Ϊ�ַ���}
    function ByteToStr(FileRec: TFileRec; BeginPos, EndPos: byte): string;
    {���ܣ���ȡһ�м�¼��ʱ��}
    function GetTime(FileRec: TFileRec): TDateTime;
    procedure ReadCommonInfo(FileRec: TFileRec;LKJCommonRec: TLKJCommonRec);
    //���ܣ���ȡ���ʱ��
    function GetRuKuTime(Mem: TMemoryStream; var OutTime: TDateTime): Boolean;
    procedure Read(RuntimeFile : TLKJRuntimeFile;fmtFile: TMemoryStream);    
  public
    {����:��ԭʼ�ļ�������Ϣ}
    procedure LoadFromFile(orgFile : string;RuntimeFile : TLKJRuntimeFile);override;
    {����:���ݴ��������ȡ�ļ��Ķ�Ӧʱ��,ʹ����fmtdll}
    function GetFileTime(orgFileName: string; TimeType: TFileTimeType; var OutTime: TDateTime): Boolean;
  end;

implementation

{ TFileInfoReader }

function TfmtFileReader.ByteToStr(FileRec: TFileRec; BeginPos,
  EndPos: byte): string;
var
   i: byte;
   str: string;
begin
   i := BeginPos;
   str := '';
   while i <= EndPos do
   begin
      str := str + chr(FileRec[i]);
      i := i + 1;
   end;
   Result := Trim(str)
end;

class function TfmtFileReader.GetEventCode(FileRec: TFileRec): Integer;
begin
  Result := FileRec[0] * 256 + FileRec[1];
end;

function TfmtFileReader.GetFileTime(orgFileName: string;
  TimeType: TFileTimeType; var OutTime: TDateTime): Boolean;
var
  HeadInfo: RLKJRTFileHeadInfo;
  strFormatFile: string;
  Mem: TMemoryStream;
  T: array[0..25] of Byte;
begin
  Result := False;
  ReadHead(orgFileName, HeadInfo);
  if TimeType <> fttBegin then
  begin
    strFormatFile := FmtLkjOrgFile(orgFileName)
  end;

  case TimeType of
    fttBegin:
      begin
        OutTime := HeadInfo.DTFileHeadDt;
        Result := True;
      end;
    fttEnd:
      begin
        Mem := TMemoryStream.Create;
        try
          Mem.LoadFromFile(strFormatFile);
          Mem.Seek(Mem.Size - 26, 0);
          Mem.Read(T, 26);
          if (T[2] > 23) or (T[3] > 59) or (T[4] > 59) then
          begin
            Result := False;
            Exit;
          end;

          OutTime := EncodeTime(T[2], T[3], T[4], 0);

          OutTime := CombineDateTime(HeadInfo.DTFileHeadDt, OutTime);

          if CompareTime(OutTime, HeadInfo.DTFileHeadDt) < 0 then
            IncDay(OutTime, 1);
          Result := True;
        finally
          Mem.Free;
          SysUtils.DeleteFile(strFormatFile);
        end;
      end;
    fttRuKu:
      begin
        Mem := TMemoryStream.Create;
        try
          Mem.LoadFromFile(strFormatFile);
          Result := GetRuKuTime(Mem, OutTime);
          if Result then
          begin
            OutTime := CombineDateTime(HeadInfo.DTFileHeadDt, OutTime);
            if CompareTime(OutTime, HeadInfo.DTFileHeadDt) < 0 then
              IncDay(OutTime, 1);
          end;

        finally
          Mem.Free;
          SysUtils.DeleteFile(strFormatFile);
        end;
      end;
  end;
end;

function TfmtFileReader.GetRuKuTime(Mem: TMemoryStream;
  var OutTime: TDateTime): Boolean;
var
  T: array[0..25] of Byte;
  i, index: integer;
begin
  Result := False;
  i := 0;
  index := 0;
  while Mem.Position < Mem.Size do
  begin
    Mem.Read(T, 26);
    //վ��ͣ��
    if (T[0] = $87) and (T[1] = $18) then
    begin
      index := -1;
    end;
    //���
    if (T[0] = $86) and (T[1] = $12) and (index = -1) then
    begin
      index := i;
    end;
    Inc(I);
  end;
  if index > 0 then
  begin
    Mem.Seek(26 * index, 0);
    Mem.Read(T, 26);
    OutTime := EncodeTime(T[2], T[3], T[4], 0);
    Result := True;
  end;
end;

function TfmtFileReader.GetTime(FileRec: TFileRec): TDateTime;
begin
  if (FileRec[2] >= 24) or (FileRec[3] >= 60) or (FileRec[4] >= 60) then
  begin
    if m_LastRecordTime < 1 then
      m_LastRecordTime := m_FileDateTime;

    Result := m_LastRecordTime;
    Exit;
  end;

  Result := EncodeTime(FileRec[2],FileRec[3],FileRec[4],0);

  Result :=  CombineDateTime(m_FileDateTime,Result);
  if CompareTime(Result,m_FileDateTime) < 0 then
    Result :=  IncDay(Result);
  m_LastRecordTime := Result;

end;

procedure TfmtFileReader.LoadFromFile(orgFile: string;
  RuntimeFile: TLKJRuntimeFile);
var
  strFmtFile: string;
  fmtFileStream: TMemoryStream;
  FileInfoReader: TfmtFileReader;
begin
  fmtFileStream := TMemoryStream.Create;
  FileInfoReader := TfmtFileReader.Create;
  try
    //��ȡͷ��Ϣ
    ReadHead(orgFile,RuntimeFile.HeadInfo);
    strFmtFile := FmtLkjOrgFile(orgFile);
    fmtFileStream.LoadFromFile(strFmtFile);
    if fmtFileStream.Size = 0 then
      raise Exception.Create('��ʽ�����м�¼�ļ�: ' +
        ExtractFileName(orgFile) +'ʧ��');
      
    FileInfoReader.Read(RuntimeFile,fmtFileStream)


  finally
    if FileExists(strFmtFile) then
      SysUtils.DeleteFile(strFmtFile);
    
    fmtFileStream.Free;
    FileInfoReader.Free;
  end;

end;

function TfmtFileReader.NewLKJCommonRec(
  RuntimeFile: TLKJRuntimeFile): TLKJCommonRec;
begin
  Result := TLKJCommonRec.Create;
  if RuntimeFile.Records.Count > 0 then
    Result.Clone(RuntimeFile.Records[RuntimeFile.Records.Count - 1])
  else
    Result.CommonRec.DTEvent := m_FileDateTime;
end;

procedure TfmtFileReader.Read(RuntimeFile: TLKJRuntimeFile;
  fmtFile: TMemoryStream);
var
  nEventCode: Integer;
  LKJCommonRec: TLKJCommonRec;
  FileRec: TFileRec;
begin
  if RuntimeFile = nil then
    raise Exception.Create('RuntimeFile ��������Ϊ��');
  {��ȡ�ļ�ͷ}
  ReadFileHead(fmtFile,RuntimeFile);

  fmtFile.Seek(FILEHEAD_LENGTH * SizeOf(TFileRec),0);

  while fmtFile.Position < fmtFile.Size do
  begin
    fmtFile.Read(FileRec,SizeOf(FileRec));

    nEventCode := GetEventCode(FileRec);
    LKJCommonRec := NewLKJCommonRec(RuntimeFile);
    LKJCommonRec.CommonRec.nRow := RuntimeFile.Records.Count;
    LKJCommonRec.CommonRec.nEvent := nEventCode;
    RuntimeFile.Records.Add(LKJCommonRec);
    case nEventCode of
      CommonRec_Event_DuiBiao,
      CommonRec_Event_CuDuan,

      CommonRec_Event_TrainPosForward,
      CommonRec_Event_TrainPosBack,
      CommonRec_Event_TrainPosReset,
      CommonRec_Event_SpeedChange,
      CommonRec_Event_RotaChange,
      CommonRec_Event_GanYChange,
      CommonRec_Event_SpeedLmtChange,
      CommonRec_Event_GangYChange,
      CommonRec_Event_GuoFX,
      $8B08,     //������¼
      $8B0C,     //������¼
      $8B0D,     //ʱ��ص�
      $8B0E,     //��¼����
      CommonRec_Event_XingHaoTuBian,
      CommonRec_Event_GLBTuBian,
      CommonRec_Event_EnterStation,
      CommonRec_Event_SectionSignal,
      CommonRec_Event_InOutStation,
      CommonRec_Event_LeaveStation,
      CommonRec_Event_StartTrain,
      CommonRec_Event_ZiTing,
      CommonRec_Event_StopInRect,
      CommonRec_Event_StartInRect,
      CommonRec_Event_StopInJiangJi,
      CommonRec_Event_StopInStation,
      CommonRec_Event_StopOutSignal,
      CommonRec_Event_StartInStation,
      CommonRec_Event_StartInJiangJi,
      CommonRec_Event_RuDuan
      : ReadCommonInfo(FileRec,LKJCommonRec);
    else
      begin
        if FileRec[0] = $8A then    //�źű仯
        begin
          if FileRec[1] <> $02 then //��ʽ��ƽ�仯
            ReadCommonInfo(FileRec,LKJCommonRec);
        end;
        
      end;
    end;
  end;
  

end;

procedure TfmtFileReader.ReadCheCi(fmtFile: TMemoryStream;
  var HeadInfo: RLKJRTFileHeadInfo);
var
  FileRec: TFileRec;
begin
  fillchar(FileRec,SizeOf(FileRec),0);
  fmtFile.Seek(SizeOf(FileRec),0);
  fmtFile.Read(FileRec,SizeOf(FileRec));
  HeadInfo.nTrainNo := FileRec[2] + FileRec[3] * 256 + FileRec[17] * 65536;

  fmtFile.Read(FileRec,SizeOf(FileRec));
  if GetEventCode(FileRec) = FLAG_CHECI_HEAD then
  begin
    HeadInfo.strTrainHead := ByteToStr(FileRec,15,18);
  end;

end;
procedure TfmtFileReader.ReadCommonInfo(FileRec: TFileRec;
  LKJCommonRec: TLKJCommonRec);
begin
  LKJCommonRec.CommonRec.DTEvent := GetTime(FileRec);
  if FileRec[7] <= 128 then
  begin
    LKJCommonRec.CommonRec.nCoord := FileRec[5] + 256 * (FileRec[6] + FileRec[7] * 256);
  end;
  LKJCommonRec.CommonRec.nDistance := FileRec[8] + FileRec[9] * 256;

  if FileRec[12] = $80 then
    LKJCommonRec.CommonRec.bIsPingdiao := True;

  LKJCommonRec.CommonRec.nLampNo := FileRec[10] + FileRec[11] * 256;
  LKJCommonRec.CommonRec.nLieGuanPressure := FileRec[13] * 10;
  LKJCommonRec.CommonRec.nGangPressure := FileRec[14] * 10;
  LKJCommonRec.CommonRec.nRotate := (FileRec[17] + FileRec[18] * 256) mod 10000; 
  LKJCommonRec.CommonRec.nSpeed := (FileRec[19] + FileRec[20] * 256) mod 1000;
  LKJCommonRec.CommonRec.nLimitSpeed := (FileRec[21] + FileRec[22] * 256) mod 1000;

end;


procedure TfmtFileReader.ReadDriver(fmtFile: TMemoryStream;
  var HeadInfo: RLKJRTFileHeadInfo);
  function GetDriverNo(FileRec: TFileRec): string;
  begin
    Result := Trim(chr(FileRec[7]) +
              chr(FileRec[8]) +
              chr(FileRec[9]) +
              chr(FileRec[10]) +
              chr(FileRec[11]) +
              chr(FileRec[12]) +
              chr(FileRec[13]) +
              chr(FileRec[14]));
  end;
var
  FileRec: TFileRec;
begin
  fmtFile.Seek(0,0);
  while fmtFile.Position < fmtFile.Size do
  begin
    FillChar(FileRec,sizeof(FileRec),0);
    fmtFile.Read(FileRec,SizeOf(FileRec));
    if (FileRec[0] = $81) or (FileRec[0] = $82) or (FileRec[0] = $84) then
    begin
      case FileRec[1] of
        $04, $57, $58, $59:
          begin
            HeadInfo.nFirstDriverNO := StrToInt(GetDriverNo(FileRec));
          end;

        $11:
          begin
            HeadInfo.nSecondDriverNO := StrToInt(GetDriverNo(FileRec));
          end;
      end;
    end;
    
  end;
end;


procedure TfmtFileReader.ReadFileHead(fmtFile: TMemoryStream;
  RuntimeFile: TLKJRuntimeFile);
begin
  ReadCheCi(fmtFile,RuntimeFile.HeadInfo);
  ReadDriver(fmtFile,RuntimeFile.HeadInfo);
  ReadTrainType(fmtFile,RuntimeFile.HeadInfo);
  ReadTrainNo(fmtFile,RuntimeFile.HeadInfo);
  ReadFileTime(fmtFile,RuntimeFile.HeadInfo);
  ReadKCTime(fmtFile,RuntimeFile.HeadInfo);
  ReadKeHuo(fmtFile,RuntimeFile.HeadInfo);
  fmtFile.Seek(0,0);
end;

procedure TfmtFileReader.ReadFileTime(fmtFile: TMemoryStream;
  var HeadInfo: RLKJRTFileHeadInfo);
var
  FileRec: TFileRec;
  bFindFileTime: Boolean;
begin
  bFindFileTime := False;
  fmtFile.Seek(SizeOf(FileRec) * FILEHEAD_LENGTH,0);
  while fmtFile.Position < fmtFile.Size do
  begin
    fmtFile.Read(FileRec,SizeOf(FileRec));
    if TfmtFileReader.GetEventCode(FileRec) =  FLAG_FILE_BEGIN then
    begin
      HeadInfo.DTFileHeadDt := EncodeDateTime(FileRec[2] + 2000,FileRec[3],FileRec[4],
        FileRec[5],FileRec[6],FileRec[7],0);
      m_FileDateTime := HeadInfo.DTFileHeadDt;
      bFindFileTime := True;
      Break;
    end;
  end;
  fmtFile.Seek(0,0);
  if not bFindFileTime then
    raise Exception.Create('δ�ҵ��ļ���ʼʱ��');
end;

procedure TfmtFileReader.ReadKCTime(fmtFile: TMemoryStream;
  var HeadInfo: RLKJRTFileHeadInfo);
var
  FileRec: TFileRec;
  nEventCode: Integer;
begin
  fmtFile.Seek(0,0);
  while fmtFile.Position < fmtFile.Size do
  begin
    fmtFile.Read(FileRec,SizeOf(FileRec));
    nEventCode := GetEventCode(FileRec);
    if (nEventCode = CommonRec_Event_DuiBiao) or
      (nEventCode = CommonRec_Event_LeaveStation) then
    begin
      HeadInfo.dtKCDataTime := GetTime(FileRec);
      Break;
    end;
  end;
end;

procedure TfmtFileReader.ReadKeHuo(fmtFile: TMemoryStream;
  var HeadInfo: RLKJRTFileHeadInfo);
var
  FileRec: TFileRec;
begin
  fmtFile.Seek(SizeOf(FileRec),0);
  fmtFile.Read(FileRec,SizeOf(FileRec));

  if FileRec[1] mod 2 = 1 then
    HeadInfo.TrainType := ttPassenger
  else
    HeadInfo.TrainType := ttCargo;
end;

procedure TfmtFileReader.ReadTrainNo(fmtFile: TMemoryStream;
  var HeadInfo: RLKJRTFileHeadInfo);
var
  FileRec: TFileRec;
begin
  fmtFile.Seek(0,0);
  fmtFile.Read(FileRec,SizeOf(FileRec));
  HeadInfo.nLocoID := FileRec[20] + FileRec[21] * 256;
end;

procedure TfmtFileReader.ReadTrainType(fmtFile: TMemoryStream;
  var HeadInfo: RLKJRTFileHeadInfo);
var
  FileRec: TFileRec;
begin
  fmtFile.Seek(0,0);
  while fmtFile.Position < fmtFile.Size do
  begin
    fmtFile.Read(FileRec,SizeOf(FileRec));
    case FileRec[0] of
      $81,$82,$84 :
        begin
          if FileRec[1] = $21 then
          begin
            HeadInfo.nLocoType := FileRec[5] + FileRec[6] * 256;
          end;
        end;
    end;
    if GetEventCode(FileRec) = CommonRec_Event_DuiBiao then
      Break;
  end;
end;

end.

