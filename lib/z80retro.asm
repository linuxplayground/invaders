;===============================================================================
; Check if a key was pressed
; INPUT: void
; OUTPUT: A = 1 when a key is pressed, A = 0 when no key pressed.
; CLOBBERS: IY
;===============================================================================
isKeyPressed:
        in      a,(0x32)        ; read sio control status byte
        and     1               ; check the rcvr ready bit
        ret

;===============================================================================
; Gets latest character entered.  DOES NOT BLOCK ON RETRO
; INPUT: void
; OUTPUT: Ascii value of key in A
; CLOBBERS: IY, BC
;===============================================================================
getChar:
        in    a,(0x30)          ; read sio control data byte
        ret

;===============================================================================
; Returns the Joystick Status that can be matched against the Joystick enums
; defined at the end of this file.
; INPUT: void
; OUTPUT: A = 1 when a key is pressed, A = 0 when no key pressed.
; CLOBBERS: none
;===============================================================================
getJoyStatus:
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
        ; in      a,(io_tmslatch)
        ; rlca
        ; jr      nc,tms_wait
        in      a,(joy0)        ; read the /INT status via bodge wire 
        and     0x02            ; check U6, pin 4 (D1)
        jp      nz,tms_wait
        in      a,(io_tmslatch) ; read the VDP status register to reset the IRQ
        ret

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
