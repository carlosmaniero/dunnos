;;; Copyright (c) 2022 Maniero

;;; Clear the screen
;;;
;;; this function does not expect any register to be set
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

;;; Set the cursor position at (0, 0) position
;;;
;;; this function does not expect any register to be set
reset_cursor_position:
    mov     dh, 0               ; row
    mov     dl, 0               ; column
    jmp     set_cursor_position

;;; set the cursor position
;;;
;;; DH = row
;;; DL = column
set_cursor_position:
    pusha
    mov     ah, 0x2
    mov     bh, 0x0
    int     0x10
    popa
    ret

;;; print a single char
;;;
;;; AL = char to be printed
print_char:
    pusha
    mov     ah, 0x0E
    mov     bh, 0
    int     0x10
    popa
    ret

;;; print a new line
print_nl:
    pusha
    mov     al, 10
    call    print_char
    mov     al, 13
    call    print_char
    popa
    ret


;;; Print a zero-ended string
;;;
;;; SI = the string
print_string:
    pusha
.loop:
    lodsb
    cmp     al, 0
    je      .return
    call    print_char
    jmp     .loop
.return:
    popa
    ret

SCREEN_ROWS db 24
SCREEN_COLS db 79
