; include macros first.
        include 'macros.asm'

        org     0x100
        ld      sp,.stack

        call    init
main:
        call    setup
        call    draw_shields


loop:
        inc8    ticks
        ld      a,(alien_count) ; check if we have won
        or      a
        jr      z,exit_game
        call    is_key_pressed  ; check user input
        or      a
        jr      z,joy_input
        call    player_key_input
        or      a
        jr      nz,exit_game
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
        jp      nz,exit_game
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
        call    cpm_terminate

; includes
        include 'platform.asm'
        include 'tms.asm'
        include 'utils.asm'
        include 'inv_patterns.asm'
        include 'setup.asm'
        include 'alien.asm'
        include 'shields.asm'
        include 'sprites.asm'
        include 'player.asm'

; global variables
ticks:          db 0
game_speed:     db 8
tile_px_x:      db 0
tile_px_y:      db 0
tile_x:         db 0
tile_y:         db 0
tile_name:      db 0
bullet_active:  db 0
alien_dir:      db 1    ; 0 = moving left, 1 = moving right
alien_new_dir:  db 1    ; record the new direction
alien_drop:     db 0    ; boolean flag to indicate that aliens must drop a row
alien_top_y:    db 2    ; y value of top row
alien_bottom_y: db 10   ; y value of bottom row
alien_row:      db 0    ; row counter
alien_count:    db 57   ; remaning aliens
alien_note:     db 10, 9, 7, 5
alien_march_counter: db 4; marching tempo
alien_march_index: db 0 ; index into alien_note
; stack
        ds      1024
.stack: equ     $
