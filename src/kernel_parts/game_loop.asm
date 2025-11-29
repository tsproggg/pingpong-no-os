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
        call wait_vsync         ; Wait for vertical sync (limits to ~60 FPS)
        call read_keyboard

        ; Frame counter for ball updates
        inc byte [ball_frame_counter]
        cmp byte [ball_frame_counter], ball_update_rate
        jl .skip_ball_update

        mov byte [ball_frame_counter], 0
        call update_ball

    .skip_ball_update:
        jmp .loop