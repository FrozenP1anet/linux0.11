# linux0.11
## bootsect.S
* Load setup module into memory 
* Load system module into memory 
## setup.S
* Get hardware info
* Set GDT
* Enter protected mode
* Jump to kernel
## head.S
* Setup IDT
* Define default intrrupt handler
* Define clock interrupt handler
* Setup page directory and page tables, enable memory paging
* Setup stack
* Enter main() function

## Add printk() support

## Create process
### Create INIT process
* Set PCB(Process control block), including ldt[3] and tss
* Set ldt and tss address to GDT 
* Set up kernel stack

## main.c
* Initialize memory management
* Initialize systam call
* Initialize console
* Set CPU exceptions
* Enter user mode
