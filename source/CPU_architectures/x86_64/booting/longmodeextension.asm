global long_mode_start
extern kernel_main

section .text

bits 64

long_mode_start:
    mov ax, 0
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax

    mov dword [0xb8000], 0x000b8000 ;if it got here... success

    call kernel_main                ;calls kernel_main external function entry in kernel dir

    hlt