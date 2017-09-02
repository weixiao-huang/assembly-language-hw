.include "linux.s"
.include "record-def.s"

.type add_age, @function
.globl add_age
.equ ST_AGE_START_ADDRESS, 8

add_age:
    pushl %ebp
    movl %esp, %ebp

    movl ST_AGE_START_ADDRESS(%ebp), %edx
    movl (%edx), %eax
    incl %eax
    movl %eax, (%edx)
    
    leave
    ret
