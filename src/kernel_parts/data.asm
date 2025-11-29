section .data
    ; ---- functions ----
    number_to_string_f_buff db 0,0,0,0,0,0

    ; ---- colors ----
    BLACK_COLOR equ 0x00
    WHITE_COLOR equ 0x0F

    ; ---- game ----
    ; screen size
    screen_size_x equ 640
    screen_size_y equ 480

    ; field frame
    field_frame_border_width equ 2
    field_frame_margin_top equ 48   ; 5px margin + 38px text + 5px margin
    field_frame_margin_x equ 18
    field_frame_margin_bottom equ 8

    field_frame_size_x dw 0
    field_frame_size_y dw 0

    field_frame_top dw 0        ; inner coordinate (bottom of the border)
    field_frame_left dw 0       ; inner coordinate (right of the border)
    field_frame_bottom dw 0     ; inner coordinate (top of the border)
    field_frame_right dw 0      ; inner coordinate (left of the border)

    ; ball
    ball_radius equ 4    ; Ball radius
    ball_x dw 0          ; Ball center x coord
    ball_y dw 0          ; Ball center y coord

    ; ball movement
    ball_dx dw 1        ; horizontal speed (+right, -left)
    ball_dy dw 1        ; vertical speed (+down, -up)

    ; ball update rate control
    ball_update_rate equ 90    ; Update ball for written frames
    ball_frame_counter db 0

    ; paddles
    paddle_width equ 8
    paddle_height equ 80
    paddle_speed equ 10

    paddle_1_x dw 0
    paddle_1_y dw 0     ; left top corner

    paddle_2_x dw 0
    paddle_2_y dw 0     ; left top corner

    ; score
    game_score_left dw 0
    game_score_right dw 0