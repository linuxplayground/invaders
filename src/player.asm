; player input and management. updates the sprite attribute data not the buffer
player_key_input:
        call    get_char
        cp      0x1b
        jr      z,.quit
        jp      .return

player_joy_input:
        xor     a               ; read joystick 0 status
        call    get_joy_status
        ld      c,a

        and     joy_map_left
        jr      z,.not_left
        ; must be left
        ld      a,(player_attributes+1)
        sub     2
        ld      (player_attributes+1),a
        jp      .not_right

.not_left:
        ld      a,c
        and     joy_map_right
        jr      z,.not_right
        ; must be right
        ld      a,(player_attributes+1)
        add     2
        ld      (player_attributes+1),a
        ; fall through - always check the fire button.

.not_right:
        ld      a,(bullet_active)
        or      a
        jr      nz,.return      ; don't try to shoot if we are still shooting.
        ld      a,c
        and     joy_map_button
        jr      z,.return
        ; do fire logic

        ld      b,0             ; TONE A
        ld      de,0x0880       ; ENVELOPE DELAY
        ld      hl,71           ; INDEX TO NOTE
        call    ay_play_note_delay

        ld      iy,bullet_active
        ld      (iy+0),1       ; mark bullet as active
        ld      hl,(player_attributes)
        ld      (bullet_attributes),hl  ; set bullet position to match player
        ld      a,(bullet_attributes+1)
        add     8
        ld      (bullet_attributes+1),a ; shift bullet over to the centre of the
                                        ; the player
        ; fall through
.return:
        xor     a
        ret
.quit:
        ld      a,0xff
        ret

; move the bullet up the screen.
; check for collisions...
update_bullet:
        ld      a,(bullet_active)
        or      a
        ret     z
        ld      a,(bullet_attributes)
        sub     3
        ld      (bullet_attributes),a
        cp      8
        jr      nc,.detect_alien_collide
        ld      a,0xd0
        ld      (bullet_attributes),a
        xor     a
        ld      (bullet_active),a
        ret
.detect_alien_collide:
        ld      hl,(bullet_attributes)
        call    tile_at_xy
        or      a
        ret     z                       ; no alien tile under bullet.
        call    bullet_tile_collide
        or      a
        ret     z                       ; no alien pixel under bullet.
        ; we have hit an alien - find which one and set it's pattern to 0
        call    alien_at_tile_xy
        or      a
        ret     z                       ; no aliens or shields under bullet
        push    af                      ; save alien at tile_xy
        xor     a
        ld      (hl),a                  ; set the alien pattern to a zero
        ld      (bullet_active),a       ; disable bullet processing.
        ld      a,0xd7
        ld      (bullet_attributes),a   ; disable the bullet sprite.
        call    tms_wait                ; we need to make sure the alien that
        call    draw_alien_grid         ; we hit is removed from the screen
        call    tms_flush_buffer        ; because the last alien is left behind
        ; update score                  ; otherwise.
        pop     af                      ; restore alien at tile_xy
        cp      0x68                    ; is it less <= to bottom rows?
        jr      nc,.not_bottom_rows
        ld      a,5
        jp      .update_score
.not_bottom_rows:
        cp      0x70                    ; is it <= middle rows?
        jr      nc,.not_middle_rows
        ld      a,25
        jp      .update_score
.not_middle_rows:
        ld      a,45
        ; fall through
.update_score:
        ld      hl,(score)
        addhla
        ld      (score),hl
        call    update_scores
        ; decrement alien count
        dec8    alien_count
        ; calculate game speed based on remaining invader count.
        div8
        add     2
        ld      (game_speed),a
        ret

print_high_score:
        ; print the high score
        ld      de,tb16
        ld      hl,(high_score)
        call    itoa16
        ld      de,0x1200       ;x=8, y=0
        ld      hl,tb16
        call    print_at_loc_buf
        ret
print_score:
        ld      de,tb16
        ld      hl,(score)
        call    itoa16
        ld      de,0x0600       ;x=8, y=0
        ld      hl,tb16
        call    print_at_loc_buf
        ret

update_scores:
        call    print_score
        ; check if high score needs updating
        ld      hl,(score)
        ex      de,hl
        ld      hl,(high_score)
        or      a
        sbc     hl,de
        add     hl,de
        jr      nc,.update_scores_print_high_score
        ; it does - set it.
        ld      hl,(score)
        ld      (high_score),hl
.update_scores_print_high_score:
        jp      print_high_score

display_lives:
        ; clear the lives space in the title bar.
        ld      de,0x1f00       ; x=31, y=0
        ld      b,5
.display_lives_clear_lp:
        xor     a
        call    set_char_at_loc_buf
        dec     d
        djnz .display_lives_clear_lp
        ; draw the remaining lives
        ld      de,0x1f00
        ld      a,(lives)
        ld      b,a
.display_lives_lp:
        ld      a,0x78          ; lives icon
        call    set_char_at_loc_buf
        dec     d
        djnz    .display_lives_lp
        ret

; blink the player ship
blink_player:
        ld      c,3
.blink_player_lp:
        push    bc
        ld      a,0x00
        ld      (player_attributes+3),a
        call    tms_wait
        call    flush_sprite_attribute_data
        ld      b,20
        call    tms_delay
        ld      a,0x0f
        ld      (player_attributes+3),a
        call    tms_wait
        call    flush_sprite_attribute_data
        ld      b,20
        call    tms_delay
        pop     bc
        dec     c
        jr      nz,.blink_player_lp
        ret

        include "tiles.asm"