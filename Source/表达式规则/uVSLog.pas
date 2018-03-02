unit uVSLog;

interface

uses
  SysUtils,Forms,xmldom, XMLIntf, msxmldom, XMLDoc,uVSConst,
  uVSSimpleExpress,uVSCombExpress,uLKJRuntimeFile;
type
  TVSXMLLog = class
  private
    m_xmlDoc : TXMLDocument;
    m_bOpenLog : boolean;
    m_xmlNode : IXMLNode;
  public
    {$region '���졢����'}
    constructor Create();
    destructor Destroy();override;
    {$endregion '���졢����'}
  public
    procedure AddRule(RuleTtile : string);
    function CreateCombExpress(VSExp : TVSExpression;var CurNode : Pointer):IXMLNode;
    procedure AddCombExpress(VSExp : TVSCombExpression;RecHead: RLKJRTFileHeadInfo; RecRow: TLKJRuntimeFileRec);
    procedure RebackCombExpress(VSExp : TVSCombExpression);
    procedure AddExpress(VSExp : TVSExpression;RecHead: RLKJRTFileHeadInfo; RecRow: TLKJRuntimeFileRec);
    property OpenLog : Boolean read m_bOpenLog write m_bOpenLog;
  end;
var
  VSLog : TVSXMLLog;
  ErrorHandle : THandle;
implementation

{ TVSXMLLog }

function TVSXMLLog.CreateCombExpress(VSExp: TVSExpression;var CurNode : Pointer):IXMLNode;
var
  strTitle : string;
begin
  if not OpenLog then exit;
  
  strTitle := 'δ������ϱ��ʽ';
  if (VSExp.Title <> '') then
    strTitle := VSExp.Title;    
  Result := m_xmlNode;
  m_xmlNode := m_xmlNode.AddChild(strTitle);
  CurNode := Pointer(m_xmlNode);
end;

procedure TVSXMLLog.AddCombExpress(VSExp: TVSCombExpression;
  RecHead: RLKJRTFileHeadInfo; RecRow: TLKJRuntimeFileRec);
begin
  if not OpenLog then Exit;
  try
    m_xmlNode := IXMLNode(VSExp.ParentData);
    IXMLNode(VSExp.CurData).Attributes['���'] := VSExp.GetStateText(VSExp.State);
    if RecRow <> nil then
      IXMLNode(VSExp.CurData).Attributes['ʱ��'] := FormatDatetime('HHmmss',TLKJCommonRec(RecRow).CommonRec.DTEvent);
  except
    //application.MessageBox(PChar(VSExp.Title),'',0);
  end;
end;

procedure TVSXMLLog.AddExpress(VSExp: TVSExpression;RecHead: RLKJRTFileHeadInfo; RecRow: TLKJRuntimeFileRec);
var
  xmlnode : IXMLNode;
  strTitle : string;
