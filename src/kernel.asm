bits 16

section .data
success_msg db "Kernel successfully loaded", 10
success_msg_l equ 27

section .text
    global _start
    extern clear_screen
    extern print_string

; FIXME: CPU loses ptr to the .data segment after compilation

_start:
    cli
    mov ax, 0x9000      ; Load the desired stack segment value into AX
    mov ss, ax          ; Set the Stack Segment (SS)
    mov sp, 0xFFFF      ; Set the Stack Pointer (SP) to the top of the segment
    sti

    mov ax, cs
    mov ds, ax

    call clear_screen

    mov dx, success_msg
    mov cx, success_msg_l
    call print_string
    hlt