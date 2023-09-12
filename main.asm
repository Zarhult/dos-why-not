            bits 16
            org 0x100               ; DOS loads program here
Start:      call    InstallKB
            call    InitVideo
.gameLoop:  call    WaitFrame
            call    DrawPixel
            cmp     byte [Quit], 1
            jne     .gameLoop
            call    RestoreKB
            ; exit
            mov     ax, 0x4c00      ; set AH to 0x4c exit syscall with AL return code 0
            int     0x21

Quit:       db      0               ; initialize to 0, set to 1 when user quits

%include "kb.asm"
%include "video.asm"
    
