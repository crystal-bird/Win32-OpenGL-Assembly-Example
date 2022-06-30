; --------------------------------------------------------------------------------------------------------
;                                                                                                       --
; Win32 Main Window Setup.                                                                              --
;                                                                                                       --
; --------------------------------------------------------------------------------------------------------

; --------------------------------------------------------------------------------------------------------
;                                                                                                       --
; Assembler directives (NASM)                                                                           --
;                                                                                                       --
; --------------------------------------------------------------------------------------------------------

default                             rel

; --------------------------------------------------------------------------------------------------------
;                                                                                                       --
; General Includes                                                                                      --
;                                                                                                       --
; --------------------------------------------------------------------------------------------------------

%include                            "Macros.i"
%include                            "Externals.i"
%include                            "WinConst.i"

; --------------------------------------------------------------------------------------------------------
;                                                                                                       --
; Readonly data section                                                                                 --
;                                                                                                       --
section                             .rdata
;                                                                                                       --
; --------------------------------------------------------------------------------------------------------

; ------------- [Strings] --------------------------------------------------------------------------------

FakeClassName:                      db "FakeWindowClassName", 0
ClassName:                          db "MainWindowClass", 0
WindowName:                         db "Win32 OpenGL 4.6 in Assembly", 0

Name_wglChoosePixelFormatARB:       db "wglChoosePixelFormatARB", 0
Name_wglCreateContextAttribsARB:    db "wglCreateContextAttribsARB", 0
Name_wglSwapIntervalEXT:            db "wglSwapIntervalEXT", 0

; ------------- [Structures] -----------------------------------------------------------------------------

PixelFormatDescriptor:
                                    .nSize:                     dw PixelFormatDescriptorEnd - PixelFormatDescriptor
                                    .nVersion:                  dw 1
                                    .dwFlags:                   dd PFD_DOUBLEBUFFER | PFD_DRAW_TO_WINDOW | PFD_SUPPORT_OPENGL
                                    .iPixelType:                db PFD_TYPE_RGBA
                                    .cColorBits:                db 32
                                    .cRedBits:                  db 0
                                    .cRedShift:                 db 0
                                    .cGreenBits:                db 0
                                    .cGreenShift:               db 0
                                    .cBlueBits:                 db 0
                                    .cBlueShift:                db 0
                                    .cAlphaBits:                db 0
                                    .cAlphaShift:               db 0
                                    .cAccumBits:                db 0
                                    .cAccumRedBits:             db 0
                                    .cAccumGreenBits:           db 0
                                    .cAccumBlueBits:            db 0
                                    .cAccumAlphaBits:           db 0
                                    .cDepthBits:                db 24
                                    .cStencilBits:              db 8
                                    .cAuxBuffers:               db 0
                                    .iLayerType:                db PFD_MAIN_PLANE
                                    .bReserved:                 db 0
                                    .dwLayerMask:               dd 0
                                    .dwVisibleMask:             dd 0
                                    .dwDamageMask:              dd 0
PixelFormatDescriptorEnd:

; ------------- [Arrays] ----------------------------------------------------------------------------------

PixelAttributes:
                                    .DoubleBuffer:              dd WGL_DOUBLE_BUFFER_ARB, 1
                                    .DrawToWindow:              dd WGL_DRAW_TO_WINDOW_ARB, 1
                                    .SupportOpenGL:             dd WGL_SUPPORT_OPENGL_ARB, 1
                                    .ColorBits:                 dd WGL_COLOR_BITS_ARB, 32
                                    .DepthBits:                 dd WGL_DEPTH_BITS_ARB, 24
                                    .StencilBits:               dd WGL_STENCIL_BITS_ARB, 8
                                    .End:                       dd 0
PixelAttributesEnd:

ContextAttributes:
                                    .MajorVersion:              dd WGL_CONTEXT_MAJOR_VERSION_ARB, 4
                                    .MinorVersion:              dd WGL_CONTEXT_MINOR_VERSION_ARB, 6
                                    .ProfileMask:               dd WGL_CONTEXT_PROFILE_MASK_ARB, WGL_CONTEXT_COMPATIBILITY_PROFILE_BIT_ARB
                                    .ContextFlags:              dd WGL_CONTEXT_FLAGS_ARB, WGL_CONTEXT_FORWARD_COMPATIBLE_BIT_ARB
                                    .End:                       dd 0
