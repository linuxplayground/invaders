; writes all the sprite attribute data to vdp memory
flush_sprite_attribute_data:
        ld      hl,player_attributes
        ld      de,tms_spriteAttributeTable
        ld      bc,sprite_attributes_len
        call    tms_write_slow
        ret

; sprite attribute data
sprite_attributes:
player_attributes:
        db      21*8+4          ; vertical position.   0=top
        db      32*8/2-16/2     ; horizontal position. 0=left
        db      4               ; pattern name number
        db      0x08            ; early clock & color
bullet_attributes:
        db      0xd0            ; vertical position.   0=top
        db      0x00            ; horizontal position. 0=left
        db      8               ; pattern name number
        db      0x08            ; early clock & color
explode_attributes:
        db      0xd0            ; vertical position.   0=top
        db      0x00            ; horizontal position. 0=left
        db      12              ; pattern name number
        db      0x08            ; early clock & color
bomb_attributes:
        db      0xd0            ; vertical position.   0=top
        db      0x00            ; horizontal position. 0=left
        db      16              ; pattern name number
        db      0x08            ; early clock & color
        ds      0x080-($-sprite_attributes),0xd0              ; padd the rest (0xd0 = no such sprite)
sprite_attributes_len:        equ     $-sprite_attributes