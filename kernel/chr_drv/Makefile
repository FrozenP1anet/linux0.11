AR := ar
LD := ld
GCC := gcc
CCFLAG := -I../../include -nostdinc -Wall -fomit-frame-pointer -fno-pic -c -m32
OBJS := console.o tty_io.o

console.o: console.c
	$(GCC) $(CCFLAG) -o $@ $<

tty_io.o: tty_io.c
	$(GCC) $(CCFLAG) -o $@ $<

chr_drv.a: $(OBJS)
	$(AR) rcs $@ $^
	sync

clean:
	rm -f *.o
	rm -f chr_drv.a
