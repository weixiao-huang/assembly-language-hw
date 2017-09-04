.type list_init, @function
.globl list_init
list_init:
    pushl %ebp
    movl %esp, %ebp

    movl 8(%ebp), %eax
    movl %eax, (%eax)
    movl %eax, 4(%eax)

    leave
    ret

.type __list_add, @function
__list_add:
    pushl %ebp
    movl %esp, %ebp

    movl 8(%ebp), %eax  # elm
    movl 12(%ebp), %ecx # prev
    movl 16(%ebp), %edx # next 

    movl %eax, 4(%ecx)
    movl %eax, (%edx)

    movl %edx, 4(%eax)
    movl %ecx, (%eax)

    leave
    ret
    
.type list_add_before, @function
.globl list_add_before
list_add_before:
    pushl %ebp
    movl %esp, %ebp

    movl 8(%ebp), %eax  # listelm
    movl 12(%ebp), %ecx # elm

    pushl %eax      # listelm
    pushl (%eax)    # listelm->prev
    pushl %ecx      # elm
    call __list_add
    addl $12, %esp

    leave
    ret
     
.type list_add_after, @function
.globl list_add_after
list_add_after:
    pushl %ebp
    movl %esp, %ebp

    movl 8(%ebp), %eax  # listelm
    movl 12(%ebp), %ecx # elm

    pushl 4(%eax)    # listelm->next
    pushl %eax      # listelm
    pushl %ecx      # elm
    call __list_add
    addl $12, %esp

    leave
    ret
 