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

.equ MIN_BLOCK_ORDER, 4
.equ MAX_BLOCK_ORDER, 16
.equ DEFAULT_SIZE_ORDER, 12
.equ LINK_SIZE, 8


.section .text

.type find_header_by_order, @function
find_header_by_order:
    pushl %ebp
    movl %esp, %ebp

    movl 8(%ebp), %eax
    subl $MIN_BLOCK_ORDER, %eax
    imull $LINK_SIZE, %eax
    addl heap_begin, %eax

    leave
    ret

.globl allocate_init
.type allocate_init, @function
allocate_init:
    pushl %ebp
    movl %esp, %ebp

# if the brk system call is called with 0 in %ebx, it returns the first invalid address
# get the heap_begin
    movl $SYS_BRK, %eax
    movl $0, %ebx
    int $LINUX_SYSCALL
    movl %eax, heap_begin
    movl %eax, current_break
    
# allocate the linker headers (from MIN_BLOCK_ORDER to MAX_BLOCK_ORDER)
    movl $MAX_BLOCK_ORDER, %ebx
    subl $MIN_BLOCK_ORDER, %ebx
    incl %ebx
    imull $LINK_SIZE, %ebx # get the size of LINK HEADERs
    leal (%ebx, %eax), %ebx
    movl $SYS_BRK, %eax
    int $LINUX_SYSCALL
# set data_begin
    movl %eax, data_begin
    movl %eax, current_break

# allocate (1 << DEFAULT_SIZE_ORDER) space from data_begin
    movl data_begin, %ebx
    movl $1, %ecx
    sall $DEFAULT_SIZE_ORDER, %ecx
    leal (%ecx, %ebx), %ebx
    movl $SYS_BRK, %eax
    int $LINUX_SYSCALL
# set final initial current_break
set_current_break:
    movl %eax, current_break

# preparing to init_loop - for init list headers
    movl heap_begin, %eax
    movl $MIN_BLOCK_ORDER, %ecx

init_loop:
    cmpl $MAX_BLOCK_ORDER, %ecx
    jg init_end
    pushl %eax
    call list_init
    addl $4, %esp
    incl %ecx
    addl $LINK_SIZE, %eax
    jmp init_loop

init_end:
    pushl $DEFAULT_SIZE_ORDER
    call find_header_by_order
    
# make data begin available
    movl data_begin, %ecx
    movl $AVAILABLE, 8(%ecx)
    pushl %eax
    pushl %ecx
    call list_init
    popl %ecx
    popl %eax

# add data begin list after default order pointer header
    pushl data_begin   # data begin list
    pushl %eax         # default order pointer (list header)
    call list_add_after
    addl $8, %esp

    leave
    ret


.type find_buddy, @function
find_buddy:
    pushl %ebp
    movl %esp, %ebp

    movl 8(%ebp), %eax      # 首地址

    subl data_begin, %eax
    movl $1, %edx
    movb 12(%ebp), %cl
    sall %cl, %edx     # 12(%ebp) - order
    xorl %edx, %eax
    addl data_begin, %eax

    leave
    ret


.globl allocate
.type allocate, @function
.equ ST_MEM_SIZE, 8
allocate:
    pushl %ebp
    movl %esp, %ebp
    movl ST_MEM_SIZE(%ebp), %ecx

    addl $12, %ecx
    pushl %ecx
    call round
    movl %eax, (%esp)

    movl %eax, %edx     # %edx 用于记录找到可用块的round是多少
    call find_header_by_order   # %eax - list header pointer

up_search:
# 如果超过了header的区域，则没有找到任何可用块，准备扩容
    cmpl data_begin, %eax
    jge expand_capacity
    movl %eax, %ecx

up_traverse_list:
# 只需判断链表非空即可
    cmpl 4(%ecx), %eax 
    je up_traverse_list_end  # 空链表
# 找到了一个可用块 - 4(%ecx)
    movl 4(%ecx), %ecx
split_or_alloc:
    cmpl (%esp), %edx   # (%esp) - 最初需要分配的内存的order
    je allocate_here
# 否则需要分裂空间
# 先在对应的list中删除 %ecx
    pushl %edx
    pushl %eax
    pushl %ecx
    call list_del
    popl %ecx
    popl %eax
    popl %edx

# list header 回退一位
    subl $LINK_SIZE, %eax
    pushl %edx
    pushl %ecx
    pushl %eax
    call list_add_before
    popl %eax
    popl %ecx
    popl %edx

    decl %edx
    pushl %eax
    pushl %edx
    pushl %ecx
    call find_buddy
    popl %ecx

    pushl %eax
    call list_init
    movl $AVAILABLE, 8(%eax)

# 12(%esp) - list header;
# 8(%esp) - %edx;
# 4(%esp) - buddy addr;
# 0(%esp) - list header;
    movl 8(%esp), %eax
    pushl %eax
    call list_add_before

gdb_test:
    popl %eax
    addl $4, %esp
    popl %edx
    popl %eax
    movl %eax, %ecx
    jmp up_traverse_list

up_traverse_list_end:
    addl $LINK_SIZE, %eax
    incl %edx
    jmp up_search

expand_capacity:

allocate_here:
    pushl %ecx
    call list_del
    popl %ecx
    movl $UNAVAILABLE, 8(%ecx)
    leal 12(%ecx), %eax
    popl %edx
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
