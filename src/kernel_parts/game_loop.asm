; ------------------    GAME: LOOP    ------------------

; ------------------------------------
; |     SUBROUTINE: GAME: LOOP       |
; ------------------------------------
; Inputs: none
; Used registers: ax, bx, cx, dx, si, di
game_loop:
    .init:
        mov al, 0x0F               ; White color

        mov bl, 1                   ; Paddle 1
        call draw_paddle
        mov bl, 2                   ; Paddle 2
        call draw_paddle

        call draw_ball

    .loop:
        call read_keyboard

        jmp .loop

