        org     0x100
        ld      sp,.stack

main:
        ;
        ; open an existing file and read the first 256bytes of data into a buffer
        ; then to test, we just print all the data that's in that buffer.
        ;
        ld      hl,fname
        ld      b,0x33
        call    f_open
        cp      0xff
        jr      nz,read_file
        ; file does not exist. Put 0x0040 into buffer
        ld      hl,0x0040
        ld      (read_buffer),hl
        jp      exit

read_file:
        ld      hl,read_buffer
        ld      bc,0x0002
        call    f_read

        call    f_close
exit:
        jp 0    ; exit.

fname:  db "TESTFILETXT",0
read_buffer:    ds 0x02
test_oveflow:   db 0xff
; stack
        ds      1024
.stack: equ     $

        include 'stdio.asm'
