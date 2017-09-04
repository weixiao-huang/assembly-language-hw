FROM huangwx/gcc5-i686-elf
# RUN apt update

# RUN apt install -y libc6-i386 libc6-dev-i386

COPY ./src /usr/src/myapp
WORKDIR /usr/src/myapp

RUN gcc -m32 test.c alloc.s round.s list.s -o myapp
CMD ["./myapp"]