; ------------------------------
; |      Game Score Display     |
; ------------------------------
game_score_display:
    ; Clear the score buffer first
    mov di, score_buffer
    mov cx, score_buffer_length
    .clear_loop:
        mov byte [di], 0
        inc di
        loop .clear_loop

    ; Convert player 1 score
    mov al, [score_player1]
    mov di, score_buffer
    call convert
    ; di now points to the position after player 1's score

    ; Add separator for a score
    mov byte [di], ':'
    inc di
    ; di now points to where player 2's score should start

    ; Convert player 2 score
    mov al, [score_player2]
    call convert
    ; di now points to the position after player 2's score

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