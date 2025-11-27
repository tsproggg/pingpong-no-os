; --------------------    KEYBOARD    --------------------

; -----------------------------------
; |     SUBROUTINE: KEYBOARD        |
; -----------------------------------
; Inputs: bl - key to check
;         si - message to print on key press
; Used registers: ax,bx,si
print_on_key_press:
    call read_character_non_blocking

    cmp al, bl
    jne .nothing_pressed
    call print_string

    .nothing_pressed:
        ret

; -----------------------------------
; |     SUBROUTINE: KEYBOARD        |
; -----------------------------------
; Inputs: none
; Outputs: al - ASCII symbol code
; Used registers: ax
read_character_non_blocking:
    call read_key_status
    jz .nothing_pressed
    call read_character_blocking

    .nothing_pressed:
       ret


; -----------------------------------
; |     SUBROUTINE: KEYBOARD        |
; -----------------------------------
; Inputs: none
; Outputs: al - ASCII symbol code
; Used registers: ax
read_character_blocking:
    mov ah, 0x00
    int 0x16
    ret


; -----------------------------------
; |     SUBROUTINE: KEYBOARD        |
; -----------------------------------
; Inputs: none
; Output: ZF - zero flag (0 = keystroke available, 1 = buffer is empty)
; Used registers: ax
read_key_status:
    mov ah, 0x01
    int 0x16
    ret

