org 0x7C00
bits 16

start:
    cli
    mov ax, 0x9000      ; Load the desired stack segment value into AX
    mov ss, ax          ; Set the Stack Segment (SS)
    mov sp, 0xFFFF      ; Set the Stack Pointer (SP) to the top of the segment
    sti

    mov ax, cs
    mov ds, ax

load_kernel:
    mov ah, 0x02        ; BIOS read sectors
    mov al, 1           ; number of sectors
    mov dh, 0           ; head 0
    mov ch, 0           ; cylinder 0
    mov cl, 2           ; sector 2 (sectors start at 1)

    mov bx, 0x100
    mov es, bx
    xor bx, bx

    ; DL must NOT be reset, use the one BIOS gave us
    ; (it already contains boot drive number)
    ; DO NOT: mov dl, 0

    int 0x13
    jc disk_read_error

    jmp 0x100:0

disk_read_error:
	mov si, DISK_READ_ERROR_MSG
	call print_string_serial
	hlt

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

DISK_READ_ERROR_MSG db 'DISK_READ_ERROR', 10

times 510 - ($ - $$) db 0
dw 0xAA55
