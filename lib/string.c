#include <string.h>

int strlen(const char * s)
{
    const char* p = s;
    while (*p) p++;
    return p - s;
}
