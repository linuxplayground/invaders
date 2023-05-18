;===============================================================================
; Interrupt Service Routine for the Nabu Keyboard and Joystick handling.
; INPUT: void
; OUTPUT: void
; CLOBBERS: none
;===============================================================================
isrKeyboard:
        push	bc
        push	de
        push	hl
        push	af
        push	iy

        ld	iy,0
        in	a,(io_keyboard)
        ld	c,a
        sub	a,0x80
        jr	c,isrKeyboard_1
        ld	a,0x83
        sub	a,c
        jr	c,isrKeyboard_1
        ld	iy,lastKeyIntVal
        ld	(iy+0),c
        jr	isrKeyboard_exit
isrKeyboard_1:
        ld	a,c
        sub	0x90
        jr	c,isrKeyboard_2
        ld	a,0x95
        sub	a,c
        jr	nc,isrKeyboard_exit
isrKeyboard_2:
        ld	a,(lastKeyIntVal+0)
        cp	0x80
        jr	z,isrKeyboard_3
        cp	0x81
        jr	z,isrKeyboard_4
        cp	0x82
        jr	z,isrKeyboard_5
        cp	0x83
        jr	z,isrKeyboard_6
        jr	isrKeyboard_7
isrKeyboard_3:
        ld	iy,lastKeyIntVal
        ld	(iy+0),0x00
        ld	hl,joy_status
        ld	(hl),c
        jr	isrKeyboard_exit
isrKeyboard_4:
        ld	iy,lastKeyIntVal
        ld	(iy+0),0x00
        ld	hl,joy_status+1
        ld	(hl),c
        jr	isrKeyboard_exit
isrKeyboard_5:
        ld	iy,lastKeyIntVal
        ld	(iy+0),0x00
        ld	hl,joy_status+2
        ld	(hl),c
        jr	isrKeyboard_exit
isrKeyboard_6:
        ld	iy,lastKeyIntVal
        ld	(iy+0),0x00
        ld	hl,joy_status+3
        ld	(hl),c
        jr	isrKeyboard_exit
isrKeyboard_7:					; not a joystick. Add key press to buffer
        ld	hl,kbd_buffer+0			; increment buffer write position.
        ld	de,(kbd_buffer_write_pos)
        ld	d,0
        add	hl,de
        ld	(hl),c
        ld	a,(kbd_buffer_write_pos)
        inc	a
        ld	(kbd_buffer_write_pos),a
isrKeyboard_exit:
        pop	iy
        pop	af
        pop	hl
        pop	de
        pop	bc
        ei
        reti

;===============================================================================
; Check if a key was pressed
; INPUT: void
; OUTPUT: A = 1 when a key is pressed, A = 0 when no key pressed.
; CLOBBERS: IY
;===============================================================================
isKeyPressed:
        ld	a,(kbd_buffer_write_pos)
        ld	iy,kbd_buffer_read_pos
        sub	a,(iy+0)
        jr	nz,isKeyPressed_1
        jr	isKeyPressed_2
isKeyPressed_1:				; a key was pressed - return 1 in A
        ld	a,1
        ret
isKeyPressed_2:				; no key was pressed - return 0 in A
        ld	a,0
        ret

;===============================================================================
; Blocking wait for keyboard character
; INPUT: void
; OUTPUT: Ascii value of key in A
; CLOBBERS: IY, BC
;===============================================================================
getChar:
        ld	a,(kbd_buffer_write_pos)
        ld	iy,kbd_buffer_read_pos
        sub	a,(iy+0)
        jr	z,getChar		; back to getChar
        ld	bc,kbd_buffer
        ld	hl,(kbd_buffer_read_pos)
        ld	h,0x00
        add	hl,bc
        ld	c,(hl)			; c contains ascii value
        ld	a,(kbd_buffer_read_pos)
        inc	a			; increment and store buffer read pos
        ld	(kbd_buffer_read_pos),a
        ld	a,c			; copy c to a
        ret

;===============================================================================
; Returns the Joystick Status that can be matched against the Joystick enums
; defined at the end of this file.
; INPUT: void
; OUTPUT: A = 1 when a key is pressed, A = 0 when no key pressed.
; CLOBBERS: IY
;===============================================================================
getJoyStatus:
        or      a
        jr      z,.getJoy0
        ld      a,(joy_status+1)
        and     0x1f
        ret
.getJoy0:
        ld      a,(joy_status+0)
        and     0x1f
        ret

;===============================================================================
; VARIABLES, ENUMS AND IO PORTS
;===============================================================================
lastKeyIntVal:	db 0

io_tmsdata:             equ 0xa0      ; NABU
io_tmslatch:            equ 0xa1      ; NABU
io_keyboard:            equ 0x90      ; NABU

joy_map_left:           equ %00000001
joy_map_down:           equ %00000010
joy_map_right:          equ %00000100
joy_map_up:             equ %00001000
joy_map_button:         equ %00010000
