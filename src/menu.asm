; Display the main menu
; wait for fire button or escape keypress.
menu:
        ld      c,5
        ld      hl,str_menu_1
        call    center_text_in_buf_row
        call    print_at_loc_buf
        ld      c,6
        ld      hl,str_menu_2
        call    center_text_in_buf_row
        ld      c,8
        ld      hl,str_menu_3
        call    center_text_in_buf_row
        ld      c,10
        ld      hl,str_menu_4
        call    center_text_in_buf_row

        call    tms_wait
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
        ld      a,0xff
        ret