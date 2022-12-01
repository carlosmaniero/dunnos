;;; Copyright (c) 2022 Maniero
%ifndef BOOT_CPUID
    %define BOOT_CPUID

detect_cpuid:
    pushfd                      ; Store the original EFLAGS
    pushfd                      ; Store EFLAGS that will be changed
    xor dword [esp], 1 << 21    ; Invert the ID bit in stored EFLAGS
    popfd                       ; Load stored EFLAGS (with ID bit inverted)
    pushfd                      ; Store EFLAGS again (ID bit may or may not be inverted)
    pop eax                     ; eax = modified EFLAGS (ID bit may or may not be inverted)
    xor eax, [esp]              ; eax = whichever bits were changed
    popfd                       ; Restore original EFLAGS
    and eax, 1 << 21            ; eax = zero if ID bit can't be changed, else non-zero
    ret

%endif
