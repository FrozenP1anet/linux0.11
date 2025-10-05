BOOTSEG = 0x7c0

.code16
.text

.global _start
_start:
    jmpl $BOOTSEG, $start2

start2:
    movw $BOOTSEG, %ax
    movw %ax, %ds
    movw %ax, %es
    movw %ax, %fs
    movw %ax, %gs

    movw $msg, %ax
    movw %ax, %bp
    movw $0x01301, %ax  # Specify the function and sub-function of BIOS interrupt 0x10
    movw $0x0c, %bx     # Red
    movw $12, %cx       # String lenth
    movb $0, %dl        # Set the starting column number of the cursor
    int $0x010          # Trigger BIOS interrupt 0x10 (Video display control)

loop:
    jmp loop

msg:
.ascii "Hello World!"

.org 510
boot_flag:
    .word 0xaa55    # Boot signature
