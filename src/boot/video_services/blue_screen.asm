;;; Copyright (c) 2022 Maniero
%ifndef BOOT_VIDEO_SERVICES_BLUE_SCREEN
    %define BOOT_VIDEO_SERVICES_BLUE_SCREEN
%include "boot/video_services/vga.asm"
%include "boot/kernel_constants.asm"

VGA_ERROR_SCREEN_COLOR  equ 0x3F

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
%endif
