program OpenCommandPalette;

uses
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.Variants,
  System.Classes,
  Cod.Windows,
  Vcl.Forms,
  Cod.Instances;

{$R *.res}

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

procedure SimulateTrayClick(AppHWND: HWND);
const
  WM_TRAY_CALLBACK = WM_USER + 1;  // Vcl.ExtCtrls
  WM_LBUTTONDOWN = $0201;
  WM_LBUTTONUP   = $0202;
begin
  if not IsWindow(AppHWND) then Exit;

  // LBUTTONDOWN
  PostMessage(AppHWND, WM_TRAY_CALLBACK, 0, WM_LBUTTONDOWN);

  // LBUTTONUP
  PostMessage(AppHWND, WM_TRAY_CALLBACK, 0, WM_LBUTTONUP);
end;

procedure FocusWindow(Window: HWND);
var
  ForeThread, ThisThread: DWORD;
begin
  ForeThread := GetWindowThreadProcessId(GetForegroundWindow(), nil);
  ThisThread := GetCurrentThreadId();

  AttachThreadInput(ThisThread, ForeThread, True);
  SetForegroundWindow(Window);
  SetActiveWindow(Window);
  BringWindowToTop(Window);
  AttachThreadInput(ThisThread, ForeThread, False);
end;

var
  Window: HWND;
begin
  Window := GetCommandPaletteAppHWND;

  // Click
  SimulateTrayClick(Window);

  // Bring to top
  FocusWindow( Window );
end.
