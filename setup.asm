;===============================================================================
; Setups up the VDP memory and registers.
; INPUT: void
; OUTPUT: void
; CLOBBERS: AF, BC, DE, HL
;===============================================================================
setup:
        call    tms_clear_vram
        call    tms_init_g1
        
        ld      de,tms_patternTable
        ld      bc,inv_patterns_len
        ld      hl,inv_patterns
        call    tms_write_slow

        ld      c,tms_dark_yellow
        call    tms_set_backdrop_color
        
        ld      c,tms_gray<<4|tms_black
        call    tms_set_all_colors

        ret