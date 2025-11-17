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
    mov ax, cs
    mov ds, ax

    call clear_screen

    mov dx, success_msg
    mov cx, success_msg_l
    call print_string
    hlt