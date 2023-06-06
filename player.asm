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
        dec     a
        ld      (player_attributes+1),a
        jp      .not_right

.not_left:
        ld      a,c
        and     joy_map_right
        jr      z,.not_right
        ; must be right
        ld      a,(player_attributes+1)
        inc     a
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

update_bullet:
        ld      a,(bullet_attributes)
        sub     3
        ld      (bullet_attributes),a
        cp      8
        jr      nc,update_bullet_return
        ld      a,0xd0
        ld      (bullet_attributes),a
        xor     a
        ld      (bullet_active),a
update_bullet_return:
        ret

; variables
bullet_active:  db      0
