GCC := gcc
CCFLAG := -I../include -nostdinc -Wall -fomit-frame-pointer -c
LDFLAG := -Ttext 0x0 -s --oformat binary
OBJS := head.o main.o

system: $(OBJS)
	$(LD) $(LDFLAG) -e startup_32 -o $@ $^

head.o: head.S
	$(GCC) -traditional -c -o $@ $<

main.o: main.c
	$(GCC) $(CCFLAG) -o $@ $<

clean:
	rm *.o
	rm system
