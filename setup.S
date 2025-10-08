INITSEG = 0x9000

SETUPSEG = 0x9020

.code16
.text

.globl _start_setup

_start_setup:
    movw %cs, %ax
    movw %ax, %ds
    movw %ax, %es

    # Display $msg
    movw $setup_msg, %ax
    movw %ax, %bp
    movw $0x1301, %ax
    movw $0x0c, %bx # Red
    movw $16, %cx   # Char number
    movb $0, %dl    # Column
    movb $3, %dh    # Row
    int $0x10

    # Get hardware info
    movw $INITSEG, %ax
    movw %ax, %ds
    movb $0x03, %ah
    xor %bh, %bh
    int $0x10
    movw %dx, (0)
    movb $0x88, %ah
    int $0x15
    movw %ax, (2)

    movb $0x0f, %ah
    int $0x10
    movw %bx, (4)
    movw %ax, (6)
    movb $0x12, %ah
    movb $0x10, %bl
    int $0x10
    movw %ax, (8)
    movw %bx, (10)
    movw %cx, (12)
    # ???
    # movw $0x5019, (14)

    # Get hd0 info
    movw $0x0000, %ax
    movw %ax, %ds
    ldsw (4 * 0x41), %si
    movw $INITSEG, %ax
    movw %ax, %es
    movw $0x0080, %di
    movw $0x10, %cx
    rep
    movsb

    # Get hd1 info
    movw $0x0000, %ax
    movw %ax, %ds
    ldsw (4 * 0x46), %si
    movw $INITSEG, %ax
    movw %ax, %es
    movw $0x0090, %di
    movw $0x10, %cx
    rep
    movsb

    movw $0x1500, %ax
    movb $0x81, %dl
    int $0x13
    jc no_disk1
    cmpb $3, %ah
    je is_disk1
no_disk1:
    movw $INITSEG, %ax
    movw %ax, %es
    movw $0x0090, %di
    movw $0x10, %cx
    movw $0x00, %ax
    rep
    stosb
is_disk1:
    # Close interrupt
    cli

    movw $0x0000, %ax
    cld
do_move:
    # Move kernel from 0x10000 to 0x0
    # (Overwrite BIOS memory space)
    movw %ax, %es
    addw $0x1000, %ax
    cmpw $0x9000, %ax
    jz end_move
    movw %ax, %ds
    subw %di, %di
    subw %si, %si
    movw $0x8000, %cx
    rep
    movsw
    jmp do_move

end_move:
    # Display 'A'(Real mode)
    movw $0xb800, %ax
    movw %ax, %gs
    movb $0xf, %ah
    movb $0x41, %al
    movl $0x100, %edi
    movw %ax, %gs:(%di)
    movw $SETUPSEG, %ax
    movw %ax, %ds
    # Set gdtr register
    lgdt gdt_48

    # Open A20 address line
    call empty_8042
    movb $0xd1, %al
    outb %al, $0x64
    call empty_8042
    movb $0xdf, %al
    outb %al, $0x60
    call empty_8042

    # Set cr0.PE, enter protected mode
    movl %cr0, %eax
    xorb $1, %al
    movl %eax, %cr0

    # Long jump to text segment
    .byte 0x66, 0xea
    .long 0x0
    .word 0x8

empty_8042:
    # Check if IO operation is finish
    # Two empty command
    .word 0x00eb, 0x00eb
    inb $0x64, %al
    testb $2, %al
    jnz empty_8042
    ret

setup_msg:
    .ascii "setup is running"

gdt:
    .word 0, 0, 0, 0

    # Text segment
    .word 0x07ff
    .word 0x0000
    .word 0x9a00
    .word 0x00c0

    # Data segment
    .word 0x07ff
    .word 0x0000
    .word 0x9200
    .word 0x00c0

    # Video memory segment
    .word 0xffff
    .word 0x8000
    .word 0x920b
    .word 0x00c0

gdt_48:
    .word 0x800
    .word 512+gdt, 0x9
