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

        ; Check for win condition
        call check_win_condition
        cmp al, 1
        je .game_won

        cmp byte [game_over_flag], 1
        je .restart_point

        jmp .loop

    .game_won:
        ; Reset scores
        mov byte [score_player1], 0
        mov byte [score_player2], 0
        mov byte [game_over_flag], 0

        ; Clear paddles and ball
        mov al, BLACK_COLOR
        mov bl, 1
        call draw_paddle
        mov bl, 2
        call draw_paddle
        call erase_ball

        jmp .init

    .restart_game:
        mov byte [game_over_flag], 0

        ; clear screen
        mov al, BLACK_COLOR
        mov bl, 1
        call draw_paddle
        mov bl, 2
        call draw_paddle

        call erase_ball

        ; CLEAR THE OLD SCORE TEXT FIRST
        call clear_score_area

        call game_score_display
        mov si, score_buffer
        call print_string_graphics

        jmp .init

; ------------------------------------
; |   SUBROUTINE: CHECK WIN          |
; ------------------------------------
; Checks if either player has reached 11 points
; Outputs: al = 1 if someone won, 0 otherwise
; Used registers: al
check_win_condition:
    xor al, al              ; al = 0 (no winner)

    cmp byte [score_player1], 11
    jge .winner_found

    cmp byte [score_player2], 11
    jge .winner_found

    ret

.winner_found:
    mov al, 1               ; al = 1 (winner found)
    ret