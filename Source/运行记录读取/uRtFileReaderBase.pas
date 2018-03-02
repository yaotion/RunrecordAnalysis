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

{���ܣ�ת��ԭʼ�ļ�Ϊ��ʽ���ļ�}
  function FmtLkjOrgFile(orgFile: string): string;
implementation
function FmtLkjOrgFile(orgFile: string): string;
{���ܣ�ת��ԭʼ�ļ�Ϊ��ʽ���ļ�}
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
  //���ļ���ͷ��Ϣ�е����м�¼����ʱ������,��С����
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

    //������ļ������м�¼��ϳ�һ���б�����ʱ����С���ļ���ͷ�ļ���ϢΪ
    //�����ṹ��ͷ�ļ�
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
