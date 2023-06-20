; player input and management. updates the sprite attribute data not the vdp
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
        xor     a
        ld      (hl),a                  ; set the alien pattern to a zero
        ld      (bullet_active),a       ; disable bullet processing.
        ld      a,0xd7
        ld      (bullet_attributes),a   ; disable the bullet sprite.
        ; decrement alien count
        dec8    alien_count
        ; calculate game speed based on remaining invader count.
        div8
        add     2
        ld      (game_speed),a
        ret

        include "tiles.asm"