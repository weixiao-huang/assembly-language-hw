
all: build run

run:
	docker run --privileged -it --rm --name my-running-app gcc5-i686-elf

build:
	docker build -t huangwx/gcc5-i686-elf .

debug:
	docker run --privileged -it --rm --name my-debugging-app gcc5-i686-elf /usr/bin/gdb ./myapp