ContextAttributesEnd:

; --------------------------------------------------------------------------------------------------------
;                                                                                                       --
; Initialized Data section                                                                              --
;                                                                                                       --
section                             .data
;                                                                                                       --
; --------------------------------------------------------------------------------------------------------

Running:                            dq 1

; --------------------------------------------------------------------------------------------------------
;                                                                                                       --
; Unitialized data section                                                                              --
;                                                                                                       --
section                             .bss
;                                                                                                       --
; --------------------------------------------------------------------------------------------------------

; ------------- [Handles] --------------------------------------------------------------------------------

Instance:                           resb 8
Window:                             resb 8
DeviceContext:                      resb 8
GLRenderingContext:                 resb 8

; ------------- [Function pointers] ----------------------------------------------------------------------

FnPtr_wglChoosePixelFormatARB:      resb 8
FnPtr_wglCreateContextAttribsARB:   resb 8
FnPtr_wglSwapIntervalEXT:           resb 8

; ------------- [Structures] -----------------------------------------------------------------------------

WindowClass:
                                    .cbSize:                    resb 4
                                    .style:                     resb 4
                                    .lpfnWndProc:               resb 8
                                    .cbClsExtra:                resb 4
                                    .cbWndExtra:                resb 4
                                    .hInstance:                 resb 8
                                    .hIcon:                     resb 8
                                    .hCursor:                   resb 8
                                    .hbrBackground:             resb 8
                                    .lpszMenuName:              resb 8
                                    .lpszClassName:             resb 8
                                    .hIconSm:                   resb 8
WindowClassEnd:

; --------------------------------------------------------------------------------------------------------
;                                                                                                       --
; Code section                                                                                          --
;                                                                                                       --
section                             .code
;                                                                                                       --
; --------------------------------------------------------------------------------------------------------

; --------------------------------------------------------------------------------------------------------
;                                                                                                       --
; Code includes                                                                                         --
;                                                                                                       --
; --------------------------------------------------------------------------------------------------------

; --------------------------------------------------------------------------------------------------------
;                                                                                                       --
; Code                                                                                                  --
;                                                                                                       --
; --------------------------------------------------------------------------------------------------------

