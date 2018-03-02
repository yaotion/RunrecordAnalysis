unit uXMLlkjFileReader;

interface
uses
  Classes,xmldom, XMLIntf, msxmldom,XMLDoc,SysUtils,Math, Variants,DateUtils,
  uLKJRuntimeFile, uVSConst,uConvertDefine,uRtFileReaderBase;
type
  //////////////////////////////////////////////////////////////////////////////
  ///LKJRuntimeFile的XML读写类
  //////////////////////////////////////////////////////////////////////////////
  TLKJRuntimeXMLReader = class(TRunTimeFileReaderBase)
  public
    constructor Create();
    destructor Destroy;override;
  private
    m_FieldConvert : TFieldConvert;
  public
    procedure ReadHead(FileName : string;var HeadInfo: RLKJRTFileHeadInfo);override;
    procedure LoadFromFile(FileName : string;RuntimeFile : TLKJRuntimeFile);override;
    procedure LoadFromFiles(FileList : TStrings;RuntimeFile : TLKJRuntimeFile);override;
    procedure SaveToFile(FileName : string;RuntimeFile : TLKJRuntimeFile);    
  end;
implementation
{ TLKJRuntimeXMLReader }

constructor TLKJRuntimeXMLReader.Create;
begin
  inherited Create;
  m_FieldConvert := TFieldConvert.Create;
end;

destructor TLKJRuntimeXMLReader.Destroy;
begin
  m_FieldConvert.Free;
  inherited;
end;

procedure TLKJRuntimeXMLReader.LoadFromFile(FileName: string;
  RuntimeFile: TLKJRuntimeFile);
var
  i: Integer;
  LKJCommonRec: TLKJCommonRec;
  node,SubNode: IXMLNode;
  XmlDoc: IXMLDocument;
begin
  XmlDoc := NewXMLDocument();
  try
    XmlDoc.LoadFromFile(FileName);
    node := XmlDoc.DocumentElement; 
    ReadHead(FileName,RuntimeFile.HeadInfo);
    for I := 0 to Node.ChildNodes.Count - 1 do
    begin
      LKJCommonRec:= TLKJCommonRec.Create;
      SubNode := Node.ChildNodes.Nodes[i];
      with LKJCommonRec.CommonRec do
      begin
        nRow := SubNode.Attributes['Rec'];
        strDisp := SubNode.Attributes['Disp'];
        nEvent:= SubNode.Attributes['nEvent'];
        DTEvent:= StrToDateTime(SubNode.Attributes['Hms']);
        nCoord:= m_FieldConvert.GetnCoord(SubNode.Attributes['Glb']);
        nDistance:= SubNode.Attributes['Jl'];
        strXhj := SubNode.Attributes['Xhj'];
        strSignal := SubNode.Attributes['Signal'];
        LampSign:= SubNode.Attributes['Xh_code'];
        nLampNo:=  SubNode.Attributes['Xhj_no'];
        SignType:= SubNode.Attributes['Xht_code'];
        nSpeed:= SubNode.Attributes['Speed'];
        nLimitSpeed:= SubNode.Attributes['S_lmt'];
        WorkZero:= m_FieldConvert.ConvertWorkZero(SubNode.Attributes['Shoub']);
        HandPos:= m_FieldConvert.ConvertHandPos(SubNode.Attributes['Shoub']);
        WorkDrag:= m_FieldConvert.ConvertWorkDrag(SubNode.Attributes['Shoub']);
        nShoub :=  SubNode.Attributes['Shoub'];
        strGK := SubNode.Attributes['Hand'];
        nLieGuanPressure:= SubNode.Attributes['Gya'];
        nGangPressure:= SubNode.Attributes['Gangy'];
        nRotate:= SubNode.Attributes['Rota'];
        nJG1Pressure:= SubNode.Attributes['Jg1'];
        nJG2Pressure:= SubNode.Attributes['Jg2'];
        strOther:= SubNode.Attributes['OTHER'];
        ShuoMing := SubNode.Attributes['Shuoming'];
        JKZT := SubNode.Attributes['JKZT'];
        nValidJG := SubNode.Attributes['ValidJG'];
      end;
      RuntimeFile.Records.Add(LKJCommonRec);
    end;
  finally
     XmlDoc := nil;
  end;
end;

procedure TLKJRuntimeXMLReader.LoadFromFiles(FileList: TStrings;
  RuntimeFile: TLKJRuntimeFile);
begin
  ;
end;

procedure TLKJRuntimeXMLReader.ReadHead(FileName: string;
  var HeadInfo: RLKJRTFileHeadInfo);
var
  XmlDoc: IXMLDocument;
  node,subNode: IXMLNode;
  i: Integer;
