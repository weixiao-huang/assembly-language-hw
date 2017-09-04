
all: build run

run:
	docker run -it --rm --name my-running-app gcc5-i686-elf

build:
	docker build -t gcc5-i686-elf .