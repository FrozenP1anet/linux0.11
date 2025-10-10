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
