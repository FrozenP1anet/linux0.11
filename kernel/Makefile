GCC := gcc
# -m is required for targeting 32-bit architecture
CCFLAG := -I../include -nostdinc -Wall -fomit-frame-pointer -fno-pic -c -m32
LDFLAG := -Ttext 0x0 -s --oformat binary -m elf_i386
OBJS := head.o main.o sched.o

system: $(OBJS)
	$(LD) $(LDFLAG) -e startup_32 -o $@ $^

head.o: head.S
	$(GCC) -m32 -traditional -c -o $@ $<

main.o: main.c
	$(GCC) $(CCFLAG) -o $@ $<

sched.o: sched.c
	$(GCC) $(CCFLAG) -o $@ $<

clean:
	rm *.o
	rm system
