unit uVSRuleReader;

interface

uses
  Classes,Contnrs,xmldom, XMLIntf, msxmldom,XMLDoc,
    uVSRules,uVSSimpleExpress,uVSCombExpress;
type
  TVSRuleReader = class
  private
    m_XMLDoc : IXMLDocument;
    m_RuleList : TList;
    m_ExpressList : array of TVSExpression;
  protected
    procedure LoadRuleInfo(Node : IXMLNode;Rule : TVSRule);
    procedure LoadExpression(Node : IXMLNode;out Express : TVSExpression);
    procedure LoadCompExpression(Node : IXMLNode;Express : TVSCompExpression);
    procedure LoadOrderExpression(Node : IXMLNode;Express : TVSOrderExpression);
    procedure LoadOffsetExpression(Node : IXMLNode;Express : TVSOffsetExpression);
    procedure LoadCompBehindExpression(Node : IXMLNode;Express : TVSCompBehindExpression);
    procedure LoadSimpleConditionExpression(Node:IXMLNode;Express : TVSSimpleConditionExpression);
    procedure LoadCombAndExpression(Node : IXMLNode;Express : TVSCombAndExpression);
    procedure LoadCombOrExpression(Node : IXMLNode;Express : TVSCombOrExpression);
    procedure LoadCombOrderExpression(Node : IXMLNode;Express : TVSCombOrderExpression);
    procedure LoadCombIntervalExpression(Node : IXMLNode;Express : TVSCombIntervalExpression);
    procedure LoadCombNoIntervalExpression(Node : IXMLNode;Express : TVSCombNoIntervalExpression);
    //根据已生成的表达式ID获取表达式
    function  FindExpress(ExpressID : string) : TVSExpression;
  public
    procedure LoadFromXML(XMLFile : string);
  public
    constructor Create(RuleList : TObjectList);
    destructor Destroy;override;
  end;
implementation

{ TVSRuleReader }

constructor TVSRuleReader.Create(RuleList: TObjectList);
begin
  m_RuleList := RuleList;
end;

destructor TVSRuleReader.Destroy;
begin
  m_XMLDoc := nil;
  inherited;
end;

function TVSRuleReader.FindExpress(ExpressID: string): TVSExpression;
var
  i: Integer;
begin
  result := nil;
  if ExpressID = '' then exit;
  
  for i := 0 to length(m_ExpressList) - 1 do
  begin
    if m_ExpressList[i] <> nil then
    begin
      if m_ExpressList[i].ExpressID = ExpressID then
      begin
        Result := m_ExpressList[i];
        break;
      end;
    end;
  end;
end;

procedure TVSRuleReader.LoadCombAndExpression(Node: IXMLNode;
  Express: TVSCombAndExpression);
var
  i: Integer;
  subNode : IXMLNode;
  exp : TVSExpression;
begin
  for i := 0 to Node.ChildNodes.Count - 1 do
  begin
    subNode := Node.ChildNodes[i];
    LoadExpression(subNode,exp);
    if exp <> nil then
    begin
      Express.Expressions.Add(exp);
    end;
  end;
end;

procedure TVSRuleReader.LoadCombIntervalExpression(Node: IXMLNode;
  Express: TVSCombIntervalExpression);
var
  exp : TVSExpression;
  subNode : IXMLNode;
begin
  Express.MatchFirst := Node.Attributes['MatchFirst'];
  Express.MatchMatch := Node.Attributes['MatchMatch'];
  Express.ReturnType := Node.Attributes['ReturnType'];

  subNode := node.ChildNodes.FindNode('BeginExpress');
  if subNode <> nil then
  begin
    LoadExpression(subNode,exp);
    if exp <> nil then
    begin
      Express.BeginExpression := exp;
    end;
  end;

  subNode := node.ChildNodes.FindNode('Expression');
  if subNode <> nil then
  begin
    LoadExpression(subNode,exp);
    if exp <> nil then
    begin
      Express.Expression := exp;
    end;
  end;

  subNode := node.ChildNodes.FindNode('EndExpress');
  if subNode <> nil then
  begin
    LoadExpression(subNode,exp);
    if exp <> nil then
    begin
      Express.EndExpression := exp;
    end;
  end;
end;

