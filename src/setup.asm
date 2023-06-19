;===============================================================================
; Setups up the VDP memory and registers.
; INPUT: void
; OUTPUT: void
; CLOBBERS: AF, BC, DE, HL
;===============================================================================
setup:
        call    tms_clear_vram
        call    tms_init_g1
        
        ld      bc,inv_patterns_len
        ld      hl,inv_patterns
        call    tms_load_pattern_table

        ld      bc,sprite_patterns_len
        ld      hl,emptySprite
        call    tms_load_sprite_pattern_table

        ld      c,tms_dark_yellow
        call    tms_set_backdrop_color
        
        ld      c,tms_gray<<4|tms_black
        call    tms_set_all_colors

        ret