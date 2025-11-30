; ------------------    GAME: BALL    ------------------

; ----------------------------------------
; |     SUBROUTINE: BALL UPDATE          |
; ----------------------------------------
; Draw ball at current position
; Inputs: none
; Used registers: ax, bx, cx, dx, si, di
draw_ball:
    mov al, WHITE_COLOR
    call redraw_ball
    ret


; ----------------------------------------
; |     SUBROUTINE: BALL UPDATE          |
; ----------------------------------------
; Draw ball at current position
; Inputs: none
; Used registers: ax, bx, cx, dx, si, di
erase_ball:
    mov al, BLACK_COLOR
    call redraw_ball
    ret


; ----------------------------------------
; |     SUBROUTINE: BALL UPDATE          |
; ----------------------------------------
; Draw ball at current position
; Inputs:
;    al - color
;    uses ball_x, ball_y, ball_radius
; Used registers: ax, bx, cx, dx, si, di
redraw_ball:
    ; al already has color
    mov bx, [ball_x]
    mov dx, [ball_y]

    ; compute rectangle
    mov cx, bx
    sub bx, ball_radius     ; x0
    add cx, ball_radius     ; x1

    mov si, dx
    sub dx, ball_radius     ; y0
    add si, ball_radius     ; y1

    call draw_filled_rectangle
    ret


; ---------------------------------------
; |     SUBROUTINE: BALL UPDATE         |
; ---------------------------------------
; Moves ball and handles bouncing
; Uses: ax, bx, cx, dx, si, di
update_ball:
    ; erase previous frame
    call erase_ball

    ; load current position
    mov ax, [ball_x]
    mov bx, [ball_y]

    ; load velocity
    mov cx, [ball_dx]
    mov dx, [ball_dy]

    ; update positions
    add ax, cx
    add bx, dx

    ; ---- screen boundaries ----
    ; horizontal bounce
    cmp ax, ball_radius
    jl .bounce_left

    mov si, 640 - ball_radius
    cmp ax, si
    jg .bounce_right
    jmp .check_vertical

    .bounce_left:
        ; Reverse direction: cx = -cx using sub
        mov si, cx
        xor cx, cx
        sub cx, si
        ; Correct position
        add ax, cx
        add ax, cx  ; double correction to bounce back
        jmp .check_vertical

    .bounce_right:
        ; Reverse direction: cx = -cx using sub
        mov si, cx
        xor cx, cx
        sub cx, si
        ; Correct position
        add ax, cx
        add ax, cx  ; double correction to bounce back

    .check_vertical:
        cmp bx, ball_radius
        jl .bounce_top

        mov si, 480 - ball_radius
        cmp bx, si
        jg .bounce_bottom
        jmp .store

    .bounce_top:
        ; Reverse direction: dx = -dx using sub
        mov si, dx
        xor dx, dx
        sub dx, si
        ; Correct position
        add bx, dx
        add bx, dx  ; double correction to bounce back
        jmp .store

    .bounce_bottom:
        ; Reverse direction: dx = -dx using sub
        mov si, dx
        xor dx, dx
        sub dx, si
        ; Correct position
        add bx, dx
        add bx, dx  ; double correction to bounce back

    .store:
        ; save updated values
        mov [ball_x], ax
        mov [ball_y], bx
        mov [ball_dx], cx
        mov [ball_dy], dx

        ; draw new frame
        call draw_ball
        ret