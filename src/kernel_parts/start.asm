bits 16
org 0x0000


section .data
    success_msg db "Kernel successfully loaded", 13, 10, 0

    number_to_string_f_buff db 0,0,0,0,0,0
    temp_color db 0
    draw_filled_rectangle_f_color db 0
    rectangle_x0: dw 0
    rectangle_y0: dw 0
    rectangle_x1: dw 0
    rectangle_y1: dw 0
    
    paddle_width dw 6
    paddle_height dw 80

    paddle_1_x dw 8
    paddle_1_y dw 200

    paddle_2_x dw 624
    paddle_2_y dw 200

    paddle_speed dw 10


section .text
    global _start


; ----------------------------------
; |     SUBROUTINE: START          |
; ----------------------------------
_start:
    ; stack initialization
    cli
    mov ax, 0x9000      ; Load the desired stack segment value into AX
    mov ss, ax          ; Set the Stack Segment (SS)
    mov sp, 0xFFFF      ; Set the Stack Pointer (SP) to the top of the segment
    sti

    ; section .data pointer initialization
    mov ax, cs
    mov ds, ax

    ; clear screen
    call clear_screen

    ; entering vga video mode 640x480 px
    mov ax, 0x12
    int 0x10



    mov al, 0x0F               ; White color
    mov bl, 1                   ; Paddle 1
    call draw_paddle
    mov bl, 2                   ; Paddle 2
    call draw_paddle

    ; mov si, success_msg
    ; call print_string_graphics

    game_loop:
        ; call wait_vsync

        call read_keyboard
        
        jmp game_loop

    hlt

