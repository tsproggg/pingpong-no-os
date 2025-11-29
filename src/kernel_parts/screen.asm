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
; Inputs:
;   al = color
;   bx = x0
;   cx = x1
;   dx = y0
;   si = y1
; Used registers: ax, bx, cx, dx, si, di
draw_filled_rectangle:
    push bp
    mov bp, sp

    ; Save ALL parameters to memory
    push ax     ; color
    push bx     ; x0
    push cx     ; x1
    push dx     ; y0
    push si     ; y1

    ; Validate bounds
    cmp cx, bx      ; if x1 <= x0, exit
    jbe .done
    cmp si, dx      ; if y1 <= y0, exit
    jbe .done

    mov ah, 0x0C    ; BIOS write pixel function
    mov bh, 0       ; Page 0

    mov di, [bp-8]  ; DI = current y (start at y0)

    .y_loop:
        mov cx, [bp-4]  ; CX = current x (RELOAD from memory each row!)

    .x_loop:
        mov al, [bp-2]
        mov dx, di      ; DX = current y
        ; CX already has current x
        int 0x10

        inc cx
        cmp cx, [bp-6]
        jbe .x_loop     ; unsigned comparison

        inc di
        cmp di, [bp-10]
        jbe .y_loop     ; unsigned comparison

    .done:
        mov sp, bp
        pop bp
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