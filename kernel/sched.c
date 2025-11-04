#include <asm/system.h>
#include <linux/head.h>
#include <linux/sched.h>
#include <linux/mm.h>
#include <errno.h>
#include <string.h>

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
struct task_struct * current = &(init_task.task);               // Current task PCB
struct task_struct * task[NR_TASKS] = {&(init_task.task), };    // Task's PCB array

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

void test_b(void) {
__asm__("movl $0, %edi\n\r"
        "movw $0x18, %ax\n\r"
        "movw %ax, %gs\n\r"
        "movb $0x0f, %ah\n\r"
        "movb $'B', %al\n\r"
        "loopb:\n\r"
        "movw %ax, %gs:(%edi)\n\r"
        "jmp loopb");
}

int create_second_process() {
    struct task_struct * p;
    int nr;

    // Get idle task number
    nr = find_empty_process();
    if (nr < 0)
        return -EAGAIN;

    // Create new PCB
    p = (struct task_struct *)get_free_page();
    memcpy(p, current, sizeof(struct task_struct));

    set_tss_desc(gdt + FIRST_TSS_ENTRY + (nr<<1), &(p->tss));
    set_ldt_desc(gdt + FIRST_LDT_ENTRY + (nr<<1), &(p->ldt));

    memcpy(&(p->tss), &(current->tss), sizeof(struct tss_struct));

    p->tss.eip = (long)test_b;
    p->tss.ldt = _LDT(nr);      // LDT segment selector
    // Privilege Level 0's ss and esp
    p->tss.ss0 = 0x10;
    p->tss.esp0 = PAGE_SIZE + (long)p;
    // Corrent ss and esp
    p->tss.ss = 0x10;
    p->tss.esp = PAGE_SIZE + (long)p;  
    p->tss.ds = 0x10;
    p->tss.es = 0x10;
    p->tss.cs = 0x8;
    p->tss.fs = 0x10;
    p->tss.eflags = 0x602;

    task[nr] = p;
    return nr;
}       
