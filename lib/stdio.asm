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
fcount:                 db 0x80         ; number of bytes to read or write
frec:                   ds 0x80         ; 128 byte internal buffer for file io

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
        xor     a
        ld      (fcb+32),a      ; set index into file to zero
        ld      de,fcb          ; de points to fcb
        ld      c,bdos_fmake
        call    bdos_call       ; fcb is now initialised with the file details.
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
        ret                     ; or 0xFF on error.

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
        ld      (fcount),bc     ; save byte count to write
        ; save value of HL ptr + BC len
        adc     hl,bc
        ld      (p_flast),hl
        pop     hl
.f_write_loop:
        call    flush_frec
        ; calculate B = number of bytes left or 80.
        push    hl                      ; save HL (current ram pointer)
        ex      de,hl                   ; DE is now current pointer into file
        ld      hl,(p_flast)            ; HL is last pointer of file
        or      a                       ; clear carry
        sbc     hl,de                   ; subtract current from last
        ld      (fcount),hl             ; save bytes remaining
        ld      de,0x0080               ; subtract 80 from bytes remaining
        or      a                       ; if bytes remaining is > 80 then
        sbc     hl,de                   ; set bytes to copy into frec buffer
        add     hl,de                   ; to 0x80
        jr      nc,.f_write_loop_full_rec
        ld      a,(fcount)              ; else restore bytes remaining
        ld      c,a                     ; and proceed to copy data into frec
        jp      .f_write_loop_rec       ; buffer.
.f_write_loop_full_rec:
        ld      c,0x80                  ; From before, if bytes remaining is > 80
.f_write_loop_rec:
        pop     hl                      ; restore HL (current ram pointer)
        call    cp_ram_to_frec          ; copy data from ram into frec buffer

        push    hl
        ; Set DMA address to start of frec
        ld      de,frec
        ld      c,bdos_setdma
        call    bdos_call

        ld      de,fcb
        ld      c,bdos_fwrite
        call    bdos_call
        ; compare current ram pointer with p_flast to see if we are done.
        pop     hl
        ld      de,(p_flast)
        or      a
        sbc     hl,de
        add     hl,de
        jr      c,.f_write_loop

        ret

;===============================================================================
; Read DE number of bytes from a file into a file into buffer pointed to by HL
; INPUT: HL = pointer to data buffer to read into.
;        BC = length of data to read. Should be <= sizeofbuffer
; OUTPUT: void
; CLOBBERS: AF, BC, DE, HL
;===============================================================================
f_read:
        ld      (p_fcur),hl     ; start of user buffer
        add     hl,bc
        ld      (p_flast),hl    ; end of user buffer
.f_read_lp:
        ; read a record into internal buffer
        ld      de,frec         ; set dma to internal buffer
        ld      c,bdos_setdma
        call    bdos_call
        ld      de,fcb          ; read already open file
        ld      c,bdos_fread
        call    bdos_call
        ; p_flast - p_fcur => fcount
        ld      de,(p_fcur)
        ld      hl,(p_flast)
        sbc     hl,de
        push    hl              ; save difference
        ld      de,0x0080       ; check if difference is less than 80
        or      a
        sbc     hl,de
        add     hl,de
        jr      c,.f_read_less_than_80 ; it is less than 80
        pop     hl              ; throw away saved difference - we don't need it
        ld      bc,0x0080       ; read a whole record
        jp      .f_read_record
.f_read_less_than_80:
        pop     bc              ; pop the saved difference into bc and
.f_read_record:                 ; copy bc number of bytes from internal buffer
        ld      hl,(p_fcur)     ; to user buffer
        call    cp_frec_to_ram
        ld      (p_fcur),hl     ; new posistion of file pointer after read
        ; is this past last?
        ld      de,(p_flast)
        or      a
        sbc     hl,de
        add     hl,de
        jr      c,.f_read_lp    ; loop if HL < last address in user buffer.
        ret

;===============================================================================
; INTERNAL HELPER FUNCTIONS
;===============================================================================

; Sets the current user area and the disk in the FCB byte 0
; B  = uuuudddd uuuu=user area; dddd=disk
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

; zero out internal IO buffer. (frec)
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

; when writing a file, we want ot copy data from ram into the internal freq
; buffer so we can either copy all 80 bytes or just the number of remaining
; bytes.  We add an EOF every time but it's overwritten by the next go round.
; unless this is the last goround.
cp_ram_to_frec:
        ld      de,frec
        ld      b,0     ; c = number of bytes 80 or less than 80.
        ldir
        ld      a,0x1a  ; insert EOF
        ld      (de),a
        ret

; for read operations we need to copy data from the file into the internal buffer
; copies data in freq to user buffer.  If an 0x1a is found, stop.
cp_frec_to_ram:
        ex      de,hl
        ld      hl,frec
        inc     b
.cp_frec_to_ram_lp:
        ld      a,(hl)
        cp      0x1a
        jr      z,.cp_frec_to_ram_end
        ld      (de),a
        inc     hl
        inc     de
        dec     c
        jr      nz,.cp_frec_to_ram_lp
        dec     b
        jr      nz,.cp_frec_to_ram_lp
        xor     a
        ex      de,hl
        ret
.cp_frec_to_ram_end:
        ld      a,1
        ex      de,hl
        ret