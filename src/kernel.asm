bits 16

section .text
    global _start
    extern clear_screen

; FIXME: The success_msg is not visible in the output of qemu

_start:
    mov ax, cs
    mov ds, ax

    call clear_screen
    ; call print_string_vga
    hlt

; New VGA Text Output Procedure
print_string_vga:
    xor si, si

    .next_char:
        cmp si, success_msg_l
        je .done

        mov al, [success_msg + si]
        mov ah, 0x0E  ; BIOS interrupt teletype output
        mov bh, 0x00  ; page number (usually 0)
        ; BL = foreground color (optional, often ignored by QEMU's simple VGA)
        int 0x10 ; Call the BIOS video interrupt

        inc si
        jmp .next_char

    .done:
        ret

success_msg db "Kernel successfully loaded", 10
success_msg_l equ 27