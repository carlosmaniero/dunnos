# DunnOS

DunnoOS will be someday (or not) a multitasking OS.

## Building

**📦 Dependencies:** This project requires the [NASM](https://www.nasm.us/) assembler.

After installing it:

    ./build.sh

It will generate a `boot.bin` file that can be used into a
VM, emulator or you can even create a bootable USB drive and run in your
machine. Make sure **Legacy Boot** is enabled.

## Running

For testing purpouses I'm using [QEMU](https://www.qemu.org/) make sure
you have it installed before to proceed.

    qemu-system-x86_64 -hda boot.bin

## Main goals

- [x] Bootloader
    - [x] Legacy
    - [ ] Multiboot
- [ ] Entering real mode
- [ ] Entering long mode
- [ ] Paging
- [ ] FAT filesystem
- [ ] Multitask
- [ ] X Server
