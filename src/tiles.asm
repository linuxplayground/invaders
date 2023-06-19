; returns the tile in the frame buffer at x,y
; INPUT: H=X, L=Y
; OUTPUT: A = tile, tile_px_x = x offset, tile_px_y = y offset inside tile.
;         tile_x = tile x position, tile_y = tile y position.
tile_at_xy:
        ld      a,l
        and     0x07
        ld      (tile_px_y),a
        
        ld      a,l
        div8
        ld      (tile_y),a

        ld      a,h
        and     0x07
        ld      (tile_px_x),a

        ld      a,h
        div8
        ld      (tile_x),a

        ld      de,tms_buffer
        ld      hl,(tile_y)
        ld      h,0
        mul32
        ld      a,(tile_x)
        addhla                  ; hl points to tile under HL pixel location
        add     hl,de           ; cell position in tms buffer
        ld      a,(hl)
        ld      (tile_name),a   ; save pattern name.
        ret 

; sprite to tile collision detection.  We want to test 3 rows from current y
; to below.  It's possible that the the bullet, could be positioned over an eye
; or something, and at the speed the bullet goes, could miss the tile altogether
; input A = pattern name
;       tile_px_x, tile_px_y
; returns A = 0 MISS
;         A > 0 HIT
bullet_tile_collide:
        ld      b,4
.bullet_tile_collide_lp:
        ld      a,(tile_name)
        call    pixel_at_tile_xy
        or      a
        ret     nz
        ld      a,(tile_px_y)
        dec     a
        ld      (tile_px_y),a
        djnz    .bullet_tile_collide_lp
        xor     a
        ret


; test if the specific pixel location of the bullet matches a turned on pixel
; in the tile beneath it.
; inpput  A = pattern name
; returns A = 0 MISS
;         A > 0 HIT which ever bit was set.
pixel_at_tile_xy:
        ; load the pattern from pattern table offset by tile_px_y
        ld      de,inv_patterns
        ld      l,a
        ld      h,0     ; hl = pattern name
        mul8            ; A is offset into invader patterns for start of invaders
        ld      a,(tile_px_y)
        addhla          ; 
        add     hl,de   ; hl points to pattern row offset by tile_px_y
        ld      a,(hl)  ; a now has the pattern row data.
        ld      c,a     ; save A into c for now.
        ld      hl,pattern_test_bit_mask
        ld      a,(tile_px_x)
        addhla
        ld      a,(hl)  ; a now has the bitmask to test against c
        and     c
        ret

; returns HL = pointer to alien at tile_x, tile_y
; A > 0 HIT (pattern name of hit tile.)
; A = 0 MISS
alien_at_tile_xy:
        ld      ix,aliens
        ld      b,5                     ; search through 5 rows we only have to
        ld      a,(tile_y)
.alien_at_test_y_loop:                  ; match on the first item in each row.
        cp      (ix+3)
        jr      z,.alien_at_test_x
        ld      de,44
        add     ix,de                   ; increase IX by 11 aliens to look at
        djnz    .alien_at_test_y_loop   ; the next row.
        ; something terrible has happened.
        ; should not get here without matching at least one row.
        nop                             ; should never be executed.
.alien_at_test_x:
        ld      b,11                    ; 11 columns to check
.alien_at_test_x_loop:
        ld      a,(ix+2)
        ld      c,a
        ld      a,(tile_x)                
        cp      c
        jr      z,.alien_at_match       ; test left side of alien
        inc     c
        cp      c
        jr      z,.alien_at_match       ; test right side of alien
        inc     ix
        inc     ix
        inc     ix
        inc     ix                      ; move pointer along to next object.
        djnz    .alien_at_test_x_loop
        ; getting here means we did not find any ailens under our bullet.
        xor     a
        ret
.alien_at_match:
        ; ix at this time points to the start of the alien we hit. save it to HL
        push    ix
        pop     hl
        ld      a,(ix+0)                ; returns the pattern name of the alien
        ret                             ; matched.

tile_px_x:      db 0
tile_px_y:      db 0
tile_x:         db 0
tile_y:         db 0
tile_name:      db 0