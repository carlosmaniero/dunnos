;;; Copyright (c) 2022 Maniero

;;; Multiboot spec: https://www.gnu.org/software/grub/manual/multiboot2/multiboot.html
BOOTLOADER2_MAGIC_NUMBER equ 0xE85250D6
BOOTLOADER2_ARCHITECTURE equ 0x0 ; i386 protected mode
BOOTLOADER2_HEADER_LEN   equ multiboot_header_start - multiboot_header_end
BOOTLOADER2_CHECKSUM     equ 0x100000000 - (BOOTLOADER2_MAGIC_NUMBER + BOOTLOADER2_ARCHITECTURE + BOOTLOADER2_HEADER_LEN)

    section .multiboot_header
multiboot_header_start:
    dd BOOTLOADER2_MAGIC_NUMBER ; magic
    dd BOOTLOADER2_ARCHITECTURE ; architecture
    dd BOOTLOADER2_HEADER_LEN   ; header_length
    dd BOOTLOADER2_CHECKSUM     ; when added to the previous values, must have a 32-bit unsigned sum of zero

multiboot_header_tags:
multiboot_header_terminate_tag:
    ;; Tags are terminated by a tag of type ‘0’ and size ‘8’.
    dw 0                        ; type
    dw 0                        ; flags
    dd 8                        ; size
multiboot_header_end:
