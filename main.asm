; include macros first.
is_nabu:        equ     1
        include 'macros.asm'

        org     0x100
        ld      sp,.stack

ticks:  db 0

if is_nabu = 1
        call    init_nabu
endif

main:
        call    setup

loop:
        ld      a,(ticks)
        cp      0x04
        jr      nz,vdp_wait
        ; call    tms_clear_buffer
        call    draw_alien_grid
        call    tms_flush_buffer
        ld      a,(alien_drop)
        or      a
        jr      z,.reset_ticks
        call    drop_aliens
        or      a
        jp      nz,exit
.reset_ticks:
        ; xor     a
        ld      (ticks),a
        jp      tick
vdp_wait:
        call    tms_wait
tick:
        inc8    ticks
user_input:   
        call    is_key_pressed
        or      a
        jr      z,loop
exit:
        call    cpm_terminate

; includes
if is_nabu = 1
        include 'nabu.asm'
else
        include 'z80retro.asm'
endif
        include 'tms.asm'
        include 'utils.asm'
        include 'inv_patterns.asm'
        include 'setup.asm'
        include 'alien.asm'

; stack
        ds      1024
.stack: equ     $
