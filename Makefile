all: build gcc

build:
	docker build -t buflab .

gcc:
	docker run --privileged -it --rm --name buflab-container buflab