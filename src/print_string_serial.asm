bits 16

section .text
    global print_string_serial

; Inputs:
; si - message pointer

print_string_serial:
.next_char:
    lodsb                   ; AL = [SI], SI++
    or al, al
    jz .done
.wait:
    mov dx, 0x3FD           ; COM1 Line Status Register (0x3F8 + 5)
    in al, dx               ; read LSR
    test al, 0x20           ; check Transmit Holding Empty
    jz .wait
    mov dx, 0x3F8           ; COM1 data port
    mov al, [si-1]          ; get character
    out dx, al              ; send character
    jmp .next_char
.done:
    ret