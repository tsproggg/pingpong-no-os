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

    ; Initialize PIC (Programmable Interrupt Controller)
    call init_pic
    
    ; Set up IRQ handlers
    call setup_irq_handlers

    ; Enable interrupts
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

    hlt

