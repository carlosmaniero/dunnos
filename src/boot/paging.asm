;;; Copyright (c) 2022 Maniero

;;; - enable paging:
;;;     - Enable paging cr0.PG = 1 (31 bit) (must be enabled after enabling 4 level page)
;;;     - Enable protection cr0.PE = 1 (0 bit)
;;;     - 4 level page:
;;;         - cr4.PAE = 1 (5 bit)
;;;         - cr4.PCIDE = 0 (17 bit) Disable PCIDE since it will require some complex strategy implementation
;;;         - cr4.LA57 = 0 (12 bit) (to disable 5-level paging)
;;;         - ia32_efer.LME = 1 (To see later maybe it is the default value)
;;;         - each paging structure comprises 512 = 29 entries and translation uses 9 bits at a time
;;;           - from a 48-bit linear address. Bits 47:39 identify the first paging-structure entry, bits 38:30 identify a second,
;;;             bits 29:21 a third, and bits 20:12 identify a fourth. Again, the last identifies the page frame.
;;;
;;; Kernel Higher-Half
;;; ===========================================================================
;;;
;;; Higher-half is used to make the kernel available for every process, since
;;; with higher-half, the kernel does not needs to swap CR4 register to perform
;;; kernel tasks such as syscall interruptions.
;;;
;;; +----------------------------------+
;;; | Kernel address:                  |
;;; |------------------+---------------|
;;; | virtual address  | 0x000C0000000 |
;;; | physical address | 0x00000100000 |
;;; +------------------+---------------+
;;;
;;; Paging:
;;;
;;; DunnOS, for now implements PML4. The follow table is the
;;; address-translation of the initial kenel's position:
;;;
;;; First we need to translate the hex location position to binary:
;;;
;;; +--------------+-----------------------------------------+
;;; | Hex position | C    0    0    0    0    0    0    0    |
;;; | Bin position | 1100 0000 0000 0000 0000 0000 0000 0000 |
;;; +--------------+-----------------------------------------+
;;;
;;; After we need to group the the bits where every group represents a page level:
;;;
;;; +----------------------------+--------+------+
;;; | Level | Level name         | range  | bits |
;;; +-------+--------------------+--------+------+
;;; |     0 | Page offset        | 00..11 | 12   |
;;; |     1 | Page table         | 12..20 | 09   |
;;; |     2 | Page directory     | 21..29 | 09   |
;;; |     3 | Page directory ptr | 30..38 | 09   |
;;; |     4 | PML4               | 39..47 | 09   |
;;; +-------+--------------------+--------+------+
;;;
;;; Applying this to DunnOS kernel entrypoint:
;;;
;;; +----------------------------------------------------------------------+
;;; | level | PML4      | dir ptr   | directory | table     | offset       |
;;; |-------+-----------+-----------+-----------+-----------+--------------|
;;; | bin   | 000000000 | 000000011 | 000000000 | 000000000 | 000000000000 |
;;; | pos   | 47 ... 39 | 38 ... 30 | 29 ... 21 | 20 ... 12 | 11   ...   0 |
;;; | total | 9 bits    | 9 bits    | 9 bits    | 9 bits    | 12 bits      |
;;; +-------+-----------+-----------+-----------+-----------+--------------+
;;;
;;; The scheme above concludes that, the first kernel page is available at:
;;;
;;; +-------------------+---+
;;; | PML4              | 0 |
;;; | Directory Pointer | 3 |
;;; | Directory:        | 0 |
;;; | Table:            | 0 |
;;; +-------------------+---+
;;;
;;; Virtual page layout
;;; ================================================================================
;;;
;;; This is the DunnOS virtual page layout:
;;;
;;; +-----------------------------------------------+------+
;;; | start      | end        | description         | size |
;;; +-----------------------------------------------+------+
;;; | 0x00000000 | 0x000FFFFF | multiloader and vga | 1M   |
;;; | ...        | ...        | ...                 | ...  |
;;; | 0xC0000000 | 0xC01FFFFF | DunnOS Kernel       | 2M   |
;;; +-----------------------------------------------+------+
;;;
%ifndef BOOT_PAGING
    %define BOOT_PAGING
%include "boot/kernel_constants.asm"

C4_PAE              equ 1 << 5  ; Physical Address Extension: more than 32 bits
C4_PCIDE            equ 1 << 17 ; process-context identifiers (intel 4.10.1 Process-Context Identifiers (PCIDs))
C4_LA57             equ 1 << 12 ; Enables 5-level paging

PAGE_PRESENT        equ 1 << 0
PAGE_WRITABLE       equ 1 << 1
PAGE_SUPERVISOR     equ 1 << 2

PAGE_SIZE           equ 0x1000  ; 4Kb

PML4_TO_PDPTE_FLAGS equ PAGE_PRESENT | PAGE_WRITABLE | PAGE_SUPERVISOR
PDPTE_TO_PDE_FLAGS  equ PAGE_PRESENT | PAGE_WRITABLE | PAGE_SUPERVISOR
PDE_TO_PTABLE_FLAGS equ PAGE_PRESENT | PAGE_WRITABLE | PAGE_SUPERVISOR
PTABLE_FLAGS        equ PAGE_PRESENT | PAGE_WRITABLE | PAGE_SUPERVISOR

    section .text
enable_paging:
    call    setup_page_table
    ret

setup_page_table:
    ;; first ptml4 -> pdpte
    lea     eax, [paging.pdpte - KERNEL_POSITION]
    or      eax, PML4_TO_PDPTE_FLAGS
    mov     [paging.pml4 - KERNEL_POSITION], eax

    ;; first pdpte -> identity pde
    lea     eax, [paging.identity_pde - KERNEL_POSITION]
    or      eax, PDPTE_TO_PDE_FLAGS
    mov     [paging.pdpte - KERNEL_POSITION], eax

    ;; identity pde -> identity ptable
    lea     eax, [paging.identity_ptable - KERNEL_POSITION]
    or      eax, PDE_TO_PTABLE_FLAGS
    mov     [paging.identity_pde - KERNEL_POSITION], eax

    mov     ecx, 0
.identity_ptable_map_loop:
    mov     eax, ecx
    mov     ebx, PAGE_SIZE
    mul     ebx
    or      eax, PTABLE_FLAGS
    lea     ebx, [paging.identity_ptable - KERNEL_POSITION + 8 * ecx]
    mov     [ebx], eax
    inc     ecx
    cmp     ecx, 256            ; 1MB
    jne     .identity_ptable_map_loop

    jmp     $

    ;; =================
    ;; end section .text

    section .bss
align PAGE_SIZE          ; 4KB (this ensures the last twelve bits are all zeros)
paging:
.pml4:
    resq    512
.pdpte:
    resq    512
.identity_pde:
    resq    512
.identity_ptable:
    resq    512
.kernel_pde:
    resq    512
.kernel_ptable:
    resq    512
.end:
%endif
