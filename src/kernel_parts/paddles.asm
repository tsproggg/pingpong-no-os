; --------------------    PADDLES    --------------------

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

    jmp .done                     ; Invalid paddle number, exit

    .draw_paddle_1:
        ; Load paddle 1 position
        mov bx, [paddle_1_x]       ; x0

        mov cx, [paddle_1_x]
        add cx, paddle_width       ; x1

        mov dx, [paddle_1_y]       ; y0

        mov si, [paddle_1_y]
        add si, paddle_height      ; y1
        call draw_filled_rectangle

        jmp .done

    .draw_paddle_2:
        mov bx, [paddle_2_x]       ; x0

        mov cx, [paddle_2_x]
        add cx, paddle_width       ; x1

        mov dx, [paddle_2_y]       ; y0

        mov si, [paddle_2_y]
        add si, paddle_height      ; y1
        call draw_filled_rectangle

        jmp .done

    .done:
        ret


; ------------------------------
; |     SUBROUTINE: PADDLES    |
; ------------------------------
; Inputs: None
; Used registers: ax, bx, cx, dx, si, di
move_paddle_1_up:
    .check_bounds:
        mov ax, [paddle_1_y]
        sub ax, paddle_speed
        cmp ax, [field_frame_top]
        jg .redraw

        ; clamping new position
        mov ax, [field_frame_top]
        inc ax                 ; to make the highest pixel of the paddle below the frame

        add ax, paddle_speed   ; to feed update_position_up a value where it can subtract paddle_speed
        mov [paddle_1_y], ax

    .redraw:
        mov bx, [paddle_1_x]
        mov dx, [paddle_1_y]

        call update_position_up

        mov ax, [paddle_1_y]
        sub ax, paddle_speed
        mov [paddle_1_y], ax

    .done:
        ret


; ------------------------------
; |     SUBROUTINE: PADDLES    |
; ------------------------------
; Inputs: None
; Used registers: ax, bx, cx, dx, si, di
move_paddle_1_down:
    .check_bounds:
        mov ax, [paddle_1_y]
        add ax, paddle_height
        add ax, paddle_speed

        cmp ax, [field_frame_bottom]
        jl .redraw

        ; clamping
        mov ax, [field_frame_bottom]
        dec ax                  ; to make the lowest pixel of the paddle above the frame
        sub ax, paddle_height
        sub ax, paddle_speed    ; to feed update_position_down a value where it can add paddle_speed
        mov [paddle_1_y], ax

    .redraw:
        mov bx, [paddle_1_x]
        mov dx, [paddle_1_y]

        call update_position_down

        mov ax, [paddle_1_y]
        add ax, paddle_speed
        mov [paddle_1_y], ax

    .done:
        ret


; ------------------------------
; |     SUBROUTINE: PADDLES    |
; ------------------------------
; Inputs: None
; Used registers: ax, bx, cx, dx, si, di
move_paddle_2_up:
   .check_bounds:
        mov ax, [paddle_2_y]
        sub ax, paddle_speed
        cmp ax, [field_frame_top]
        jg .redraw

        ; clamping new position
        mov ax, [field_frame_top]
        inc ax                 ; to make the highest pixel of the paddle below the frame

        add ax, paddle_speed   ; to feed update_position_up a value where it can subtract paddle_speed
        mov [paddle_2_y], ax

   .redraw:
        mov bx, [paddle_2_x]
        mov dx, [paddle_2_y]

        call update_position_up

        mov ax, [paddle_2_y]
        sub ax, paddle_speed

        mov [paddle_2_y], ax

    .done:
        ret


; ------------------------------
; |     SUBROUTINE: PADDLES    |
; ------------------------------
; Inputs: None
; Used registers: ax, bx, cx, dx, si, di
move_paddle_2_down:
    .check_bounds:
        mov ax, [paddle_2_y]
        add ax, paddle_height
        add ax, paddle_speed

        cmp ax, [field_frame_bottom]
        jl .redraw

        ; clamping
        mov ax, [field_frame_bottom]
        dec ax                  ; to make the lowest pixel of the paddle above the frame
        sub ax, paddle_height
        sub ax, paddle_speed    ; to feed update_position_down a value where it can add paddle_speed
        mov [paddle_2_y], ax

    .redraw:
        mov bx, [paddle_2_x]
        mov dx, [paddle_2_y]

        call update_position_down

        mov ax, [paddle_2_y]
        add ax, paddle_speed
        mov [paddle_2_y], ax

    .done:
        ret


; ------------------------------
; |     SUBROUTINE: PADDLES    |
; ------------------------------
; Inputs: bx - X position, dx - old Y position  
; Used registers: ax, bx, cx, dx, si, di
update_position_up:
    mov al, WHITE_COLOR      ; color white

    mov cx, bx
    add cx, paddle_width     ; x1

    mov si, dx               ; y1
    sub dx, paddle_speed     ; y0

    ; save x0 and old y0
    push bx
    push dx

    call draw_filled_rectangle

    ; restore x0 and old y0
    pop dx
    pop bx

    mov al, BLACK_COLOR              ; color black

    mov cx, bx
    add cx, paddle_width      ; x1

    add dx, paddle_height
    mov si, dx
    add si, paddle_speed      ; y1
    call draw_filled_rectangle

    ret


; ------------------------------
; |     SUBROUTINE: PADDLES    |
; ------------------------------
; Inputs: bx - X position, dx - old Y position
; Used registers: ax, bx, cx, dx, si, di
update_position_down:
    mov al, BLACK_COLOR       ; color black

    mov cx, bx
    add cx, paddle_width      ; x1

    mov si, dx
    add si, paddle_speed      ; y1

    ; save x0 and old y0
    push bx
    push dx

    call draw_filled_rectangle

    ; restore x0 and old y0
    pop dx
    pop bx

    mov al, WHITE_COLOR       ; color white

    mov cx, bx
    add cx, paddle_width      ; x1

    add dx, paddle_height     ; y0

    mov si, dx
    add si, paddle_speed      ; y1
    call draw_filled_rectangle

    ret

move_paddles:
    ; Check paddle 1 up (W key)
    cmp byte [key_w_pressed], 1
    jne .check_s
    call move_paddle_1_up

.check_s:
    ; Check paddle 1 down (S key)
    cmp byte [key_s_pressed], 1
    jne .check_up
    call move_paddle_1_down

.check_up:
    ; Check paddle 2 up (Up arrow)
    cmp byte [key_uparrow_pressed], 1
    jne .check_down
    call move_paddle_2_up

.check_down:
    ; Check paddle 2 down (Down arrow)
    cmp byte [key_downarrow_pressed], 1
    jne .done
    call move_paddle_2_down

.done:
    ret