;
;                                   Function:           SetupMainWindow
;                                   Description:        Setup the main program window.
;
;                                   Parameters:         None
;
;                                   Returns:            None
;
function                            SetupMainWindow

                                    ; ------------- [Setup stack frame] -------------------------------------

                                    push            rbp
                                    mov             rbp, rsp
                                    sub             rsp, 96

                                    ; ------------- [Get the application instance] --------------------------

                                    xor             rcx, rcx
                                    call            GetModuleHandleA
                                    mov             [Instance], rax

                                    ; ------------- [Setup fake window class] -------------------------------

                                    mov             rdx, DefWindowProcA
                                    mov             rcx, FakeClassName

                                    mov             dword [WindowClass.cbSize], 80
                                    mov             dword [WindowClass.style], CS_VREDRAW | CS_HREDRAW | CS_OWNDC
                                    mov             qword [WindowClass.lpfnWndProc], rdx
                                    mov             dword [WindowClass.cbClsExtra], 0
                                    mov             dword [WindowClass.cbWndExtra], 0
                                    mov             qword [WindowClass.hInstance], rax
                                    mov             qword [WindowClass.hIcon], DEFAULT_APP_ICON
                                    mov             qword [WindowClass.hCursor], DEFAULT_CURSOR_ICON
                                    mov             qword [WindowClass.hbrBackground], 0
                                    mov             qword [WindowClass.lpszMenuName], 0
                                    mov             qword [WindowClass.lpszClassName], rcx
                                    mov             qword [WindowClass.hIconSm], DEFAULT_APP_ICON

                                    ; ------------- [Register fake window class] ----------------------------

                                    lea             rcx, [WindowClass]
                                    call            RegisterClassExA

                                    ; ------------- [Create fake window] ------------------------------------

                                    xor             rcx, rcx
                                    mov             rdx, FakeClassName
                                    xor             r8, r8
                                    mov             r9, WS_OVERLAPPEDWINDOW
                                    mov             dword [rsp + 32], 0
                                    mov             dword [rsp + 40], 0
                                    mov             dword [rsp + 48], 0
                                    mov             dword [rsp + 56], 0
                                    mov             qword [rsp + 64], 0
                                    mov             qword [rsp + 72], 0
                                    mov             qword [rsp + 80], 0
                                    mov             qword [rsp + 88], 0
                                    call            CreateWindowExA
                                    mov             [Window], rax

                                    ; ------------- [Get fake device context] -------------------------------

                                    mov             rcx, rax
                                    call            GetDC
                                    mov             [DeviceContext], rax

                                    ; ------------- [Choose and set pixel format] ---------------------------

                                    mov             rcx, rax
                                    mov             rdx, PixelFormatDescriptor
                                    call            ChoosePixelFormat

                                    mov             rcx, [DeviceContext]
                                    mov             rdx, rax
                                    mov             r8, PixelFormatDescriptor
                                    call            SetPixelFormat

                                    ; ------------- [Create the GL rendering context] -----------------------

                                    mov             rcx, [DeviceContext]
                                    call            wglCreateContext
                                    mov             [GLRenderingContext], rax

                                    ; ------------- [Make the GL rendering context current] -----------------

                                    mov             rcx, [DeviceContext]
                                    mov             rdx, rax
                                    call            wglMakeCurrent

                                    ; ------------- [Get WGL extension functions] ---------------------------

                                    mov             rcx, Name_wglChoosePixelFormatARB
                                    call            wglGetProcAddress
                                    mov             [FnPtr_wglChoosePixelFormatARB], rax

                                    mov             rcx, Name_wglCreateContextAttribsARB
                                    call            wglGetProcAddress
                                    mov             [FnPtr_wglCreateContextAttribsARB], rax

                                    mov             rcx, Name_wglSwapIntervalEXT
                                    call            wglGetProcAddress
                                    mov             [FnPtr_wglSwapIntervalEXT], rax

                                    ; ------------- [Cleanup fake stuff] ------------------------------------

                                    mov             rcx, [DeviceContext]
                                    xor             rdx, rdx
                                    call            wglMakeCurrent

                                    mov             rcx, [GLRenderingContext]
                                    call            wglDeleteContext
                                    
                                    mov             rcx, [Window]
                                    mov             rdx, [DeviceContext]
                                    call            ReleaseDC

                                    mov             rcx, [Window]
                                    call            DestroyWindow

                                    ; ------------- [Setup window class] -------------------------------

                                    mov             rdx, WindowProc
                                    mov             rcx, ClassName

                                    mov             dword [WindowClass.cbSize], 80
                                    mov             dword [WindowClass.style], CS_VREDRAW | CS_HREDRAW | CS_OWNDC
                                    mov             qword [WindowClass.lpfnWndProc], rdx
                                    mov             dword [WindowClass.cbClsExtra], 0
                                    mov             dword [WindowClass.cbWndExtra], 0
                                    mov             qword [WindowClass.hInstance], rax
                                    mov             qword [WindowClass.hIcon], DEFAULT_APP_ICON
                                    mov             qword [WindowClass.hCursor], DEFAULT_CURSOR_ICON
                                    mov             qword [WindowClass.hbrBackground], 0
                                    mov             qword [WindowClass.lpszMenuName], 0
                                    mov             qword [WindowClass.lpszClassName], rcx
                                    mov             qword [WindowClass.hIconSm], DEFAULT_APP_ICON

                                    ; ------------- [Register window class] ----------------------------

                                    lea             rcx, [WindowClass]
                                    call            RegisterClassExA

                                    ; ------------- [Create window] ------------------------------------

                                    xor             rcx, rcx
                                    mov             rdx, ClassName
                                    mov             r8, WindowName
                                    mov             r9, WS_OVERLAPPEDWINDOW | WS_VISBILE
                                    mov             dword [rsp + 32], CW_USEDEFAULT
                                    mov             dword [rsp + 40], CW_USEDEFAULT
                                    mov             dword [rsp + 48], 1600
                                    mov             dword [rsp + 56], 900
                                    mov             qword [rsp + 64], 0
                                    mov             qword [rsp + 72], 0
                                    mov             qword [rsp + 80], 0
                                    mov             qword [rsp + 88], 0
                                    call            CreateWindowExA
                                    mov             [Window], rax

                                    ; ------------- [Get device context] ------------------------------------

                                    mov             rcx, rax
                                    call            GetDC
                                    mov             [DeviceContext], rax

                                    ; ------------- [Choose and set pixel format] ---------------------------

                                    mov             rcx, rax
                                    mov             rdx, PixelAttributes
                                    xor             r8, r8
                                    mov             r9, 1
                                    lea             rax, [rsp + 48]
                                    mov             qword [rsp + 32], rax
                                    lea             rax, [rsp + 56]
                                    mov             qword [rsp + 40], rax
                                    call            [FnPtr_wglChoosePixelFormatARB]

                                    mov             rcx, [DeviceContext]
                                    mov             rdx, [rsp + 48]
                                    mov             r8, PixelFormatDescriptor
                                    call            SetPixelFormat

                                    ; ------------- [Create the GL rendering context] -----------------------

                                    mov             rcx, [DeviceContext]
                                    xor             rdx, rdx
                                    mov             r8, ContextAttributes
                                    call            [FnPtr_wglCreateContextAttribsARB]
                                    mov             [GLRenderingContext], rax

                                    ; ------------- [Make the GL rendering context current] -----------------

                                    mov             rcx, [DeviceContext]
                                    mov             rdx, rax
                                    call            wglMakeCurrent

                                    ; ------------- [Enable VSync] ------------------------------------------

                                    mov             rcx, 1
                                    call            [FnPtr_wglSwapIntervalEXT]

                                    ; ------------- [Restore stack frame] -----------------------------------

                                    mov             rsp, rbp
                                    pop             rbp

                                    ; ------------- [Return] ------------------------------------------------

                                    xor             rax, rax
                                    ret

