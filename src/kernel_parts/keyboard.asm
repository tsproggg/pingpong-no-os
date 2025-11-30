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
    call print_string_graphics

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
    mov ah, 0x11
    int 0x16
    ret


; -------------------------------------
; |     SUBROUTINE: KEYBOARD         |
; -------------------------------------
; Inputs: none
; Output: ax - scan code of the pressed key
; read_keyboard:
;     xor ax, ax
;     call read_character_non_blocking
;     cmp al, 119
;     je .w_pressed
;     cmp al, 115
;     je .s_pressed
;     cmp al, 0 ; check for extended key
;     jne .done
;     cmp ah, 0x48
;     je .uparrow_pressed
;     cmp ah, 0x50
;     je .downarrow_pressed

;     jmp .done

;     .w_pressed:
;         call move_paddle_1_up
;         jmp .done
;     .s_pressed:
;         call move_paddle_1_down
;         jmp .done
;     .uparrow_pressed:
;         call move_paddle_2_up
;         jmp .done
;     .downarrow_pressed:
;         call move_paddle_2_down
;         jmp .done

;     .done:
;         ret

read_keyboard:
    cmp al, 0x11  ; 'W' key make code
    je .w_pressed

    cmp al, 0x91  ; 'W' key break code
    je .w_released

    cmp al, 0x1F  ; 'S' key make code
    je .s_pressed

    cmp al, 0x9F  ; 'S' key break code
    je .s_released

    cmp al, 0x48  ; Up Arrow make code
    je .uparrow_pressed

    cmp al, 0xC8  ; Up Arrow break code
    je .uparrow_released

    cmp al, 0x50  ; Down Arrow make code
    je .downarrow_pressed

    cmp al, 0xD0  ; Down Arrow break code
    je .downarrow_released

    jmp .done

    .w_pressed:
        mov byte [key_w_pressed], 1
        jmp .done
    .w_released:
        mov byte [key_w_pressed], 0
        jmp .done
    .s_pressed:
        mov byte [key_s_pressed], 1
        jmp .done
    .s_released:
        mov byte [key_s_pressed], 0
        jmp .done
    .uparrow_pressed:
        mov byte [key_uparrow_pressed], 1
        jmp .done
    .uparrow_released:
        mov byte [key_uparrow_pressed], 0
        jmp .done
    .downarrow_pressed:
        mov byte [key_downarrow_pressed], 1
        jmp .done
    .downarrow_released:
        mov byte [key_downarrow_pressed], 0
        jmp .done

    .done:
        ret
