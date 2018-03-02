unit uXMLLkjRunTimeFile;

interface
uses
  SysUtils,Forms,xmldom, XMLIntf, msxmldom, XMLDoc,uLKJRuntimeFile,Windows;
type
////////////////////////////////////////////////////////////////////////////////
/// TXmlLkjRunTimeFile ���ܣ�ʵ�� TLKJRuntimeFile ��XML�ļ��໥ת��
////////////////////////////////////////////////////////////////////////////////
  TXmlLkjRunTimeFile = class
    private
      procedure AddHeadInfoToXML(NewNode : IXMLNode;HeadInfo: RLKJRTFileHeadInfo);
      procedure AddRewListToXML(NewNode : IXMLNode;LkjFile : TLKJRuntimeFile);
      procedure AddHeadInfoToLkjFile(NewNode : IXMLNode;LkjFile : TLKJRuntimeFile);
      procedure AddRewListToLkjFile(NewNode : IXMLNode;LkjFile : TLKJRuntimeFile);
    public
      //���ܣ���TLKJRuntimeFileת��ΪXml�ļ�
      procedure ConvertLkjRuntimeFileToXml(LkjFile : TLKJRuntimeFile;XmlFileName : string);
      //���ܣ���Xml�ļ�ת��ΪTLKJRuntimeFile
      procedure ConvertXmlToLkjRunTimeFile(XmlFileName: string;var LkjRuntimeFile: TLKJRuntimeFile);
  end;
implementation

{ TVirtualFile }

procedure TXmlLkjRunTimeFile.AddHeadInfoToLkjFile(NewNode: IXMLNode;
  LkjFile: TLKJRuntimeFile);
var
  subNode : IXMLNode;
begin
  subNode := NewNode.ChildNodes['HeadInfo'];
  with LkjFile.HeadInfo do
  begin
    nLocoID := subNode.Attributes['�������'];
    nLocoType := subNode.Attributes['�����ͺ�'];
    strTrainHead := subNode.Attributes['����ͷ'];
    nTrainNo := subNode.Attributes['����'];
    nDistance := subNode.Attributes['���о���'];
    nJKLineID := subNode.Attributes['��·��'];
    nDataLineID := subNode.Attributes['���ݽ�·��'];
    nFirstDriverNO := subNode.Attributes['˾������'];
    nSecondDriverNO := subNode.Attributes['��˾����'];
    nStartStation := subNode.Attributes['ʼ��վ'];
    nEndStation := subNode.Attributes['�յ�վ'];
    nLocoJie := subNode.Attributes['��������'];
    nDeviceNo := subNode.Attributes['װ�ú�'];
    nTotalWeight := subNode.Attributes['����'];
    nSum := subNode.Attributes['�ϼ�'];
    nLoadWeight := subNode.Attributes['����'];
    nJKVersion := subNode.Attributes['��ذ汾'];
    nDataVersion := subNode.Attributes['���ݰ汾'];
    DTFileHeadDt := StrToDateTime(subNode.Attributes['�ļ�ͷʱ��']);
    Factory := subNode.Attributes['�������'];
    TrainType := subNode.Attributes['�ͻ�����'];
    BenBu := subNode.Attributes['����'];
    nStandardPressure := subNode.Attributes['��׼��ѹ'];
    nMaxLmtSpd := subNode.Attributes['�����������'];
  end;

end;

procedure TXmlLkjRunTimeFile.AddHeadInfoToXML(NewNode: IXMLNode;
  HeadInfo: RLKJRTFileHeadInfo);
