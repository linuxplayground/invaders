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
        
        ld      bc,color_table_data_len
        ld      hl,color_table_data
        call    tms_load_color_table

        ret

; Set up new game  This is needed so we can impliment the conept of levels
; and play again etc.  First we copy the aliens array out of memory into
; reserved space allocated for this purpose.
new_game:
        ld      a,2
        ld      (alien_top_y),a
        ld      a,10
        ld      (alien_bottom_y),a
        xor     a
        ld      (score),a
        ld      de,0x0000
        ld      hl,str_score
        call    print_at_loc_buf
        call    update_scores
        call    display_lives
        call    draw_score_line
        ret

new_level:
        ; copy aliens_default into aliens for this game.
        ld      bc,aliens_len
        ld      hl,aliens_default
        ld      de,aliens
        ldir
        ld      a,2
        ld      (alien_top_y),a
        ld      a,10
        ld      (alien_bottom_y),a

        ld      a,(game_level)
        or      a
        jr      z,.new_level_set_vars
        ld      b,a
.new_level_shift_aliens_lp:
        push    bc
        call    drop_aliens
        pop     bc
        djnz    .new_level_shift_aliens_lp
.new_level_set_vars:
        ; reset standard game_vars
        ld      a,55
        ld      (alien_count),a

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

        ; disable UFO sprite that was shown in the menu.
        ld      hl,0xffd7
        ld      (ufo_attributes),hl
        ld      a,120
        ld      (player_attributes+1),a
        call    flush_sprite_attribute_data
        ret

draw_score_line:
        ld      de,0x0001       ; x=00, y=0
        ld      b,32
.display_lives_clear_lp:
        ld      a,0x13
        call    set_char_at_loc_buf
        inc     d
        djnz .display_lives_clear_lp

; fetches high score from disk.  High score is 0 if file does not exist.
get_high_score:
        ld      a,(0x04)        ; user / disk
        ld      b,a
        ld      hl,high_score_name
        call    f_open
        cp      0xff            ; high score is default (0) if file does not
        ret     z               ; exist.
.read_file:
        ld      hl,high_score
        ld      bc,0x0002
        call    f_read
        call    f_close
        ret

; saves high score to disk.  Creates file if it does not exist. Deletes existing
; file.
save_high_score:
        ld      a,(0x04)        ; user / disk
        ld      b,a
        ld      hl,high_score_name
        call    f_make
        ld      hl,high_score
        ld      bc,0x0002
        call    f_write
        call    f_close
        ret
