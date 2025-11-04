.code32
.text
.globl startup_32, idt, gdt, pg_dir, tmp_floppy_area
# Paging directory start
# The area before address 0x1000 will be overwritten by the page directory
pg_dir:
startup_32:
    # In data segment
    movl $0x10, %eax
    movw %ax, %ds
    movw %ax, %es
    movw %ax, %fs
    movw %ax, %gs
    
    lss stack_start, %esp   # Set %esp and %ss
    call setup_idt
    call set_clock_idt
    call setup_gdt
    
    sti     # Open maskable interrupt

    movl $0x10, %eax
    movw %ax, %ds
    movw %ax, %es
    movw %ax, %fs
    # In video memory segment
    movl $0x18, %eax
    movw %ax, %gs

    xorl %eax, %eax
1:
    incl %eax
    movl %eax, 0x000000
    movl %eax, 0x100000
    je 1b

    jmp after_page_tables

setup_idt:
    # %eax storges lower 4 byte of intr description
    # %edx storges upper 4 byte of intr description
    leal ignore_int, %edx
    movl $0x00080000, %eax
    movw %dx, %ax
    movw $0x8e00, %dx
    leal idt, %edi
    movl $256, %ecx     # IDT entry number = 256
rp_sidt:
    movl %eax, (%edi)
    movl %edx, 4(%edi)
    addl $8, %edi
    decl %ecx
    jne rp_sidt
    lidt idt_descr
    ret

setup_gdt:
    lgdt gdt_descr
    ret

set_clock_idt:
    leal clock_handle, %edx
    movl $0x00080000, %eax
    movw %dx, %ax
    movw $0x8e00, %dx
    leal idt, %edi
    addl $0x100, %edi   # Clock intr num = 32
    movl %eax, (%edi)
    movl %edx, 4(%edi)
    ret

# Paging table start
.org 0x1000
pg0:

.org 0x2000
pg1:

.org 0x3000
pg2:

.org 0x4000
pg3:

.org 0x5000

tmp_floppy_area:
    .fill 1024, 1, 0

after_page_tables:
    pushl $0
    pushl $0
    pushl $0
    pushl $L6
    # main() function enter point
    pushl $main
    jmp setup_paging
L6:
    jmp L6

clock_handle:
    # Red 'I'+1 when intrrupt occurs
    movl $0x96, %edi
    incb %gs:(%edi)
    # Send EOI to PIC, interrupt end
    movb $0x20, %al
    outb %al, $0x20
    iret

ignore_int:
    pushl %eax
    pushl %ecx
    pushl %edx
    pushw %ds
    pushw %es
    pushw %fs
    movl $0x10, %eax
    movw %ax, %ds
    movw %ax, %es
    movw %ax, %fs
    # Display red letter 'I' in postion 0x96
    movl $0x96, %edi
    movb $0x0c, %ah
    movb $'I', %al
    movw %ax, %gs:(%edi)
    popw %fs
    popw %es
    popw %ds
    popl %edx
    popl %ecx
    popl %eax
    iret

.align 4 
setup_paging:
    # Clean page directory and page tables
    movl $1024*5, %ecx
    xorl %eax, %eax
    xorl %edi, %edi
    cld
    rep
    stosl

    # Set PDEs (total 4 PDEs)
    movl $pg0 + 7, pg_dir
    movl $pg1 + 7, pg_dir + 4
    movl $pg2 + 7, pg_dir + 8
    movl $pg3 + 7, pg_dir + 12
    # Set PTEs (total 4096 PTEs, cover 16MB physical memory)
    movl $pg3 + 4092, %edi
    movl $0xfff007, %eax
    std
1:
    stosl
    subl $0x1000, %eax
    jge 1b
    xorl %eax, %eax
    movl %eax, %cr3     # cr3 reg points to page directory
    # Set cr0.PE (turn on paging)
    movl %cr0, %eax
    orl $0x80000000, %eax
    movl %eax, %cr0

    ret

.align 4
.word 0
idt_descr:
    .word 256*8-1
    .long idt

.align 4
.word 0
gdt_descr:
    .word 256*8-1
    .long gdt

.align 8
idt:
    .fill 256, 8, 0
gdt:
    .quad 0x0000000000000000    # CPU reserve
    .quad 0x00c09a0000000fff    # Text segment
    .quad 0x00c0920000000fff    # Data segment
    .quad 0x00c0f20b8000ffff    # Video segment
    .quad 0x0000000000000000
    .fill 251, 8, 0
