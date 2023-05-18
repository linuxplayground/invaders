; include macros first.
is_nabu:        equ     1

        include 'macros.asm'

        org     0x100

        ld      sp,.stack

if is_nabu = 1
; set up kbd isr
        im      2
        ld      hl, isrKeyboard
        ld      (0xff00+4), hl
endif

; includes
if is_nabu = 1
        include 'nabu.asm'
else
        include 'z80retro.asm'
endif
        include 'tms.asm'
        include 'utils.asm'

; stack
        ds      1024
.stack: equ     $