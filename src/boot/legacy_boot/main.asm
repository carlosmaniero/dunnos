;;; Copyright (c) 2022 Maniero
org 0x7c00                      ; The place where the bootloader is loaded by bios
bits 16                         ; Real mode is 16 bits

jmp start

%include "./stdout.asm"
%include "./stdin.asm"

;;; Application entrypoint
start:
    call    screen_clear

    mov     si, BOOTLOADER_WELCOME_MESSAGE
    call    print_string

    call    print_debug_status

    call    breakpoint

    call    print_nl

    hlt
    jmp     $

;;; Print the debug message
print_debug_status:
    pusha
    cmp     byte [DEBUG_MODE_ENABLED], 1
    jne     .set_disabled_message

    mov     si, BOOTLOADER_DEBUG_ON_MESSAGE
    jmp     .print
.set_disabled_message:
    mov     si, BOOTLOADER_DEBUG_OFF_MESSAGE
.print:
    call    print_string
    popa
    ret

;;; Show a breakpoint message and wait for a keypress
;;; It only stops when debug mode is enabled
breakpoint:
    pusha
    cmp     byte [DEBUG_MODE_ENABLED], 0
    je      .ret

    mov     si, BOOTLOADER_DEBUG_BREAKPOINT
    call    print_string

    call    read_char
.ret
    popa
    ret

;;; Constants
DEBUG_MODE_ENABLED:           db 1

BOOTLOADER_WELCOME_MESSAGE:   db "Dunno Bootloader", 10, 13, 0

BOOTLOADER_DEBUG_ON_MESSAGE:  db "Debug: Enabled", 10, 13, 0
BOOTLOADER_DEBUG_OFF_MESSAGE: db "Debug: Disabled", 10, 13, 0

BOOTLOADER_DEBUG_BREAKPOINT:  db "Breakpoint... press any key to continue..."

;;; BIOS signature
times 510 - ($ - $$) db 0       ; Bios signature is required at the end of the 512 bytes
dw 0xAA55                       ; Boot signature
