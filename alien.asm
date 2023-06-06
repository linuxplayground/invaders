alien_dir:      db 1    ; 0 = moving left, 1 = moving right
alien_new_dir:  db 1    ; record the new direction
alien_drop:     db 0    ; boolean flag to indicate that aliens must drop a row
alien_top_y:    db 2    ; y value of top row
alien_bottom_y: db 10   ; y value of bottom row
alien_row:      db 0    ; row counter

; move and draw the alien grid
draw_alien_grid:
        ld      ix,aliens
        ld      a,(alien_bottom_y)
        ld      hl,alien_top_y
        sub     (hl)
        div2
        inc     a
        ld      (alien_row),a
.draw_alien_row:
        ld      d,(ix+2)
        ld      e,(ix+3)
        xor     a
        call    set_char_at_loc_buf

        ld      b,11
.draw_alien_grid_1:
        ld      de,tms_buffer
        ld      l,(ix+3)        ; ty
        ld      h,0
        mul32
        add     hl,de           ; row position in tms buffer
        ex      de,hl
        
        ; decide new position
        ld      a,(alien_dir)   ; get the direction
        or      a
        jr      z,.moving_left
.moving_right:
        ld      a,(ix+1)        ; current px
        inc     a
        ld      (ix+1),a
        jp      .calc_new_tx
.moving_left:
        ld      a,(ix+1)        ; current px
        dec     a
        ld      (ix+1),a        ; save px
.calc_new_tx:
        div4                    ; calculate tx
        ld      (ix+2),a        ; save tx
        ; only check boundaries if the alien we are drawing is not 0.
        ld      a,(ix+0)
        or      a
        jr      z,.not_left_bound       ; skip the boundary check if pattern is 0
        ld      a,(ix+2)
        cp      0x1e            ; check boundaries
        jr      c,.not_right_bound
        ld      a,0
        ld      (alien_new_dir),a
        ld      a,1
        ld      (alien_drop),a
        jp      .not_left_bound
.not_right_bound:
        cp      0x01
        jr      nc,.not_left_bound
        ld      a,1
        ld      (alien_new_dir),a
        ld      (alien_drop),a
.not_left_bound:
        ld      a,(ix+2)
        adddea
        ld      a,(ix+0)        ; type
        or      a
        jr      z,.draw_alien_pattern
        ld      c,a             ; save type
        ld      a,(ix+1)        ; px
        and     0x03            ; px modulus 4 (to get the pattern)
        add     a,a             ; double it to get the starting offset of the
        add     c               ; alien pattern
.draw_alien_pattern:
        ld      (de),a
        inc     de
        or      a
        jr      z,.draw_alien_grid_2
        inc     a
.draw_alien_grid_2:
        ld      (de),a
.draw_alien_grid_inc_ix:
        inc     ix
        inc     ix
        inc     ix
        inc     ix

        dec     b
        jr      nz,.draw_alien_grid_1

        ld      d,(ix-2)        ; draw a blank at the end of the row too.
        inc     d
        inc     d
        ld      e,(ix-1)
        xor     a
        call    set_char_at_loc_buf
        
        ld      a,(alien_row)
        dec     a
        ld      (alien_row),a
        jp      nz,.draw_alien_row
        ; set the direction to whatever was decided.
        ld      a,(alien_new_dir)
        ld      (alien_dir),a
        ret

; this routine is executed whenever the aliens have changed direction.  It can
; not be run during the draw aliens routine as all aliens must move in unison.
; the drop_aliens flag will have already been checked so just drop them all
; by one row.
drop_aliens:
        ld      ix,aliens
        ld      a,(alien_bottom_y)
        ld      hl,alien_top_y
        sub     (hl)
        div2
        inc     a
        ld      (alien_row),a
.drop_alien_row:
        ld      l,(ix+3)
        ld      h,0
        ld      b,11
        call    clear_row
.drop_aliens_1:
        ld      a,(ix+3)
        add     1
        ld      (ix+3),a
        ld      a,(ix+0)
        or      a
        jr      z,.drop_aliens_2
        ld      a,(ix+3)
        cp      22
        jr      nc,.drop_aliens_3
        ld      (alien_bottom_y),a
.drop_aliens_2:
        inc     ix
        inc     ix
        inc     ix
        inc     ix
        dec     b
        jr      nz,.drop_aliens_1

        ld      a,(alien_row)
        dec     a
        ld      (alien_row),a
        jr      nz,.drop_alien_row

        ld      a,(alien_top_y)
        inc     a
        ld      (alien_top_y),a

        xor     a               ; return value of 0 means not game over.
        ld      (alien_drop),a ; reset drop_aliens flag
        ret
.drop_aliens_3:
        ld      a,1             ; return value of 1 means game over.
        ret

; clear out a row
; l = y row number to clear out
clear_row:
        push    af
        push    bc
        push    de
        push    hl
        ld      de,tms_buffer
        mul32
        add     hl,de
        ex      de,hl
        ld      b,32
        xor     a
.blank_row_1:
        ld      (de),a
        inc     de
        dec     b
        jr      nz,.blank_row_1
        pop     hl
        pop     de
        pop     bc
        pop     af
        ret

        include "aliens_array.asm"