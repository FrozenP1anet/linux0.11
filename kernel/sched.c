#define PAGE_SIZE   4096

long user_stack[PAGE_SIZE >> 2];

// a is stack pointer, load to %esp
// b is the segment selector for the data segment, indicating
// that stack is located in data segment
struct {
    long * a;
    short b;
} stack_start = {&user_stack[PAGE_SIZE >> 2], 0x10};
