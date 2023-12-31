        include 'macros.asm'

        org     0x100
        ld      sp,.stack

        call    init
setup_game:
        call    setup
main:
        call    menu
        or      a
        jp      nz,exit_game

        call    tms_clear_buffer

        ld      hl,0x78ac
        ld      (player_attributes),hl   ; reset vertical position of player after menu
        ld      hl,0xd0ff
        ld      (ufo_attributes),hl   ; reset vertical position of player after menu
        call    flush_sprite_attribute_data
        call    new_game
level:
        call    new_level
        call    draw_shields
        call    draw_alien_grid
        call    tms_wait
        call    tms_flush_buffer
        call    blink_player
loop:
        inc8    ticks
        ld      a,(alien_count) ; check if we have won
        or      a
        jp      nz,.not_new_level
        ld      a,(game_level)
        inc     a
        ld      (game_level),a
        jp      level
.not_new_level:
        call    is_key_pressed  ; check user input
        or      a
        jr      z,joy_input
        call    player_key_input
        or      a
        jp      nz,main
joy_input:                      ; check joystick inputs
        call    player_joy_input
        call    update_bullet   ; updates the bullet if one is active

        ; handle screen update
        call    tms_wait        ; wait for TMS Frame
        call    flush_sprite_attribute_data   ; always flush the sprites
        ld      a,(game_speed)
        ld      c,a
        ld      a,(ticks)
        cp      c
        jr      c,loop          ; ticks < game_speed, do not flush buffer
        call    draw_alien_grid
        call    tms_flush_buffer
        ld      a,(alien_drop)
        or      a
        jr      z,reset_ticks   ; only drop aliens if they reach edge
        call    drop_aliens
        or      a               ; aliens have reached row 22 - end game
        jp      nz,game_over
reset_ticks:
        xor     a
        ld      (ticks),a       ; reset ticks.

        ; marching music
        dec8    alien_march_counter
        or      a
        jr      nz,exit_loop
        ld      a,4
        ld      (alien_march_counter),a

        ld      hl,alien_note
        ld      a,(alien_march_index)
        addhla
        ld      a,(hl)
        ld      b,1             ; TONE B
        ld      de,0x0480       ; ENVELOPE DELAY
        ld      l,a
        ld      h,0
        call    ay_play_note_delay
        inc8    alien_march_index
        cp      4
        jr      c,exit_loop
        xor     a
        ld      (alien_march_index),a
exit_loop:
        jp      loop
exit_game:
        call    ay_all_off

        ld      hl,str_saving
        ld      c,22
        call    center_text_in_buf_row
        call    tms_wait
        call    tms_flush_buffer
        call    save_high_score

        call    cpm_terminate
game_over:
        ld      b,30
        call    tms_delay
        ld      a,1
        ld      (game_over_flag),a
        jp      setup_game

; includes platform
        include 'platform.asm'
; include standard libraries
        include "stdlib.asm"
        include "stdio.asm"
        include 'tms.asm'
; include game libraries
        include 'inv_patterns.asm'
        include 'setup.asm'
        include 'alien.asm'
        include 'shields.asm'
        include 'sprites.asm'
        include 'player.asm'
        include 'strings.asm'
        include 'menu.asm'

; global variables
ticks:          db 0    ; current frame count
game_speed:     db 8    ; number of frames to wait before flushing screen
tile_px_x:      db 0    ; pixel offset inside tile for collision detection
tile_px_y:      db 0    ; pixel offset inside tile for collision detection
tile_x:         db 0    ; tile position
tile_y:         db 0    ; tile position
tile_name:      db 0    ; name of tile in tms pattern table
bullet_active:  db 0    ; keep track of if a bullet is in flight
bomb_active:    db 0    ; keep track of if a bomb is in flight
ufo_active:     db 0    ; keep track of if a ufo is active
fire_count:     db 22   ; number of shots remaining before next UFO
alien_dir:      db 1    ; 0 = moving left, 1 = moving right
alien_new_dir:  db 1    ; record the new direction
alien_drop:     db 0    ; boolean flag to indicate that aliens must drop a row
alien_top_y:    db 2    ; y value of top row
alien_bottom_y: db 10   ; y value of bottom row
alien_row:      db 0    ; row counter
alien_count:    db 55   ; remaning aliens
alien_note:     db 10, 9, 7, 5 ; index into ay_notes
alien_march_counter: db 4; marching tempo (higher numbers = slower)
alien_march_index: db 0 ; index into alien_note
lives:          db 3    ; 3 lives.  (when lives reaches zero we are dead.)
extra_life_given: db 0  ; keep track of if extra life has een given
game_level:     db 0    ; current game level.
game_over_flag: db 0    ; this is how we know to show the GAME OVER text.
str_score:      db "SCORE<     > HIGH<     >",0
str_menu_1:     db "INVADERS - V1.0",0
str_menu_2:     db "BY PRODUCTION-DAVE",0
str_menu_3:     db "SHOOT STARTS",0
str_menu_4:     db "ESCAPE QUITS",0
str_menu_5:     db " 5 25 45 ?? P1",0
str_menu_6:     db "GAME OVER",0
str_loading:    db "LOADING ...",0
str_saving:     db "SAVING ...",0

high_score_name: db "INVADERSDAT",0
score:          ds 2    ; two bytes for the score (16 bit)
high_score:     ds 2    ; two bytes for the high score (16 bit)
tb16:           ds 7    ; ascii integer buffer with leading zeros and /0 termin
aliens:         ds aliens_len
; stack
        ds      1024
.stack: equ     $
