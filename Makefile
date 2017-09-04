
all: build run

run:
	docker run -it --rm --name my-running-mips-app my-mips-app

build:
	docker build -t my-mips-app .