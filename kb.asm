OldKBHandler:   dw      0
OldKBSeg:       dw      0

InstallKB:      push    es
                push    bx
                push    dx
                ; backup old KB interrupt
                mov     ax, 0x3509
                int     0x21
                mov     [OldKBHandler], bx
                mov     [OldKBSeg],     es
                ; install new KB interrupt
                mov     ah, 0x25 ; AL is still 9 (keyboard interrupt)
                mov     dx, KBHandler
                int     0x21
                pop     dx,
                pop     bx,
                pop     es,
                ret

RestoreKB:      push    dx
                push    ds
                mov     ax, 0x2509
                mov     dx, [OldKBHandler]
                mov     ds, [OldKBSeg]
                int     0x21
                pop     ds
                pop     dx
                ret

KBHandler:      push    ax
                in      al, 0x60
                cmp     al, 0x01    ; ESC pressed?
                jne     .done
                mov     [Quit], al

.done:          mov     al, 0x20    ; ACK that the key was handled
                out     0x20, al    ; send ACK
                pop     ax
                iret
