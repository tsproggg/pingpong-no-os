; ------------------    GAME: BALL    ------------------

; ---------------------------------------
; |     SUBROUTINE: GAME: BALL          |
; ---------------------------------------
; Draw ball at current position
; Inputs: none
; Used registers: ax, bx, cx, dx, si, di
draw_ball:
    mov al, 15
    call redraw_ball
    ret


; ---------------------------------------
; |     SUBROUTINE: GAME: BALL          |
; ---------------------------------------
; Draw ball at current position
; Inputs: none
; Used registers: ax, bx, cx, dx, si, di
erase_ball:
    mov al, 0
    call redraw_ball
    ret

; ---------------------------------------
; |     SUBROUTINE: GAME: BALL          |
; ---------------------------------------
; Draw ball at current position
; Inputs:
;    al - color
;    uses ball_x, ball_y, ball_radius
; Used registers: ax, bx, cx, dx, si, di
redraw_ball:
    mov al, 15              ; white color for ball

    mov bx, [ball_x]
    sub bx, ball_radius     ; x0

    mov cx, [ball_x]
    add cx, ball_radius     ; x1

    mov dx, [ball_y]
    sub dx, ball_radius     ; y0

    mov si, [ball_y]
    add si, ball_radius     ; y1

    call draw_filled_rectangle
    ret
