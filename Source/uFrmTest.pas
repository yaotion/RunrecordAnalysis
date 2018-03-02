unit uFrmTest;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Grids, AdvObj, BaseGrid, AdvGrid, ExtCtrls, StdCtrls, ComCtrls,Contnrs,
  XPMan;

type
  TfrmTest = class(TForm)
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    Panel1: TPanel;
    Button1: TButton;
    Memo1: TMemo;
    AdvStringGrid1: TAdvStringGrid;
    TabSheet2: TTabSheet;
    Panel2: TPanel;
    btnAnalysis: TButton;
    Memo3: TMemo;
    Edit1: TEdit;
    TabSheet3: TTabSheet;
    Panel3: TPanel;
    btnTest: TButton;
    edtXMLFile: TEdit;
    edtRuleXML: TEdit;
    TabSheet4: TTabSheet;
    Panel4: TPanel;
    btnReadTimes: TButton;
    edtFiles: TEdit;
    edtRule: TEdit;
    Memo2: TMemo;
    OpenDialog1: TOpenDialog;
    XPManifest1: TXPManifest;
    RadioGroup1: TRadioGroup;
    rbtOrigin: TRadioButton;
    rbtADO: TRadioButton;
    rbtfmt: TRadioButton;
    procedure Button1Click(Sender: TObject);
    procedure btnAnalysisClick(Sender: TObject);
    procedure btnTestClick(Sender: TObject);
    procedure btnReadTimesClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmTest: TfrmTest;

implementation
uses
  uLKJRuntimeFile,uVSLib,uVSAnalysisResultList,uVSRuleReader,
  uVSConst, uRtAdoFileReader, uRtFileReaderBase, uRtOrgFileReader,
  uRtfmtFileReader;
{$R *.dfm}

procedure TfrmTest.btnReadTimesClick(Sender: TObject);
var
  analysis : TLKJAnalysis;
  OperationTime: ROperationTime;
  Files: TStringList;
  nTickCount: Cardinal;
begin
  memo2.Lines.Clear;
  if OpenDialog1.Execute then
  begin
    try
      nTickCount := GetTickCount;
      analysis := TLKJAnalysis.Create();         
      Files := TStringList.Create;
      try
        Files.AddStrings(OpenDialog1.Files);
        analysis.GetOperationTime(Files,OperationTime,edtRule.Text);
        Memo2.Lines.Add('���ʱ�䣺' + DateTimeToStr(OperationTime.inhousetime));
        Memo2.Lines.Add('�ӳ�ʱ�䣺' + DateTimeToStr(OperationTime.jctime));
        Memo2.Lines.Add('����ʱ�䣺' + DateTimeToStr(OperationTime.outhousetime));
        Memo2.Lines.Add('��վʱ�䣺' + DateTimeToStr(OperationTime.tqarrivetime));
        Memo2.Lines.Add('���ο��㣺' + DateTimeToStr(OperationTime.tqdat));
        Memo2.Lines.Add('����ʱ�䣺' + DateTimeToStr(OperationTime.jhtqtime));
        Memo2.Lines.Add('����ʱ��' + IntToStr(GetTickCount - nTickCount));
      finally
        analysis.Free;
        Files.Free;
      end;
    finally
      btnAnalysis.Enabled := true;
    end;
  end;

end;
procedure TfrmTest.btnTestClick(Sender: TObject);
var
  ruleReader : TVSRuleReader;
  ruleList : TObjectList;
begin
  ruleList := TObjectList.Create;
  try
    ruleReader := TVSRuleReader.Create(ruleList);
    try
      ruleReader.LoadFromXML(edtXMLFile.Text);
    finally
      ruleReader.Free;
    end;
  finally
    ruleList.Free;
  end;
end;

procedure TfrmTest.Button1Click(Sender: TObject);
var
  lkjFile : TLKJRuntimeFile;
  rec : TLKJCommonRec;
  i,tick: Cardinal;
  reader : TRunTimeFileReaderBase;
