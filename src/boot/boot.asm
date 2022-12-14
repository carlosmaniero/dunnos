;;; Copyright (c) 2022 Maniero
global start
bits 32

%include "boot/kernel_constants.asm"

%include "boot/video_services/vga.asm"
%include "boot/video_services/blue_screen.asm"

%include "boot/cpuid.asm"
%include "boot/long_mode.asm"
%include "boot/paging.asm"

extern kernel_init

    section .text
start:
    mov esp, stack_top - KERNEL_POSITION
    ;; TODO: try to simulate this behaviour
    call    detect_cpuid
    cmp     al, 0
    je      no_cpuid

    call    detect_long_mode
    cmp     al, 0
    je      no_long_mode

    call    enable_paging

    mov     eax, enable_gdt
    jmp     eax

enable_gdt:
    lgdt    [gdt64.pointer]

    jmp     gdt64.code:kernel_init
    hlt


no_cpuid:
    lea esi, [ERROR_NO_CPUID_CODE - KERNEL_POSITION]
    lea edi, [ERROR_NO_CPUID_MSG - KERNEL_POSITION]
    jmp blue_screen

no_long_mode:
    lea esi, [ERROR_NO_LONG_MODE_CODE - KERNEL_POSITION]
    lea edi, [ERROR_NO_LONG_MODE_MSG - KERNEL_POSITION]
    jmp blue_screen
    ;; end section .text

    section .data
ERROR_NO_CPUID_CODE     db "0x00010000 CPUID not available", 0
ERROR_NO_CPUID_MSG      db "Sorry! It means your hardware is not compatible with DunnOS :(", 0

ERROR_NO_LONG_MODE_CODE db "0x00010001 Long mode not available", 0
ERROR_NO_LONG_MODE_MSG  db "It seems you are trying to running DunnOS in a non x86 64 bits machine.", 10, "DunnOS is 64 bits only :(", 0
    ;; end section .data

    section .bss
stack_bottom:
    resb 64
stack_top:
    ;; end section .bss

    section .rodata
align 8
gdt64:
    dq 0 ; zero entry
.code: equ $ - gdt64 ; new
    dq (1<<43) | (1<<44) | (1<<47) | (1<<53) ; code segment
.pointer:
    dw $ - gdt64 - 1
    dq gdt64 - KERNEL_POSITION
