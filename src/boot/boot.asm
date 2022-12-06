global start

VGA_START equ 0xb8000
VGA_END   equ VGA_START + 80 * 25 * 2
VGA_DEFAULT_COLOR equ 0x3000

bits 32

    section .text
clean_screen:
    mov   eax, VGA_START
.loop:
    mov   word [eax], VGA_DEFAULT_COLOR + ' '
    add   eax, 2
    cmp   eax, VGA_END
    jne   .loop
    ret
; Prints `ERR: ` and the given error code to screen and hangs.
; parameter: error code (in ascii) in al
print_error:
    call    clean_screen
    mov     dword [0xb8000], 0xCF72CF45
    mov     dword [0xb8004], 0xCF3ACF72
    mov     word  [0xb8008], 0xFC20
    mov     ebx, 0xb800a
    mov     ah, 0xFC
.loop:
    lodsb
    cmp     al, 0
    je      .hang

    mov     word [ebx], ax

    add     ebx, 2
    jmp     .loop
.hang:
    hlt
start:
    lea esi, [ERROR_CODE_NO_CPUID - 0xc0000000]
    jmp print_error

    section .data
ERROR_CODE_NO_CPUID db "0x00010000 NoCPUID", 0

    section .bss
stack_bottom:
    resb 64
stack_top:
