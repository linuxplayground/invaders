;===============================================================================
; Jumpt to CPM Warm Boot vector
; INPUT: void
; OUTPUT: void
; CLOBBERS: hl, de
;===============================================================================
cpm_terminate:
        jp      0

;===============================================================================
; Fills memory with a single value.
; INPUT: A = value to fill, HL = start address, BC = count / size
; OUTPUT: void
; CLOBBERS: hl, de
;===============================================================================
fillmem:
        ld      (hl),a
        ld      e,l
        ld      d,h
        inc     de
        dec     bc
        ldir
        ret
