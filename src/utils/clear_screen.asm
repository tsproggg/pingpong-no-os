bits 16

; USED REGISTERS: AX, BX, DX

section .text
    global clear_screen
; Clear screen using BIOS int 0x10
clear_screen:
    mov ah, 0x00
    mov al, 0x03
    int 0x10

    ; Ensure cursor at row 0, col 0 (BIOS int 0x10 AH=0x02)
    mov ah, 0x02
    mov bh, 0x00    ; page
    mov dh, 0x00    ; row
    mov dl, 0x00    ; column
    int 0x10
    ret
