bits 16

section .text
    global _start
    extern print_string_serial

_start:
    mov si, hw
    call print_string_serial
    hlt

hw db "Kernel successfully loaded", 10