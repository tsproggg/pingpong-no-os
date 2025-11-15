bits 16

section .text
    global _start
    extern clear_screen
    extern print_string

; FIXME: The success_msg is not visible in the output of qemu

_start:
    mov ax, cs
    mov ds, ax

    call clear_screen

    mov dx, success_msg
    mov cx, success_msg_l
    call print_string
    hlt

success_msg db "Kernel successfully loaded", 10
success_msg_l equ 27