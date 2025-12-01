; ------------------------------
; |      Game Score Display     |
; ------------------------------
game_score_display:

    ; call empty_score_buffer
    mov byte al, [score_player1]
    mov di, score_buffer
    call convert
    mov byte [di], ':'       ; space separator
    inc di
    mov byte al, [score_player2]
    call convert
    mov byte [di], 0
    ret


convert:
    mov ah, 0          ; AX = AL value
    mov cx, 0          ; digit count

    cmp ax, 0
    jne .convert_loop
    mov byte [di], '0'
    inc di
    jmp .done
.convert_loop:
    xor dx, dx
    mov bx, 10
    div bx            ; AX = AX / 10, DX = remainder (digit)

    add dl, '0'       ; convert digit → ASCII
    push dx           ; push onto stack
    inc cx

    test ax, ax
    jnz .convert_loop

.write_back:
    pop dx
    mov [di], dl
    inc di
    loop .write_back

    .done:
    ret