; ===== BEGIN: start.asm =====
bits 16
org 0x0000


section .data
    success_msg db "Kernel successfully loaded", 13, 10, 0

    number_to_string_f_buff db 0,0,0,0,0,0
    temp_color db 0
    draw_filled_rectangle_f_color db 0
    rectangle_x0: dw 0
    rectangle_y0: dw 0
    rectangle_x1: dw 0
    rectangle_y1: dw 0
    
    paddle_width dw 6
    paddle_height dw 80

    paddle_1_x dw 8
    paddle_1_y dw 200

    paddle_2_x dw 624
    paddle_2_y dw 200

    paddle_speed dw 10


section .text
    global _start


; ----------------------------------
; |     SUBROUTINE: START          |
; ----------------------------------
_start:
    ; stack initialization
    cli
    mov ax, 0x9000      ; Load the desired stack segment value into AX
    mov ss, ax          ; Set the Stack Segment (SS)
    mov sp, 0xFFFF      ; Set the Stack Pointer (SP) to the top of the segment
    sti

    ; section .data pointer initialization
    mov ax, cs
    mov ds, ax

    ; clear screen
    call clear_screen

    ; entering vga video mode 640x480 px
    mov ax, 0x12
    int 0x10



    mov al, 0x0F               ; White color
    mov bl, 1                   ; Paddle 1
    call draw_paddle
    mov bl, 2                   ; Paddle 2
    call draw_paddle

    ; mov si, success_msg
    ; call print_string_graphics

    game_loop:
        ; call wait_vsync

        call read_keyboard
        
        jmp game_loop

    hlt


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


; -------------------------------------
; |     SUBROUTINE: KEYBOARD         |
; -------------------------------------
; Inputs: none
; Output: al - scan code of the pressed key
read_keyboard:
    call read_character_non_blocking
    cmp al, 119
    je .w_pressed
    cmp al, 115
    je .s_pressed
    cmp al, 48h
    je .uparrow_pressed
    cmp al, 50h
    je .downarrow_pressed

    jmp .done

    .w_pressed:
        call move_paddle_1_up
        jmp .done
    .s_pressed:
        call move_paddle_1_down
        jmp .done
    .uparrow_pressed
        call move_paddle_2_up
        jmp .done
    .downarrow_pressed
        call move_paddle_2_down
        jmp .done

    .done:
        ret
; -----------------------------------
; |      SUBROUTINE: PADDLES        |
; -----------------------------------
; Inputs: al - color, bl - paddle number (1 or 2)
; Used registers: ax, bx, cx, dx, si, di
draw_paddle:
    ; Determine which paddle to draw
    cmp bl, 1
    je .draw_paddle_1
    cmp bl, 2
    je .draw_paddle_2
    ret                     ; Invalid paddle number, exit

    .draw_paddle_1:
        ; Load paddle 1 position
        mov bx, [paddle_1_x]       ; x0
        mov cx, [paddle_1_x]
        add cx, [paddle_width]      ; x1
        mov dx, [paddle_1_y]       ; y0
        mov si, [paddle_1_y]
        add si, [paddle_height]     ; y1

        call draw_filled_rectangle
        ret
    .draw_paddle_2:
        mov bx, [paddle_2_x]       ; x0
        mov cx, [paddle_2_x]
        add cx, [paddle_width]      ; x1
        mov dx, [paddle_2_y]       ; y0
        mov si, [paddle_2_y]
        add si, [paddle_height]     ; y1

        call draw_filled_rectangle
        ret

; ------------------------------
; |     SUBROUTINE: PADDLES    |
; ------------------------------
; Inputs: None
; Used registers: ax, bx, cx, dx, si, di
move_paddle_1_up:
    mov ax, [paddle_1_y]

    .check_bounds:
        cmp ax, [paddle_speed] 
        jb .done
    

    mov bx, [paddle_1_x]
    mov dx, [paddle_1_y]

    call update_position_up

    mov ax, [paddle_1_y]
    sub ax, [paddle_speed]

    mov [paddle_1_y], ax

    .done:
        ret