begin
  with HeadInfo do
  begin
    NewNode.Attributes['�������'] := nLocoID;
    NewNode.Attributes['�����ͺ�'] := nLocoType;
    NewNode.Attributes['����ͷ'] := strTrainHead;
    NewNode.Attributes['����'] := nTrainNo ;
    NewNode.Attributes['���о���'] := nDistance ;
    NewNode.Attributes['��·��'] := nJKLineID ;
    NewNode.Attributes['���ݽ�·��'] := nDataLineID ;
    NewNode.Attributes['˾������'] := nFirstDriverNO ;
    NewNode.Attributes['��˾����'] := nSecondDriverNO ;
    NewNode.Attributes['ʼ��վ'] := nStartStation ;
    NewNode.Attributes['�յ�վ'] := nEndStation ;
    NewNode.Attributes['��������'] := nLocoJie ;
    NewNode.Attributes['װ�ú�'] := nDeviceNo ;
    NewNode.Attributes['����'] := nTotalWeight ;
    NewNode.Attributes['�ϼ�'] := nSum ;
    NewNode.Attributes['����'] := nLoadWeight ;
    NewNode.Attributes['��ذ汾'] := nJKVersion ;
    NewNode.Attributes['���ݰ汾'] := nDataVersion ;
    NewNode.Attributes['�ļ�ͷʱ��'] := DTFileHeadDt ;
    NewNode.Attributes['�������'] := Factory ;
    NewNode.Attributes['�ͻ�����'] := TrainType ;
    NewNode.Attributes['����'] := BenBu ;
    NewNode.Attributes['��׼��ѹ'] := nStandardPressure  ;
    NewNode.Attributes['�����������'] := nMaxLmtSpd  ;
  end;
end;

procedure TXmlLkjRunTimeFile.AddRewListToLkjFile(NewNode: IXMLNode;
  LkjFile: TLKJRuntimeFile);
var
  i : Integer;
  rec : RCommonRec;
  subNode : IXMLNode;
  lkjCommonrec : TLKJCommonRec;
begin

  for I := 0 to NewNode.ChildNodes['RewList'].ChildNodes.Count - 1 do
  begin
    subNode := NewNode.ChildNodes['RewList'].ChildNodes[i];

    rec.nRow := subNode.Attributes['�к�'];
    rec.nEvent := subNode.Attributes['�¼�����'];
    rec.DTEvent := StrToDateTime(subNode.Attributes['�¼�ʱ��']);
    rec.nCoord := subNode.Attributes['�����'];
    rec.nDistance := subNode.Attributes['����'];
    rec.LampSign := subNode.Attributes['�����ź�'];
    rec.nLampNo := subNode.Attributes['�źŻ����'];
    rec.SignType := subNode.Attributes['�źŻ�����'];
    rec.nSpeed := subNode.Attributes['�ٶ�'];
    rec.nLimitSpeed := subNode.Attributes['����'];
    rec.WorkZero := subNode.Attributes['��ǹ���'];
    rec.HandPos := subNode.Attributes['ǰ�󹤿�'];
    rec.WorkDrag :=subNode.Attributes['ǣ�ƹ���'];
    rec.nLieGuanPressure := subNode.Attributes['��ѹ'];
    rec.nGangPressure := subNode.Attributes['��ѹ'];
    rec.nRotate := subNode.Attributes['����'];
    rec.nJG1Pressure := subNode.Attributes['����1'];
    rec.nJG2Pressure := subNode.Attributes['����2'];
    rec.strOther := subNode.Attributes['����'];
    rec.nJKLineID := subNode.Attributes['��ǰ��·��'];
    rec.nDataLineID := subNode.Attributes['��ǰ���ݽ�·��'];
    rec.nStation := subNode.Attributes['�ѹ���վ��'];
    rec.nToJKLineID := subNode.Attributes['��һ��վ�Ľ�·��'];
    rec.nToDataLineID := subNode.Attributes['��һ��վ�����ݽ�·��'];
    rec.nToStation := subNode.Attributes['��һ��վ���'];
    rec.nStationIndex := subNode.Attributes['��վ���'];

    lkjCommonrec := TLKJCommonRec.Create;
    lkjCommonrec.CommonRec := rec;
    LkjFile.Records.Add(lkjCommonrec);
  end;
end;

procedure TXmlLkjRunTimeFile.AddRewListToXML(NewNode: IXMLNode; LkjFile: TLKJRuntimeFile);
var
  i : Integer;
  rec : RCommonRec;
  subNode : IXMLNode;
