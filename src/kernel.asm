bits 16
org 0x0000


section .data
    success_msg db "Kernel successfully loaded", 13, 10, 0

    number_to_string_f_buff db 0,0,0,0,0,0
    draw_filled_rectangle_f_color db 0
    rectangle_x0: dw 0
    rectangle_y0: dw 0
    rectangle_x1: dw 0
    rectangle_y1: dw 0

    player_x: dw 14
    player_y: dw 50

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

    ; Example 1: Draw a green rectangle


    ; debug message
    mov si, success_msg
    call print_string_graphics

; -----------------------------------
; |     SUBROUTINE: DEMO_LOOP       |
; -----------------------------------
; Inputs: none
; Used registers: all

.demo_loop:
    .loop:
        ; ----- Draw player normally -----
        mov al, 2               ; green color
        mov bx, [player_x]      ; x0 (left)
        mov cx, bx
        add cx, 20              ; x1 = x0 + width
        mov dx, [player_y]      ; y0 (top)
        mov si, dx
        add si, 20              ; y1 = y0 + height
        call draw_filled_rectangle

        ; ----- Read keyboard -----
        call read_character_non_blocking
        cmp al, 97              ; 'a' - move left
        je .a_pressed
        cmp al, 100             ; 'd' - move right
        je .d_pressed

        jmp .infinite_loop

    ; ===========================
    ;   A KEY PRESSED (MOVE RIGHT)
    ; ===========================
    .a_pressed:
        ; 1) ERASE OLD RECTANGLE (black)
        mov al, 0               ; black color
        mov bx, [player_x]      ; Load current x
        mov cx, bx
        add cx, 20              ; Calculate x1
        mov dx, [player_y]      ; Load current y
        mov si, dx
        add si, 20              ; Calculate y1
        call draw_filled_rectangle

        ; 2) UPDATE POSITION (move right)
        mov bx, [player_x]
        inc bx                  ; Move right by 1 pixel
        mov [player_x], bx

        ; 3) DRAW NEW RECTANGLE (green)
        mov al, 2               ; green
        mov bx, [player_x]      ; Load NEW x
        mov cx, bx
        add cx, 20              ; Calculate x1
        mov dx, [player_y]      ; Load y
        mov si, dx
        add si, 20              ; Calculate y1
        call draw_filled_rectangle

        jmp .infinite_loop

    ; ===========================
    ;   D KEY PRESSED (MOVE LEFT)
    ; ===========================
    .d_pressed:
        ; 1) ERASE OLD RECTANGLE (black)
        mov al, 0               ; black color
        mov bx, [player_x]      ; Load current x
        mov cx, bx
        add cx, 20              ; Calculate x1
        mov dx, [player_y]      ; Load current y
        mov si, dx
        add si, 20              ; Calculate y1
        call draw_filled_rectangle

        ; 2) UPDATE POSITION (move left)
        mov bx, [player_x]
        dec bx                  ; Move left by 1 pixel
        mov [player_x], bx

        ; 3) DRAW NEW RECTANGLE (green)
        mov al, 2               ; green
        mov bx, [player_x]      ; Load NEW x
        mov cx, bx
        add cx, 20              ; Calculate x1
        mov dx, [player_y]      ; Load y
        mov si, dx
        add si, 20              ; Calculate y1
        call draw_filled_rectangle

        jmp .infinite_loop

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

    ; Ensure cursor at row 0, col 0 (BIOS int 0x10 AH=0x02)
    mov ah, 0x02
    mov bh, 0x00    ; page
    mov dh, 0x00    ; row
    mov dl, 0x00    ; column
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
    mov ah, 0x01
    int 0x16
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