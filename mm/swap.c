#include <linux/mm.h>

// Get free physical page, and return its start address
unsigned long get_free_page() {
    register unsigned long __res asm("ax") = 0;

repeat:
__asm__("std ; repne ; scasb\n\t"
        "jne 1f\n\t"
        "movb $1,1(%%edi)\n\t"      // Set the corresponding element in the mem_maparray to 1.​
        "sall $12, %%ecx\n\t"       // The index of the physical page << 12.​
        "addl %2, %%ecx\n\t"        // %ecx points to allocated physical page
        "movl %%ecx, %%edx\n\t"
        "movl $1024, %%ecx\n\t"
        "leal 4092(%%edx), %%edi\n\t"
        "xor  %%eax, %%eax\n\t"
        "rep; stosl;\n\t"           // Clean physical page
        "movl %%edx,%%eax\n"
        "1:"
        :"=a"(__res)
        :""(0), "i"(LOW_MEM), "c"(PAGING_PAGES),
        "D"(mem_map+PAGING_PAGES-1)
        :"dx");

    if (__res >= HIGH_MEMORY)
        goto repeat;
    return __res;
}
