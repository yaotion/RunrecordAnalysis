unit uXMLLkjRunTimeFile;

interface
uses
  SysUtils,Forms,xmldom, XMLIntf, msxmldom, XMLDoc,uLKJRuntimeFile,Windows;
type
////////////////////////////////////////////////////////////////////////////////
/// TXmlLkjRunTimeFile 功能：实现 TLKJRuntimeFile 与XML文件相互转换
////////////////////////////////////////////////////////////////////////////////
  TXmlLkjRunTimeFile = class
    private
      procedure AddHeadInfoToXML(NewNode : IXMLNode;HeadInfo: RLKJRTFileHeadInfo);
      procedure AddRewListToXML(NewNode : IXMLNode;LkjFile : TLKJRuntimeFile);
      procedure AddHeadInfoToLkjFile(NewNode : IXMLNode;LkjFile : TLKJRuntimeFile);
      procedure AddRewListToLkjFile(NewNode : IXMLNode;LkjFile : TLKJRuntimeFile);
    public
      //功能：把TLKJRuntimeFile转换为Xml文件
      procedure ConvertLkjRuntimeFileToXml(LkjFile : TLKJRuntimeFile;XmlFileName : string);
      //功能：把Xml文件转换为TLKJRuntimeFile
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
    nLocoID := subNode.Attributes['机车编号'];
    nLocoType := subNode.Attributes['机车型号'];
    strTrainHead := subNode.Attributes['车次头'];
    nTrainNo := subNode.Attributes['车次'];
    nDistance := subNode.Attributes['走行距离'];
    nJKLineID := subNode.Attributes['交路号'];
    nDataLineID := subNode.Attributes['数据交路号'];
    nFirstDriverNO := subNode.Attributes['司机工号'];
    nSecondDriverNO := subNode.Attributes['副司机号'];
    nStartStation := subNode.Attributes['始发站'];
    nEndStation := subNode.Attributes['终点站'];
    nLocoJie := subNode.Attributes['机车单节'];
    nDeviceNo := subNode.Attributes['装置号'];
    nTotalWeight := subNode.Attributes['总重'];
    nSum := subNode.Attributes['合计'];
    nLoadWeight := subNode.Attributes['载重'];
    nJKVersion := subNode.Attributes['监控版本'];
    nDataVersion := subNode.Attributes['数据版本'];
    DTFileHeadDt := StrToDateTime(subNode.Attributes['文件头时间']);
    Factory := subNode.Attributes['软件厂家'];
    TrainType := subNode.Attributes['客货类型'];
    BenBu := subNode.Attributes['本补'];
    nStandardPressure := subNode.Attributes['标准管压'];
    nMaxLmtSpd := subNode.Attributes['输入最高限速'];
  end;

end;

procedure TXmlLkjRunTimeFile.AddHeadInfoToXML(NewNode: IXMLNode;
  HeadInfo: RLKJRTFileHeadInfo);
