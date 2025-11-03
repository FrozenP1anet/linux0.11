#include <asm/system.h>
#include <linux/head.h>
#include <linux/sched.h>

#define PAGE_SIZE   4096

long user_stack[PAGE_SIZE >> 2];

// a is stack pointer, load to %esp
// b is the segment selector for the data segment, indicating
// that stack is located in data segment
struct {
    long * a;
    short b;
} stack_start = {&user_stack[PAGE_SIZE >> 2], 0x10};

// Task stack
union task_union {
    struct task_struct task;
    char stack[PAGE_SIZE];
};

static union task_union init_task = {INIT_TASK, };

extern int system_call();

void sched_init() {
    struct desc_struct * p;
    // Set tss segment to gdt
    set_tss_desc(gdt + FIRST_TSS_ENTRY, &(init_task.task.tss));
    // Set ldt segment to gdt
    set_ldt_desc(gdt + FIRST_LDT_ENTRY, &(init_task.task.ldt));
    __asm__("pushfl; andl $0xffffbfff, (%esp); popfl");
    // Set tr register
    ltr(0);
    // Set ldt register
    lldt(0);
    // set_intr_gate(0x80, &system_call);
    set_system_gate(0x80, &system_call);
}
