# DunnOS

DunnoOS will be someday (or not) a multitasking OS.

## Building

**📦 Dependencies:**

- This project requires the [NASM](https://www.nasm.us/) assembler.
  - `sudo apt-get install nasm`
- make 
  - `sudo apt-get install make`
- grub
  - `sudo apt-get install grub-common`
  - `sudo apt-get install grub-pc-bin`
- xorisso
  - `sudo apt-get install xorriso`

After installing all dependencies:

    make

It will generate a `build/dunnos.iso` file that can be used into a
VM, emulator or you can even create a bootable USB drive and run in your
machine.

## Running

For testing purpouses I'm using [QEMU](https://www.qemu.org/) make sure
you have it installed before to proceed.

    qemu-system-x86_64 --cdrom ./build/dunnos.iso

## Main goals

- [x] Bootloader
    - [x] Multiboot
- [x] Entering protected mode (4 free with grub)
- [ ] Entering long mode
- [ ] Paging
- [ ] FAT filesystem
- [ ] Multitask
- [ ] X Server