; ------------------------------
; |     SUBROUTINE: PADDLES    |
; ------------------------------
; Inputs: None
; Used registers: ax, bx, cx, dx, si, di
move_paddle_1_down:
    mov ax, [paddle_1_y]
    add ax, [paddle_speed]

    .check_bounds_down:
        mov cx, 480
        add ax, [paddle_height]
        cmp ax, cx
        jg .done
    
    mov bx, [paddle_1_x]
    mov dx, [paddle_1_y]
    call update_position_down
    mov ax, [paddle_1_y]
    add ax, [paddle_speed]
    mov [paddle_1_y], ax
    .done:
        ret
    
; ------------------------------
; |     SUBROUTINE: PADDLES    |
; ------------------------------
; Inputs: None
; Used registers: ax, bx, cx, dx, si, di
move_paddle_2_up:
    mov ax, [paddle_2_y]

    .check_bounds:
        cmp ax, [paddle_speed] 
        jb .done
    

    mov bx, [paddle_2_x]
    mov dx, [paddle_2_y]

    call update_position_up

    mov ax, [paddle_2_y]
    sub ax, [paddle_speed]

    mov [paddle_2_y], ax

    .done:
        ret

; ------------------------------
; |     SUBROUTINE: PADDLES    |
; ------------------------------
; Inputs: None
; Used registers: ax, bx, cx, dx, si, di
move_paddle_2_down:
    mov ax, [paddle_2_y]
    add ax, [paddle_speed]

    .check_bounds_down:
        mov cx, 480
        add ax, [paddle_height]
        cmp ax, cx
        jg .done
    
    mov bx, [paddle_2_x]
    mov dx, [paddle_2_y]
    call update_position_down
    mov ax, [paddle_2_y]
    add ax, [paddle_speed]
    mov [paddle_2_y], ax
    .done:
        ret
; ------------------------------
; |     SUBROUTINE: PADDLES    |
; ------------------------------
; Inputs: bx - X position, dx - old Y position  
; Used registers: ax, bx, cx, dx, si, di
update_position_up:
    mov al, 0x0F       ; color white
    mov cx, bx
    add cx, [paddle_width]     ; x1
    mov si, dx                 ; y1
    sub dx, [paddle_speed]     ; y0

    push bx
    push dx
    call draw_filled_rectangle;
    pop dx
    pop bx

    mov al, 0x00        ; color black
    mov cx, bx
    add cx, [paddle_width]      ; x1
    add dx, [paddle_height]     ; y1
    mov si, dx
    add si, [paddle_speed]
    call draw_filled_rectangle;

    ret

; ; ------------------------------
; |     SUBROUTINE: PADDLES    |
; ------------------------------
; Inputs: bx - X position, dx - old Y position
; Used registers: ax, bx, cx, dx, si, di
update_position_down:
    mov al, 0x00       ; color black
    mov cx, bx
    add cx, [paddle_width]     ; x1
    mov si, dx                 ; y1
    add si, [paddle_speed]     ; y0

    push bx
    push dx
    call draw_filled_rectangle;
    pop dx
    pop bx

    mov al, 0x0F        ; color white
    mov cx, bx
    add cx, [paddle_width]      ; x1
    add dx, [paddle_height]     ; y0
    mov si, dx
    add si, [paddle_speed]     ; y1
    call draw_filled_rectangle;

    ret
; --------------------    SCREEN    --------------------

; -----------------------------------
; |     SUBROUTINE: SCREEN          |
; -----------------------------------
; Inputs: none
; Used registers: ax, bx, dx
clear_screen:
    mov ah, 0x00
    mov al, 0x03
    int 0x10
    ret


; -----------------------------------
; |     SUBROUTINE: SCREEN          |
; -----------------------------------
; Inputs: si - string pointer
; Used registers: ax, bx, dx, si
print_string_graphics:
    mov ah, 0x02    ; set cursor position
    mov bh, 0x00    ; page 0
    mov dh, 1       ; row (adjust as needed)
    mov dl, 3       ; column (adjust as needed)
    int 0x10

    ; Print the string using BIOS teletype function
    mov ah, 0x0E    ; BIOS teletype output
    mov bh, 0       ; page 0
    mov bl, 0x0F    ; white color on black background

    .next_char:
        mov al, [si]
        cmp al, 0
        je .done
        int 0x10
        inc si
        jmp .next_char

    .done:
        ret


