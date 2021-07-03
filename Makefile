x86_64_asm_sources := $(shell find source/CPU_architectures/x86_64/booting -name *.asm)
x86_64_asm_objects := $(patsubst source/CPU_architectures/x86_64/%.asm, output/x86_64/%.o, $(x86_64_asm_sources))

$(x86_64_asm_objects): output/x86_64/%.o : source/CPU_architectures/x86_64/%.asm
	mkdir -p $(dir $@) && \
	nasm -f elf64 $(patsubst output/x86_64/%.o, source/CPU_architectures/x86_64/%.asm, $@) -o $@

.PHONY: buildx86_64
buildx86_64: $(x86_64_asm_objects)
	mkdir -p compiled/x86_64 && \
	x86_64-elf-ld -n -o compiled/x86_64/kernel.bin -T source/linking/CPU_architectures/x86_64/linker.ld $(x86_64_asm_objects) && \
	cp compiled/x86_64/kernel.bin source/linking/CPU_architectures/x86_64/iso/boot/kernel.bin
	grub-mkrescue /usr/lib/grub/i386-pc -o output/x86_64/kernel.iso source/linking/CPU_architectures/x86_64/iso