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
    ; Save parameters since we'll be modifying registers
    mov [draw_filled_rectangle_f_color], al
    mov [rectangle_x1], cx  ; Save x1
    mov [rectangle_y1], si  ; Save y1

    ; Validate bounds
    cmp cx, bx      ; if x1 < x0, exit
    jb .done
    cmp si, dx      ; if y1 < y0, exit
    jb .done

    mov ah, 0x0C    ; BIOS write pixel function
    mov bh, 0       ; Page 0

    mov di, dx      ; DI = current y (start at y0)

    .y_loop:
        mov cx, bx      ; CX = current x (start at x0 for each row)

    .x_loop:
        mov al, [draw_filled_rectangle_f_color]
        mov dx, di      ; DX = current y
        ; CX already has current x
        int 0x10

        inc cx
        cmp cx, [rectangle_x1]
        jle .x_loop

        inc di
        cmp di, [rectangle_y1]
        jle .y_loop

    .done:
        ret

