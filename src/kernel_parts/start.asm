bits 16
org 0x0000


section .data
    success_msg db "Kernel successfully loaded", 13, 10, 0

    number_to_string_f_buff db 0,0,0,0,0,0
    draw_filled_rectangle_f_color db 0
    rectangle_x1: dw 0
    rectangle_y1: dw 0


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

    ; Example 1: Draw a green rectangle
    mov al, 2               ; green color
    mov bx, 14              ; x0 (left)
    mov cx, 100             ; x1 (right)
    mov dx, 50              ; y0 (top) - FIXED: top < bottom
    mov si, 250             ; y1 (bottom)
    call draw_filled_rectangle

    ; debug message
    mov si, success_msg
    call print_string_graphics

    .infinite_loop:
        hlt
        jmp .infinite_loop


