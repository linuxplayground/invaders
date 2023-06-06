; draw the sheilds into the framebuffer.
draw_shields:
        ld      de,tms_buffer
        ld      l,19
        ld      h,0
        mul32
        add     hl,de           ; row position in tms buffer
        ex      de,hl
        ld      a,5
        adddea
        ld      b,shields_array_len
        ld      hl,sheilds_array
.draw_sheidls_1:
        ld      a,(hl)
        ld      (de),a
        inc     de
        inc     hl
        djnz    .draw_sheidls_1
        ret

        include "shields_array.asm"
