        include 'tms_constants.asm'

;===============================================================================
; Initialize the VDP in Graphics Mode 1 hybrid mode.
; refer to .tms_init_g1_registers at the end of this file for details.
; Disable all sprites by setting byte 0 in each sprite attribute table to 0xD0
; INPUT: void
; OUTPUT: void
; CLOBBERS: none
;===============================================================================
tms_init_g1:
        ld      hl,.tms_init_g1_registers
        ld      b,.tms_init_g1_registers_length
        ld      c,io_tmslatch
        otir
        ; clear sprite attribute table and set Y position to D0
        ld      b,32
        ld      de,tms_spriteAttributeTable
        call    tms_set_write_address
.clear_sprites_loop:
        ld      a,0xd0
        call    tms_put
        xor     a
        call    tms_put
        call    tms_put
        call    tms_put
        djnz    .clear_sprites_loop
        ret

;===============================================================================
; Set one of the VDP registers
; INPUT: B = Register to set, C = value to set
; OUTPUT: void
; CLOBBERS: none
;===============================================================================
tms_set_register:
        ld      a,c
        out     (io_tmslatch),a
        ld      a,b
        or      0x80
        out     (io_tmslatch),a
        ret

;===============================================================================
; Write one byte of data to the VDP at the current address.
; includes a delay
; OUTPUT: void
; CLOBBERS: none
;===============================================================================
tms_put:
        out     (io_tmsdata),a
        push    hl
        pop     hl
        push    hl
        pop     hl
        ret

;===============================================================================
; Set the backdrop colour.
; INPUT: C = Colour to set [0-15]
; OUTPUT: void
; CLOBBERS: DE
;===============================================================================
tms_set_backdrop_color:
        ld      b,0x07
        call    tms_set_register
        ret

;===============================================================================
; Set the VDP Address to write to.
; INPUT: de = write address
; OUTPUT: void
; CLOBBERS: none
;===============================================================================
tms_set_write_address:
        di
        ld      a,e
        out     (io_tmslatch),a
        ld      a,d
        or      0x40
        out     (io_tmslatch),a
        ei
        ret

;===============================================================================
; Set the VDP Address to read from.
; INPUT: de = read address
; OUTPUT: void
; CLOBBERS: none
;===============================================================================
tms_set_read_address:
        di
        ld      a,e
        out     (io_tmslatch),a
        ld      a,d
        out     (io_tmslatch),a
        ei
        ret

;===============================================================================
; Copy system memory to VDP memory after vblank signal only.
; INPUT: DE = VDP target memory address, HL = host memory address, BC = count
; OUTPUT: void
; CLOBBERS: AF, BC, DE, HL
;===============================================================================
tms_write_fast:
        call    tms_set_write_address
        ld      d,b
        ld      e,c
        ld      c,io_tmsdata
; goldilocks
        ld      b,e
        inc     e
        dec     e
        jr      z,tms_write_fast_loop
        inc     d
tms_write_fast_loop:
        outi
        jp      nz,tms_write_fast_loop
        dec     d
        jp      nz,tms_write_fast_loop
        ret

;===============================================================================
; Copy system memory to VDP memory at any time.
; INPUT: DE = VDP target memory address, HL = host memory address, BC = count
; OUTPUT: void
; CLOBBERS: AF, BC, DE, HL
;===============================================================================
tms_write_slow:
        call    tms_set_write_address

        ld      d,b
        ld      e,c
        ld      c,io_tmsdata
.tms_write_slow_loop:
        outi
        push    hl
        pop     hl
        push    hl
        pop     hl
        dec     de
        ld      a,d
        or      e
        jr      nz,.tms_write_slow_loop
        ret

;===============================================================================
; Set the whole colour table to a single colour.
; INPUT: C = Colour to set [0-15]
; OUTPUT: void
; CLOBBERS: HL, DE
;===============================================================================
tms_set_all_colors:
        ld      de,tms_colorTable
        call    tms_set_write_address

        ld      l,c
        ld      de,tms_colorTableLen
        jp      tms_set_vram_loop_start

;===============================================================================
; Initialize all VDP RAM to 0
; INPUT: void
; OUTPUT: void
; CLOBBERS: DE, HL
;===============================================================================
tms_clear_vram:
        ld      de,0x00
        call    tms_set_write_address

        ld      de,0x3FFF
        ld      l,0x00

        ; pass through

;===============================================================================
; Write value in L to VDP for DE count times.
; ASSUMES THAT VDP WRITE ADDRESS has already been configured with a call to
; tms_set_write_address.
; INPUT: L = value to write, DE = Number of times to write.
; OUTPUT: void
; CLOBBERS: AF, BC, DE, HL
;===============================================================================
tms_set_vram_loop_start:
        ld      b,e
        dec     de
        inc     d
        ld      a,l
tms_set_vram_loop:
        out     (io_tmsdata),a
        push    hl
        pop     hl
        push    hl
        pop     hl
        push    hl
        pop     hl
        djnz    tms_set_vram_loop
        dec     d
        jp      nz,tms_set_vram_loop
        ret

;===============================================================================
; Load pattern table.
; INPUT: HL = Address of first byte of pattern data, BC = Number of bytes in 
; pattern table.
; OUTPUT: void
; CLOBBERS: AF, DE
;===============================================================================
tms_load_pattern_table:
        ld      de,tms_patternTable
        call    tms_write_slow
        ret

;===============================================================================
; Load sprite pattern table.
; INPUT: HL = Address of first byte of pattern data, BC = Number of bytes in 
; pattern table.
; OUTPUT: void
; CLOBBERS: AF, DE
;===============================================================================
tms_load_sprite_pattern_table:
        ld      de,tms_spritePatternTable
        call    tms_write_slow
        ret

