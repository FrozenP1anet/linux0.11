.code32
.text
.globl startup_32
startup_32:
    # In data segment
    movl $0x10, %eax
    movw %ax, %ds
    movw %ax, %es
    movw %ax, %fs
    # In video memory segment
    movl $0x18, %eax
    movw %ax, %gs
    call setup_idt
    call set_clock_idt
    call setup_gdt
    int $0x80
    sti     # Open interrupt

    # Display 'B' to the upleft corner of screen (protected mode)
    movl $0x18, %eax
    movw %ax, %gs
    movl $0x0, %edi
    movb $0xf, %ah
    movb $0x42, %al
    movw %ax, %gs:(%edi)

loop:
    jmp loop

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
clock_handle:
    # Red 'I' ++ when intrrupt occurs
    movl $0x96, %edi
    incb %gs:(%edi)
    # Send EOI to PIC, interrupt end
    movb $0x20, %al
    outb %al, $0x20
    iret

setup_gdt:
    lgdt gdt_descr
    ret

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
    .quad 0x00c09a00000007ff    # Text segment
    .quad 0x00c09200000007ff    # Data segment
    .quad 0x00c0f20b8000ffff    # Video segment
    .quad 0x0000000000000000
    .fill 251, 8, 0
