debug:                  equ     1

        org     0x100
        ld      sp,.stack

main:
        ; make a new file and write some data into it.
        ld      hl,fname
        ld      b,0x33
        call    f_make          ; create a new file (also opens it)

        ld      hl,data
        call    str_len         ; length is returned in BC
        ld      hl,data
        call    f_write         ; write data to the file

        call    f_close         ; close the file.
        ;
        ; open an existing file and read the first 256bytes of data into a buffer
        ; then to test, we just print all the data that's in that buffer.
        ;
        ld      hl,fname
        ld      b,0x33
        call    f_open

        ld      hl,read_buffer
        ld      bc,0x0006
        call    f_read

        call    f_close

        ld      a,(test_oveflow)
        call    hexdump_a
        jp 0    ; exit.

fname:  db "TESTFILETXT",0
data:   db "01234567012345670123456701234567012345670123456701234567012345",0x0a,0x0d   ; 0x40
        db "11234567012345670123456701234567012345670123456701234567012345",0x0a,0x0d   ; 0x80
        db "21234567012345670123456701234567012345670123456701234567012345",0x0a,0x0d   ; 0xa0
        db "31234567012345670123456701234567012345670123456701234567012345",0x0a,0x0d   ; 0xf0
        db "41234567012345670123456701234567012345670123456701234567012345",0x0a,0x0d   ; 0x140
        db "51234567012345670123456701234567012345670123456701234567012345",0x0a,0x0d   ; 0x180
        db "61234567012345670123456701234567012345670123456701234567012345",0x0a,0x0d   ; 0x1a0
        db "71234567012345670123456701234567012345670123456701234567012345",0x0a,0x0d   ; 0x1f0
        db 0x00
read_buffer:    ds 0x06
test_oveflow:   db 0xff
; stack
        ds      1024
.stack: equ     $

        include 'stdio.asm'
        include 'strings.asm'
        include 'platform.asm'
