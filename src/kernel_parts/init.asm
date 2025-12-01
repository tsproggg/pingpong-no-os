; --------------------    INIT    --------------------

; ---------------------------------
; |     SUBROUTINE: INIT          |
; ---------------------------------
; Inputs: none
; Used registers: ax
define_field_frame_inner_borders:
    mov word [field_frame_size_x], screen_size_x
    sub word [field_frame_size_x], field_frame_margin_x
    sub word [field_frame_size_x], field_frame_border_width
    sub word [field_frame_size_x], field_frame_margin_x
    sub word [field_frame_size_x], field_frame_border_width ; field_frame_size_x

    mov word [field_frame_size_y], screen_size_y
    sub word [field_frame_size_y], field_frame_margin_top
    sub word [field_frame_size_y], field_frame_border_width
    sub word [field_frame_size_y], field_frame_margin_bottom
    sub word [field_frame_size_y], field_frame_border_width ; field_frame_size_y

    mov word [field_frame_top], field_frame_margin_top
    add word [field_frame_top], field_frame_border_width    ; field_frame_top

    mov word [field_frame_bottom], screen_size_y
    sub word [field_frame_bottom], field_frame_margin_bottom
    sub word [field_frame_bottom], field_frame_border_width ; field_frame_bottom

    mov word [field_frame_left], field_frame_margin_x
    add word [field_frame_left], field_frame_border_width   ; field_frame_left

    mov word [field_frame_right], screen_size_x
    sub word [field_frame_right], field_frame_margin_x
    sub word [field_frame_right], field_frame_border_width  ; field_frame_right

    ret

; ---------------------------------
; |     SUBROUTINE: INIT          |
; ---------------------------------
; Inputs: none
; Used registers: ax
define_paddles_starting_coords:
    mov ax, [field_frame_left]
    mov [paddle_1_x], ax        ; paddle_1_x

    mov ax, [field_frame_top]
    mov [paddle_1_y], ax

    mov ax, [field_frame_size_y]
    shr ax, 1   ; ax = field_frame_size_y / 2
    add word [paddle_1_y], ax

    mov ax, paddle_height
    shr ax, 1   ; ax = paddle_height / 2
    sub word [paddle_1_y], ax                        ; paddle_1_y

    mov ax, [paddle_1_x]
    mov word [paddle_2_x], screen_size_x
    sub word [paddle_2_x], ax
    sub word [paddle_2_x], paddle_width              ; paddle_2_x

    mov ax, [paddle_1_y]
    mov word [paddle_2_y], ax                        ; paddle_2_y

    ret

; ---------------------------------
; |     SUBROUTINE: INIT          |
; ---------------------------------
; Inputs: none
; Used registers: ax
define_ball_starting_coords:
    mov ax, [field_frame_left]
    add ax, [field_frame_right]
    shr ax, 1   ; ax = field_frame_size_x / 2

    add [ball_x], ax
    ; sub word [ball_x], ball_radius       ; ball_x

    mov ax, [field_frame_top]
    add ax, [field_frame_bottom]
    shr ax, 1   ; ax = field_frame_size_y / 2

    add word [ball_y], ax
    ; sub word [ball_y], ball_radius       ; ball_y

    ret

; ---------------------------------
; |     SUBROUTINE: INIT          |
; ---------------------------------
; Inputs: none
; Used registers: ax
init_random_ball_direction:
    call read_random_byte
    test al, 1
    jz .posx

    ; Negate ball_dx using sub: ball_dx = 0 - ball_dx
    mov ax, 0
    sub ax, [ball_dx]
    mov [ball_dx], ax

    .posx:
        call read_random_byte
        test al, 1
        jz .posy

        ; Negate ball_dy using sub: ball_dy = 0 - ball_dy
        mov ax, 0
        sub ax, [ball_dy]
        mov [ball_dy], ax

    .posy:
        ret
        
