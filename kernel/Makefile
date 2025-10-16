GCC := gcc
# -m is required for targeting 32-bit architecture
CCFLAG := -I../include -nostdinc -Wall -fomit-frame-pointer -fno-pic -fno-stack-protector -c -m32
LDFLAG := -Ttext 0x0 -s --oformat binary -m elf_i386
OBJS := head.o main.o sched.o chr_drv/chr_drv.a printk.o vsprintf.o ../lib/lib.a ../mm/mm.o \
	sys_call.o asm.o traps.o

system: $(OBJS)
	$(LD) $(LDFLAG) -e startup_32 -o $@ $^

head.o: head.S
	$(GCC) -m32 -traditional -c -o $@ $<

sys_call.o : sys_call.S
	$(GCC) -m32 -traditional -c -o $@ $<

main.o: main.c
	$(GCC) $(CCFLAG) -o $@ $<

sched.o: sched.c
	$(GCC) $(CCFLAG) -o $@ $<

printk.o : printk.c
	$(GCC) $(CCFLAG) -o $@ $<

vsprintf.o : vsprintf.c
	$(GCC) $(CCFLAG) -o $@ $<

asm.o : asm.S
	$(GCC) -m32 -traditional -c -o $@ $<

traps.o : traps.c
	$(GCC) $(CCFLAG) -o $@ $<

chr_drv/chr_drv.a: chr_drv/*.c
	cd chr_drv; make chr_drv.a; cd ..

../lib/lib.a : ../lib/*.c
	cd ../lib; make lib.a; cd ../kernel

../mm/mm.o : ../mm/*.c
	cd ../mm; make mm.o; cd ..

clean:
	rm -f *.o
	rm -f system
	cd chr_drv; make clean; cd ..
	cd ../lib; make clean; cd ../kernel
	cd ../mm; make clean; cd ../kernel
