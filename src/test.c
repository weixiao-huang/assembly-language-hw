#include <stdio.h>
#include <stdlib.h>

extern int allocate_init();
extern int allocate(int size);

int main() {
    printf("allocate_init:\n");
    printf("0x%x\n", allocate_init());
    printf("allocate:\n");
    printf("0x100: 0x%x\n", allocate(0x100));
    printf("0x200: 0x%x\n", allocate(0x200));
    // printf("0x300: 0x%x\n", allocate(0x300));
    // printf("0x400: 0x%x\n", allocate(0x400));
    return 0;
}