;
;                                   Function:           IsMainWindowOpen
;                                   Description:        Check if the main window is still open.
;
;                                   Parameters:         None
;
;                                   Returns:            The current status of the main window.
;
function                            IsMainWindowOpen

                                    ; ------------- [Return] ------------------------------------------------

                                    mov             rax, [Running]
                                    ret

;
;                                   Function:           UpdateMainWindow
;                                   Description:        Updates the main window.
;
;                                   Parameters:         None
;
;                                   Returns:            None
;

function                            UpdateMainWindow

                                    ; ------------- [Setup stack frame] -------------------------------------

                                    push            rbp
                                    mov             rbp, rsp
                                    sub             rsp, 96

                                    ; ------------- [Peek messages] -----------------------------------------

                                    lea             rcx, [rsp + 40]
                                    xor             rdx, rdx
                                    xor             r8, r8
                                    xor             r9, r9
                                    mov             qword [rsp + 32], PM_REMOVE
                                    call            PeekMessageA

                                    ; ------------- [Check if there are any messages] -----------------------

                                    test            rax, rax
                                    jz              .DoneMessages

                                    ; ------------- [Translate and dispatch messages if there are any] ------

                                    lea             rcx, [rsp + 40]
                                    call            TranslateMessage

                                    lea             rcx, [rsp + 40]
                                    call            DispatchMessageA

.DoneMessages:

                                    ; ------------- [Swap window buffers] -----------------------------------

                                    mov             rcx, [DeviceContext]
                                    call            SwapBuffers

                                    ; ------------- [Restore stack frame] -----------------------------------

                                    mov             rsp, rbp
                                    pop             rbp

                                    ; ------------- [Return] ------------------------------------------------

                                    xor             rax, rax
                                    ret

;
;                                   Function:           WindowProc
;                                   Description:        Main window callback.
;
;                                   Parameters:
;                                       rcx     -       Window
;                                       rdx     -       Message
;                                       r8      -       WParam
;                                       r9      -       LParam
;
;                                   Returns:            0 if successful.
;
function                            WindowProc

                                    ; ------------- [Process message] ---------------------------------------

                                    cmp             rdx, WM_QUIT
                                    je              .CloseWindow
                                    cmp             rdx, WM_CLOSE
                                    je              .CloseWindow

                                    jmp            DefWindowProcA

.CloseWindow:

                                    mov             qword [Running], 0

.Return:

                                    ; ------------- [Return] ------------------------------------------------

                                    xor             rax, rax
                                    ret