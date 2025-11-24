bits 16
org 0x0000


section .data
    success_msg db "Kernel successfully loaded", 13, 10, 0
    ; key_msg db "Amongus" ; debug message for keyboard input

    number_to_string_f_buff db 0,0,0,0,0,0


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

    mov ax, 0x12
    int 0x10

    ; Example 1: Draw a green rectangle
    mov al, 2               ; green color
    mov bx, 14              ; x0 (left)
    mov cx, 100             ; x1 (right)
    mov dx, 50              ; y0 (top) - FIXED: top < bottom
    mov si, 250             ; y1 (bottom)
    call draw_filled_rectangle

    ; clear screen
    ;call clear_screen

    ; Go to video mode to see rectangle
    mov ah, 0x00
    int 0x16

    ; Now switch back to text mode for the message
    mov ax, 0x03
    int 0x10

    ; debug message
    mov si, success_msg
    call print_string
    ;call shutdown

    ; [DEBUG] for testing keyboard input
    ; .looping:    
    ;     mov bl, ' '
    ;     call keyboard_event
    ;     jmp .looping

    hlt

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
; Used registers: ax, bx
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


; --------------------    SYSTEM    --------------------

; -----------------------------------
; |     SUBROUTINE: SYSTEM          |
; -----------------------------------
; Inputs: bl - key to check
; Used registers: ax,si
keyboard_event:
    .check_keypress:
        call .read_key_status
        jz .nothing_pressed
        call .read_character

        cmp al, bl
        jne .nothing_pressed
        ; mov si, key_msg    ; Do Some action when key is pressed
        ; call print_string

    .nothing_pressed:
        ret

    .read_character:
        mov ah, 0x00
        int 0x16
        ret

    .read_key_status:
        mov ah, 0x01
        int 0x16
        ret

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



; -------------------------------------------------------------
; |     SUBROUTINE: PLOT PIXEL  (mode 0x12: VGA 640 x 480)    |
; -------------------------------------------------------------
; Inputs: cx = x, dx = y, al = color
; Used registers: ax, bx, cx

plot_pixel:
    mov ah, 0Ch
    mov bh, 0    ; prints on the visible page
    int 10h
    ret



; --------------------------------------------
; |     SUBROUTINE: DRAW FILLED RECTANGLE    |
; --------------------------------------------
; Inputs: bx = x0, cx = x1, dx = y0, si = y1, ah = color
; Used registers: ax, bx, cx, dx, si, bp, di, bh, ah

draw_filled_rectangle:
    push ax
    push bx
    push cx
    push dx
    push si
    push di
    push bp

    ; Save the color separately since we'll be modifying AH
    mov byte [.color_save], al

    mov bp, bx    ; bp = x0 (left)
    mov di, cx    ; di = x1 (right)
    mov bx, dx    ; bx = y0 (top)

    ; bounds check
    cmp di, bp
    jb .done_restore
    cmp si, bx
    jb .done_restore

.y_loop:
    mov dx, bx       ; DX = current y
    mov cx, bp       ; CX = start at x0

.x_loop:
    mov al, [.color_save]  ; Reload color each time
    mov ah, 0x0C           ; BIOS write pixel
    mov bh, 0x00           ; page 0
    int 0x10

    inc cx
    cmp cx, di
    jle .x_loop

    inc bx
    cmp bx, si
    jle .y_loop

.done_restore:
    pop bp
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret

.color_save: db 0