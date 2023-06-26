; writes all the sprite attribute data to vdp memory
flush_sprite_attribute_data:
        ld      hl,sprite_attributes
        ld      de,tms_spriteAttributeTable
        ld      bc,tms_spriteAttributeTableLen
        call    tms_write_slow
        ret

; sprite attribute data
sprite_attributes:
player_attributes:
        db      22*8-4          ; vertical position.   0=top
        db      120             ; horizontal position. 0=left
        db      4               ; pattern name number
        db      0x0e            ; early clock & color
ufo_attributes:
        db      192             ; vertical position.   0=top
        db      0               ; horizontal position. 0=left
        db      8               ; pattern name number
        db      0x16            ; early clock & color
bullet_attributes:
        db      192             ; vertical position.   0=top
        db      0               ; horizontal position. 0=left
        db      12              ; pattern name number
        db      0x18            ; early clock & color
explode_attributes:
        db      192             ; vertical position.   0=top
        db      0               ; horizontal position. 0=left
        db      16              ; pattern name number
        db      0x1e            ; early clock & color
bomb_attributes:
        db      192             ; vertical position.   0=top
        db      0               ; horizontal position. 0=left
        db      20              ; pattern name number
        db      0x1c            ; early clock & color


        ds      0x80-($-sprite_attributes),0xd0              ; padd the rest (0xd0 = no such sprite)
sprite_attributes_len:        equ     $-sprite_attributes
PLAYER:         equ 0
UFO:            equ 4
BULLET:         equ 8
EXPLODE:        equ 12
BOMB:           equ 16