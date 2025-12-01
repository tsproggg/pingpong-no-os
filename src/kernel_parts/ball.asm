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
    cmp ax, [field_frame_left]
    jl .game_over_left

    cmp ax, [field_frame_right]
    jg .game_over_right

    push dx
    call check_collision_paddle1
    cmp dx, 1
    pop dx
    je .bounce_left

    push dx
    call check_collision_paddle2
    cmp dx, 1
    pop dx
    je .bounce_right

    jmp .check_vertical

    .game_over_right:
        ; Player 1 scores
        inc byte [score_player1]
        mov byte [game_over_flag], 1
        jmp .store

    .game_over_left:
        ; Player 2 scores
        inc byte [score_player2]
        mov byte [game_over_flag], 1
        jmp .store
    
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
        mov si, [field_frame_top]
        add si, ball_radius
        cmp bx, si
        jl .bounce_top
        
        mov si, [field_frame_bottom]
        sub si, ball_radius
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

; ---------------------------------------
; |     SUBROUTINE: BALL UPDATE         |
; ---------------------------------------
; Check collision with paddle 1
; Inputs:
;    ax - ball_x
;    bx - ball_y
; Outputs: dx - collision flag (0 = no collision, 1 = collision)
; Used registers: si, dx
check_collision_paddle1:
    xor dx, dx
    mov si, [paddle_1_x]
    add si, paddle_width
    add si, ball_radius
    cmp ax, si
    jg .no_paddle1_collision

    mov si, [paddle_1_y]
    sub si, ball_radius
    cmp bx, si
    jl .no_paddle1_collision

    mov si, [paddle_1_y]
    add si, paddle_height
    add si, ball_radius
    cmp bx, si
    jg .no_paddle1_collision
    mov dx, 1

    .no_paddle1_collision:
        ret

; ---------------------------------------
; |     SUBROUTINE: BALL UPDATE         |
; ---------------------------------------
; Check collision with paddle 2
; Inputs:
;    ax - ball_x
;    bx - ball_y
; Used registers: si
; Outputs: dx - collision flag (0 = no collision, 1 = collision)
check_collision_paddle2:
    xor dx, dx
    mov si, [paddle_2_x]
    sub si, ball_radius
    cmp ax, si
    jl .no_paddle2_collision
    mov si, [paddle_2_y]
    sub si, ball_radius
    cmp bx, si
    jl .no_paddle2_collision
    mov si, [paddle_2_y]
    add si, paddle_height
    add si, ball_radius
    cmp bx, si
    jg .no_paddle2_collision
    mov dx, 1

    .no_paddle2_collision:
        ret