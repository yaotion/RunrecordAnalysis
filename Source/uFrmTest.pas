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
        Memo2.Lines.Add('入库时间：' + DateTimeToStr(OperationTime.inhousetime));
        Memo2.Lines.Add('接车时间：' + DateTimeToStr(OperationTime.jctime));
        Memo2.Lines.Add('出库时间：' + DateTimeToStr(OperationTime.outhousetime));
        Memo2.Lines.Add('到站时间：' + DateTimeToStr(OperationTime.tqarrivetime));
        Memo2.Lines.Add('车次开点：' + DateTimeToStr(OperationTime.tqdat));
        Memo2.Lines.Add('退勤时间：' + DateTimeToStr(OperationTime.jhtqtime));
        Memo2.Lines.Add('共耗时：' + IntToStr(GetTickCount - nTickCount));
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
    {$region '初始化列'}
    AdvStringGrid1.Cells[0,0] := '序号';
    AdvStringGrid1.Cells[1,0] := '事件';
    AdvStringGrid1.Cells[2,0] := '事件号';
    AdvStringGrid1.Cells[3,0] := '发生时间';
    AdvStringGrid1.Cells[4,0] := '公里标';
    AdvStringGrid1.Cells[5,0] := '信号机距离';
    AdvStringGrid1.Cells[6,0] := '灯号';
    AdvStringGrid1.Cells[7,0] := '信号灯';
    AdvStringGrid1.Cells[8,0] := '信号机类型';
    AdvStringGrid1.Cells[9,0] := '信号机编号';

    AdvStringGrid1.Cells[10,0] := '信号机';
    AdvStringGrid1.Cells[11,0] := '速度';
    AdvStringGrid1.Cells[12,0] := '限速';
    AdvStringGrid1.Cells[13,0] := '手柄';
    AdvStringGrid1.Cells[14,0] := '工况';
    AdvStringGrid1.Cells[15,0] := '零位';
    AdvStringGrid1.Cells[16,0] := '前后';
    AdvStringGrid1.Cells[17,0] := '牵制';
    AdvStringGrid1.Cells[18,0] := '管压';
    AdvStringGrid1.Cells[19,0] := '缸压';

    AdvStringGrid1.Cells[20,0] := '转速';
    AdvStringGrid1.Cells[21,0] := '均缸1';
    AdvStringGrid1.Cells[22,0] := '均缸2';
    AdvStringGrid1.Cells[23,0] := '其它';
    AdvStringGrid1.Cells[24,0] := '交路号';
    AdvStringGrid1.Cells[25,0] := '数据交路号';
    AdvStringGrid1.Cells[26,0] := '车站号';
    AdvStringGrid1.Cells[27,0] := '到站交路号';
    AdvStringGrid1.Cells[28,0] := '到站数据交路号';
    AdvStringGrid1.Cells[29,0] := '到站号';

    AdvStringGrid1.Cells[30,0] := '车站序号';
    AdvStringGrid1.Cells[31,0] :='说明';
    AdvStringGrid1.Cells[32,0] := '监控状态';
    AdvStringGrid1.Cells[33,0] := '是否在调车';
    AdvStringGrid1.Cells[34,0] := '是否在降级';
    AdvStringGrid1.Cells[35,0] := '是否在平调';
    AdvStringGrid1.Cells[36,0] := '有效均缸号';
    AdvStringGrid1.Cells[37,0] := '所属车次';
    {$endregion '初始化列'}
    for i := 0 to lkjFile.Records.Count - 1 do
    begin
      {$region '数据赋值'}
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
      {$endregion '数据赋值'}
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
      {$region '设置启用的事件及取值范围'}
      eventList := TLKJEventList.Create;
      event := TLKJEventItem.Create;
      event.strEventID := '1001';
      event.strEvent := '开车事件';
      event.nBeforeSeconds := 50;
      event.nAfterSeconds := 50;
      eventList.Add(event);

      event := TLKJEventItem.Create;
      event.strEventID := '1002';
      event.strEvent := '停车事件';
      event.nBeforeSeconds := 50;
      event.nAfterSeconds := 50;
      eventList.Add(event);

      event := TLKJEventItem.Create;
      event.strEventID := '1004';
      event.strEvent := '侧线运行事件';
      event.nBeforeSeconds := 50;
      event.nAfterSeconds := 50;
      eventList.Add(event);


      event := TLKJEventItem.Create;
      event.strEventID := '1005';
      event.strEvent := '人为紧急事件';
      event.nBeforeSeconds := 50;
      event.nAfterSeconds := 50;
      eventList.Add(event);

      event := TLKJEventItem.Create;
      event.strEventID := '1006';
      event.strEvent := '进入调车事件';
      event.nBeforeSeconds := 50;
      event.nAfterSeconds := 50;
      eventList.Add(event);

      event := TLKJEventItem.Create;
      event.strEventID := '1007';
      event.strEvent := '退出调车事件';
      event.nBeforeSeconds := 50;
      event.nAfterSeconds := 50;
      eventList.Add(event);

      event := TLKJEventItem.Create;
      event.strEventID := '1008';
      event.strEvent := '调车区域事件';
      event.nBeforeSeconds := 50;
      event.nAfterSeconds := 50;
      eventList.Add(event);

      event := TLKJEventItem.Create;
      event.strEventID := '1009';
      event.strEvent := '红黄灯信号事件';
      event.nBeforeSeconds := 50;
      event.nAfterSeconds := 50;
      eventList.Add(event);


      event := TLKJEventItem.Create;
      event.strEventID := '1011';
      event.strEvent := '信号故障事件';
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
