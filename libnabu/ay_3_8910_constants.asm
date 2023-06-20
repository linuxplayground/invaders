; AY mixer channel masks.  Always OR AY_DEFAULT with the channels you want to
; enable when setting the mixer regster.  This is to ensure that IO_PORTA and
; IO_PORTB do not get altered.
AY_MIX_TONE_A:          equ %01111110
AY_MIX_TONE_B:          equ %01111101
AY_MIX_TONE_C:          equ %01111011
AY_MIX_NOISE_A:         equ %01110111
AY_MIX_NOISE_B:         equ %01101111
AY_MIX_NOISE_C:         equ %01011111
AY_MIX_ALL_OFF:         equ %01111111

; these are actually indexes into the PERIOD table below.
AY_CHANNEL_A:           equ 0x00
AY_CHANNEL_B:           equ 0x02
AY_CHANNEL_C:           equ 0x04

AY_PERIOD_TONE_A_F:     equ 0x00
AY_PERIOD_TONE_A_C:     equ 0x01
AY_PERIOD_TONE_B_F:     equ 0x02
AY_PERIOD_TONE_B_C:     equ 0x03
AY_PERIOD_TONE_C_F:     equ 0x04
AY_PERIOD_TONE_C_C:     equ 0x05

AY_PERIOD_NOISE:        equ 0x06
AY_MIXER:               equ 0x07

AY_VOLUME_A:            equ 0x08
AY_VOLUME_B:            equ 0x09
AY_VOLUME_C:            equ 0x0a

AY_ENVELOPE_F:          equ 0x0b
AY_ENVELOPE_C:          equ 0x0c

AY_ENVELOPE_SHAPE:      equ 0x0d

AY_ENV_SHAPE_OFF:       equ 0x00
AY_ENV_SHAPE_DECAY:     equ 0x00
AY_ENV_SHAPE_SAW_CONT:  equ 0x0A