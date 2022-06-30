%macro WINAPI 1
    extern __imp_%1
    %define %1 [__imp_%1]
%endmacro

WINAPI          LoadLibraryA
WINAPI          GetProcAddress
WINAPI          GetModuleHandleA
WINAPI          DefWindowProcA
WINAPI          RegisterClassExA
WINAPI          CreateWindowExA
WINAPI          GetDC
WINAPI          ChoosePixelFormat
WINAPI          SetPixelFormat
WINAPI          wglCreateContext
WINAPI          wglMakeCurrent
WINAPI          wglGetProcAddress
WINAPI          PeekMessageA
WINAPI          TranslateMessage
WINAPI          DispatchMessageA
WINAPI          SwapBuffers
WINAPI          wglDeleteContext
WINAPI          ReleaseDC
WINAPI          DestroyWindow
WINAPI          ExitProcess