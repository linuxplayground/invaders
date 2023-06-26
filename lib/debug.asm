;===============================================================================
; Print out the contents of the A register in HEX
; INPUT: A = value to print
; OUTPUT: void
; CLOBBERS: none
;===============================================================================
hexdump_a:
        push    af
        srl     a
        srl     a
        srl     a
        srl     a
        call    .hexdump_nib
        pop     af
        push    af
        and     0x0f
        call    .hexdump_nib
        ld      a,':'
        call    puts
        pop     af
        ret

.hexdump_nib:
        add     '0'
        cp      '9'+1
        jp      m,.hexdump_num
        add     'A'-'9'-1
.hexdump_num:
        jp      puts