# FROM gcc:4.9
FROM asmimproved/qemu-mips:latest
COPY ./src /usr/src/myapp
WORKDIR /usr/src/myapp

RUN mips-linux-gnu-gcc -static -mips32r5  main.s -o main
CMD ["./main"]