procedure TVSRuleReader.LoadCombNoIntervalExpression(Node: IXMLNode;
  Express: TVSCombNoIntervalExpression);
var
  exp : TVSExpression;
  subNode : IXMLNode;
begin
  subNode := node.ChildNodes.FindNode('BeginExpress');
  if subNode <> nil then
  begin
    LoadExpression(subNode,exp);
    if exp <> nil then
    begin
      Express.BeginExpression := exp;
    end;
  end;

  subNode := node.ChildNodes.FindNode('Expression');
  if subNode <> nil then
  begin
    LoadExpression(subNode,exp);
    if exp <> nil then
    begin
      Express.Expression := exp;
    end;
  end;

  subNode := node.ChildNodes.FindNode('EndExpress');
  if subNode <> nil then
  begin
    LoadExpression(subNode,exp);
    if exp <> nil then
    begin
      Express.EndExpression := exp;
    end;
  end;
end;

procedure TVSRuleReader.LoadCombOrderExpression(Node: IXMLNode;
  Express: TVSCombOrderExpression);
var
  i: Integer;
  subNode : IXMLNode;
  exp : TVSExpression;
begin
  Express.MatchedIndex := Node.Attributes['MatchedIndex'];
  Express.BeginIndex := Node.Attributes['BeginIndex'];
  Express.EndIndex := Node.Attributes['EndIndex'];
  for i := 0 to Node.ChildNodes.Count - 1 do
  begin
    subNode := Node.ChildNodes[i];
    LoadExpression(subNode,exp);
    if exp <> nil then
    begin
      Express.Expressions.Add(exp);
    end;
  end;
end;

procedure TVSRuleReader.LoadCombOrExpression(Node: IXMLNode;
  Express: TVSCombOrExpression);
var
  i: Integer;
  subNode : IXMLNode;
  exp : TVSExpression;
begin
  for i := 0 to Node.ChildNodes.Count - 1 do
  begin
    subNode := Node.ChildNodes[i];
    LoadExpression(subNode,exp);
    if exp <> nil then
    begin
      Express.Expressions.Add(exp);
    end;
  end;
end;

procedure TVSRuleReader.LoadCompBehindExpression(Node: IXMLNode;
  Express: TVSCompBehindExpression);
begin
  Express.Key := Node.Attributes['Key'];
  Express.OperatorSignal := Node.Attributes['OperatorSignal'];
  Express.Value := Node.Attributes['Value'];
  Express.CompDataType := Node.Attributes['CompDataType'];
  Express.FrontExp := FindExpress(Node.Attributes['FrontExp']);
  Express.BehindExp := FindExpress(Node.Attributes['BehindExp']);
end;

procedure TVSRuleReader.LoadCompExpression(Node: IXMLNode;
  Express: TVSCompExpression);
begin
  Express.Key := Node.Attributes['Key'];
  Express.OperatorSignal := Node.Attributes['OperatorSignal'];
  Express.Value := Node.Attributes['Value'];
end;

