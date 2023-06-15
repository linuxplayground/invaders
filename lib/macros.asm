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

;===============================================================================
; Audio Set mixer channels
; INPUT: channels = eg. enable TONE A and TONE B "AY_MIX_TONE_A&AY_MIX_TONE_B"
;===============================================================================
ay_set_mixer: macro channels
        ld      b,0x07
        ld      c,channels
        call    ay_write
endm
;===============================================================================
; Audio Set Volume
; INPUT: chan = AY_VOLUME_A,AY_VOLUME_B,AY_VOLUME_C
;        envelope = 0 = not controlled by envelope, 1=controlled by envelope
;===============================================================================
ay_set_volume: macro chan volume envelope
        ld      b,chan
if envelope = 0
        ld      c,volume
else
        ld      c,0x10|volume
endif
        call    ay_write
endm
;===============================================================================
; Audio Play note
; INPUT: chan = AY_CHANNEL_A,AY_CHANNEL_B,AY_CHANNEL_C
;        course Course Period
;        fine   Fine Period
;===============================================================================
ay_play_note: macro chan course fine
        ld      b,chan
        ld      c,fine
        call    ay_write
        ld      b,chan+1
        ld      c,course
        call    ay_write
endm
;===============================================================================
; Audio Set Envelope Period
; INPUT: course Course Period
;        fine   Fine Period
;===============================================================================
ay_set_env_period: macro course fine
        ld      b,AY_ENVELOPE_F
        ld      c,fine
        call    ay_write
        ld      b,AY_ENVELOPE_C
        ld      c,course
        call    ay_write
endm
;===============================================================================
; Audio Set Envelope Shape
; INPUT: Shape of envelope AY_ENV_SHAPE_SAW_CONT
;===============================================================================
ay_set_env_shape: macro shape
        ld      b,AY_ENVELOPE_SHAPE
        ld      c,shape
        call    ay_write
endm