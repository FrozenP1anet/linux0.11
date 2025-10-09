int main(void)
{
    __asm__("int $0x80  \n\r"::);

    while (1) ;
}
