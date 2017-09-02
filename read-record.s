.include "linux.s"
.include "record-def.s"
# INPUT: The file descriptor and a buffer
# OUTPUT: This function writes the data to the buffer and returns a status code.

# stack procedural parameters
.equ ST_READ_BUFFER, 8
.equ ST_FILEDS, 12

.section .text
.globl read_record
.type read_record, @function
read_record:
    pushl %ebp
    movl %esp, %ebp
    pushl %ebx

    movl ST_FILEDS(%ebp), %ebx
    movl ST_READ_BUFFER(%ebp), %ecx
    movl $RECORD_SIZE, %edx
    movl $SYS_READ, %eax
    int $LINUX_SYSCALL

    popl %ebx
    leave
    ret
