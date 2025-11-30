; --------------------------------
; |   Kernel Interrupt Handling  |
; --------------------------------
; Input: None
; Used registers: ax
; Initialize PIC (8259)
init_pic:
    ; Initialize Master PIC (IRQ 0-7)
    mov al, 0x11           ; ICW1: Initialize, cascade mode
    out 0x20, al
    
    mov al, 0x20           ; ICW2: Master PIC vector offset (IRQ 0 = INT 0x20)
    out 0x21, al
    
    mov al, 0x04           ; ICW3: Master has slave at IRQ 2
    out 0x21, al
    
    mov al, 0x01           ; ICW4: 8086 mode
    out 0x21, al
    
    ; Enable all interrupts (mask all off = 0x00)
    mov al, 0x00
    out 0x21, al            ; Master PIC mask
    out 0xA1, al            ; Slave PIC mask
    
    ret

; --------------------------------
; |   Kernel Interrupt Handling  |
; --------------------------------
; Input: None
; Used registers: ax, es
; Set up IRQ handler vectors in IVT
setup_irq_handlers:
    ; Save interrupt vector table segment
    push es
    
    ; Point ES to IVT (segment 0)
    xor ax, ax
    mov es, ax
    
    ; Set up IRQ 0 (Timer) - INT 0x20
    mov word [es:0x20*4], irq0_handler
    mov word [es:0x20*4+2], cs
    
    ; Set up IRQ 1 (Keyboard) - INT 0x21
    mov word [es:0x21*4], irq1_handler
    mov word [es:0x21*4+2], cs
    
    ; Restore ES
    pop es
    ret

; --------------------------------
; |   Kernel Interrupt Handling  |
; --------------------------------
; Input: None
; Used registers: ax
; IRQ 0 Handler - Timer interrupt
irq0_handler:
    pusha
    
    ; Increment timer counter
    inc byte [timer_counter]
    
    ; Send EOI (End of Interrupt) to PIC
    mov al, 0x20
    out 0x20, al
    
    popa
    iret

; --------------------------------
; |   Kernel Interrupt Handling  |
; --------------------------------
; Input: None
; Used registers: ax
; IRQ 1 Handler - Keyboard interrupt
irq1_handler:
    pusha
    
    ; Read keyboard scan code
    in al, 0x60
    
    call read_keyboard 

    ; Send EOI to PIC
    mov al, 0x20
    out 0x20, al
    
    popa
    iret