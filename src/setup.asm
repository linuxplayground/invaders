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

; Set up new game  This is needed so we can impliment the conept of levels
; and play again etc.  First we copy the aliens array out of memory into
; reserved space allocated for this purpose.
new_game:
        ; copy aliens_default into aliens for this game.
        ld      bc,aliens_len
        ld      hl,aliens_default
        ld      de,aliens
        ldir

        ; reset standard game_vars
        ld      a,55
        ld      (alien_count),a
        ld      a,2
        ld      (alien_top_y),a
        ld      a,10
        ld      (alien_bottom_y),a
        ld      a,8
        ld      (game_speed),a
        ld      a,1
        ld      (alien_dir),a
        ld      (alien_new_dir),a
        ld      a,3
        ld      (lives),a
        xor     a
        ld      (bullet_active),a
        ld      (bomb_active),a
        ld      (ufo_active),a
        ld      (score),a
        ; this bit will come from disk eventually.
        ld      hl,40
        ld      (high_score),hl
        
        ld      de,0x0000
        ld      hl,str_score
        call    print_at_loc_buf
        call    update_scores
        call    display_lives
        ret