;===============================================================================
; VARIABLES, ENUMS AND IO PORTS
;===============================================================================
io_tmsdata:             equ 0x80
io_tmslatch:            equ 0x81
joy0:                   equ 0xa8
joy1:                   equ 0xa9

joy_map_left:           equ %00000100
joy_map_right:          equ %00100000
joy_map_up:             equ %10000000
joy_map_down:           equ %01000000
joy_map_button:         equ %00000001

;===============================================================================
; Check if a key was pressed
; INPUT: void
; OUTPUT: A = 1 when a key is pressed, A = 0 when no key pressed.
; CLOBBERS: IY
;===============================================================================
is_key_pressed:
        in      a,(0x32)        ; read sio control status byte
        and     1               ; check the rcvr ready bit
        ret

;===============================================================================
; Gets latest character entered.  DOES NOT BLOCK ON RETRO
; INPUT: void
; OUTPUT: Ascii value of key in A
; CLOBBERS: IY, BC
;===============================================================================
get_char:
        in    a,(0x30)          ; read sio control data byte
        ret

;===============================================================================
; Returns the Joystick Status that can be matched against the Joystick enums
; defined at the beginning of this file.
; INPUT: A 0 = joy0, !0 = joy1
; OUTPUT: joy_status
; CLOBBERS: none
;===============================================================================
get_joy_status:
        or      a
        jr      z,.getJoy0
.getJoy1:
        in      a,(joy1)
        xor     0xff
        ld      (joy_status+1),a
        ret
.getJoy0:
        in      a,(joy0)
        xor     0xff
        ld      (joy_status+0),a
        ret

;===============================================================================
; Wait for the VDP VSYNC status to appear on the status register
; INPUT: void
; OUTPUT: void
; CLOBBERS: AF
;===============================================================================
tms_wait:
        in      a,(joy0)        ; read the /INT status via bodge wire 
        and     0x02            ; check U6, pin 4 (D1)
        jp      nz,tms_wait
        in      a,(io_tmslatch) ; read the VDP status register to reset the IRQ
        ret

;===============================================================================
; Stub functions that can't be done on the retro
;===============================================================================
init:
        ret
ay_read:
        ret
ay_write:
        ret
ay_all_off:
        ret
ay_set_mixer:
        ret
ay_set_tone_volume:
        ret
ay_set_noise_volume:
        ret
