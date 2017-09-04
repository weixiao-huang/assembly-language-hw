# FROM gcc:4.9
FROM pwootage/gcc5-i686-elf
COPY ./src /usr/src/myapp
WORKDIR /usr/src/myapp
RUN apt update

RUN apt install -y libc6-i386 libc6-dev-i386
# RUN apt install -y gcc-multilib g++-multilib
# RUN ln -s /usr/lib/x86_64-linux-gnu /usr/lib64 

RUN gcc -m32 -o myapp test.c alloc.s 
CMD ["./myapp"]