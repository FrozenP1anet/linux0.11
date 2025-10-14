#include <linux/tty.h>
#include <linux/kernel.h>

int main(void)
{
    tty_init();

    printk("hello %d\n", 28);

    while (1) ;
}
