unit uRtFileReaderBase;

interface
uses
  Classes,uLKJRuntimeFile,uRtHeadInfoReader,SysUtils,uVSConst;
type
  TRunTimeFileReaderBase = class
  public
    procedure ReadHead(FileName : string;var HeadInfo: RLKJRTFileHeadInfo);virtual;
    procedure LoadFromFile(FileName : string;RuntimeFile : TLKJRuntimeFile);virtual;abstract;
    procedure LoadFromFiles(FileList : TStrings;RuntimeFile : TLKJRuntimeFile);virtual;
  end;

{功能：转换原始文件为格式化文件}
  function FmtLkjOrgFile(orgFile: string): string;
implementation
function FmtLkjOrgFile(orgFile: string): string;
{功能：转换原始文件为格式化文件}
var
  strFormatFile : string;
  strPath: string;
begin
  strPath := ExtractFilePath(ParamStr(0));
  strFormatFile := strPath + 'format\';
  if not DirectoryExists(strFormatFile) then
    ForceDirectories(strFormatFile);

  strFormatFile := strFormatFile + ExtractFileName(orgFile) + 'f';
  NewFmtFile(strPath,orgFile,strFormatFile);
  Result := strFormatFile;
end;

{ TRunTimeFileReaderBase }

procedure TRunTimeFileReaderBase.LoadFromFiles(FileList: TStrings;
  RuntimeFile: TLKJRuntimeFile);
var
  tempList,orderList : TStrings;
  dtMin : TDateTime;
  header : RLKJRTFileHeadInfo;
  i,nIndex: Integer;
begin
  tempList := TStringList.Create;
  tempList.AddStrings(FileList);
  //按文件的头信息中的运行记录生成时间排序,从小到大
  orderList := TStringList.Create;
  try
    while tempList.Count > 0 do
    begin
      dtMin := 10000000;
      nIndex := -1;
      for i := 0 to tempList.Count - 1 do
      begin
        ReadHead(tempList[i],header);
        if dtMin > header.DTFileHeadDt then
        begin
          dtMin := header.DTFileHeadDt;
          nIndex := i;
        end;
      end;
      orderList.Add(tempList[nIndex]);
      tempList.Delete(nIndex);
    end;

    //将多个文件的运行记录组合成一个列表，并以时间最小的文件的头文件信息为
    //整个结构的头文件
    RuntimeFile.Clear;
    for i := 0 to orderList.Count - 1 do
    begin
      if i = 0 then
      begin
        ReadHead(orderList[i],header);
      end;
      LoadFromFile(orderList[i], RuntimeFile);
    end;
    RuntimeFile.HeadInfo := header;
  finally
    tempList.Free;
    orderList.Free;
  end;
end;

procedure TRunTimeFileReaderBase.ReadHead(FileName: string;
  var HeadInfo: RLKJRTFileHeadInfo);
var
  OrgHeadReader: TOrgHeadReader;
begin
  OrgHeadReader := TOrgHeadReader.Create;
  try
    OrgHeadReader.read(FileName,HeadInfo);
  finally
    OrgHeadReader.Free;
  end;
end;

end.
