bdos_call:              equ 0x0005
bdos_conout:            equ 0x02
bdos_conio:             equ 0x06
bdos_const:             equ 0x0b
bdos_fopen:             equ 0x0f
bdos_fclose:            equ 0x10
bdos_fread:             equ 0x14
bdos_fdelete:           equ 0x13
bdos_fwrite:            equ 0x15
bdos_fmake:             equ 0x16
bdos_setdma:            equ 0x1a
bdos_gsuid:             equ 0x20

fcb:                    equ 0x5c
fblk_c:                 db 0x00         ; 8bit counter of 128byte blocks
p_flast:                dw 0x0000       ; ptr to last byte of memory
p_fcur:                 dw 0x0000       ; ptr to current byte in file
fcount:                 db 0x80         ; number of bytes to read.
frec:                   ds 0x80         ; 128 byte internal buffer for file io
joy_status:             ds 4
kbd_buffer:             ds 0xff
kbd_buffer_read_pos:    db 0
kbd_buffer_write_pos:   db 0

;===============================================================================
; Blocking wait for keypress
; INPUT: void
; OUTPUT: A=0 no key press, A=1 key press detected
; CLOBBERS: HL on Nabu
;===============================================================================
wait_for_key:
        call    is_key_pressed
        or      a
        jr      nz,wait_for_key
        ret

;===============================================================================
; CP/M Get Key press
; INPUT: void
; OUTPUT: ascii of pressed key in A
; CLOBBERS: BC, DE
;===============================================================================
getk:
        ld      c,bdos_conio
        ld      de,0xff
        call    bdos_call
        ret
;===============================================================================
; CP/M Write char
; INPUT: ascii value to write in A
; OUTPUT: void
; CLOBBERS: BC, DE
;===============================================================================
puts:
        ld      e,a
        ld      c,bdos_conout
        call    bdos_call
        ret

;===============================================================================
; F I L E   I O   R O U T I N E S
; Only one file can be open at a time in this implimentation.  It's possible to
; open more files at the same time, but I have not added support for that here.
; Perhaps in the future...
; Also I have not bothered to differentiate between a file for READ or a file
; for WRITE.  They are all RW.
;===============================================================================

;===============================================================================
; Sets the current user area and the disk in the FCB byte 0
; INPUT: B  = uuuudddd uuuu=user area; dddd=disk
; OUTPUT: void
; CLOBBERS: BC
;===============================================================================
f_setdisk_and_user:
        push    hl
        push    bc
        ld      c,bdos_gsuid
        ld      a,b

        rra
        rra
        rra
        rra

        ld      e,a             ; extract user area from B
        call    bdos_call
        pop     bc              ; restore disk and user data in B
        ld      a,b
        and     0x0f
        ld      (fcb),a         ; set first byte of fcb to disk provided in B
        pop     hl
        ret

;===============================================================================
; Create a new file, set the CR bit of the FCB to zero so that read or writes
; continue from the beginning of the file.  Deletes any existing file of the
; same name.  Changes to specified user area and sets the disk number provided
; in B.
; XXX No error handling.
; INPUT: HL = pointer to filename
;        B  = uuuudddd uuuu=user area; dddd=disk
; OUTPUT: void
; CLOBBERS: AF, BC, DE, HL
;===============================================================================
f_make:
        call    f_setdisk_and_user
        ld      de,fcb+1        ; set de to point to start of filename
        ld      bc,0x000b       ; set length of filename to 11 bytes.
        ldir                    ; copy filename into fcb
        ld      de,fcb          ; de points to fcb
        ld      c,bdos_fdelete
        call    bdos_call       ; delete the file if it already exists.
if debug=1
        call    hexdump_a
endif
        xor     a
        ld      (fcb+32),a      ; set index into file to zero
        ld      de,fcb          ; de points to fcb
        ld      c,bdos_fmake
        call    bdos_call       ; fcb is now initialised with the file details.
if debug=1
        call    hexdump_a
endif
        ret

;===============================================================================
; Open an existing file.  Sets up FCB with details of file.
; INPUT: HL = pointer to filename.
;        B  = uuuudddd uuuu=user area; dddd=disk
; OUTPUT: void
; CLOBBERS: AF, BC, DE, HL
;===============================================================================
f_open:
        call    f_setdisk_and_user
        ld      de,fcb+1        ; set de to point to start of filename
        ld      bc,0x000b       ; set length of filename to 11 bytes.
        ldir                    ; copy filename into fcb
        xor     a
        ld      (fcb+32),a      ; set index into file to zero
        ld      de,fcb          ; de points to fcb
        ld      c,bdos_fopen
        call    bdos_call       ; fcb is now initialised with the file details.
