#include <stdio.h>
#include <stdlib.h>

extern int allocate_init();
extern int allocate(int size);
extern int deallocate(unsigned int*);

int main() {
    printf("allocate_init:\n");
    printf("0x%x\n", allocate_init());
    printf("allocate:\n");
    unsigned int *a, *b, *c;
    printf("0x120: 0x%x\n", a = allocate(0x10));
    printf("0x50: 0x%x\n", b = allocate(0x100));
    printf("0x50: 0x%x\n", c = allocate(0x80));
    deallocate(a);
    deallocate(b);
    deallocate(c);
    printf("0x120: 0x%x\n", a = allocate(0x10));
    printf("0x50: 0x%x\n", b = allocate(0x100));
    printf("0x50: 0x%x\n", c = allocate(0x80));
    // printf("0x300: 0x%x\n", allocate(0x300));
    // printf("0x400: 0x%x\n", allocate(0x400));
    return 0;
}
