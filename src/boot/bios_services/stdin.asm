;;; Copyright (c) 2022 Maniero
%ifndef BOOT_BIOS_SERVICE_STDIN
    %define BOOT_BIOS_SERVICE_STDIN
;;; Read a char from the keyboard
;;; It halts the program until a key is pressed
;;;
;;; on return:
;;; AH = keyboard scan code
;;; AL = ASCII character or zero if special function keu
read_char:
    xor     ah, ah
    int     0x16
    ret
%endif
