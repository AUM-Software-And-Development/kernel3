global start         ;set access label of address for linking

section .text

bits 32

start:
    mov al, 100
    mov byte [0xb8000], al
    hlt