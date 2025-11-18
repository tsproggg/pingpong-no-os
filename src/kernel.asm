bits 16
org 0x0000

section .data
    success_msg db "Kernel successfully loaded", 13, 10, 0

section .text
    global _start

_start:
    cli
    mov ax, 0x9000      ; Load the desired stack segment value into AX
    mov ss, ax          ; Set the Stack Segment (SS)
    mov sp, 0xFFFF      ; Set the Stack Pointer (SP) to the top of the segment
    sti

    mov ax, cs
    mov ds, ax

    call clear_screen

    mov si, success_msg
    call print_string
    hlt

; ---------------------------
; |     SUBROUTINE          |
; ---------------------------
; Inputs: none
; Used registers: ax, bx, dx
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

; ---------------------------
; |     SUBROUTINE          |
; ---------------------------
; Inputs: si - string pointer
; Used registers: ax, bx
print_string:
    .next_char:
        mov al, [si]
        cmp al, 0
        je .done

        mov ah, 0x0E  ; BIOS interrupt teletype output
        mov bh, 0x00  ; page number (usually 0)
        mov bl, 0x00  ; BL = foreground color (optional, often ignored by QEMU's simple VGA)
        int 0x10 ; Call the BIOS video interrupt

        inc si
        jmp .next_char

    .done:
        ret