;;; Copyright (c) 2022 Maniero
%ifndef BOOT_LONG_MODE
    %define BOOT_LONG_MODE

%include "boot/cpuid.asm"
%include "boot/bios_services/stdout.asm"

enter_long_mode:
    pusha
    mov     si, DETECTING_CPUID_MESSAGE
    call    print_string

    call    detect_cpuid
    je      long_mode_not_available

    mov     si, CPUID_AVAILABLE_MESSAGE
    call    print_string

    ret

long_mode_not_available:
    mov     si, CPUID_NOT_AVAILABLE_MESSAGE
    call    print_string

DETECTING_CPUID_MESSAGE db "Detecting CPUID: ", 0
CPUID_AVAILABLE_MESSAGE db "Available", 10, 13, 0
CPUID_NOT_AVAILABLE_MESSAGE db "Not available", 10, 13, 0
%endif
