section .multiboot2_header

startheader:
    dd 0xe85250d6               ;multiboot2 mag num
    dd 0                        ;protected mode i386 
    dd endheader - startheader  ;get length
    dd 0x100000000 - (0xe85250d6 + 0 + (endheader - startheader))

                                ;clear data
    dw 0
    dw 0
    dd 8
endheader: