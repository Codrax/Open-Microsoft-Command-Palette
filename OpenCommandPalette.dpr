program OpenCommandPalette;

uses
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.Variants,
  System.Classes,
  Cod.Windows,
  Vcl.Forms,
  ShellAPI,
  Vcl.ExtCtrls,
  Cod.Instances,
  Winapi.ActiveX,
  System.Win.ComObj,
  Winapi.Winrt,
  Winapi.ApplicationModel,
  Cod.WindowsRT,
  Cod.WindowsRT.ActivationManager,
  Cod.UWP,
  Winapi.Management;

{$R *.res}

procedure AttachThreadFocusWindow(Window: HWND);
var
  ForeThread, ThisThread: DWORD;
begin
  ForeThread := GetWindowThreadProcessId(GetForegroundWindow(), nil);
  ThisThread := GetCurrentThreadId();

  if AttachThreadInput(ThisThread, ForeThread, True) then begin
    SetForegroundWindow(Window);
    SetActiveWindow(Window);
    BringWindowToTop(Window);
    AttachThreadInput(ThisThread, ForeThread, False);
  end;
end;

function GetCommandPaletteAppHWND: HWND;
var
  AFound: integer;
begin
  AFound := 0;

  // Find
  EnumerateActiveWindows(procedure(Window: HWND; var Continue: boolean) begin
    if Window.GetTitle = 'Command Palette' then begin
      AFound := Window;
      Continue := false;
    end;
  end);
  Result := AFound;
end;

procedure DoRunCommandPalette;
const
  APP_FAMILYNAME = 'Microsoft.CommandPalette_8wekyb3d8bbwe';
  APP_ACTIVATIONNAME = '!App';
var
  Mgr: IApplicationActivationManager;
  PID: dword;
  aHWND: HWND;
begin
  // Exists?
  const PackageManager = TDeployment_PackageManager.Create;
  var Iterable: IIterable_1__IPackage;
  const FamName = HSTRING.Create(APP_FAMILYNAME);
  const UserSID = HSTRING.Create(GetUserCLSID);
  try
    Iterable := PackageManager.FindPackagesForUser(UserSID, FamName);
  except
    FamName.Free;
    UserSID.Free;
  end;
  if not Iterable.First.HasCurrent then begin
    with TTrayIcon.Create(Application) do
      try
        Visible := true;
        BalloonTitle := 'Command Palette was not found!';
        BalloonHint := 'We''ve attempted to run the app but it does not seem to be installed on your device.';
        ShowBalloonHint;
        Visible := false;
      except
      end;
  end;

  // Click
  Mgr := TApplicationActivationManager.Create;
  Mgr.ActivateApplication(APP_FAMILYNAME+APP_ACTIVATIONNAME, nil, ActivateOptions.None, PID);

  // Focus Window
  aHWND := GetCommandPaletteAppHWND;
  AttachThreadFocusWindow(aHWND);
end;

begin
  DoRunCommandPalette;
end.
