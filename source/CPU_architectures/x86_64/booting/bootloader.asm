global start            ;set access label of address for linking
extern long_mode_start

section .text

bits 32

start:
    mov esp, topofstack ;where to begin accessing reserved space for OS specific modules

    call check_multiboot_compatibility
    call check_cpuid
    call check_longmode_compatibility

    call setup_page_tables
    call enable_paging

    lgdt [gdt64.pointer]
    jmp gdt64.code_segment:long_mode_start

    mov al, "B"
    jmp error           ;if it got here... (boot) error

check_multiboot_compatibility:
    cmp eax, 0x36d76289 ;ensure multiboot compatible at boot
    jne .not_multiboot_compatible
    ret
.not_multiboot_compatible:
    mov al, "M"
    jmp error

check_cpuid:
    pushfd              ;get flags onto stack
    pop eax             ;get flags from stack
    mov ecx, eax
    xor eax, 1 << 21    ;flips bit 21 into position
    push eax
    popfd
    pushfd
    pop eax
    push ecx
    popfd
    cmp eax, ecx        ;if state not changed
    je .no_cpuid
    ret
.no_cpuid:
    mov al, "C"
    jmp error

check_longmode_compatibility:
    mov eax, 0x80000000 ;argument for cpuid hosting longmode support (extended)
    cpuid
    cmp eax, 0x80000001
    jb .not_longmode_compatible

    mov eax, 0x80000001
    cpuid
    test edx, 1 << 29
    jz .not_longmode_compatible
    ret
.not_longmode_compatible:
    mov al, "L"
    jmp error

setup_page_tables:
    mov eax, page_table_l3
    or eax, 0b11        ;present, writable
    mov [page_table_l4], eax

    mov eax, page_table_l2
    or eax, 0b11        ;present, writable
    mov [page_table_l3], eax

    mov ecx, 0          ;counter
.loop:
    mov eax, 0x200000   ;2MiB
    mul ecx
    
    or eax, 0b10000011  ;present, writable
    mov [page_table_l2 + ecx * 8], eax

    inc ecx
    cmp ecx, 512        ;is entire page table mapped?
    jne .loop
    ret

enable_paging:
                        ;get page table location to cpu
    mov eax, page_table_l4
    mov cr3, eax
                        ;enable physical address extension (64bit paging)
    mov eax, cr4
    or eax, 1 << 5
    mov cr4, eax
                        ;enable long mode
    mov ecx, 0xC0000080
    rdmsr
    or eax, 1 << 8
    wrmsr
                        ;enable paging
    mov eax, cr0
    or eax, 1 << 31
    mov cr0, eax
    ret

error:
    mov dword [0xb8000], 0x4f524f45
    mov dword [0xb8004], 0x4f3a4f52
    mov dword [0xb8008], 0x4f204f20
    mov byte [0xb800a], al
    hlt

section .bss

align 4096
page_table_l4:
    resb 4096
page_table_l3:
    resb 4096
page_table_l2:
    resb 4096

bottomofstack:
    resb 4096 * 4
topofstack:

section .rodata         ;read only data section
gdt64:
    dq 0                ;zero entry
.code_segment: equ $ - gdt64                          ;store this address:
    dq (1 << 43) | (1 << 44 ) | (1 << 47) | (1 << 53) ;code segment
.pointer:
    dw $ - gdt64 - 1    ;current mem address, or end of table - start aka addr gdt64 (label)
    dq gdt64            ;store label pointer, else never ending loop