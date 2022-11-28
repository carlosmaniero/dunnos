org 0x7c00                      ; The place where the bootloader is loaded by bios
bits 16                         ; Real mode is 16 bits

jmp start

%include "./stdout.asm"

start:
    call    screen_clear

    mov     si, BOOTLOADER_WELCOME_MESSAGE
    call    print_msg

    call    print_debug_status

    hlt
    jmp     $

print_debug_status:
    cmp     byte [DEBUG_MODE_ENABLED], 1
    jne     .set_disabled_message

    mov     si, BOOTLOADER_DEBUG_ON_MESSAGE
    jmp     .print
.set_disabled_message:
    mov     si, BOOTLOADER_DEBUG_OFF_MESSAGE
.print:
    call    print_msg
    ret



;;; Constants
DEBUG_MODE_ENABLED:           db 1

BOOTLOADER_WELCOME_MESSAGE:   db "Dunno Bootloader", 10, 13, 0

BOOTLOADER_DEBUG_ON_MESSAGE:  db "Debug: Enabled", 10, 13, 0
BOOTLOADER_DEBUG_OFF_MESSAGE: db "Debug: Disabled", 10, 13, 0

;;; BIOS signature
times 510 - ($ - $$) db 0       ; Bios signature is required at the end of the 512 bytes
dw 0xAA55                       ; Boot signature
