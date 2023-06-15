;===============================================================================
; VARIABLES
;===============================================================================
origint:          db 0
last_key_int_val: db 0
tms_status_reg:   db 0
tms_is_ready:     db 0

;===============================================================================
; CONSTANTS
;===============================================================================
io_control:             equ 0x00

io_aydata:              equ 0x40
io_aylatch:             equ 0x41
io_tmsdata:             equ 0xa0
io_tmslatch:            equ 0xa1
io_keyboard:            equ 0x90

joy_map_left:           equ %00000001
joy_map_down:           equ %00000010
joy_map_right:          equ %00000100
joy_map_up:             equ %00001000
joy_map_button:         equ %00010000

CONTROL_ROMSEL:         equ 0x01
CONTROL_VDOBUF:         equ 0x02
CONTROL_STROBE:         equ 0x04
CONTROL_LED_CHECK:      equ 0x08
CONTROL_LED_ALERT:      equ 0x10
CONTROL_LED_PAUSE:      equ 0x20

IO_PORTA:               equ 0x0e
IO_PORTB:               equ 0x0f

INT_MASK_KEYBOARD:      equ 0x20
INT_MASK_VDP:           equ 0x10

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
        ld	iy,last_key_int_val
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
        ld	a,(last_key_int_val+0)
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
        ld	iy,last_key_int_val
        ld	(iy+0),0x00
        ld	hl,joy_status
        ld	(hl),c
        jr	isrKeyboard_exit
isrKeyboard_4:
        ld	iy,last_key_int_val
        ld	(iy+0),0x00
        ld	hl,joy_status+1
        ld	(hl),c
        jr	isrKeyboard_exit
isrKeyboard_5:
        ld	iy,last_key_int_val
        ld	(iy+0),0x00
        ld	hl,joy_status+2
        ld	(hl),c
        jr	isrKeyboard_exit
isrKeyboard_6:
        ld	iy,last_key_int_val
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
; Interrupt Service Routine for the VDP Vertical Sync interrupt.
; INPUT: void
; OUTPUT: void
; CLOBBERS: none
;===============================================================================
isrVdp:
        di
        push    af
        ld      a,1
        ld      (tms_is_ready),a
        in      a,(io_tmslatch)
        ld      (tms_status_reg),a
        pop     af
        ei
        ret

;===============================================================================
; Read a register from the AY-3-8910
; INPUT: A = Register to read
; OUTPUT: A = value
; CLOBBERS: AF
;===============================================================================
ay_read:
        out     (io_aylatch),a
        in      a,(io_aydata)
        ret

;===============================================================================
; Write a value to the AY-3-8910 register
; INPUT: B = Register to write to, C = value to write
; OUTPUT: void
; CLOBBERS: none
;===============================================================================
ay_write:
        ld      a,b
        out     (io_aylatch),a
        ld      a,c
        out     (io_aydata),a
        ret

;===============================================================================
; Setup the interrupts for the nabu
; INPUT: void
; OUTPUT: void
; CLOBBERS: hl
;===============================================================================
init_nabu:
        ;Turn off the rom
        ld      a,CONTROL_ROMSEL|CONTROL_VDOBUF
        out     (io_control),a
        di      ; disable interrupts

        im      2

        ld      hl, isrKeyboard
        ld      (0xff00+4), hl

        ld      hl, isrVdp
        ld      (0xff00+6), hl

        ld      b,0x07
        ld      c,01111111b
        call    ay_write        ; configure PORTA for writing and port B for reading

        ld      a,IO_PORTA
        call    ay_read         ; get the current interrupt mask from AY Port A
        or      INT_MASK_KEYBOARD|INT_MASK_VDP
        ld      c,a
        ld      b,IO_PORTA
        call    ay_write
        ei      ; enable interrupts
        ret

;===============================================================================
; Check if a key was pressed
; INPUT: void
; OUTPUT: A = 1 when a key is pressed, A = 0 when no key pressed.
; CLOBBERS: HL
;===============================================================================
is_key_pressed:
        ld	a,(kbd_buffer_write_pos)
        ld	hl,kbd_buffer_read_pos
        sub	a,(hl)
        jr	nz,is_key_pressed_1
        jr	is_key_pressed_2
is_key_pressed_1:				; a key was pressed - return 1 in A
        ld	a,1
        ret
is_key_pressed_2:				; no key was pressed - return 0 in A
        ld	a,0
        ret

;===============================================================================
; Blocking wait for keyboard character
; INPUT: void
; OUTPUT: Ascii value of key in A
; CLOBBERS: IY, BC
;===============================================================================
get_char:
        ld	a,(kbd_buffer_write_pos)
        ld	iy,kbd_buffer_read_pos
        sub	a,(iy+0)
        jr	z,get_char		; back to get_char
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
; defined at the beginning of this file.
; INPUT: void
; OUTPUT: A = 1 when a key is pressed, A = 0 when no key pressed.
; CLOBBERS: IY
;===============================================================================
get_joy_status:
        or      a
        jr      z,.get_joy0
        ld      a,(joy_status+1)
        and     0x1f
        ret
.get_joy0:
        ld      a,(joy_status+0)
        and     0x1f
        ret

;===============================================================================
; Wait for the VDP VSYNC status to appear on the status register
; INPUT: void
; OUTPUT: void
; CLOBBERS: AF
;===============================================================================
tms_wait:
        ld      a,(tms_is_ready)
        or      a
        jr      z,tms_wait
        xor     a
        ld      (tms_is_ready), a
        ret
