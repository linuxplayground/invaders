; Display the main menu
; wait for fire button or escape keypress.
menu:
        call    tms_clear_screen
        call    get_high_score
        ld      de,0x0000
        ld      hl,str_score
        call    print_at_loc_buf
        call    update_scores
        call    display_lives
        call    draw_score_line

        ld      c,5
        ld      hl,str_menu_1
        call    center_text_in_buf_row

        ld      c,7
        ld      hl,str_menu_2
        call    center_text_in_buf_row

        ld      c,9
        ld      hl,str_menu_3
        call    center_text_in_buf_row

        ld      c,11
        ld      hl,str_menu_4
        call    center_text_in_buf_row

        ld      a,0x64
        ld      de,0x0810
        call    set_char_at_loc_buf
        ld      a,0x65
        ld      de,0x0910
        call    set_char_at_loc_buf

        ld      a,0x6c
        ld      de,0x0b10
        call    set_char_at_loc_buf
        ld      a,0x6d
        ld      de,0x0c10
        call    set_char_at_loc_buf

        ld      a,0x74
        ld      de,0x0e10
        call    set_char_at_loc_buf
        ld      a,0x75
        ld      de,0x0f10
        call    set_char_at_loc_buf

        ld      de,0x0812
        ld      hl,str_menu_5
        call    print_at_loc_buf

        ld      hl,0x887a
        ld      (ufo_attributes),hl
        ld      hl,0x9f78
        ld      (player_attributes),hl

        ld      a,(game_over_flag)
        or      a
        jr      z,.flush
        ld      c,13
        ld      hl,str_menu_6
        call    center_text_in_buf_row
        xor     a
        ld      (game_over_flag),a
.flush:
        call    tms_wait
        call    flush_sprite_attribute_data
        call    tms_flush_buffer

.wait_for_menu_input:
        call    is_key_pressed
        or      a
        jr      z,.menu_joystick
        call    get_char
        cp      0x1b
        jr      z,.menu_quit
.menu_joystick:
        xor     a               ; read joystick 0 status
        call    get_joy_status
        and     joy_map_button
        jr      z,.wait_for_menu_input
.menu_play:
        xor     a
        ret        
.menu_quit:
        ld      a,0x01
        ret