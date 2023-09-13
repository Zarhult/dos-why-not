; the VGA hardware is always in one of two states:
; * refresh, where the screen gets redrawn.
;            This is the state the VGA is in most of the time.
; * retrace, a relatively short period when the electron gun is returning to
;            the top left of the screen, from where it will begin drawing the
;            next frame to the monitor. Ideally, we write the next frame to
;            the video memory entirely during retrace, so each refresh is
;            only drawing one full frame
; The following procedure waits until the *next* retrace period begins.
; First it waits until the end of the current retrace, if we're in one
; (if we're in refresh this part of the procedure does nothing)
; Then it waits for the end of refresh.
WaitFrame:      push    dx
                ; VGA graphics hardware sends status info over port 0x03da
                mov     dx, 0x03da              ; must use dx for 16 bit port num
.waitRetrace:   in      al, dx
                ; bit 3 will be on if we're in retrace
                test    al, 0x08                ; are we in retrace?
                jnz     .waitRetrace
.endRefresh:    in      al, dx
                test    al, 0x08                ; are we in refresh?
                jz      .endRefresh
                pop dx
                ret

InitVideo:      ; set video mode to 0x13
                mov     ax, 0x13
                int     0x10
                ; make ES point to VGA memory
                ; DOS will handle restoring ES
                mov     ax, 0xa000
                mov     es, ax
                ret

DrawPixel:      mov     byte [es:0x0001], 0x0f
                ret

DrawImage:      call DrawPixel                  ; todo: more than just a pixel
                ret

ClearScreen:    push    di
                push    cx
                push    ax
                xor     di, di                  ; starts at es:0
                mov     cx, 320*200             ; all of video memory
                cld                             ; increment di each iteration
                mov     ax, 0x0
                rep     stosb                   ; zero all 320*200 bytes at es:di
                pop     ax
                pop     cx
                pop     di
                ret
