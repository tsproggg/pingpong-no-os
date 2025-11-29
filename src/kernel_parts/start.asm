bits 16
org 0x0000


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

    jmp game_loop


    call init_random_ball_direction

    ; ---------------------------------------
    ; |  SUBROUTINE: INITIAL RANDOM DIR     |
    ; ---------------------------------------
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

    hlt