if debug=1
        call    hexdump_a
endif
        ret

;===============================================================================
; Close an alrady open file using the previously set FCB.
; INPUT: void
; OUTPUT: void
; CLOBBERS: AF, BC, DE, HL
;===============================================================================
f_close:
        ld      c,bdos_fclose
        ld      de,fcb
        call    bdos_call
        ret

; zero out IO buffer.
flush_frec:
        push    bc
        push    de
        ld      b,0x80
        ld      de,frec
        xor     a
.flush_frec_lp:
        ld      (de),a
        inc     de
        djnz    .flush_frec_lp

        pop     de
        pop     bc
        ret

; load data into frec while writing to file.
write_frec:
        ld      de,frec
        ld      b,0x80
.write_frec_lp:
        ld      a,(hl)
        or      a
        jr      z,.write_frec_eof
        ld      (de),a
        inc     de
        inc     hl
        djnz    .write_frec_lp
        ret
.write_frec_eof:         ; insert EOF
        ; inc     de    ; data is zero terminated, replace zero with ctrl+z
        ld      a,0x1a
        ld      (de),a
        ret

;===============================================================================
; Write a buffer to the already open file.  Copies data in 128 byte chunks from
; data pointed to by HL.  It does this via an internal 128byte buffer that's
; always initialised to zero.  It inserts a CTRL+Z char at the end of the file.
; INPUT: HL = pointer to data buffer to write.
;        BC = length of buffer
; OUTPUT: void
; CLOBBERS: AF, BC, DE, HL
;===============================================================================
f_write:
        push    hl
        ; save value of HL ptr + BC len
        adc     hl,bc
        ld      (p_flast),hl
        pop     hl
.f_write_loop:
        call    flush_frec
        call    write_frec

        push    hl
        ; Set DMA address to start of frec
        ld      de,frec
        ld      c,bdos_setdma
        call    bdos_call

        ld      de,fcb
        ld      c,bdos_fwrite
        call    bdos_call
        ; compare hl with p_flast to see if we are done.
        pop     hl
        ld      de,(p_flast)
        or      a
        sbc     hl,de
        add     hl,de
        jr      c,.f_write_loop

        ret

; copies data in freq to user buffer.  If an 0x1a is found, stop.
cp_frec_to_user:
        ex      de,hl
        ld      hl,frec
        inc     b
.cp_frec_to_user_lp:
        ld      a,(hl)
        cp      0x1a
        jr      z,.cp_frec_to_user_end
        ld      (de),a
        inc     hl
        inc     de
        dec     c
        jr      nz,.cp_frec_to_user_lp
        dec     b
        jr      nz,.cp_frec_to_user_lp
        xor     a
        ex      de,hl
        ret
.cp_frec_to_user_end:
        ld      a,1
        ex      de,hl
        ret

;===============================================================================
; Read DE number of bytes from a file into a file into buffer pointed to by HL
; INPUT: HL = pointer to data buffer to read into.
;        BC = length of data to read. Should be <= sizeofbuffer
; OUTPUT: void
; CLOBBERS: AF, BC, DE, HL
; IF HL equals DE, Z=1,C=0
; IF HL is less than DE, Z=0,C=1
; IF HL is more than DE, Z=0,C=0
;===============================================================================
f_read:
        ld      (p_fcur),hl
        add     hl,bc
        ld      (p_flast),hl
.f_read_lp:
        ; read a record into internal buffer
        ld      de,frec
        ld      c,bdos_setdma
        call    bdos_call
        ld      de,fcb
        ld      c,bdos_fread
        call    bdos_call
        ; p_flast - p_fcur => fcount
        ld      de,(p_fcur)
        ld      hl,(p_flast)
        sbc     hl,de
        push    hl
        ld      de,0x0080
        or      a
        sbc     hl,de
        add     hl,de
        jr      c,.f_read_less_than_80
        pop     hl      ; throw away
        ld      bc,0x0080
        jp      .f_read_record
.f_read_less_than_80:
        pop     bc      ; save hl into bc
.f_read_record:
        ld      hl,(p_fcur)
        call    cp_frec_to_user
        ld      (p_fcur),hl     ; new posistion of file pointer
        ; is this past last?
        ld      de,(p_flast)
        or      a
        sbc     hl,de
        add     hl,de
        jr      c,.f_read_lp
        ret

if debug=1
        include 'debug.asm'
endif