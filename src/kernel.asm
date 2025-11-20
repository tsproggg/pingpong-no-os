bits 16
org 0x0000


section .data
    success_msg db "Kernel successfully loaded", 13, 10, 0

    number_to_string_f_buff db 0,0,0,0,0,0


section .text
    global _start


; ----------------------------------
; |     SUBROUTINE: START          |
; ----------------------------------
_start:
    ; stack initialization
    cli
    mov ax, 0x9000      ; Load the desired stack segment value into AX
    mov ss, ax          ; Set the Stack Segment (SS)
    mov sp, 0xFFFF      ; Set the Stack Pointer (SP) to the top of the segment
    sti

    ; section .data pointer initialization
    mov ax, cs
    mov ds, ax

    ; clear screen
    call clear_screen

    ; debug message
    mov si, success_msg
    call print_string
    ;call shutdown
    hlt

; --------------------    SCREEN    --------------------

; -----------------------------------
; |     SUBROUTINE: SCREEN          |
; -----------------------------------
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


; -----------------------------------
; |     SUBROUTINE: SCREEN          |
; -----------------------------------
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

; -----------------------------------
; |     SUBROUTINE: SCREEN          |
; -----------------------------------
; Inputs: ax - number to convert
; Outputs: si - pointer to the string
; Used registers: ax, cx, dx, di
number_to_string:
    mov si, 10
    mov cx, 1           ; degree counter

    .calculate_next_digit:
        xor dx, dx      ; remainder register
        div si          ; ax / si = ax (remainder: dx in range [0;9])

        add dl, 48
        mov di, number_to_string_f_buff + 5
        sub di, cx
        mov [di], dl

        inc cx

        test ax, ax     ; check ax == 0
        jne .calculate_next_digit

    .find_number_start:
        mov di, number_to_string_f_buff

        .loop:
            cmp byte [di], 0
            jne .done

            inc di
            jmp .loop

    .done:
        mov si, di
        ret


; --------------------    SYSTEM    --------------------

; -----------------------------------
; |     SUBROUTINE: SYSTEM          |
; -----------------------------------
; Inputs: none
; Used registers: ax, bx, cx
shutdown:
    .do_shutdown:
        ; 1) Connect to APM BIOS
        mov ax, 0x5301
        xor bx, bx
        int 0x15
        jc .apm_fail

        ; 2) Enable power management
        mov ax, 0x5308
        mov bx, 1
        mov cx, 1
        int 0x15
        jc .apm_fail

        ; 3) Turn off the machine
        mov ax, 0x5307
        mov bx, 1        ; all devices
        mov cx, 3        ; power-off
        int 0x15
        jc .apm_fail

    .apm_fail:
        cli
        hlt
        jmp $
