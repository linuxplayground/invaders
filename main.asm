; include macros first.
is_nabu:        equ     1
        include 'macros.asm'

        org     0x100
        ld      sp,.stack

ticks:  db 0

if is_nabu = 1
        call    init_nabu
        ; ay_set_mixer AY_MIX_TONE_A&AY_MIX_TONE_B
        ; ay_set_volume AY_VOLUME_A 15 1
        ; ay_set_volume AY_VOLUME_B 15 1
        ; ay_set_env_period 0x02 0xff
        ; ay_set_env_shape AY_ENV_SHAPE_SAW_CONT
        ; ay_play_note AY_CHANNEL_A 0x00 0x80
endif

main:
        call    setup
        call    draw_shields

        ; initialise the sprite attribute table.

loop:
        ld      a,(ticks)
        cp      0x08
        jr      nz,vdp_wait
        call    draw_alien_grid
        call    tms_flush_buffer
        ld      a,(alien_drop)
        or      a
        jr      z,.reset_ticks
        call    drop_aliens
        or      a
        jp      nz,exit
.reset_ticks:
        ; xor     a
        ld      (ticks),a
        jp      tick
vdp_wait:
        call    tms_wait
        ld      a,(bullet_active)
        or      a
        jr      z,flush_sprites
        call    update_bullet
flush_sprites:
        call    flush_sprite_attribute_data
tick:
        inc8    ticks
user_input:   
        call    is_key_pressed
        or      a
        jr      z,joy_input
        call    player_key_input
        or      a               ; if player input return value in A is a 0
        jr      nz,exit         ; then loop else quit.
joy_input:
        call    player_joy_input
        or      a
        jr      z,loop
exit:
        ay_set_volume AY_VOLUME_A 0 0
        ay_set_volume AY_VOLUME_B 0 0
        ay_set_volume AY_VOLUME_C 0 0
        ay_set_env_shape AY_ENV_SHAPE_OFF
        call    cpm_terminate

; includes
if is_nabu = 1
        include 'nabu.asm'
        include 'ay-3-8910_constants.asm'
else
        include 'z80retro.asm'
endif
        include 'tms.asm'
        include 'utils.asm'
        include 'inv_patterns.asm'
        include 'setup.asm'
        include 'alien.asm'
        include 'shields.asm'
        include 'sprites.asm'
        include 'player.asm'

; stack
        ds      1024
.stack: equ     $
