.include "linux.s"
.include "record-def.s"
# INPUT: The file descriptor and a buffer
# OUTPUT: This function produces a status code

# stack procedural parameters
.equ ST_WRITE_BUFFER, 8
.equ ST_FILEDS, 12

.section .text
.globl write_record
.type write_record, @function
write_record:
    pushl %ebp
    movl %esp, %ebp
    pushl %ebx

    movl ST_FILEDS(%ebp), %ebx
    movl ST_WRITE_BUFFER(%ebp), %ecx
    movl $RECORD_SIZE, %edx

    movl $SYS_WRITE, %eax
    int $LINUX_SYSCALL

    popl %ebx
#    leave
    movl %ebp, %esp
    popl %ebp
    ret
