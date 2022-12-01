;;; Copyright (c) 2022 Maniero
org 0x7c00                      ; The place where the bootloader is loaded by bios
bits 16                         ; Real mode is 16 bits

jmp start

%include "boot/bios_services/stdout.asm"
%include "boot/bios_services/stdin.asm"
%include "boot/long_mode.asm"

;;; Application entrypoint
start:
    call    screen_clear

    mov     si, BOOTLOADER_WELCOME_MESSAGE
    call    print_string

    call    enter_long_mode

    hlt
    jmp     $

BOOTLOADER_WELCOME_MESSAGE:   db "Dunno Bootloader", 10, 13, 0
;;; BIOS signature
times 510 - ($ - $$) db 0       ; Bios signature is required at the end of the 512 bytes
dw 0xAA55                       ; Boot signature
