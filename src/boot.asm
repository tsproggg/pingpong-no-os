org 0x7C00
bits 16

start:
    mov ax, cs
    mov ds, ax

load_kernel:
    ; DL must NOT be reset, use the one BIOS gave us
    ; (it already contains boot drive number)
    ; DO NOT: mov dl, 0

    mov ah, 0x02        ; BIOS read sectors
    mov al, 1           ; number of sectors
    mov dh, 0           ; head 0
    mov ch, 0           ; cylinder 0
    mov cl, 2           ; sector 2 (sectors start at 1)

    mov bx, 0x100
    mov es, bx
    xor bx, bx

    int 0x13
    jc disk_read_error

    jmp 0x100:0

disk_read_error:
	mov si, DISK_READ_ERROR_MSG

	.print_string:
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

	hlt


DISK_READ_ERROR_MSG db 'DISK_READ_ERROR', 10

times 510 - ($ - $$) db 0
dw 0xAA55
