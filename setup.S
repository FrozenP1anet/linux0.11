.code16
.text

.global _start_setup

_start_setup:
    movw %cs, %ax
    movw %ax, %ds
    movw %ax, %es

    # Display $mag
    movw $setup_msg, %ax
    movw %ax, %bp
    movw $0x1301, %ax
    movw $0x0c, %bx # Red
    movw $16, %cx   # Char number
    movb $0, %dl    # Column
    movb $3, %dh    # Row
    int $0x10

setup_msg:
.ascii "Setup is running"
