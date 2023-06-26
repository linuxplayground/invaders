;===============================================================================
; itoa16 - convert an unsigned 16bit word to ascii.  Adds leading ZEROS
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

;===============================================================================
; Returns the length of a zero terminated string buffer.
; INPUT: HL Pointer to zero terminated string buffer
; OUTPUT: BC = Length of string, original value of HL
; CLOBBERS: BC
;===============================================================================
str_len:
        push    hl
        ld      bc,0x0000
.str_len_lp:
        ld      a,(hl)
        or      a
        jr      z,.str_len_done
        inc     hl
        inc     bc
        jr      z,.str_len_done ; if overflow beyond 255, then return.
        jp      .str_len_lp
.str_len_done:
        pop     hl
        ret
