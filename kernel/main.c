#include <linux/tty.h>

int main(void)
{
    tty_init();

    for (int i = 0; i < 22; i++) {
        console_print("hello123\r\n", 10);
    }

    while (1) ;
}
