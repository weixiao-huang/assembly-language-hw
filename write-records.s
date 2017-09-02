.include "linux.s"
.include "record-def.s"
.include "records-data.s"

.section .data
file_name:
    .ascii "test.dat\0"

.equ ST_FILE_DESCRIPTOR, -4

.section .text
.globl _start
_start:
    movl %esp, %ebp
    subl $4, %esp   # Allocate space to hold the descriptor

    movl $file_name, %ebx
    movl $0101, %ecx    # to create if it doesn't exist, and open for writing
    movl $0666, %edx

    movl $SYS_OPEN, %eax
    int $LINUX_SYSCALL

    movl %eax, ST_FILE_DESCRIPTOR(%ebp)

    pushl ST_FILE_DESCRIPTOR(%ebp)
    pushl $record1
    call write_record
    addl $8, %esp

    pushl ST_FILE_DESCRIPTOR(%ebp)
    pushl $record1
    call write_record
    addl $8, %esp

    pushl ST_FILE_DESCRIPTOR(%ebp)
    pushl $record2
    call write_record
    addl $8, %esp

    pushl ST_FILE_DESCRIPTOR(%ebp)
    pushl $record3
    call write_record
    addl $8, %esp

    pushl ST_FILE_DESCRIPTOR(%ebp)
    pushl $record4
    call write_record
    addl $8, %esp

close_and_exit:
    movl ST_FILE_DESCRIPTOR(%ebp), %ebx
    movl $SYS_CLOSE, %eax
    int $LINUX_SYSCALL

    movl $0, %ebx
    movl $SYS_EXIT, %eax
    int $LINUX_SYSCALL
