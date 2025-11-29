; -----------------------------------
; |     SUBROUTINE: RANDOM BYTE     |
; -----------------------------------
; Output: al = random byte
read_random_byte:
    in al, 0x40         ; PIT counter channel 0 (fast changing)
    ret