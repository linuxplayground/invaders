        org     0x100
        ld      sp,.stack

main:
        ; make a new file and write some data into it.
        ld      hl,fname
        ld      b,0x00
        call    f_make          ; create a new file (also opens it)

        ld      hl,data
        ; call    str_len         ; length is returned in BC
        ld      bc,0x0005
        ld      hl,data
        call    f_write         ; write data to the file

        call    f_close         ; close the file.
        ;
        ; open an existing file and read the first 256bytes of data into a buffer
        ; then to test, we just print all the data that's in that buffer.
        ;
        ld      hl,fname
        ld      b,0x00
        call    f_open

        ld      hl,read_buffer
        ld      bc,0x0005
        call    f_read

        call    f_close
        jp 0    ; exit.

fname:  db "TESTFILETXT",0
data:   db "01234567012345670123456701234567012345670123456701234567012345",0x0a,0x0d   ; 0x3F
        db "01234567012345670123456701234567012345670123456701234567012345",0x0a,0x0d   ; 0x7F
        db "01234567012345670123456701234567012345670123456701234567012345",0x0a,0x0d   ; 0xBF
        db "01234567012345670123456701234567012345670123456701234567012345",0x0a,0x0d   ; 0xFF
        db "012345670123456701234567012",0x0a,0x0d   ; 0x40
        db 0x00
read_buffer:    ds 0x150
test_oveflow:   db 0xff
; stack
        ds      1024
.stack: equ     $

        include 'stdio.asm'
        include 'strings.asm'