begin
  if OpenDialog1.Execute then
  begin
    memo1.Lines.Clear;
    Memo1.Lines.AddStrings(OpenDialog1.Files);
  end
  else
    Exit;

    
  lkjFile := TLKJRuntimeFile.Create();
  try
    tick := gettickcount;

    if rbtOrigin.Checked then
      reader := TOrgFileReader.Create()
    else
    if rbtfmt.Checked then
      reader := TfmtFileReader.Create()
    else
      reader := TAdoFileReader.Create();

    reader.LoadFromFiles(memo1.Lines,lkjFile);
    reader.Free;
    caption := IntToStr(gettickcount - tick);
    AdvStringGrid1.ColCount := 38;
    AdvStringGrid1.RowCount := lkjFile.Records.Count + 2;
    {$region '��ʼ����'}
    AdvStringGrid1.Cells[0,0] := '���';
    AdvStringGrid1.Cells[1,0] := '�¼�';
    AdvStringGrid1.Cells[2,0] := '�¼���';
    AdvStringGrid1.Cells[3,0] := '����ʱ��';
    AdvStringGrid1.Cells[4,0] := '�����';
    AdvStringGrid1.Cells[5,0] := '�źŻ�����';
    AdvStringGrid1.Cells[6,0] := '�ƺ�';
    AdvStringGrid1.Cells[7,0] := '�źŵ�';
    AdvStringGrid1.Cells[8,0] := '�źŻ�����';
    AdvStringGrid1.Cells[9,0] := '�źŻ����';

    AdvStringGrid1.Cells[10,0] := '�źŻ�';
    AdvStringGrid1.Cells[11,0] := '�ٶ�';
    AdvStringGrid1.Cells[12,0] := '����';
    AdvStringGrid1.Cells[13,0] := '�ֱ�';
    AdvStringGrid1.Cells[14,0] := '����';
    AdvStringGrid1.Cells[15,0] := '��λ';
    AdvStringGrid1.Cells[16,0] := 'ǰ��';
    AdvStringGrid1.Cells[17,0] := 'ǣ��';
    AdvStringGrid1.Cells[18,0] := '��ѹ';
    AdvStringGrid1.Cells[19,0] := '��ѹ';

    AdvStringGrid1.Cells[20,0] := 'ת��';
    AdvStringGrid1.Cells[21,0] := '����1';
    AdvStringGrid1.Cells[22,0] := '����2';
    AdvStringGrid1.Cells[23,0] := '����';
    AdvStringGrid1.Cells[24,0] := '��·��';
    AdvStringGrid1.Cells[25,0] := '���ݽ�·��';
    AdvStringGrid1.Cells[26,0] := '��վ��';
    AdvStringGrid1.Cells[27,0] := '��վ��·��';
    AdvStringGrid1.Cells[28,0] := '��վ���ݽ�·��';
    AdvStringGrid1.Cells[29,0] := '��վ��';

    AdvStringGrid1.Cells[30,0] := '��վ���';
    AdvStringGrid1.Cells[31,0] :='˵��';
    AdvStringGrid1.Cells[32,0] := '���״̬';
    AdvStringGrid1.Cells[33,0] := '�Ƿ��ڵ���';
    AdvStringGrid1.Cells[34,0] := '�Ƿ��ڽ���';
    AdvStringGrid1.Cells[35,0] := '�Ƿ���ƽ��';
    AdvStringGrid1.Cells[36,0] := '��Ч���׺�';
    AdvStringGrid1.Cells[37,0] := '��������';
    {$endregion '��ʼ����'}
    for i := 0 to lkjFile.Records.Count - 1 do
    begin
      {$region '���ݸ�ֵ'}
      rec := TLKJCommonRec(lkjFile.Records[i]);
      AdvStringGrid1.Cells[0,i+1] := Format('%d',[rec.CommonRec.nRow]);
      AdvStringGrid1.Cells[1,i+1] := Format('%s',[rec.CommonRec.strDisp]);
      AdvStringGrid1.Cells[2,i+1] := Format('%d',[rec.CommonRec.nEvent]);
      AdvStringGrid1.Cells[3,i+1] := Format('%s',[FormatDateTime('yyyyMMdd hh:nn:ss',rec.CommonRec.DTEvent)]);
      AdvStringGrid1.Cells[4,i+1] := Format('%d',[rec.CommonRec.nCoord]);
      AdvStringGrid1.Cells[5,i+1] := Format('%d',[rec.CommonRec.nDistance]);
      AdvStringGrid1.Cells[6,i+1] := Format('%d',[Ord(rec.CommonRec.LampSign)]);
      AdvStringGrid1.Cells[7,i+1] := Format('%s',[rec.CommonRec.strSignal]);
      AdvStringGrid1.Cells[8,i+1] := Format('%d',[Ord(rec.CommonRec.SignType)]);
      AdvStringGrid1.Cells[9,i+1] := Format('%d',[Ord(rec.CommonRec.nLampNo)]);

      AdvStringGrid1.Cells[10,i+1] := Format('%s',[rec.CommonRec.strXhj]);
      AdvStringGrid1.Cells[11,i+1] := Format('%d',[rec.CommonRec.nSpeed]);
      AdvStringGrid1.Cells[12,i+1] := Format('%d',[rec.CommonRec.nLimitSpeed]);
      AdvStringGrid1.Cells[13,i+1] := Format('%d',[rec.CommonRec.nShoub]);
      AdvStringGrid1.Cells[14,i+1] := Format('%s',[rec.CommonRec.strGK]);
      AdvStringGrid1.Cells[15,i+1] := Format('%d',[Ord(rec.CommonRec.WorkZero)]);
      AdvStringGrid1.Cells[16,i+1] := Format('%d',[Ord(rec.CommonRec.HandPos)]);
      AdvStringGrid1.Cells[17,i+1] := Format('%d',[Ord(rec.CommonRec.WorkDrag)]);
      AdvStringGrid1.Cells[18,i+1] := Format('%d',[rec.CommonRec.nLieGuanPressure]);
      AdvStringGrid1.Cells[19,i+1] := Format('%d',[rec.CommonRec.nGangPressure]);

      AdvStringGrid1.Cells[20,i+1] := Format('%d',[rec.CommonRec.nRotate]);
      AdvStringGrid1.Cells[21,i+1] := Format('%d',[rec.CommonRec.nJG1Pressure]);
      AdvStringGrid1.Cells[22,i+1] := Format('%d',[rec.CommonRec.nJG2Pressure]);
      AdvStringGrid1.Cells[23,i+1] := Format('%s',[rec.CommonRec.strOther]);
      AdvStringGrid1.Cells[24,i+1] := Format('%d',[rec.CommonRec.nJKLineID]);
      AdvStringGrid1.Cells[25,i+1] := Format('%d',[rec.CommonRec.nDataLineID]);
      AdvStringGrid1.Cells[26,i+1] := Format('%d',[rec.CommonRec.nStation]);
      AdvStringGrid1.Cells[27,i+1] := Format('%d',[rec.CommonRec.nToJKLineID]);
      AdvStringGrid1.Cells[28,i+1] := Format('%d',[rec.CommonRec.nToDataLineID]);
      AdvStringGrid1.Cells[29,i+1] := Format('%d',[rec.CommonRec.nToStation]);

      AdvStringGrid1.Cells[30,i+1] := Format('%d',[rec.CommonRec.nStationIndex]);
      AdvStringGrid1.Cells[31,i+1] := Format('%s',[rec.CommonRec.ShuoMing]);
      AdvStringGrid1.Cells[32,i+1] := Format('%d',[rec.CommonRec.JKZT]);
      AdvStringGrid1.Cells[33,i+1] := Format('%s',[BoolToStr(rec.CommonRec.bIsDiaoChe)]);
      AdvStringGrid1.Cells[34,i+1] := Format('%s',[BoolToStr(rec.CommonRec.bIsJiangji)]);
      AdvStringGrid1.Cells[35,i+1] := Format('%s',[BoolToStr(rec.CommonRec.bIsPingdiao)]);
      AdvStringGrid1.Cells[36,i+1] := Format('%d',[rec.CommonRec.nValidJG]);
      AdvStringGrid1.Cells[37,i+1] := Format('%s',[rec.CommonRec.strCheCi]);
      {$endregion '���ݸ�ֵ'}
    end;
  finally
    lkjFile.Free;
  end;
