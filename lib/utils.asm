bdos:           equ 0x0005
con_out:	equ 0x02
conio:		equ 0x06
con_status:     equ 0x0b

joy_status:		ds  4
kbd_buffer:		ds  0xff
kbd_buffer_read_pos:	db 0
kbd_buffer_write_pos:	db 0

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
        ld	c,conio
        ld	e,0xff
        call	bdos
        ret
;===============================================================================
; CP/M Write char
; INPUT: ascii value to write in A
; OUTPUT: void
; CLOBBERS: BC, DE
;===============================================================================
puts:
        ld	e,a
        ld	c,con_out
        call	bdos
        ret

;===============================================================================
; Jumpt to CPM Warm Boot vector
; INPUT: void
; OUTPUT: void
; CLOBBERS: hl, de
;===============================================================================
cpm_terminate:
        jp      0

;===============================================================================
; Fills memory with a single value.
; INPUT: A = value to fill, HL = start address, BC = count / size
; OUTPUT: void
; CLOBBERS: hl, de
;===============================================================================
fillmem:
        ld 	(hl),a
        ld 	e,l
        ld 	d,h
        inc 	de
        dec 	bc
        ldir
        ret

;===============================================================================
; Print out the contents of the A register in HEX
; INPUT: A = value to print
; OUTPUT: void
; CLOBBERS: none
;===============================================================================
hexdump_a:
        push	af
        srl	a
        srl	a
        srl	a
        srl	a
        call	.hexdump_nib
        pop	af
        push	af
        and	0x0f
        call	.hexdump_nib
        ld      a,':'
        call    puts
        pop	af
        ret

.hexdump_nib:
        add	'0'
        cp	'9'+1
        jp	m,.hexdump_num
        add	'A'-'9'-1
.hexdump_num:
        jp	puts
