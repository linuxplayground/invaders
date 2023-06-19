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