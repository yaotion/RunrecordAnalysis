unit uRtHeadInfoReader;

interface
uses
  uBytesStream,Classes,SysUtils,uLKJRuntimeFile,Math, Windows;
type
  TOrgHeadReader = class
  public
    constructor Create();
    destructor Destroy; override;
  public
    procedure read(orgFileName: string;var HeadInfo: RLKJRTFileHeadInfo);
  private
    m_BytesStream : TBytesStream;
    function BCDToHex(nBcd: Byte): Integer;
    function MoreBcdToHex(nBegin, nLen: Integer): Integer;
    function ConvertFactory(b : byte): TLKJFactory;
    function ConvertTrainType(b: byte): TLKJTrainType;
    function ConvertBenBu(b: byte): TLKJBenBu;
  end;
implementation

{ TOrgHeadReader }

function TOrgHeadReader.BCDToHex(nBcd: Byte): Integer;
begin
  Result := (nBcd div 16) * 10 + (nBcd mod 16);
end;

function TOrgHeadReader.ConvertFactory(b: byte): TLKJFactory;
begin
  if b = $53 then
     Result := sfSiWei
  else
     Result :=sfZhuZhou;
end;

function TOrgHeadReader.ConvertTrainType(b: byte): TLKJTrainType;
begin
     if b mod 2 = 1 then
        Result := ttPassenger
     else
        Result := ttCargo;
end;
function TOrgHeadReader.ConvertBenBu(b: byte): TLKJBenBu;
begin
  if ((b mod 4) div 2) = 1 then
     Result := bbBu
  else
     Result := bbBen;
end;
constructor TOrgHeadReader.Create;
begin
  m_BytesStream := TBytesStream.Create(128);
end;

destructor TOrgHeadReader.Destroy;
begin
  m_BytesStream.Free;
  inherited;
end;

function TOrgHeadReader.MoreBcdToHex(nBegin, nLen: Integer): Integer;
var
  i: integer;
  k: Extended;
  l: Integer;
begin
  k := 0;
  l := 0;
  for i := nLen - 1 downto 0 do
  begin

    k := k + BcdToHex(m_BytesStream.GetBuffer(nBegin + i)^) * Power(100, l);
    Inc(l);
  end;
  Result := Round(k);
end;
procedure TOrgHeadReader.read(orgFileName: string;var HeadInfo: RLKJRTFileHeadInfo);
begin
  FillChar(HeadInfo,SizeOf(RLKJRTFileHeadInfo),0);
  m_BytesStream.LoadFromFile(orgFileName);
  HeadInfo.nLocoType := MoreBcdToHex(56, 3);
  HeadInfo.nLocoID := MoreBcdToHex(60, 3);

  with m_BytesStream do
  begin
    HeadInfo.strTrainHead :=
      chr(Get(10))+chr(Get(10)) + chr(Get(10))+chr(Get(10));

    HeadInfo.Factory := ConvertFactory(Get(86));
    HeadInfo.DTFileHeadDt := EncodeDate(BCDToHex(Get(2))+2000,BCDToHex(Get(3)),
      BCDToHex(Get(4))) +
      EncodeTime(MoreBcdToHex(5, 1),MoreBcdToHex(6, 1),MoreBcdToHex(7, 1),0);
  end;
  HeadInfo.nTrainNo := MoreBcdToHex(14, 3) mod 1000000;
  HeadInfo.nLunJing := MoreBcdToHex(64, 3);
  HeadInfo.nJKLineID := MoreBcdToHex(19, 2);
  HeadInfo.nDataLineID := MoreBcdToHex(17, 1);
  HeadInfo.nFirstDriverNO := MoreBcdToHex(24, 4);
  HeadInfo.nSecondDriverNO := MoreBcdToHex(28, 4);
  HeadInfo.nDeviceNo:= MoreBcdToHex(89, 3);
  HeadInfo.nTotalWeight := MoreBcdToHex(34, 3);
  HeadInfo.nSum := MoreBcdToHex(52, 2);
  HeadInfo.nLoadWeight := MoreBcdToHex(37, 3);
  HeadInfo.nJKVersion := MoreBcdToHex(78,4);
  HeadInfo.nDataVersion := MoreBcdToHex(82,4);
  HeadInfo.nStartStation := MoreBcdToHex(22, 2);

  HeadInfo.TrainType := ConvertTrainType(MoreBcdToHex(9, 1) mod 4);
  HeadInfo.BenBu := ConvertBenBu(MoreBcdToHex(9, 1) mod 4);

end;

end.
