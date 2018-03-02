unit uVSAnalysisResultList;
{违标分类单元}
interface

uses classes, SysUtils, Contnrs;

type
  //运行记录分析出的事件信息
  TLKJEventDetail = class
    //事件发生的事件
    dtCurrentTime : TDateTime;
    //事件范围的开始时间
    dtBeginTime : TDateTime;
    //事件范围的结束时间
    dtEndTime : TDateTime;
  end;
  TLKJEventDetailList = class(TObjectList)
  protected
    function GetItem(Index: Integer): TLKJEventDetail;
    procedure SetItem(Index: Integer; AObject: TLKJEventDetail);
  public
    function Add(AObject: TLKJEventDetail): Integer;
    function IndexOf(AObject: TLKJEventDetail): Integer;
    procedure Insert(Index: Integer; AObject: TLKJEventDetail);
    property Items[Index: Integer]: TLKJEventDetail read GetItem write SetItem; default;
  end;

  //事件列表
  TLKJEventItem = class
  public
    //开始前多少秒(最小为0)
    nBeforeSeconds : Cardinal;
    //结束后多少秒(最小为0)
    nAfterSeconds : Cardinal;
    //所属事件定义编号
    strEventID : string;
    //所属事件名称
    strEvent:string;
    //分析出的事件信息数组
    DetailList : TLKJEventDetailList;
  public
    constructor Create;
    destructor Destroy;override;
  end;

  TLKJEventList = class(TObjectList)
  protected
    function GetItem(Index: Integer): TLKJEventItem;
    procedure SetItem(Index: Integer; AObject: TLKJEventItem);
  public
    function Add(AObject: TLKJEventItem): Integer;
    function IndexOf(AObject: TLKJEventItem): Integer;
    procedure Insert(Index: Integer; AObject: TLKJEventItem);
    property Items[Index: Integer]: TLKJEventItem read GetItem write SetItem; default;
  end;



implementation



{ TLKJEventDetailList }

function TLKJEventDetailList.Add(AObject: TLKJEventDetail): Integer;
begin
  Result := inherited Add(AObject);
end;

function TLKJEventDetailList.GetItem(Index: Integer): TLKJEventDetail;
begin
  Result := TLKJEventDetail(inherited Items[Index]);
end;

function TLKJEventDetailList.IndexOf(AObject: TLKJEventDetail): Integer;
begin
  Result := inherited IndexOf(AObject);
end;

procedure TLKJEventDetailList.Insert(Index: Integer; AObject: TLKJEventDetail);
begin
  inherited Insert(Index, AObject);
end;

procedure TLKJEventDetailList.SetItem(Index: Integer; AObject: TLKJEventDetail);
begin
  inherited Items[Index] := AObject;
end;

{ RLKJEventItem }

constructor TLKJEventItem.Create;
begin
  DetailList := TLKJEventDetailList.Create;
  //开始前多少秒(最小为0)
  nBeforeSeconds := 0;
  //结束后多少秒(最小为0)
  nAfterSeconds := 0;
  //所属事件定义编号
  strEventID :='';
  //所属事件名称
  strEvent:= '';
end;

destructor TLKJEventItem.Destroy;
begin
  DetailList.Free;
  inherited;
end;

{ TLKJEventArray }

function TLKJEventList.Add(AObject: TLKJEventItem): Integer;
begin
  Result := inherited Add(AObject);
end;

function TLKJEventList.GetItem(Index: Integer): TLKJEventItem;
begin
  Result := TLKJEventItem(inherited Items[Index]);
end;

function TLKJEventList.IndexOf(AObject: TLKJEventItem): Integer;
begin
  Result := inherited IndexOf(AObject);
end;

procedure TLKJEventList.Insert(Index: Integer; AObject: TLKJEventItem);
begin
  inherited Insert(Index, AObject);
end;

procedure TLKJEventList.SetItem(Index: Integer; AObject: TLKJEventItem);
begin
  inherited Items[Index] := AObject;
end;

end.


