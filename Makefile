##
# Dunnos

.PHONY = all

ASSEMBLER = nasm
ASSEMBLER_FLAGS = -f elf64

BOOTLOADER_FILES := src/boot/multiboot/multiboot_header.asm src/boot/boot.asm
BOOTLOADER_BINS := $(BOOTLOADER_FILES:src/%.asm=build/%.o)

GRUB_CONFIG = src/boot/multiboot/grub.cfg

ISO_BUILD_PATH = build/iso
GRUB_PATH = ${ISO_BUILD_PATH}/boot/grub/
KERNEL_PATH = ${ISO_BUILD_PATH}/boot
KERNEL_BIN = ${KERNEL_PATH}/kernel.bin

ISO = build/dunnos.iso

all: ${ISO}

build/%.o: src/%.asm
	@echo "Compiling assembly file: $@"
	@mkdir -p ${shell dirname $@}
	@${ASSEMBLER} ${ASSEMBLER_FLAGS} $< -o $@

$(KERNEL_BIN): $(BOOTLOADER_BINS)
	@echo "Create kernel bin: $@"
	@mkdir -p ${KERNEL_PATH}
	@ld -n -o ${KERNEL_BIN} -T linker.ld $^

$(ISO): $(KERNEL_BIN)
	@echo "Making ISO image: $@"
	@mkdir -p ${GRUB_PATH}
	@cp ${GRUB_CONFIG} ${GRUB_PATH}
	@grub-mkrescue -o ${ISO} ${ISO_BUILD_PATH}

# end
