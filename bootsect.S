BOOTSEG = 0x7c0

INITSEG = 0x9000

SETUPLEN = 4

SETUPSEG = 0x9020

ROOT_DEV = 0x000

.code16
.text

.global _start
_start:
    jmpl $BOOTSEG, $start2

start2:
    # Move bootsect from 0x07c00 to 0x90000
    movw $BOOTSEG, %ax
    movw %ax, %ds
    movw $INITSEG, %ax
    movw %ax, %es
    movw $256, %cx
    subw %si, %si
    subw %di, %di

    rep 
    movsw

    jmpl $INITSEG, $go

go:
    movw %cs, %ax
    movw %ax, %ds
    movw %ax, %es
    movw %ax, %ss
    movw $0xff00, %sp

load_setup:
    # Load setup module to memory
    movw $0x0000, %dx
    movw $0x0002, %cx   # Read sector 2
    movw $0x0200, %bx   # Data store location INITSEG:0x200
    movb $SETUPLEN, %al # Read 4 sector (sec2, 3, 4, 5)
    movb $0x02, %ah     # Function number 2 (Read from sector to memory)
    int $0x13
    jnc ok_load_setup
    movw $0x0000, %dx
    movw $0x0000, %ax   # Reset disk
    int $0x13
    jmp load_setup

ok_load_setup:
    # Display $mag
    movw $msg, %ax
    movw %ax, %bp
    movw $0x1301, %ax
    movw $0x0c, %bx
    movw $21, %cx
    movb $0, %dl
    int $0x10

    jmpl $SETUPSEG, $0

msg:
.ascii "Setup has been loaded"

.org 508
root_dev:
    .word ROOT_DEV
boot_flag:
    .word 0xaa55    # Boot signature
