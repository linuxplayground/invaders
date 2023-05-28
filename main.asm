; include macros first.
is_nabu:        equ     1

        include 'macros.asm'

        org     0x100
        ld      sp,.stack

if is_nabu = 1
        call    init_nabu
endif

main:
        call    tms_clear_vram
        call    tms_init_g1
        
        ld      b,tms_gray<<4|tms_black
        call    tms_set_all_colors
        
        ld      b,tms_dark_yellow
        call    tms_set_backdrop_color
        
        ld      de,tms_patternTable
        ld      bc,inv_patterns_len
        ld      hl,inv_patterns
        call    tms_write_slow

        ld      a,0x60
        ld      de,0x1010
        call    set_char_at_loc_buf
        ld      a,0x61
        ld      de,0x1110
        call    set_char_at_loc_buf

        call    tms_flush_buffer
        
exit:   
        call    get_char
        call    cpm_terminate

; includes
if is_nabu = 1
        include 'nabu.asm'
else
        include 'z80retro.asm'
endif
        include 'tms.asm'
        include 'utils.asm'
        include 'inv_patterns.asm'

; stack
        ds      1024
.stack: equ     $
