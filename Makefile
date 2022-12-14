##
# Dunnos

.PHONY = all

ASSEMBLER = nasm
ASSEMBLER_FLAGS = -f elf64 -I ./src

BOOTLOADER_FILES := src/boot/multiboot/multiboot_header.asm src/boot/boot.asm src/boot/kernel_init.asm
BOOTLOADER_BINS := $(BOOTLOADER_FILES:src/%.asm=build/%.o)

GRUB_CONFIG = src/boot/multiboot/grub.cfg

ISO_BUILD_PATH = build/iso
GRUB_PATH = ${ISO_BUILD_PATH}/boot/grub/
KERNEL_PATH = ${ISO_BUILD_PATH}/boot
KERNEL_BIN = ${KERNEL_PATH}/kernel.bin

RUST_TARGET = x86_64-unknown-none
RUST_PATH = src/kernel
RUST_KERNEL := ${RUST_PATH}/target/${RUST_TARGET}/debug/libkernel.a

ISO = build/dunnos.iso

all: ${ISO}

build/%.o: src/%.asm
	@echo "Compiling assembly file: $@"
	@mkdir -p ${shell dirname $@}
	@${ASSEMBLER} ${ASSEMBLER_FLAGS} $< -o $@

$(KERNEL_BIN): $(BOOTLOADER_BINS) $(RUST_KERNEL)
	@echo "Linking kernel: $@"
	@mkdir -p ${KERNEL_PATH}
	@ld -m elf_x86_64 -n -o ${KERNEL_BIN} -T linker.ld $^

$(RUST_TARGET):
	@echo "Fetching rust target"
	@rustup target install ${RUST_TARGET}

$(RUST_KERNEL):
	@echo "Building the rust kernel"
	@cd ${RUST_PATH}; cargo build --target=${RUST_TARGET}

$(ISO): $(KERNEL_BIN)
	@echo "Making ISO image: $@"
	@mkdir -p ${GRUB_PATH}
	@cp ${GRUB_CONFIG} ${GRUB_PATH}
	@grub-mkrescue -o ${ISO} ${ISO_BUILD_PATH}

# end