begin
  for I := 0 to LkjFile.Records.Count - 1 do
  begin
    rec := TLKJCommonRec(LkjFile.Records.Items[i]).CommonRec;

    subNode := NewNode.AddChild('��¼' + IntToStr(i));

    subNode.Attributes['�к�'] := rec.nRow;
    subNode.Attributes['�¼�����'] := rec.nEvent;
    subNode.Attributes['�¼�ʱ��'] := rec.DTEvent;
    subNode.Attributes['�����'] := rec.nCoord;
    subNode.Attributes['����'] := rec.nDistance;
    subNode.Attributes['�����ź�'] := rec.LampSign;
    subNode.Attributes['�źŻ����'] := rec.nLampNo;
    subNode.Attributes['�źŻ�����'] := rec.SignType;
    subNode.Attributes['�ٶ�'] := rec.nSpeed;
    subNode.Attributes['����'] := rec.nLimitSpeed;
    subNode.Attributes['��ǹ���'] := rec.WorkZero;
    subNode.Attributes['ǰ�󹤿�'] := rec.HandPos;
    subNode.Attributes['ǣ�ƹ���'] := rec.WorkDrag;
    subNode.Attributes['��ѹ'] := rec.nLieGuanPressure;
    subNode.Attributes['��ѹ'] := rec.nGangPressure;
    subNode.Attributes['����'] := rec.nRotate;
    subNode.Attributes['����1'] := rec.nJG1Pressure;
    subNode.Attributes['����2'] := rec.nJG2Pressure;
    subNode.Attributes['����'] := rec.strOther;
    subNode.Attributes['��ǰ��·��'] := rec.nJKLineID;
    subNode.Attributes['��ǰ���ݽ�·��'] := rec.nDataLineID;
    subNode.Attributes['�ѹ���վ��'] := rec.nStation;
    subNode.Attributes['��һ��վ�Ľ�·��'] := rec.nToJKLineID;
    subNode.Attributes['��һ��վ�����ݽ�·��'] := rec.nToDataLineID;
    subNode.Attributes['��һ��վ���'] := rec.nToStation;
    subNode.Attributes['��վ���'] := rec.nStationIndex;
  end;
end;
procedure TXmlLkjRunTimeFile.ConvertLkjRuntimeFileToXml(LkjFile: TLKJRuntimeFile;XmlFileName : string);
var
  xmlDoc : TXMLDocument;
  xmlNode : IXMLNode;
  NewNode : IXMLNode;
begin
  xmlDoc := TXMLDocument.Create(nil);
  try
    xmlDoc.Active := True;
    xmlDoc.Version := '1.0';
    xmlDoc.Encoding := 'gb2312';
    xmlDoc.Options := [doNodeAutoCreate,doNodeAutoIndent,doAttrNull,doAutoPrefix,doNamespaceDecl];
    xmlDoc.DocumentElement := xmlDoc.CreateNode('FileList');
    xmlNode := xmlDoc.DocumentElement;


    NewNode := xmlNode.AddChild('HeadInfo');
    AddHeadInfoToXML(NewNode,LkjFile.HeadInfo);

    NewNode := xmlNode.AddChild('RewList');
    AddRewListToXML(NewNode,LkjFile);

    xmlDoc.SaveToFile(XmlFileName);
    
    xmlDoc.DocumentElement.ChildNodes.Clear;
  finally
    xmlDoc.Free;
  end;
end;

procedure TXmlLkjRunTimeFile.ConvertXmlToLkjRunTimeFile(XmlFileName: string;
  var LkjRuntimeFile: TLKJRuntimeFile);
var
  xmlDoc : IXMLDocument;
begin
  if Assigned(LkjRuntimeFile) then
    LkjRuntimeFile.Free;
  LkjRuntimeFile := TLKJRuntimeFile.Create(nil);

  xmlDoc := NewXMLDocument();
  try
    xmlDoc.LoadFromFile(XmlFileName);
    AddHeadInfoToLkjFile(xmlDoc.DocumentElement,LkjRuntimeFile);
    AddRewListToLkjFile(xmlDoc.DocumentElement,LkjRuntimeFile);
  finally
    xmlDoc := nil;
  end;
end;
end.
