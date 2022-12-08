;;; Copyright (c) 2022 Maniero
%ifndef BOOT_LONG_MODE
    %define BOOT_LONG_MODE

    section .text
;;; Check if long mode is available
;;;
;;; return:
;;; AL 0 = Not Available
;;; AL 1 = Available
detect_long_mode:
    ; test if extended processor info in available
    mov     eax, 0x80000000     ; implicit argument for cpuid
    cpuid                       ; get highest supported argument
    cmp     eax, 0x80000001     ; it needs to be at least 0x80000001
    jb      .no_long_mode       ; if it's less, the CPU is too old for long mode

    ; use extended info to test if long mode is available
    mov     eax, 0x80000001     ; argument for extended processor info
    cpuid                       ; returns various feature bits in ecx and edx
    test    edx, 1 << 29        ; test if the LM-bit is set in the D-register
    jz      .no_long_mode       ; If it's not set, there is no long mode
    mov     al, 1
    ret
.no_long_mode:
    mov     al, 0
    ret
%endif
