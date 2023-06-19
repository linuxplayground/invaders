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
adddea: macro
        add     a, e    ; A = A+E
        ld      e, a    ; E = A+E
        adc     a, d    ; A = A+E+D+carry
        sub     e       ; A = D+carry
        ld      d, a    ; D = D+carry
endm
;===============================================================================
; Multiplication Macros (powers of 2 only.)
; INPUT: HL, value to multiply
; OUTPUT: HL = result of multiplication
; CLOBBERS: none
;===============================================================================
mul4: macro
        add     hl,hl   ;2
        add     hl,hl   ;4
endm

mul8: macro
        add     hl,hl   ;2
        add     hl,hl   ;4
        add     hl,hl   ;8
endm

mul16: macro
        add     hl,hl   ;2
        add     hl,hl   ;4
        add     hl,hl   ;8
        add     hl,hl   ;16
endm

mul32: macro
        add     hl,hl   ;2
        add     hl,hl   ;4
        add     hl,hl   ;8
        add     hl,hl   ;16
        add     hl,hl   ;x32
endm

;===============================================================================
; Division Macros (powers of 2 only.)
; INPUT: A, value to divide
; OUTPUT: A = result of division
; CLOBBERS: none
;===============================================================================
div2: macro
        and     0xfe       ; remove the bits that get rotated out
        rra
endm

div4: macro
        and     0xfc       ; remove the bits that get rotated out
        rra
        rra
endm

div8:   macro
        and     0xf8       ; remove the bits that get rotated out
        rra
        rra
        rra
endm

;===============================================================================
; Memory Management Macros
;===============================================================================
fillmem: macro start size value
        ld      a,value
        ld      hl,start
        ld      bc,size
        call    fillmem
endm

inc8: macro addr
        ld      a,(addr)
        inc     a
        ld      (addr),a
endm
