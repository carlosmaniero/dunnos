#!/usr/bin/env sh

nasm -f bin \
     -I src/ \
     -o boot.bin \
     src/boot/legacy_boot/main.asm

nasm -f elf64 src/boot/multiboot/multiboot_header.asm -o multiboot_header.o
nasm -f elf64 src/boot/boot.asm -o boot.o

ld -n -o iso/boot/kernel.bin -T linker.ld multiboot_header.o boot.o

grub-mkrescue -o os.iso iso --verbose

rm *.o
rm iso/boot/kernel.bin
