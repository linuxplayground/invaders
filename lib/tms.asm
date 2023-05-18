        include 'tms_constants.asm'

;===============================================================================
; Initialize the VDP in Graphics Mode 2 hybrid mode.
; refer to .tms_init_g2_registers at the end of this file for details.
; INPUT: void
; OUTPUT: void
; CLOBBERS: none
;===============================================================================
tms_init_g2:
        ld      hl,.tms_init_g2_registers
        ld      b,.tms_init_g2_registers_length
        ld      c,io_tmslatch
        otir
        ret

;===============================================================================
; Set the VDP Address to write to.
; INPUT: hl = write address
; OUTPUT: void
; CLOBBERS: none
;===============================================================================
tms_set_write_address:
        di
        ld      a,l
        out     (io_tmslatch),a
        ld      a,h
        or      0x40
        out     (io_tmslatch),a
        ei
        ret

;===============================================================================
; Set the VDP Address to read from.
; INPUT: hl = read address
; OUTPUT: void
; CLOBBERS: none
;===============================================================================
tms_set_read_address:
        di
        ld      a,l
        out     (io_tmslatch),a
        ld      a,h
        out     (io_tmslatch),a
        ei
        ret

;===============================================================================
; Graphics Mode II registers
;===============================================================================
.tms_init_g2_registers:
        db      0x02, 0x80      ;Graphics mode 2, no external video
        db      0xe2, 0x81      ;16K,enable display, disable int, 16x16 sprites
        db      0x0e, 0x82      ;name table = 0x1800
        db      0x9f, 0x83      ;color table = 0x2000-0x2800
        db      0x00, 0x84      ;pattern table = 0x0000-0x0800
        db      0x76, 0x85      ;sprite attribute table 0x1b00
        db      0x03, 0x86      ;sprite pattern table 0x1800
        db      0x0b, 0x87      ;backdrop color = black
.tms_init_g2_registers_length: equ $-.tms_init_g2_registers

;===============================================================================
; Frame buffer memory
;===============================================================================
        ds	0x300-(($+0x300)&0x2ff) ; pad out to align tms_buffer on a page
                                        ; boundary.
; Frame buffer for graphics mode 2
tms_buffer:     ds 0x300, 0
