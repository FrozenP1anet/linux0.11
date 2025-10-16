#ifndef __SYSTEM_H
#define __SYSTEM_H

#define sti()   __asm__("sti")
#define cli()   __asm__("cli")
#define nop()   __asm__("nop")
#define iret()   __asm__("iret")

#define _set_gate(gate_addr, type, dpl, addr)   \
__asm__("movw %%dx, %%ax\n\r"   \
        "movw %0, %%dx\n\r"     \
        "movl %%eax, %1\n\r"    \
        "movl %%edx, %2"        \
        :                       \
        :"i"((short)(0x8000 + (dpl<<13) + (type<<8))),  \
        "m"(*((char *)(gate_addr))),    \
        "m"(*(4 + (char *)(gate_addr))),\
        "d"((char *)(addr)), "a"(0x00080000))

// Combine intrrupt number with handler function
#define set_intr_gate(n, addr)  \
    _set_gate(&idt[n], 14, 0, addr)

#define set_trap_gate(n, addr)  \
    _set_gate(&idt[n], 15, 0, addr)

#define set_system_gate(n, addr) \
    _set_gate(&idt[n], 15, 3, addr)

#endif
