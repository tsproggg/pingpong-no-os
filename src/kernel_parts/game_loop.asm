; ------------------    GAME: LOOP    ------------------

; ------------------------------------
; |     SUBROUTINE: GAME: LOOP       |
; ------------------------------------
; Inputs: none
; Used registers: ax, bx, cx, dx, si, di
game_loop:
    .init:
        call draw_field_frame
        call define_paddles_starting_coords
        call define_ball_starting_coords

        mov al, WHITE_COLOR
        mov bl, 1                   ; Paddle 1
        call draw_paddle

        mov al, WHITE_COLOR
        mov bl, 2                   ; Paddle 2
        call draw_paddle

        call draw_ball

    .loop:
        call read_keyboard

        jmp .loop

