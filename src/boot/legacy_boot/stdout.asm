screen_clear:
    call    reset_cursor_position
    pusha
    xor     dh, dh              ; rows
    xor     dl, dl              ; columns
.loop:
    mov     al, ' '
    call    print_char
    inc     dl
    cmp     dl, [SCREEN_COLS]
    jne     .loop
    jmp     .next_row
.next_row:
    inc     dh
    cmp     dh, [SCREEN_ROWS]
    je      .return
    xor     dl, dl
    jmp     .loop
.return:
    popa
    jmp     reset_cursor_position

reset_cursor_position:
    mov     dh, 0               ; rows
    mov     dl, 0               ; columns
    jmp     set_cursor_position

set_cursor_position:
    pusha
    mov     ah, 0x2
    mov     bh, 0x0
    int     0x10
    popa
    ret

print_char:
    mov     ah, 0x0E
    mov     bh, 0
    int     0x10
    ret

print_msg:
    pusha
.loop:
    lodsb
    cmp     al, 0
    je      .return
    call    print_char
    jmp     .loop
    popa
.return:
    ret

SCREEN_ROWS db 24
SCREEN_COLS db 79
