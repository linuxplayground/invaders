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
        add     hl,de           ; row position in tms buffer
        ld      a,(tile_x)
        addhla                  ; hl points to tile under HL pixel location
        ld      a,(hl)
        ret 

; returns HL = pointer to alien at tile_x, tile_y
;          A > 0 HIT (pattern name of hit tile.)
;          A = 0 MISS
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
        ld      a,(tile_x)
        ; add     a,a                     
        cp      (ix+2)                  
        jr      z,.alien_at_match       
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