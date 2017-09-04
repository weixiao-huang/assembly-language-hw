.type round, @function
.globl round
round:
    pushl %ebp
    movl %esp, %ebp

    movl 8(%ebp), %edx
    movl $0, %eax
    movl $1, %ecx

loop_begin:
    cmpl %edx, %ecx
    jge loop_end
    sall $1, %ecx
    incl %eax
    jmp loop_begin

loop_end:
    leave
    ret
