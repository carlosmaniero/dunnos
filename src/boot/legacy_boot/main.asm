org 0x7c00                      ; The place where the bootloader is loaded by bios
bits 16                         ; Real mode is 16 bits

jmp start

%include "./stdout.asm"

start:
    call    screen_clear

    mov     si, BOOTLOADER_WELCOME_MESSAGE
    call    print_msg

    hlt
    jmp     $

;;; Constants
DEBUG_MODE_ENABLED:         db 1

BOOTLOADER_WELCOME_MESSAGE: db "Dunno if it gonna start but I gonna try...", 10, 13, 0

;;; BIOS signature
times 510 - ($ - $$) db 0       ; Bios signature is required at the end of the 512 bytes
dw 0xAA55                       ; Boot signature
