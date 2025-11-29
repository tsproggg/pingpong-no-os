
section .data
    ; ---- debug  ----
    success_msg db "Kernel successfully loaded", 13, 10, 0

    ; ---- functions ----
    number_to_string_f_buff db 0,0,0,0,0,0

    ; colors
    BLACK_COLOR equ 0x00
    WHITE_COLOR equ 0x0F

    ; ---- game ----
    ; screen size
    screen_size_x equ 640
    screen_size_y equ 480

    ; field frame
    field_frame_border_width equ 2
    field_frame_margin_top equ 48   ; 5px margin + 38px text + 5px margin
    field_frame_margin_left equ 18
    field_frame_size_x equ 600
    field_frame_size_y equ 420

    ; ball
    ball_radius equ 4      ; Ball radius
    ball_x dw 0          ; Ball center x coord
    ball_y dw 0          ; Ball center y coord

    ; paddles
    paddle_width equ 8
    paddle_height equ 80
    paddle_speed equ 10

    paddle_1_x dw 0
    paddle_1_y dw 0     ; left top corner

    paddle_2_x dw 0
    paddle_2_y dw 0     ; left top corner
