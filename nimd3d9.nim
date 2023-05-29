import winim/lean

{.passL: "Lib/x64/d3d9.lib".}

{.emit:"""
#include "Include/d3d9.h"

LPDIRECT3D9 d3d; 
LPDIRECT3DDEVICE9 d3ddev;

void initD3D(HWND hWnd)
{
    d3d = Direct3DCreate9(D3D_SDK_VERSION);  
    D3DPRESENT_PARAMETERS d3dpp;

    ZeroMemory(&d3dpp, sizeof(d3dpp)); 
    d3dpp.Windowed = TRUE; 
    d3dpp.SwapEffect = D3DSWAPEFFECT_DISCARD;  
    d3dpp.hDeviceWindow = hWnd;  
    d3d->CreateDevice(D3DADAPTER_DEFAULT,
        D3DDEVTYPE_HAL,
        hWnd,
        D3DCREATE_SOFTWARE_VERTEXPROCESSING,
        &d3dpp,
        &d3ddev);
}
void render_frame(void)
{
    // clear the window to a deep blue
    d3ddev->Clear(0, NULL, D3DCLEAR_TARGET, D3DCOLOR_XRGB(0, 40, 100), 1.0f, 0);
    d3ddev->BeginScene(); 
    
    d3ddev->EndScene(); 
    d3ddev->Present(NULL, NULL, NULL, NULL);
}
void cleanD3D(void)
{
    d3ddev->Release();   
    d3d->Release();  
}

""".}

proc initD3D(hwnd: HWND) {.header: "d3d9test.h", importcpp: "$1(@)" .}
proc render_frame(ceva: void) {.header: "d3d9test.h", importcpp: "$1(@)" .}
proc cleanD3D(ceva: void) {.header: "d3d9test.h", importcpp: "$1(@)" .}


proc WindowProc(hwnd: HWND, message: UINT, wParam: WPARAM, lParam: LPARAM): LRESULT {.stdcall.} =
  case message
  of WM_PAINT:
    var ps: PAINTSTRUCT
    var hdc = BeginPaint(hwnd, ps)
    defer: EndPaint(hwnd, ps)

    var rect: RECT
    GetClientRect(hwnd, rect)
    DrawText(hdc, "Hello, Windows!", -1, rect, DT_SINGLELINE or DT_CENTER or DT_VCENTER)
    return 0

  of WM_DESTROY:
    PostQuitMessage(0)
    return 0

  else:
    return DefWindowProc(hwnd, message, wParam, lParam)

proc main() =
  var
    hInstance = GetModuleHandle(nil)
    hwnd: HWND
    msg: MSG
    wndclass: WNDCLASS

  wndclass.style = CS_HREDRAW or CS_VREDRAW
  wndclass.lpfnWndProc = WindowProc
  wndclass.cbClsExtra = 0
  wndclass.cbWndExtra = 0
  wndclass.hInstance = hInstance
  wndclass.hIcon = LoadIcon(0, IDI_APPLICATION)
  wndclass.hCursor = LoadCursor(0, IDC_ARROW)
  wndclass.hbrBackground = GetStockObject(WHITE_BRUSH)
  wndclass.lpszMenuName = nil
  wndclass.lpszClassName = "HelloWin"

  if RegisterClass(wndclass) == 0:
    MessageBox(0, "This program requires Windows NT!", "HelloWin", MB_ICONERROR)
    return

  hwnd = CreateWindow("HelloWin", "The Hello Program", WS_OVERLAPPEDWINDOW,
    CW_USEDEFAULT, CW_USEDEFAULT, CW_USEDEFAULT, CW_USEDEFAULT,
    0, 0, hInstance, nil)

  ShowWindow(hwnd, SW_SHOW)
  initD3D(hwnd)
  # UpdateWindow(hwnd)

  while GetMessage(msg, 0, 0, 0) != 0:
    TranslateMessage(msg)
    DispatchMessage(msg)
    render_frame()
  cleanD3D()
main()
