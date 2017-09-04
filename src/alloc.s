.section .data

# This points to the beginning of the memory
heap_begin:
    .long 0

data_begin:
    .long 0

# This points to one location past the memory we are managing
current_break:
    .long 0

# size of space for memory region header
.equ HEADER_SIZE, 8
# Location of the "available" flag in the header
.equ HDR_AVAIL_OFFSET, 0
# Location of the size field in the header
.equ HDR_SIZE_OFFSET, 4

.equ UNAVAILABLE, 0
.equ AVAILABLE, 1
.equ SYS_BRK, 45
.equ LINUX_SYSCALL, 0x80

.equ LINK_NUM, 8
.equ DEFAULT_SIZE_ORDER, 6
.equ LINK_BYTE, 8

.type find_initial_pointer, @function
find_initial_pointer:
    pushl %ebp
    movl %esp, %ebp

    movl $DEFAULT_SIZE_ORDER, %eax
    imull $LINK_BYTE, %eax
    subl $LINK_BYTE, %eax
    addl heap_begin, %eax

    leave
    ret

.section .text
.globl allocate_init
.type allocate_init, @function
allocate_init:
    pushl %ebp
    movl %esp, %ebp

# if the brk system call is called with 0 in %ebx, it returns the first invalid address
    movl $SYS_BRK, %eax
    movl $0, %ebx
    int $LINUX_SYSCALL
    movl %eax, heap_begin
    movl %eax, current_break
    
    movl $LINK_NUM, %ebx
    imull $LINK_BYTE, %ebx # get the size of LINK HEADERs
    leal (%ebx, %eax), %ebx
    movl $SYS_BRK, %eax
    int $LINUX_SYSCALL
    movl %eax, data_begin
    movl %eax, current_break

    movl current_break, %ebx
    movl $1, %ecx
    sall $DEFAULT_SIZE_ORDER, %ecx
    leal (%ecx, %ebx), %ebx
    movl $SYS_BRK, %eax
    int $LINUX_SYSCALL
    movl %eax, current_break

    movl heap_begin, %eax
    movl $0, %ecx

init_loop:
    cmpl $LINK_NUM, %ecx
    jge init_end
    movl $0, (%eax)
    pushl %eax
    call list_init
    addl $4, %esp
    incl %ecx
    addl $8, %eax
    jmp init_loop

init_end:
    call find_initial_pointer
    
    pushl %eax
    call list_init
    popl %eax

    pushl data_begin   # initial list node
    pushl %eax         # initial pointer
    call list_add_after
    addl $8, %esp

    leave
    ret


.globl allocate
.type allocate, @function
.equ ST_MEM_SIZE, 8
allocate:
    pushl %ebp
    movl %esp, %ebp
    movl ST_MEM_SIZE(%ebp), %ecx

    movl heap_begin, %eax
    movl current_break, %ebx
loop_begin:
    cmpl %ebx, %eax
    je move_break
    movl HDR_SIZE_OFFSET(%eax), %edx
    cmpl $UNAVAILABLE, HDR_AVAIL_OFFSET(%eax)
    je next_location
    cmpl %edx, %ecx
    jle allocate_here
next_location:
    addl $HEADER_SIZE, %eax
    addl %edx, %eax
    jmp loop_begin
allocate_here:
    movl $UNAVAILABLE, HDR_AVAIL_OFFSET(%eax)
    addl $HEADER_SIZE, %eax
    leave
    ret
move_break:
    addl $HEADER_SIZE, %ebx
    addl %ecx, %ebx
    pushl %eax
    movl $SYS_BRK, %eax
    int $LINUX_SYSCALL
    popl %eax

    movl $UNAVAILABLE, HDR_AVAIL_OFFSET(%eax)
    movl %ecx, HDR_SIZE_OFFSET(%eax)
    addl $HEADER_SIZE, %eax

    movl %ebx, current_break
    leave
    ret

.globl deallocate
.type deallocate, @function
.equ ST_MEM_SEG, 4
deallocate:
    movl ST_MEM_SEG(%esp), %eax
    subl $HEADER_SIZE, %eax
    movl $AVAILABLE, HDR_AVAIL_OFFSET(%eax)
    ret
