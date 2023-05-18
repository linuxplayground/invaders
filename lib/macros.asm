;===============================================================================
; Add A to HL, result in HL
; INPUT: A = 8bit value to add to HL, HL=value to add to.
; OUTPUT: HL = result of addition.
; CLOBBERS: none
;===============================================================================
addhla: macro
        add     a, l    ; A = A+L
        ld      l, a    ; L = A+L
        adc     a, h    ; A = A+L+H+carry
        sub     l       ; A = H+carry
        ld      h, a    ; H = H+carry
endm