; -----------------------------
; |     SUBROUTINE: SCREEN    |
; -----------------------------
print_string:
    .next_char:
        mov al, [si]
        cmp al, 0
        je .done
        mov ah, 0x0E  ; BIOS interrupt teletype output
        mov bh, 0x00  ; page number (usually 0)
        mov bl, 0x00  ; BL = foreground color (optional, often ignored by QEMU's simple VGA)
        int 0x10 ; Call the BIOS video interrupt
        inc si
        jmp .next_char

        .done:
        ret


; -----------------------------------
; |     SUBROUTINE: SCREEN          |
; -----------------------------------
; Inputs: ax - number to convert
; Outputs: si - pointer to the string
; Used registers: ax, cx, dx, di
number_to_string:
    mov si, 10
    mov cx, 1           ; degree counter

    .calculate_next_digit:
        xor dx, dx      ; remainder register
        div si          ; ax / si = ax (remainder: dx in range [0;9])

        add dl, 48
        mov di, number_to_string_f_buff + 5
        sub di, cx
        mov [di], dl

        inc cx

        test ax, ax     ; check ax == 0
        jne .calculate_next_digit

    .find_number_start:
        mov di, number_to_string_f_buff

        .loop:
            cmp byte [di], 0
            jne .done

            inc di
            jmp .loop

    .done:
        mov si, di
        ret


; -----------------------------
; |     SUBROUTINE: SCREEN    |
; -----------------------------
; Plot pixel  (mode 0x12: VGA 640 x 480)
; Inputs: cx = x, dx = y, al = color
; Used registers: ax, bx
plot_pixel:
    mov ah, 0Ch
    mov bh, 0    ; prints on the visible page
    int 10h
    ret


; -----------------------------
; |     SUBROUTINE: SCREEN    |
; -----------------------------
; Inputs: bx = x0, cx = x1, dx = y0, si = y1,
; Used registers: ax, bx, cx, dx, si, di

draw_filled_rectangle:
    ; Save ALL parameters to memory
    mov [draw_filled_rectangle_f_color], al
    mov [rectangle_x0], bx
    mov [rectangle_x1], cx
    mov [rectangle_y0], dx
    mov [rectangle_y1], si

    ; Validate bounds
    cmp cx, bx      ; if x1 < x0, exit
    jb .done
    cmp si, dx      ; if y1 < y0, exit
    jb .done

    mov ah, 0x0C    ; BIOS write pixel function
    mov bh, 0       ; Page 0

    mov di, [rectangle_y0]  ; DI = current y (start at y0)

    .y_loop:
        mov cx, [rectangle_x0]  ; CX = current x (RELOAD from memory each row!)

    .x_loop:
        mov al, [draw_filled_rectangle_f_color]
        mov dx, di      ; DX = current y
        ; CX already has current x
        int 0x10

        inc cx
        cmp cx, [rectangle_x1]
        jbe .x_loop     ; unsigned comparison

        inc di
        cmp di, [rectangle_y1]
        jbe .y_loop     ; unsigned comparison

    .done:
        ret

; --------------------    SCREEN    --------------------

; -----------------------------------
; |     SUBROUTINE: SCREEN          |
; -----------------------------------
; Inputs: none
; Used registers: ax, dx
; Wait for vertical retrace to prevent flickering
; Reads VGA status register (port 0x3DA) and waits for vertical blanking period
wait_vsync:
    mov dx, 0x3DA
    ; First, wait until we're NOT in vertical retrace (bit 3 = 0)
    .wait_not_vretrace:
        in al, dx
        test al, 8           ; Test bit 3 (vertical retrace bit)
        jnz .wait_not_vretrace
    ; Then wait until we ARE in vertical retrace (bit 3 = 1)
    .wait_vretrace:
        in al, dx
        test al, 8
        jz .wait_vretrace
    ret
; --------------------    SYSTEM    --------------------
; -----------------------------------
; |     SUBROUTINE: SYSTEM          |
; -----------------------------------
; Inputs: none
; Used registers: ax, bx, cx
shutdown:
    .do_shutdown:
        ; 1) Connect to APM BIOS
        mov ax, 0x5301
        xor bx, bx
        int 0x15
        jc .apm_fail

        ; 2) Enable power management
        mov ax, 0x5308
        mov bx, 1
        mov cx, 1
        int 0x15
        jc .apm_fail

        ; 3) Turn off the machine
        mov ax, 0x5307
        mov bx, 1        ; all devices
        mov cx, 3        ; power-off
        int 0x15
        jc .apm_fail

    .apm_fail:
        cli
        hlt
        jmp $
