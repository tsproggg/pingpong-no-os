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
    push bp
    mov bp, sp

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

    ; ---- paddle collisions ----
    ; left paddle
    push ax
    push bx
    mov dx, 1
    call check_paddle_ball_collision

    test ax, ax
    jne .bounce_right   ; ball collided to the left paddle

    ; right paddle
    mov ax, [bp-2]
    mov bx, [bp-4]
    mov dx, 2
    call check_paddle_ball_collision

    test ax, ax
    jne .bounce_left    ; ball collided to the right paddle

    ; ---- field collisions ----
    ; left
    mov ax, [bp-2]
    sub ax, ball_radius         ; left end of the ball

    cmp ax, [field_frame_left]
    jle .goal_left

    ; right
    add ax, ball_radius
    add ax, ball_radius         ; right end of the ball

    cmp ax, [field_frame_right]
    jge .goal_right

    .check_vertical:
        ; field top
        mov bx, [bp-4]
        sub bx, ball_radius     ; highest end of the ball

        cmp bx, [field_frame_top]
        jle .bounce_top

        ; field bottom
        add bx, ball_radius
        add bx, ball_radius     ; lowest end of the ball

        cmp bx, [field_frame_bottom]
        jge .bounce_bottom

        jmp .store

    .goal_left:
        ; TODO: add some visual notification about the goal
        inc word [game_score_right]
        jmp .bounce_right

    .goal_right:
        ; TODO: add some visual notification about the goal
        inc word [game_score_left]
        jmp .bounce_left

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

        jmp .check_vertical

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

        mov sp, bp
        pop bp
        ret


; ---------------------------------------
; |     SUBROUTINE: BALL UPDATE         |
; ---------------------------------------
; Inputs:
;   ax - new X ball position
;   bx - new Y ball position
;   dx - paddle number (1 or 2)
; Outputs: ax - true/false (0x01 or 0x00)
; Used registers: cx, si
check_paddle_ball_collision:
    .check_paddle_number:
        cmp dx, 1
        je .load_1

        cmp dx, 2
        je .load_2

        jmp .no_collision

    .load_1:
        mov cx, [paddle_1_x]
        mov si, [paddle_1_y]
        jmp .check_by_x_1

    .load_2:
        mov cx, [paddle_2_x]
        mov si, [paddle_2_y]
        jmp .check_by_x_2

    .check_by_x_1:
        add cx, paddle_width

        sub ax, ball_radius
        cmp ax, cx
        jg .no_collision

        jmp .check_by_y

    .check_by_x_2:
        add ax, ball_radius
        cmp ax, cx
        jg .no_collision

    .check_by_y:
        add bx, ball_radius     ; lowest end of the ball

        cmp bx, si
        jl .no_collision

        add si, paddle_height   ; bottom of the paddle
        add bx, ball_radius
        add bx, ball_radius     ; highest end of the ball

        cmp bx, si
        jg .no_collision

        ; there is a collision
        mov ax, 1
        ret

    .no_collision:
        xor ax, ax
        ret