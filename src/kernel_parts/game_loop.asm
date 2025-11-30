; ------------------    GAME: LOOP    ------------------

; ------------------------------------
; |     SUBROUTINE: GAME: LOOP       |
; ------------------------------------
; Inputs: none
; Used registers: ax, bx, cx, dx, si, di
game_loop:
    .init:
        ; field
        call define_field_frame_inner_borders
        call draw_field_frame

        ; paddles
        call define_paddles_starting_coords
        mov al, WHITE_COLOR
        mov bl, 1                   ; Paddle 1
        call draw_paddle

        mov al, WHITE_COLOR
        mov bl, 2                   ; Paddle 2
        call draw_paddle

        ; ball
        call define_ball_starting_coords
        call init_random_ball_direction

        call draw_ball

        mov si, [kernel_read_message]
        call print_string_graphics

    .loop:
        hlt
        cmp byte [timer_counter], 1  ; one tick = 1/60 second
        jb .loop

        call move_paddles
        call update_ball

        jmp .loop
