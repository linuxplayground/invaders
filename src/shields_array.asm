sheilds_array:
        db      0x01,0x02,0x03
        db      0x00,0x00,0x00
        db      0x01,0x02,0x03
        db      0x00,0x00,0x00
        db      0x01,0x02,0x03
        db      0x00,0x00,0x00
        db      0x01,0x02,0x03
        db      0x00,0x00,0x00
        
        db      0x00,0x00,0x00,0x00
        db      0x00,0x00,0x00,0x00

        db      0x04,0x05,0x06
        db      0x00,0x00,0x00
        db      0x04,0x05,0x06
        db      0x00,0x00,0x00
        db      0x04,0x05,0x06
        db      0x00,0x00,0x00
        db      0x04,0x05,0x06
shields_array_len:      equ $-sheilds_array