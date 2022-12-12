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
;;; |----------------------------------|
;;; | virtual address  | 0x000C0000000 |
;;; | physical address | 0x00000100000 |
;;; +----------------------------------+
;;;
;;; Paging:
;;;
;;; DunnOS, for now implements PML4. The follow table is the
;;; address-translation of the initial kenel's position:
;;;
;;; First we need to translate the hex location position to binary:
;;;
;;; +--------------------------------------------------------+
;;; | Hex position | C    0    0    0    0    0    0    0    |
;;; | Bin position | 1100 0000 0000 0000 0000 0000 0000 0000 |
;;; +--------------------------------------------------------+
;;;
;;; After we need to group the the bits where every group represents a page level:
;;;
;;; +--------------------------------------------+
;;; | Level | Level name         | range  | bits |
;;; +--------------------------------------------+
;;; |     0 | Page offset        | 00..11 | 12   |
;;; |     1 | Page table         | 12..20 | 09   |
;;; |     2 | Page directory     | 21..29 | 09   |
;;; |     3 | Page directory ptr | 30..38 | 09   |
;;; |     4 | PML4               | 39..47 | 09   |
;;; +--------------------------------------------+
;;;
;;; Applying this to DunnOS kernel entrypoint:
;;;
;;; +----------------------------------------------------------------------+
;;; | level | PML4      | dir ptr   | directory | table     | offset       |
;;; |----------------------------------------------------------------------|
;;; | bin   | 000000000 | 000000011 | 000000000 | 000000000 | 000000000000 |
;;; | pos   | 47 ... 39 | 38 ... 30 | 29 ... 21 | 20 ... 12 | 11   ...   0 |
;;; | total | 9 bits    | 9 bits    | 9 bits    | 9 bits    | 12 bits      |
;;; +----------------------------------------------------------------------+
;;;
;;; 0xFFFFFFF
;;; The scheme above concludes that, the first kernel page is available at:
;;;
;;; PML4: 0
;;; Directory Pointer: 3
;;; Directory: 0
;;; Table: 0
;;;
%ifndef BOOT_PAGING
    %define BOOT_PAGING
C4_PAE      equ 1 << 5          ; Physical Address Extension: more than 32 bits
C4_PCIDE    equ 1 << 17         ; process-context identifiers (intel 4.10.1 Process-Context Identifiers (PCIDs))
C4_LA57     equ 1 << 12         ; Enables 5-level paging

    section .text

enable_paging:
    mov     eax, cr4
    or      eax, C4_PAE         ; Enable (Physical Address Extension)
    xor     eax, C4_PCIDE       ; Disables process-context identifier
    xor     eax, C4_LA57        ; Disables 5-level paging
    mov     cr4, eax

    section .bss
align 4096
paging:
.pml4:
    resq    512
.pdpte:
    resq    512
.pde:
    resq    512
.ptable:
    resq    512 * 3
%endif
