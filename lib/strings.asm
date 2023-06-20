;===============================================================================
; Simple as possible string library
;===============================================================================

;===============================================================================
; itoa8 - convert an unsigned 16bit word to ascii.  Adds leading ZEROS
; INPUT: DE pointer to 7 byte buffer for the result including the terminating
;               zero.
;        HL value to convert
; OUTPUT: void
; COBBERS: BC
;===============================================================================
itoa16:
        ld      bc, -10000
        call    .num1
        ld      bc, -1000
        call    .num1
        ld      bc, -100
        call    .num1
        ld      bc, -10
        call    .num1
        ld      c,b
        call    .num1
        inc     de
        xor     a
        ld      (de),a          ; add terminating zero.
.num1:
        ld      a,'0'-1
.num2:
        inc     a
        add     hl,bc
        jr      c,.num2
        sbc     hl,bc
        ld      (de),a
        inc     de
        ret
