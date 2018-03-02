unit uVSAnalysisResultList;
{Υ����൥Ԫ}
interface

uses classes, SysUtils, Contnrs;

type
  //���м�¼���������¼���Ϣ
  TLKJEventDetail = class
    //�¼��������¼�
    dtCurrentTime : TDateTime;
    //�¼���Χ�Ŀ�ʼʱ��
    dtBeginTime : TDateTime;
    //�¼���Χ�Ľ���ʱ��
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

  //�¼��б�
  TLKJEventItem = class
  public
    //��ʼǰ������(��СΪ0)
    nBeforeSeconds : Cardinal;
    //�����������(��СΪ0)
    nAfterSeconds : Cardinal;
    //�����¼�������
    strEventID : string;
    //�����¼�����
    strEvent:string;
    //���������¼���Ϣ����
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
  //��ʼǰ������(��СΪ0)
  nBeforeSeconds := 0;
  //�����������(��СΪ0)
  nAfterSeconds := 0;
  //�����¼�������
  strEventID :='';
  //�����¼�����
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


