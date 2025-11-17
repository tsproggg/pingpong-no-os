bits 16

section .text
    global print_string

; Inputs:
; dx - string source
; cx - string length

; Used registers: si, ax, bx

print_string:
    xor si, si

    .next_char:
        cmp si, cx
        je .done

        mov bx, dx
        mov al, BYTE [bx + si]
        mov ah, 0x0E  ; BIOS interrupt teletype output
        mov bh, 0x00  ; page number (usually 0)
        mov bl, 0x00  ; BL = foreground color (optional, often ignored by QEMU's simple VGA)
        int 0x10 ; Call the BIOS video interrupt

        inc si
        jmp .next_char

    .done:
        ret