begin
  with HeadInfo do
  begin
    NewNode.Attributes['机车编号'] := nLocoID;
    NewNode.Attributes['机车型号'] := nLocoType;
    NewNode.Attributes['车次头'] := strTrainHead;
    NewNode.Attributes['车次'] := nTrainNo ;
    NewNode.Attributes['走行距离'] := nDistance ;
    NewNode.Attributes['交路号'] := nJKLineID ;
    NewNode.Attributes['数据交路号'] := nDataLineID ;
    NewNode.Attributes['司机工号'] := nFirstDriverNO ;
    NewNode.Attributes['副司机号'] := nSecondDriverNO ;
    NewNode.Attributes['始发站'] := nStartStation ;
    NewNode.Attributes['终点站'] := nEndStation ;
    NewNode.Attributes['机车单节'] := nLocoJie ;
    NewNode.Attributes['装置号'] := nDeviceNo ;
    NewNode.Attributes['总重'] := nTotalWeight ;
    NewNode.Attributes['合计'] := nSum ;
    NewNode.Attributes['载重'] := nLoadWeight ;
    NewNode.Attributes['监控版本'] := nJKVersion ;
    NewNode.Attributes['数据版本'] := nDataVersion ;
    NewNode.Attributes['文件头时间'] := DTFileHeadDt ;
    NewNode.Attributes['软件厂家'] := Factory ;
    NewNode.Attributes['客货类型'] := TrainType ;
    NewNode.Attributes['本补'] := BenBu ;
    NewNode.Attributes['标准管压'] := nStandardPressure  ;
    NewNode.Attributes['输入最高限速'] := nMaxLmtSpd  ;
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

    rec.nRow := subNode.Attributes['行号'];
    rec.nEvent := subNode.Attributes['事件代码'];
    rec.DTEvent := StrToDateTime(subNode.Attributes['事件时间']);
    rec.nCoord := subNode.Attributes['公里标'];
    rec.nDistance := subNode.Attributes['距离'];
    rec.LampSign := subNode.Attributes['机车信号'];
    rec.nLampNo := subNode.Attributes['信号机编号'];
    rec.SignType := subNode.Attributes['信号机类型'];
    rec.nSpeed := subNode.Attributes['速度'];
    rec.nLimitSpeed := subNode.Attributes['限速'];
    rec.WorkZero := subNode.Attributes['零非工况'];
    rec.HandPos := subNode.Attributes['前后工况'];
    rec.WorkDrag :=subNode.Attributes['牵制工况'];
    rec.nLieGuanPressure := subNode.Attributes['管压'];
    rec.nGangPressure := subNode.Attributes['缸压'];
    rec.nRotate := subNode.Attributes['柴速'];
    rec.nJG1Pressure := subNode.Attributes['均缸1'];
    rec.nJG2Pressure := subNode.Attributes['均缸2'];
    rec.strOther := subNode.Attributes['其它'];
    rec.nJKLineID := subNode.Attributes['当前交路号'];
    rec.nDataLineID := subNode.Attributes['当前数据交路号'];
    rec.nStation := subNode.Attributes['已过车站号'];
    rec.nToJKLineID := subNode.Attributes['上一个站的交路号'];
    rec.nToDataLineID := subNode.Attributes['上一个站的数据交路号'];
    rec.nToStation := subNode.Attributes['上一个站编号'];
    rec.nStationIndex := subNode.Attributes['车站编号'];

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

    subNode := NewNode.AddChild('记录' + IntToStr(i));

    subNode.Attributes['行号'] := rec.nRow;
    subNode.Attributes['事件代码'] := rec.nEvent;
    subNode.Attributes['事件时间'] := rec.DTEvent;
    subNode.Attributes['公里标'] := rec.nCoord;
    subNode.Attributes['距离'] := rec.nDistance;
    subNode.Attributes['机车信号'] := rec.LampSign;
    subNode.Attributes['信号机编号'] := rec.nLampNo;
    subNode.Attributes['信号机类型'] := rec.SignType;
    subNode.Attributes['速度'] := rec.nSpeed;
    subNode.Attributes['限速'] := rec.nLimitSpeed;
    subNode.Attributes['零非工况'] := rec.WorkZero;
    subNode.Attributes['前后工况'] := rec.HandPos;
    subNode.Attributes['牵制工况'] := rec.WorkDrag;
    subNode.Attributes['管压'] := rec.nLieGuanPressure;
    subNode.Attributes['缸压'] := rec.nGangPressure;
    subNode.Attributes['柴速'] := rec.nRotate;
    subNode.Attributes['均缸1'] := rec.nJG1Pressure;
    subNode.Attributes['均缸2'] := rec.nJG2Pressure;
    subNode.Attributes['其它'] := rec.strOther;
    subNode.Attributes['当前交路号'] := rec.nJKLineID;
    subNode.Attributes['当前数据交路号'] := rec.nDataLineID;
    subNode.Attributes['已过车站号'] := rec.nStation;
    subNode.Attributes['上一个站的交路号'] := rec.nToJKLineID;
    subNode.Attributes['上一个站的数据交路号'] := rec.nToDataLineID;
    subNode.Attributes['上一个站编号'] := rec.nToStation;
    subNode.Attributes['车站编号'] := rec.nStationIndex;
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
