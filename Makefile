x86_64_asm_sources := $(shell find source/CPU_architectures/x86_64/booting -name *.asm)
x86_64_asm_objects := $(patsubst source/CPU_architectures/x86_64/%.asm, output/x86_64/%.o, $(x86_64_asm_sources))

x86_64_c_sources := $(shell find source/CPU_architectures/x86_64/ -name *.c)
x86_64_c_objects := $(patsubst source/CPU_architectures/x86_64/%.c, output/x86_64/%.o, $(x86_64_c_sources))

kernel_c_sources := $(shell find source/kernel -name *.c)
kernel_c_objects := $(patsubst source/kernel/%.c, output/kernel/%.o, $(kernel_c_sources))

x86_64_objects_all := $(x86_64_asm_objects) $(x86_64_c_objects)

$(x86_64_asm_objects): output/x86_64/%.o : source/CPU_architectures/x86_64/%.asm
	mkdir -p $(dir $@) && \
	nasm -f elf64 $(patsubst output/x86_64/%.o, source/CPU_architectures/x86_64/%.asm, $@) -o $@

$(x86_64_c_objects): output/x86_64/%.o : source/CPU_architectures/x86_64/%.c
	mkdir -p $(dir $@) && \
	x86_64-elf-gcc -c -I source/interfaces -ffreestanding $(patsubst output/x86_64/%.o, source/CPU_architectures/x86_64/%.c, $@) -o $@

$(kernel_c_objects): output/kernel/%.o : source/kernel/%.c
	mkdir -p $(dir $@) && \
	x86_64-elf-gcc -c -I source/interfaces -ffreestanding $(patsubst output/kernel/%.o, source/kernel/%.c, $@) -o $@

.PHONY: buildx86_64
buildx86_64: $(x86_64_objects_all) $(kernel_c_objects)
	mkdir -p compiled/x86_64 && \
	x86_64-elf-ld -n -o compiled/x86_64/kernel.bin -T source/linking/CPU_architectures/x86_64/linker.ld $(x86_64_objects_all) $(kernel_c_objects) && \
	cp compiled/x86_64/kernel.bin source/linking/CPU_architectures/x86_64/iso/boot/kernel.bin
	grub-mkrescue /usr/lib/grub/i386-pc -o output/x86_64/kernel.iso source/linking/CPU_architectures/x86_64/iso