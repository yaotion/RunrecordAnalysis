unit uRtfmtFileReader;

interface
uses
  Classes,SysUtils,Contnrs, DateUtils,uLKJRuntimeFile,uVSConst,
  Windows,uRtFileReaderBase;
const
  FILEHEAD_LENGTH = 3;                 //文件头长度

  FLAG_SETINFO_TRIANTYPE = $8121;      //车型标志 (设定)
  FLAG_SETINFO_TRIANTYPE_IC = $8221;   //车型标志 (IC设定)
  FLAG_SETINFO_TRIANTYPE_JIAN = $8421; //车型标志 (检修设定)

  FLAG_CHECI_HEAD = $B0F0;             //车次头标志
  FLAG_FILE_BEGIN = $B001;             //文件开始
  FLAG_SETTING_JL = $8105;             //设定交路
  FLAG_SETTING_STATION = $8106;        //设定车站

  FLAG_STATIONINFO = $20F0;            //车站信息
  


type
  {TFileRec运行记录中一行记录}
  TFileRec = array[0..25] of byte; 

  //////////////////////////////////////////////////////////////////////////////
  ///  类名:TFileInfoReader
  ///  功能:从格式化文件里读取文件信息
  //////////////////////////////////////////////////////////////////////////////
  TfmtFileReader = class(TRunTimeFileReaderBase)
  private
    m_LastRecordTime: TDateTime;
  protected
    {功能：读取车次}
    procedure ReadCheCi(fmtFile: TMemoryStream;var HeadInfo : RLKJRTFileHeadInfo);
    {功能：读取乘务员信息}
    procedure ReadDriver(fmtFile: TMemoryStream;var HeadInfo : RLKJRTFileHeadInfo);
    {功能：读取机车型号}
    procedure ReadTrainType(fmtFile: TMemoryStream;var HeadInfo : RLKJRTFileHeadInfo);
    {功能：读取机车号}
    procedure ReadTrainNo(fmtFile: TMemoryStream;var HeadInfo : RLKJRTFileHeadInfo);
    {功能：读取文件时间}
    procedure ReadFileTime(fmtFile: TMemoryStream;var HeadInfo : RLKJRTFileHeadInfo);
    {功能：读取开车时间}
    procedure ReadKCTime(fmtFile: TMemoryStream;var HeadInfo : RLKJRTFileHeadInfo);
    {功能：读取客货状态}
    procedure ReadKeHuo(fmtFile: TMemoryStream;var HeadInfo : RLKJRTFileHeadInfo);
  protected
    m_FileDateTime: TDateTime;
    procedure ReadFileHead(fmtFile: TMemoryStream;RuntimeFile : TLKJRuntimeFile);
    {功能：新生成一条记录，继承上一条记录的内容}
    function NewLKJCommonRec(RuntimeFile : TLKJRuntimeFile): TLKJCommonRec;
    {功能：获取事件代码}
    class function GetEventCode(FileRec: TFileRec): Integer;
    {功能：Byte序列转换为字符串}
    function ByteToStr(FileRec: TFileRec; BeginPos, EndPos: byte): string;
    {功能：获取一行记录的时间}
    function GetTime(FileRec: TFileRec): TDateTime;
    procedure ReadCommonInfo(FileRec: TFileRec;LKJCommonRec: TLKJCommonRec);
    //功能：获取入库时间
    function GetRuKuTime(Mem: TMemoryStream; var OutTime: TDateTime): Boolean;
    procedure Read(RuntimeFile : TLKJRuntimeFile;fmtFile: TMemoryStream);    
  public
    {功能:从原始文件加载信息}
    procedure LoadFromFile(orgFile : string;RuntimeFile : TLKJRuntimeFile);override;
    {功能:根据传入参数获取文件的对应时间,使用了fmtdll}
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
    //站内停车
    if (T[0] = $87) and (T[1] = $18) then
    begin
      index := -1;
    end;
    //入段
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
    //读取头信息
    ReadHead(orgFile,RuntimeFile.HeadInfo);
    strFmtFile := FmtLkjOrgFile(orgFile);
    fmtFileStream.LoadFromFile(strFmtFile);
    if fmtFileStream.Size = 0 then
      raise Exception.Create('格式化运行记录文件: ' +
        ExtractFileName(orgFile) +'失败');
      
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
    raise Exception.Create('RuntimeFile 参数不能为空');
  {读取文件头}
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
      $8B08,     //定量记录
      $8B0C,     //变量记录
      $8B0D,     //时间地点
      $8B0E,     //记录距离
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
        if FileRec[0] = $8A then    //信号变化
        begin
          if FileRec[1] <> $02 then //制式电平变化
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
    raise Exception.Create('未找到文件开始时间');
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

