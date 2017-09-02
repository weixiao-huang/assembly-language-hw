# read-records.s
.include "linux.s"
.include "record-def.s"

.section .data
input_file_name:
    .ascii "test.dat\0"
output_file_name:
    .ascii "output.dat\0"

.section .bss
    .lcomm record_buffer, RECORD_SIZE

.equ ST_INPUT_DESCRIPTOR, -4
.equ ST_OUTPUT_DESCRIPTOR, -8

.section .text
.globl _start
_start:
    movl %esp, %ebp
    subl $8, %esp

    movl $input_file_name, %ebx
    movl $0, %ecx
    movl $0666, %edx
    movl $SYS_OPEN, %eax
    int $LINUX_SYSCALL
    movl %eax, ST_INPUT_DESCRIPTOR(%ebp)

    movl $output_file_name, %ebx
    movl $0101, %ecx
    movl $0666, %edx
    movl $SYS_OPEN, %eax
    int $LINUX_SYSCALL
    movl %eax, ST_OUTPUT_DESCRIPTOR(%ebp)

record_read_loop:
    pushl ST_INPUT_DESCRIPTOR(%ebp)
    pushl $record_buffer
    call read_record

    addl $8, %esp
    cmpl $RECORD_SIZE, %eax
    jne finished_reading

    pushl $RECORD_AGE + record_buffer
    call add_age
    addl $4, %esp

#    pushl $record_buffer
#    call count_chars
#    addl $4, %esp

#    movl ST_OUTPUT_DESCRIPTOR(%ebp), %ebx
#    movl $record_buffer, %ecx
#    movl %eax, %edx
#    movl $SYS_WRITE, %eax
#    int $LINUX_SYSCALL
    pushl ST_OUTPUT_DESCRIPTOR(%ebp)
    pushl $record_buffer
    call write_record
    addl $8, %esp

#    pushl ST_OUTPUT_DESCRIPTOR(%ebp)
#    call write_newline
#    addl $4, %esp
    jmp record_read_loop
finished_reading:
    movl ST_INPUT_DESCRIPTOR(%ebp), %ebx
    movl $SYS_CLOSE, %eax
    int $LINUX_SYSCALL

    movl ST_OUTPUT_DESCRIPTOR(%ebp), %ebx
    movl $SYS_CLOSE, %eax
    int $LINUX_SYSCALL

    movl $0, %ebx
    movl $SYS_EXIT, %eax
    int $LINUX_SYSCALL
    