procedure TVSRuleReader.LoadExpression(Node: IXMLNode;out Express: TVSExpression);
begin
  Express := nil;
  try
    if node.Attributes['Type'] = 'TVSCompExpression' then
    begin
      Express := TVSCompExpression.Create;
      LoadCompExpression(Node,TVSCompExpression(Express));
      exit;
    end;
    if node.Attributes['Type'] = 'TVSOrderExpression' then
    begin
      Express := TVSOrderExpression.Create;
      LoadOrderExpression(Node,TVSOrderExpression(Express));
      exit;
    end;
    if node.Attributes['Type'] = 'TVSOffsetExpression' then
    begin
      Express := TVSOffsetExpression.Create;
      LoadOffsetExpression(Node,TVSOffsetExpression(Express));
      exit;
    end;
    if node.Attributes['Type'] = 'TVSCompBehindExpression' then
    begin
      Express := TVSCompBehindExpression.Create;
      LoadCompBehindExpression(Node,TVSCompBehindExpression(Express));
      exit;
    end;
    if node.Attributes['Type'] = 'TVSCombAndExpression' then
    begin
      Express := TVSCombAndExpression.Create;
      LoadCombAndExpression(Node,TVSCombAndExpression(Express));
      exit;
    end;
    if node.Attributes['Type'] = 'TVSCombOrExpression' then
    begin
      Express := TVSCombOrExpression.Create;
      LoadCombOrExpression(Node,TVSCombOrExpression(Express));
      exit;
    end;
    if node.Attributes['Type'] = 'TVSCombOrderExpression' then
    begin
      Express := TVSCombOrderExpression.Create;
      LoadCombOrderExpression(Node,TVSCombOrderExpression(Express));
      exit;
    end;
    if node.Attributes['Type'] = 'TVSCombIntervalExpression' then
    begin
      Express := TVSCombIntervalExpression.Create;
      LoadCombIntervalExpression(Node,TVSCombIntervalExpression(Express));
      exit;
    end;
    if node.Attributes['Type'] = 'TVSCombNoIntervalExpression' then
    begin
      Express := TVSCombNoIntervalExpression.Create;
      LoadCombNoIntervalExpression(Node,TVSCombNoIntervalExpression(Express));
      exit;
    end;
    if node.Attributes['Type'] = 'TVSSimpleConditionExpression' then
    begin
      Express := TVSSimpleConditionExpression.Create;
      LoadSimpleConditionExpression(Node,TVSSimpleConditionExpression(Express));
      exit;
    end;

  finally
    if Express <> nil then
    begin
      if node.HasAttribute('ExpressID') then
      begin
        express.ExpressID := node.Attributes['ExpressID'];
      end;
      if node.HasAttribute('Title') then
      begin
        express.Title := node.Attributes['Title'];
      end;
      SetLength(m_ExpressList,length(m_ExpressList) + 1);
      m_ExpressList[length(m_ExpressList) - 1] := Express;      
    end;
  end;
end;

procedure TVSRuleReader.LoadFromXML(XMLFile: string);
var
  root,node,subNode : IXMLNode;
  rule : TVSRule;
  exp : TVSExpression;
  i: Integer;
begin
  m_XMLDoc := NewXMLDocument();
  try
    m_XMLDoc.LoadFromFile(XMLFile);
    root := m_XMLDoc.DocumentElement;
    if (root.NodeName <> 'RunrecordRules') then exit;
    for i := 0 to root.ChildNodes.Count - 1 do
    begin
      node := root.ChildNodes[i];
      rule := TVSRule.Create;
      SetLength(m_ExpressList,0);
      LoadRuleInfo(node,rule);
      subNode := node.ChildNodes.FindNode('HeadExpression');
      if subNode <> nil then
      begin
        LoadExpression(subNode,exp);
        if exp <> nil then
        begin
          rule.HeadExpression := exp;
        end;
      end;

      subNode := node.ChildNodes.FindNode('RootExpression');
      begin
        LoadExpression(subNode,exp);
        if exp <> nil then
        begin
          rule.RootExpression := exp;
        end;
      end;
      SetLength(m_ExpressList,0);
      m_RuleList.Add(rule);
    end;
  finally
    m_xmlDoc := nil;
  end;
end;

procedure TVSRuleReader.LoadOffsetExpression(Node: IXMLNode;
  Express: TVSOffsetExpression);
begin
  Express.Key := Node.Attributes['Key'];
  Express.Order := Node.Attributes['Order'];
  Express.Value := Node.Attributes['Order'];
  Express.IncludeEqual := Node.Attributes['IncludeEqual'];
  Express.BreakLimit := Node.Attributes['BreakLimit'];
end;

procedure TVSRuleReader.LoadOrderExpression(Node: IXMLNode;
  Express: TVSOrderExpression);
begin
  Express.Key := Node.Attributes['Key'];
  Express.Order := Node.Attributes['Order'];
end;

procedure TVSRuleReader.LoadRuleInfo(Node: IXMLNode; Rule: TVSRule);
begin
  Rule.Title := Node.Attributes['Title'];
  Rule.ID := Node.Attributes['ID'];
end;

procedure TVSRuleReader.LoadSimpleConditionExpression(Node: IXMLNode;
  Express: TVSSimpleConditionExpression);
var
  exp : TVSExpression;
  subNode : IXMLNode;
begin
  subNode := node.ChildNodes.FindNode('Expression');
  if subNode <> nil then
  begin
    LoadExpression(subNode,exp);
    if exp <> nil then
    begin
      Express.Expression := exp;
    end;
  end;
end;

end.
