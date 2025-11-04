#include <string.h>

int strlen(const char * s)
{
    const char* p = s;
    while (*p) p++;
    return p - s;
}

void * memcpy(void * dest,const void * src, int n)
{
__asm__("cld\n\t"
    "rep\n\t"
    "movsb"
    ::"c" (n),"S" (src),"D" (dest)
    :);
return dest;
}
