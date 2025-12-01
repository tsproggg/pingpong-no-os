; ------------------    GAME: LOOP    ------------------

; ------------------------------------
; |     SUBROUTINE: GAME: LOOP       |
; ------------------------------------
; Inputs: none
; Used registers: ax, bx, cx, dx, si, di
game_loop:
    .init:
        call define_field_frame_inner_borders
        call draw_field_frame
        
        .restart_point:
        cmp byte [game_over_flag], 1
        je .restart_game
        ; field


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


        call game_score_display
        mov si, score_buffer
        call print_string_graphics

        .start_timer:
        hlt
        cmp byte [timer_counter], 60  ; wait for 2 seconds 
        jb .start_timer
        mov byte [timer_counter], 0

    .loop:
        hlt
        cmp byte [timer_counter], 1  ; one tick = 1/60 second
        jb .loop
        mov byte [timer_counter], 0

        call move_paddles
        call update_ball

        cmp byte [game_over_flag], 1
        je .restart_point

        jmp .loop

    .restart_game:
        mov byte [game_over_flag], 0
        
        ; clear screen
        mov ax, BLACK_COLOR
        mov bl, 1
        call draw_paddle
        mov bl, 2
        call draw_paddle

        call erase_ball

        jmp .init