all:
	as -o bootsect.o bootsect.S
	ld -m elf_x86_64 -Ttext 0x0 -s --oformat binary -o linux.img bootsect.o

clean:
	rm -f bootsect.o linux.img
