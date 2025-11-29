section .data
    ; ---- debug  ----
    success_msg db "Kernel successfully loaded", 13, 10, 0

    ; ---- functions ----
    number_to_string_f_buff db 0,0,0,0,0,0

    ; ---- game ----
    ; ball
    ball_x dw 320          ; Ball x position (center of screen)
    ball_y dw 240          ; Ball y position (center of screen)
    ball_radius equ 4         ; Ball size (8x8 pixels)

    ; ---- ball movement ----
    ball_dx dw 1        ; horizontal speed (+right, -left)
    ball_dy dw 1        ; vertical speed (+down, -up)

    ; Ball update rate control
    ball_frame_counter db 0
    ball_update_rate equ 90    ; Update ball for written frames

    ; paddles
    paddle_width equ 6
    paddle_height equ 80
    paddle_speed equ 10

    paddle_1_x dw 8
    paddle_1_y dw 200

    paddle_2_x dw 624
    paddle_2_y dw 200
