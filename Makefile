
all: build run

run:
	docker run -it --rm --name my-running-app my-gcc-app

build:
	docker build -t my-gcc-app .