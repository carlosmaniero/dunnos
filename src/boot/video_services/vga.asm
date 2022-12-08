;;; Copyright (c) 2022 Maniero
%ifndef BOOT_VIDEO_SERVICES_VGA
    %define BOOT_VIDEO_SERVICES_VGA
VGA_START               equ 0xb8000
VGA_ROW                 equ 80
VGA_END                 equ VGA_START + VGA_ROW * 25 * 2

    section .text
;;; Clean the entire screen
clean_screen:
    mov   eax, VGA_START
.loop:
    mov   word [eax], VGA_ERROR_SCREEN_COLOR * 0x100 + ' '
    add   eax, 2
    cmp   eax, VGA_END
    jne   .loop
    ret

;;; Prints a string to the VGA
;;; AL:  char
;;; AH:  String color
;;; ESI: String pointer
;;;
;;; Result:
;;; EDI: The position after the char
print_char:
    mov     word [edi], ax
    add     edi, 2
    ret

;;; Moves the pointer to the next line
;;; EDI: Screen position
new_line:
    push    eax
    push    ebx
    sub     edi, VGA_START      ; Get the total of chars printed

    mov     eax, edi
    mov     ebx, VGA_ROW * 2
    div     ebx                 ; Get the total of rows and store it on EAX

    inc     eax                 ; Increment one line

    mul     ebx                 ; get the position of the next line
    add     eax, VGA_START      ; set at the right position
    mov     edi, eax
    pop     ebx
    pop     eax
    ret

;;; Prints a string to the VGA
;;; EDI: Screen position
;;; AH:  String color
;;; ESI: String pointer
;;;
;;; Result:
;;; EDI: The position after the string
print_string:
.loop:
    lodsb
    cmp     al, 0
    je      .ret
    cmp     al, 10
    je      .new_line

    call    print_char
    jmp     .loop
.new_line:
    call    new_line
    jmp     .loop
.ret:
    ret

    section .data
ERROR_TITLE         db "Error:", 0
%endif
