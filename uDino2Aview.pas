unit uDino2Aview;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, FileCtrl, ExtCtrls, Spin, Gauges, uError, Dutils, OpWString,
  system.UITypes;

type
  TMainForm = class(TForm)
    FileListBox1: TFileListBox;
    FilterComboBox1: TFilterComboBox;
    DirectoryListBox1: TDirectoryListBox;
    DriveComboBox1: TDriveComboBox;
    Label1: TLabel;
    Button2: TButton;
    ListBox1: TListBox;
    Label2: TLabel;
    BtnDeleteFile: TButton;
    Button1: TButton;
    SaveDlgXYcoord: TSaveDialog;
    procedure BtnWriteXYcoord(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure BtnDeleteFileClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  MainForm: TMainForm;
var
  SearchRec: TSearchRec;


Procedure SweepDir( var DirStr: String; DirList: TStringList );
{- Maak een lijst van alle directories beneden DirStr}

implementation

{$R *.DFM}

procedure TMainForm.BtnWriteXYcoord(Sender: TObject);
var
  f, h: textFile;
  PeilbuisID, xStr, yStr, ExtAand, FileStr,
  MvNAPStr, DatMVStr, StartDatStr, EindDatStr, MpCMNAPStr,
  MpCMmvStr, BkfStr, OkftrStr, OkDiepstefltrStr: String;
  FltrNrs: integer;
  Procedure GetInfoFromDinoFile(  const FileName: String );
  var
    f: TextFile;
    Regel, LaatsteEinddatumStr: String;
    Len: Integer;

  Const
    WordDelims: CharSet = [','];
    ReplaceFlag: TReplaceFlags = [ rfReplaceAll ];
  begin
    xStr := ''; yStr := '';
    Try
      AssignFile( f, FileName ); Reset( f );
      Regel := '';
      Repeat
        Readln( f, Regel ); Regel := Uppercase( Regel );
        {WriteToLogFileFmt(Regel );}
      until ( pos( 'LOCATIE', Regel ) <> 0 ) or ( pos( 'Locatie', Regel ) <> 0 )or  ( EOF( f ) );
      if ( not EOF( f ) ) then begin
        Readln( f, Regel ); Regel := StringReplace( Regel, ',,', ',0,', ReplaceFlag );
        {WriteToLogFileFmt('Regel: ' + Regel );}
        ExtAand := ExtractWord( 3, Regel, WordDelims, Len );
        xStr    := ExtractWord( 4, Regel, WordDelims, Len );
        yStr    := ExtractWord( 5, Regel, WordDelims, Len );
        MvNAPStr := ExtractWord( 6, Regel, WordDelims, Len );
        //DatMVStr     := ExtractWord( 7, Regel, WordDelims, Len );
        DatMVStr := '';
        StartDatStr  := ExtractWord( 11, Regel, WordDelims, Len );
        EindDatStr   := ExtractWord( 12, Regel, WordDelims, Len );
        MpCMNAPStr   := ExtractWord( 8, Regel, WordDelims, Len );
        //MpCMmvStr    := ExtractWord( 11, Regel, WordDelims, Len );
        MpCMmvStr := '';
        BkfStr       := ExtractWord( 9, Regel, WordDelims, Len );
        OkftrStr     := ExtractWord( 10, Regel, WordDelims, Len );
        {-Probeer laatste einddatum te vinden}
        LaatsteEinddatumStr := '';
        repeat
          Readln( f, Regel ); Regel := Trim( regel );
          if ( Regel <> '' ) then begin
            Regel := StringReplace( Regel, ',,', ',0,', ReplaceFlag );
            LaatsteEinddatumStr   := ExtractWord( 9, Regel, WordDelims, Len );
          end;
        until ( ( Regel = '' ) or ( EOF( f ) ) );
        if ( ( LaatsteEinddatumStr <> '' ) and ( LaatsteEinddatumStr <> '0' ) ) then
          EindDatStr := LaatsteEinddatumStr;
      end else begin
      end;
      CloseFile( f );
    Except
    end;
  end; {-Procedure GetInfoFromDinoFile}
begin
  with SaveDlgXYcoord do begin
    InitialDir := ExtractFileDir( Application.ExeName );
    WriteToLogFileFmt('InitialDir= [%s]', [InitialDir] );
    if execute then begin
      { *** Zet de coordinaten van de peilbuizen in "xy.prn" }
      {Open in- and output files}
      AssignFile( f, ChangeFileExt( Application.ExeName, 'FLS.prn' ) ); Reset(f);
      WriteToLogFile('FLS.prn geopend' );
      AssignFile( h, FileName ); Rewrite( h );
      {-Write header}
      Writeln( h, '"Loc","FltrNrs","ExtAand","X","Y","MvNAP","DatMV","StartDat","EindDat","MpCMNAP","MpCMmv","Bkf","Okftr"' );
      while ( not EOF( f ) ) do begin
        Readln( f, FileStr ); WriteToLogFile(FileStr );
//        MessageDlg('Processing: ' + FileStr, mtInformation, [mbOk], 0);
        if ( FileExists( FileStr ) ) then begin
          PeilbuisID := ChangeFileExt( ExtractFileName( FileStr ), '' );
          Write( h, '"' + PeilbuisID + '"' );

//          S := DirStr + '\' + Edit1.Text;
//          FileListBox1.ApplyFilePath( S );

//          if FileListBox1.Items.Count > 0 then begin
            {for j:=0 to FileListBox1.Items.Count-1 do begin
              S := ' '+ FileListBox1.Items.Strings[ j ]; }
              {Write( h, S );}
            {end;}

            {-Probeer een waarde te vinden van de onderkant van het diepste filter}
//            S := DirStr + '\'+ FileListBox1.Items.Strings[ FileListBox1.Items.Count-1 ];
            GetInfoFromDinoFile(  FileStr );
            if ( ( OkftrStr <> '' ) and ( OkftrStr <> '0' ) )then
              OkDiepstefltrStr := OkftrStr
            else
              OkDiepstefltrStr := '';

            {-Haal xy coordinaat uit kopgegevens van 1-ste de beste filter (bovenste)}
//            S := DirStr + '\'+ FileListBox1.Items.Strings[ 0 ];

            {Write( h, ' ' + S );}
//            FltrNrs := FileListBox1.Items.Count;
//            GetInfoFromDinoFile(  S );
//            if ( OkDiepstefltrStr <> '' ) then
//              OkftrStr := OkDiepstefltrStr;
            Write( h, ',' + IntToStr( FltrNrs ) + ',"' + ExtAand + '",' + xStr, ',' + yStr +
            ',"' +  MvNAPStr   + '"' +
            ',"' +  DatMVStr   + '"' +
            ',"' +  StartDatStr   + '"' +
            ',"' +  EindDatStr   + '"' +
            ',"' +  MpCMNAPStr   + '"' +
            ',"' +  MpCMmvStr   + '"' +
            ',"' +  BkfStr   + '"' +
            ',"' +  OkftrStr   + '"' );
//          end;

          Writeln( h );
        end;
      end;
      MessageDlg('Info from DINO file written.', mtInformation, [mbOk], 0);

  {-Close files}
  {$I-} CloseFile(f); CloseFile( h );{$I+}
    end;
  end;
end;

procedure TMainForm.FormCreate(Sender: TObject);
begin
  InitialiseLogFile;
  FilterComboBox1.FileList := FileListBox1;
  DirectoryListBox1.FileList := FileListBox1;
  DirectoryListBox1.DirLabel := Label1;
  DriveComboBox1.DirList := DirectoryListBox1;
  Caption :=  ChangeFileExt( ExtractFileName( Application.ExeName ), '' );
end;

procedure TMainForm.FormDestroy(Sender: TObject);
begin
FinaliseLogFile;
end;

procedure TMainForm.Button2Click(Sender: TObject);
var
  S, DirStr, StartDir: String;
  i, j: Integer;
  SL: TStringList;


begin

  { *** Zet de bestandsnamen in "LogFileNameDIRS.prn" }
  DirectoryListBox1.OpenCurrent;
  S := DirectoryListBox1.Directory;
  StartDir := S;

  SL := TStringlist.Create;
  SweepDir( S, SL );
  SL.SaveToFile( ChangeFileExt( Application.ExeName, 'DIRS.prn' ) );

  {Label2.Caption := '0';
  Label2.Visible := True;}

  Listbox1.Items.Clear;
  with SL do begin
    for i := 0 to Count-1 do begin
      DirStr := Strings[ i ];
      if ( DirStr[ Length( DirStr ) ] <> '\' ) then
        DirStr := DirStr + '\';
      FileListBox1.ApplyFilePath( S );
      if FileListBox1.Items.Count > 0 then begin
        for j:=0 to FileListBox1.Items.Count-1 do begin
          S := DirStr + FileListBox1.Items.Strings[ j ];
          Listbox1.Items.Append( S );
        end;
      end;
    end;
  end;

  Listbox1.Items.SaveToFile( ChangeFileExt( Application.ExeName, 'FLS.prn' ) );
  SL.Free;

  SetCurrentDir( StartDir );
  DirectoryListBox1.Directory := StartDir;

  {Label2.Visible := False;}

end;

Procedure SweepDir( var DirStr: String; DirList: TStringList );
var
  i, NrItems: Integer;
  S: String;
begin
  if SetCurrentDir( DirStr ) then begin
    DirStr := GetCurrentDir;
    if DirList.Count = 0 then
      DirList.Append( DirStr );
    NrItems := DirList.Count;

    if ( FindFirst('*.*', faDirectory, SearchRec) = 0 ) then begin
      S := SearchRec.Name;
      if ( ( FileGetAttr( S )= faDirectory ) and ( S[ 1 ]<> '.' ) ) then begin
          if DirStr[ Length( DirStr ) ] = '\' then
            DirList.Append( DirStr + S )
          else
            DirList.Append( DirStr + '\' + S );
      end;
      while( FindNext( SearchRec ) = 0 ) do begin
        S := SearchRec.Name;
        if ( ( FileGetAttr( S )= faDirectory ) and ( S[ 1 ]<> '.' ) ) then begin
          if DirStr[ Length( DirStr ) ] = '\' then
            DirList.Append( DirStr + S )
          else
            DirList.Append( DirStr + '\' + S );
        end;
      end;
    end;
    FindClose( SearchRec );

    if ( DirList.Count > NrItems ) then begin {-Alle nieuw toegevoegde dir's}
      for i := NrItems to DirList.Count-1 do begin
        S := Dirlist.Strings[ i ];
        {if Application.MessageBox( PChar( S ), 'SweepDir in...', MB_OK) = IDOK then;}
        SweepDir( S, DirList );
      end;
    end;

    SetCurrentDir( DirStr );
  end else begin
    if Application.MessageBox( PChar( DirStr ), 'SweepDir FAILED in...', MB_OK)
    = IDOK then;
  end;

end;

procedure TMainForm.BtnDeleteFileClick(Sender: TObject);
var
  i, j: Integer;
  S: String;
begin
  {FileListBox1.ApplyFilePath(Edit1.Text);}
  if ListBox1.Items.Count > 0 then begin
    for i:=0 to ListBox1.Items.Count-1 do begin
      S := Listbox1.Items.Strings[ j ];
      if not DeleteFile( S ) then
        if Application.MessageBox( PChar( S ) , 'Cannot delete File...', MB_OK)
           = IDOK then;
    end;
  end;

end;

end.