end;

procedure TfrmTest.btnAnalysisClick(Sender: TObject);
var
  analysis : TLKJAnalysis;
  eventList : TLKJEventList;
  i: Integer;
  k: Integer;
  event : TLKJEventItem;
  lkjFile : TLKJRuntimeFile;
  reader : TAdoFileReader;
  ruleReader : TVSRuleReader;
begin
  memo3.Lines.Clear;
  btnAnalysis.Enabled := false;
  try
    analysis := TLKJAnalysis.Create();
    try
      ruleReader := TVSRuleReader.Create(analysis.Rules);
      ruleReader.LoadFromXML(edtRuleXML.Text);
      ruleReader.Free;
      //analysis.LoadFromXML('');
      {$region '�������õ��¼���ȡֵ��Χ'}
      eventList := TLKJEventList.Create;
      event := TLKJEventItem.Create;
      event.strEventID := '1001';
      event.strEvent := '�����¼�';
      event.nBeforeSeconds := 50;
      event.nAfterSeconds := 50;
      eventList.Add(event);

      event := TLKJEventItem.Create;
      event.strEventID := '1002';
      event.strEvent := 'ͣ���¼�';
      event.nBeforeSeconds := 50;
      event.nAfterSeconds := 50;
      eventList.Add(event);

      event := TLKJEventItem.Create;
      event.strEventID := '1004';
      event.strEvent := '���������¼�';
      event.nBeforeSeconds := 50;
      event.nAfterSeconds := 50;
      eventList.Add(event);


      event := TLKJEventItem.Create;
      event.strEventID := '1005';
      event.strEvent := '��Ϊ�����¼�';
      event.nBeforeSeconds := 50;
      event.nAfterSeconds := 50;
      eventList.Add(event);

      event := TLKJEventItem.Create;
      event.strEventID := '1006';
      event.strEvent := '��������¼�';
      event.nBeforeSeconds := 50;
      event.nAfterSeconds := 50;
      eventList.Add(event);

      event := TLKJEventItem.Create;
      event.strEventID := '1007';
      event.strEvent := '�˳������¼�';
      event.nBeforeSeconds := 50;
      event.nAfterSeconds := 50;
      eventList.Add(event);

      event := TLKJEventItem.Create;
      event.strEventID := '1008';
      event.strEvent := '���������¼�';
      event.nBeforeSeconds := 50;
      event.nAfterSeconds := 50;
      eventList.Add(event);

      event := TLKJEventItem.Create;
      event.strEventID := '1009';
      event.strEvent := '��Ƶ��ź��¼�';
      event.nBeforeSeconds := 50;
      event.nAfterSeconds := 50;
      eventList.Add(event);


      event := TLKJEventItem.Create;
      event.strEventID := '1011';
      event.strEvent := '�źŹ����¼�';
      event.nBeforeSeconds := 50;
      event.nAfterSeconds := 50;
      eventList.Add(event);
      {$endregion ''}
      try
        lkjFile := TLKJRuntimeFile.Create();
        try
          reader := TAdoFileReader.Create();
          try
            reader.LoadFromFile(edit1.Text,lkjFile);
          finally
            reader.Free;
          end;
          analysis.DoAnalysis(lkjFile,eventList);
        finally
          lkjFile.Free;
        end;
        for i := 0 to eventList.Count - 1 do
        begin
          memo3.Lines.Add(Format('------------%s------------',[eventList.Items[i].strEvent]));
          for k := 0 to eventList.Items[i].DetailList.Count - 1 do
          begin
            memo3.Lines.Add(Format('%s[%s--%s]',
              [
              FormatDateTime('yyyy-MM-dd HH:nn:ss',eventList.Items[i].DetailList[k].dtCurrentTime),
              FormatDateTime('yyyy-MM-dd HH:nn:ss',eventList.Items[i].DetailList[k].dtBeginTime),
              FormatDateTime('yyyy-MM-dd HH:nn:ss',eventList.Items[i].DetailList[k].dtEndTime)
              ]));
          end;
        end;
      finally
        eventList.Free;
      end;
    finally
      analysis.Free;
    end;
  finally
    btnAnalysis.Enabled := true;
  end;
end;

end.
