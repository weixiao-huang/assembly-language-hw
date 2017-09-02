# write-newline.s
.include "linux.s"

.section .data
newline:
    .ascii "\n"

.section .text
.equ ST_FILEDES, 8

.globl write_newline
.type write_newline, @function
write_newline:
    pushl %ebp
    movl %esp, %ebp

    movl ST_FILEDES(%ebp), %ebx
    movl $newline, %ecx
    movl $1, %edx
    movl $SYS_WRITE, %eax
    int $LINUX_SYSCALL

    leave
    ret