begin
  if not OpenLog then exit;
  try
    strTitle := 'δ�������ʽ';
    if (vsExp.Title <> '') then
      strTitle := VSExp.Title;
    {$region 'TVSCompExpression'}
    if VSExp.ClassName = 'TVSCompExpression' then
    begin
      xmlnode := m_xmlNode.AddChild(strTitle);
      xmlnode.Attributes['���'] := TVSExpression.GetStateText(VSExp.State);
      xmlnode.Attributes['ʵ��ֵ'] := VSExp.GetRecValue(TVSCompExpression(VSExp).Key,RecHead,RecRow);
      exit;
    end;
    {$endregion 'TVSCompExpression'}

    {$region 'TVSCompExpExpression'}
    if VSExp.ClassName = 'TVSCompExpExpression' then
    begin
      xmlnode := m_xmlNode.AddChild(strTitle);
      xmlnode.Attributes['���'] := TVSExpression.GetStateText(VSExp.State);
      exit;
    end;
    {$endregion 'TVSCompExpExpression'}
    
    {$region 'TVSOrderExpression'}
    if VSExp.ClassName = 'TVSOrderExpression' then
    begin
      xmlnode := m_xmlNode.AddChild(strTitle);
      xmlnode.Attributes['���'] := TVSExpression.GetStateText(VSExp.State);
      xmlnode.Attributes['��ֵ'] := '��';
      if VSExp.AcceptData <> nil then
      begin
        xmlnode.Attributes['��ֵ'] :=  VSExp.GetRecValue(TVSCompExpression(VSExp).Key,RecHead,VSExp.AcceptData);
      end;
      xmlnode.Attributes['��һ��ֵ'] := '';
      if VSExp.LastData <> nil then
      begin
        xmlnode.Attributes['��һ��ֵ'] :=  VSExp.GetRecValue(TVSCompExpression(VSExp).Key,RecHead,VSExp.LastData);
      end;
      xmlnode.Attributes['ʵ��ֵ'] := VSExp.GetRecValue(TVSCompExpression(VSExp).Key,RecHead,RecRow);
      exit;
    end;
    {$endregion 'TVSOrderExpression'}

    {$region 'TVSOffsetExpression'}
    if VSExp.ClassName = 'TVSOffsetExpression' then
    begin
      try
        xmlnode := m_xmlNode.AddChild(strTitle);
      except
        on e : Exception do
        begin
          
        end;
      end;
      xmlnode.Attributes['���'] := TVSExpression.GetStateText(VSExp.State);
      xmlnode.Attributes['��ֵ'] := '��';
      if VSExp.AcceptData <> nil then
      begin
        xmlnode.Attributes['��ֵ'] :=  VSExp.GetRecValue(TVSCompExpression(VSExp).Key,RecHead,VSExp.AcceptData);
      end;
      xmlnode.Attributes['��һ��ֵ'] := '';
      if VSExp.LastData <> nil then
      begin
        xmlnode.Attributes['��һ��ֵ'] :=  VSExp.GetRecValue(TVSCompExpression(VSExp).Key,RecHead,VSExp.LastData);
      end;
      xmlnode.Attributes['ʵ��ֵ'] := VSExp.GetRecValue(TVSCompExpression(VSExp).Key,RecHead,RecRow);
      exit;
    end;
    {$endregion 'TVSOffsetExpression'}

    {$region 'TVSSpecial3201Expression'}
    if VSExp.ClassName = 'TVSSpecial3201Expression' then
    begin
      xmlnode := m_xmlNode.AddChild(strTitle);
      xmlnode.Attributes['���'] := TVSExpression.GetStateText(VSExp.State);
    end;
    {$endregion 'TVSSpecial3201Expression'}

    {$region 'TVSCompBehindExpression'}
    if VSExp.ClassName = 'TVSCompBehindExpression' then
    begin
      xmlnode := m_xmlNode.AddChild(strTitle);
      xmlnode.Attributes['���'] := TVSExpression.GetStateText(VSExp.State);
      xmlnode.Attributes['��ֵ'] := '��';
      xmlnode.Attributes['βֵ'] := '��';
      if TVSCompBehindExpression(VSExp).FrontExp.GetData <> nil then
        xmlnode.Attributes['��ֵ'] := VSExp.GetRecValue(TVSCompBehindExpression(VSExp).Key,RecHead,TVSCompBehindExpression(VSExp).FrontExp.GetData);
      if TVSCompBehindExpression(VSExp).BehindExp.GetData <> nil then  
      xmlnode.Attributes['βֵ'] := VSExp.GetRecValue(TVSCompBehindExpression(VSExp).Key,RecHead,TVSCompBehindExpression(VSExp).BehindExp.GetData);
    end;
    {$endregion 'TVSCompBehindExpression'}
  finally
    if (xmlNode <> nil) and (RecRow <> nil) then
      xmlnode.Attributes['ʱ��'] := FormatDatetime('HHmmss',TLKJCommonRec(RecRow).CommonRec.DTEvent);
  end;
end;

procedure TVSXMLLog.AddRule(RuleTtile : string);
var
  strTitle : string;
begin
  if not OpenLog then exit;
  strTitle := 'δ��������';
  if RuleTtile <> '' then
  begin
    strTitle := RuleTtile;
  end;
  m_xmlNode := m_xmlDoc.DocumentElement.AddChild(strTitle);
end;

constructor TVSXMLLog.Create;
begin
  m_xmlDoc := TXMLDocument.Create(nil);
  m_xmlDoc.Active := True;
  m_xmlDoc.Version := '1.0';
  m_xmlDoc.Encoding := 'gb2312';
  m_xmlDoc.Options := [doNodeAutoCreate,doNodeAutoIndent,doAttrNull,doAutoPrefix,doNamespaceDecl];
  m_xmlDoc.DocumentElement := m_xmlDoc.CreateNode('RuleList');
end;

destructor TVSXMLLog.Destroy;
begin
  if OpenLog then
  begin
    if not DirectoryExists(ExtractFilePath(Application.ExeName) +  'log\') then
    begin
      CreateDir(ExtractFilePath(Application.ExeName) +  'log\')
    end;
    m_xmlDoc.SaveToFile(ExtractFilePath(Application.ExeName) +  'log\' + FormatDateTime('yyMMddHHmmss',now));
    m_xmlDoc.DocumentElement.ChildNodes.Clear;
  end;
  m_xmlDoc.Free;
  inherited;
end;

procedure TVSXMLLog.RebackCombExpress(VSExp: TVSCombExpression);
begin
  if not OpenLog then Exit;
  m_xmlNode := IXMLNode(VSExp.ParentData);
end;

end.
