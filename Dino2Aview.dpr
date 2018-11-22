program Dino2Aview;

uses
  Forms,
  Sysutils,
  Dialogs,
  System.UITypes,
  uError,
  uDino2Aview in 'uDino2Aview.pas' {MainForm};

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TMainForm, MainForm);
  Try
    Try
      if ( Mode = Interactive ) then begin
        Application.Run;
      end else begin
        {MainForm.GoButton.Click;}
      end;
    Except
      HandleErrorFmt( 'Error in application: [%s].', [Application.ExeName], true );
    end;
  Finally
  end;
end.