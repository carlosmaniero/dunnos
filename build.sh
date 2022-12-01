#!/usr/bin/env sh

nasm -f bin \
     -I src/ \
     -o boot.bin \
     src/boot/legacy_boot/main.asm
