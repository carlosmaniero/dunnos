#!/usr/bin/env sh

nasm -f bin \
     -I src/boot/legacy_boot \
     -o boot.bin \
     src/boot/legacy_boot/main.asm