;===============================================================================
; Writes all Zeros to VDP nameTable
; INPUT: L = value to write, DE = Number of times to write.
; OUTPUT: void
; CLOBBERS: AF, BC, DE, HL
; BUGGY - NEEDS INVESTIGATION.  USE tms_clear_buffer INSTEAD
;===============================================================================
; tms_clear_screen:
;         ld      hl,tms_nameTable
;         call    tms_set_write_address

;         ld      de,tms_nameTableLen
;         ld      l,0x00
;         jp      tms_set_vram_loop_start

;===============================================================================
; Writes all Zeros to tms_buffer
; INPUT: void
; OUTPUT: void
; CLOBBERS: AF, BC, DE, HL
;===============================================================================
tms_clear_buffer:
        ld      b,0x00
        ld      c,0x03
        ld      hl,tms_buffer
.tms_clear_buffer_loop:
        ld      a,0x00
        ld      (hl),a
        inc     hl
        djnz    .tms_clear_buffer_loop
        dec     c
        or      c
        jr      nz,.tms_clear_buffer_loop
        ret

;===============================================================================
; Flush the tms_buffer in system memory to the VDP nameTable after the vsync
; status is set on the status register.
; INPUT: void
; OUTPUT: void
; CLOBBERS: AF, BC, DE, HL
;===============================================================================
tms_flush_buffer:
        ld      de,tms_nameTable
        ld      hl,tms_buffer
        ld      bc,0x300
        call    tms_wait
        jp      tms_write_fast

;===============================================================================
; Write a characater to the tms_buffer
; INPUT: D = x, E = Y, A = char
; CLOBBERS: AF
;===============================================================================
set_char_at_loc_buf:
        push    bc
        push    de
        push    hl
        ld      c,a             ; save char to write
        ld      l,e             ; y in l
        ld      h,0
        mul32                   ; y x 32
        ld      a,d             ; x in a
        addhla                  ; add x to hl
        ld      de,tms_buffer   ; start of buffer into de
        add     hl,de           ; add buffer start to hl
        ld      a,c             ; restore char to write
        ld      (hl),a
        pop     hl
        pop     de
        pop     bc
        ret

;===============================================================================
; Get the character in the frame buffer at buffer x,y
; INPUT: D = x, E = Y, A = char
; OUPTUT: A = char
; CLOBBERS: BC, DE, HL
;===============================================================================
get_char_at_loc_buf:
        ld      l,e             ; y in l
        ld      h,0
        mul32                   ; y x 32
        ld      a,d             ; x in a
        addhla                  ; add x to hl
        ld      de,tms_buffer   ; start of buffer into de
        add     hl,de           ; add buffer start to hl
        ld      a,(hl)
        ret

;===============================================================================
; Print zero terminated string at location into buffer.
; INPUT: D = x, E = Y, HL = ptr to string
; OUPTUT: void
; CLOBBERS: AF, BC, DE, HL
;===============================================================================
print_at_loc_buf:
        push    bc
        push    de
        push    hl
        ; calculate vram from x,y
        ld      l,e             ; y in l
        ld      h,0
        mul32                   ; y x 32
        ld      a,d             ; x in a
        addhla                  ; add x to hl
        ld      de,tms_buffer
        add     hl,de
        ex      de,hl           ; de points to vram address.
        pop     hl
.print_at_loc_buf_loop:         ; iterate through stirng until \0
        ld      a,(hl)
        or      a
        jr      z,.print_at_loc_buf_exit
        ld      (de),a
        inc     hl
        inc     de
        jp      .print_at_loc_buf_loop
.print_at_loc_buf_exit:
        pop     de
        pop     bc
        ret

;===============================================================================
; Prints string pointed by HL to ROW (C) in the center of the line.
; INPUT: HL Pointer to zero terminated string
;         C Row number to write to.
; OUTPUT: A=0 when no erros, A != 0 when erros.
; CLOBBERS: ???         
;===============================================================================
center_text_in_buf_row:
        push    hl
        push    bc
        call    str_len
        ld      a,c     ;  has length of string
        cp      31
        jp      nc,.center_text_maxlen_error
        div2            ; divide length of string by 2
        ld      c,a
        ld      a,16
        sub     c
        ; now print
        ld      d,a
        pop     bc
        ld      e,c
        pop     hl
        jp      print_at_loc_buf

.center_text_maxlen_error:
        ld      a,1
        ret

;===============================================================================
; Graphics Mode I Registers
;===============================================================================
.tms_init_g1_registers:
        db      0x00,0x80       ; Graphics mode 1, no external video
        db      0xe2,0x81       ; 16K,enable display, enable int, 16x16 sprites
        db      0x05,0x82       ; R2 = name table = 0x1400
        db      0x80,0x83       ; R3 = color table = 0x2000
        db      0x01,0x84       ; R4 = pattern table = 0x0800
        db      0x20,0x85       ; R5 = sprite attribute table = 0x1000
        db      0x00,0x86       ; R6 = sprite pattern table = 0x0000
        db      0xf1,0x87       ; R7 = fg=white, bg=black
.tms_init_g1_registers_length: equ $-.tms_init_g1_registers

;===============================================================================
; Frame buffer memory
;===============================================================================1
        ds	0x300-(($+0x300)&0x2ff) ; pad out to align tms_buffer on a page
                                        ; boundary.
; Frame buffer for graphics mode 2
tms_buffer:     ds 0x300, 0

pattern_test_bit_mask:        
        db %10000000
        db %01000000
        db %00100000
        db %00010000
        db %00001000
        db %00000100
        db %00000010
        db %00000001

pattern_clear_bit_mask:      
        db %01111111
        db %10111111
        db %11011111
        db %11101111
        db %11110111
        db %11111011
        db %11111101
        db %11111110