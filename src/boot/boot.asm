global start

VGA_START               equ 0xb8000
VGA_ROW                 equ 80
VGA_END                 equ VGA_START + VGA_ROW * 25 * 2
VGA_ERROR_SCREEN_COLOR  equ 0x3F
KERNEL_POSITION         equ 0xc0000000

bits 32

    section .text
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

    call    print_char
    jmp     .loop
.ret:
    ret

;;; Prints a fatal error
;;;
;;; ESI: String pointer to error code
;;; EDI: string pointer to error description
blue_screen:
    call    clean_screen

    push    edi
    push    esi
    mov     edi, VGA_START
    lea     esi, [ERROR_TITLE - KERNEL_POSITION]
    mov     ah, 0xCF
    call    print_string

    mov     ah, 0xFC
    mov     al, ' '
    call    print_char

    pop     esi
    call    print_string

    pop     esi
    mov     edi, VGA_START + VGA_ROW * 2 * 2
    mov     ah, 0x3F
    call    print_string

    hlt

start:
    lea esi, [ERROR_NO_CPUID_CODE - KERNEL_POSITION]
    lea edi, [ERROR_NO_CPUID_MSG - KERNEL_POSITION]
    jmp blue_screen

    section .data
ERROR_TITLE         db "Error:", 0
ERROR_NO_CPUID_CODE db "0x00010000 NoCPUID", 0
ERROR_NO_CPUID_MSG  db "Sorry! It means your hardware is not compatible with DunnOS :(", 0

    section .bss
stack_bottom:
    resb 64
stack_top:
