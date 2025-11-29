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