begin
  FillChar(HeadInfo,SizeOf(HeadInfo),0);
  XmlDoc := NewXMLDocument();
  try
    XmlDoc.LoadFromFile(FileName);
    node := XmlDoc.DocumentElement;
    for I := 0 to Node.ChildNodes.Count - 1 do
    begin
      subNode := Node.ChildNodes[i];
      if i > 40 then
        Break;

      case subNode.Attributes['nEvent'] of
        File_Headinfo_dtBegin :
          begin
            HeadInfo.DTFileHeadDt := StrToDateTime(subNode.Attributes['Hms']);
          end;
        File_Headinfo_Factory :
          begin
            HeadInfo.Factory := m_FieldConvert.GetJkFactoryInfo(subNode.Attributes['OTHER']);
          end;
        File_Headinfo_KeHuo :
          begin
            m_FieldConvert.GetKeHuoBenBu(subNode.Attributes['OTHER'],HeadInfo.TrainType,HeadInfo.BenBu);
          end;
        File_Headinfo_CheCi :
          begin
            m_FieldConvert.GetCheCiInfo(subNode.Attributes['OTHER'],HeadInfo.nTrainNo,HeadInfo.strTrainHead);
          end;
        File_Headinfo_TotalWeight :
          begin
            HeadInfo.nTotalWeight := StrToInt(subNode.Attributes['OTHER']);
          end;
        File_Headinfo_DataJL :
          begin
            HeadInfo.nDataLineID := StrToInt(subNode.Attributes['OTHER']);
          end;
        File_Headinfo_JLH :
          begin
            HeadInfo.nJKLineID := StrToInt(subNode.Attributes['OTHER']);
          end;
        File_Headinfo_Driver :
          begin
            HeadInfo.nFirstDriverNO := m_FieldConvert.GetDriverNo(subNode.Attributes['OTHER']);
          end;
        File_Headinfo_SubDriver :
          begin
            HeadInfo.nSecondDriverNO := m_FieldConvert.GetDriverNo(subNode.Attributes['OTHER']);
          end;
        File_Headinfo_LiangShu :
          begin
            HeadInfo.nSum := StrToInt(subNode.Attributes['OTHER']);
          end;
        File_Headinfo_JiChang :
          begin

          end;
        File_Headinfo_ZZhong :
          begin
            HeadInfo.nLoadWeight := StrToInt(subNode.Attributes['OTHER']);
          end;
        File_Headinfo_TrainNo :
          begin
            HeadInfo.nLocoID := m_FieldConvert.GetLocalID((subNode.Attributes['OTHER']));
          end;
        File_Headinfo_TrainType :
          begin
            HeadInfo.nLocoType := StrToInt(subNode.Attributes['OTHER']);
          end;
        File_Headinfo_LkjID :
          begin
            HeadInfo.nDeviceNo := StrToInt(subNode.Attributes['OTHER']);
          end;
        File_Headinfo_StartStation :
          begin
            HeadInfo.nStartStation := StrToInt(subNode.Attributes['OTHER'])
          end;
      end;     
    end;
  finally

  end;
end;

procedure TLKJRuntimeXMLReader.SaveToFile(FileName: string;
  RuntimeFile: TLKJRuntimeFile);
var
  i : Integer;
  xmlDoc : IXMLDocument;
  RootNode, Node: IXMLNode;
  CRec: RCommonRec;
begin
  xmlDoc := NewXMLDocument();
  try
    XmlDoc.DocumentElement := XmlDoc.CreateNode('运行记录');
    RootNode := XmlDoc.DocumentElement;;
    for I := 0 to RuntimeFile.Records.Count - 1 do
    begin
      CRec := RuntimeFile.Records[i].CommonRec;
      Node := RootNode.AddChild('Row' + IntToStr(i));
      Node.Attributes['Rec'] := CRec.nRow;
      Node.Attributes['Disp'] := CRec.strDisp;
      Node.Attributes['nEvent'] := CRec.nEvent;
      Node.Attributes['Hms'] := CRec.DTEvent;
      Node.Attributes['Glb'] := m_FieldConvert.ConvertCoordToStr(CRec.nCoord);
      Node.Attributes['Xhj'] := CRec.strXhj;
      Node.Attributes['Xht_code'] := CRec.SignType;
      Node.Attributes['Xhj_no'] := CRec.nLampNo;
      Node.Attributes['Xh_code'] := CRec.LampSign;
      Node.Attributes['Speed'] := CRec.nSpeed;
      Node.Attributes['Shoub'] := CRec.nShoub;
      Node.Attributes['Hand'] := CRec.strGK;
      Node.Attributes['Gya'] := CRec.nLieGuanPressure;
      Node.Attributes['Rota'] := CRec.nRotate;
      Node.Attributes['S_lmt'] := CRec.nLimitSpeed;
      Node.Attributes['Jl'] := CRec.nDistance;
      Node.Attributes['Gangy'] := CRec.nGangPressure;
      Node.Attributes['OTHER'] := CRec.strOther;
      Node.Attributes['Signal'] := CRec.strSignal;
      Node.Attributes['Jg1'] := CRec.nJG1Pressure;
      Node.Attributes['Jg2'] := CRec.nJG2Pressure;
      Node.Attributes['JKZT'] := CRec.JKZT;
      Node.Attributes['Shuoming'] := CRec.ShuoMing;
      Node.Attributes['ValidJG'] := CRec.nValidJG;
      Node.Attributes['JiaoLu'] := CRec.nDataLineID;
      Node.Attributes['Station'] := CRec.nStation;
    end;
    xmlDoc.SaveToFile(FileName);
    XmlDoc.DocumentElement.ChildNodes.Clear;
  finally
    xmlDoc := nil;
  end;
end;

end.
