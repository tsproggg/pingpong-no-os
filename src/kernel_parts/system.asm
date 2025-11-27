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