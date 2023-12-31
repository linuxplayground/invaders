;===============================================================================
; COLOURS
;===============================================================================
tms_transparent:                equ 0x00
tms_black:                      equ 0x01
tms_medium_green:               equ 0x02
tms_light_green:                equ 0x03
tms_dark_blue:                  equ 0x04
tms_light_blue:                 equ 0x05
tms_dark_red:                   equ 0x06
tms_cyan:                       equ 0x07
tms_medium_red:                 equ 0x08
tms_light_red:                  equ 0x09
tms_dark_yellow:                equ 0x0a
tms_light_yellow:               equ 0x0b
tms_dark_green:                 equ 0x0c
tms_magenta:                    equ 0x0d
tms_gray:                       equ 0x0e
tms_white:                      equ 0x0f

;===============================================================================
; VDP MEMORY - See .tms_init_g2_registers on tms.asm for details
;===============================================================================
tms_patternTable:               equ 0x0800
tms_patternTableLen:            equ 0x0800

tms_colorTable:                 equ 0x2000
tms_colorTableLen:              equ 0x0020

tms_nameTable:                  equ 0x1400
tms_nameTableLen:               equ 0x0300

tms_spriteAttributeTable:       equ 0x1000
tms_spriteAttributeTableLen:    equ 0x0080

tms_spritePatternTable:         equ 0x0000
tms_spritePatternTableLen:      equ 0x0800
