# Get the Ubuntu environment
all: build run

build:
	docker build -t buflab .

run:
	docker run --privileged -it --rm --name buflab-container buflab

# Exploits Executable Codes
# If you change files, PLEASE make build FIRST
ex0:
	docker run --privileged -i --rm --name buflab-container buflab \
		/bin/bash -c "cat ./raw/exploit0.txt | ./bin/hex2raw | ./bin/bufbomb -u 2015011310"

ex1:
	docker run --privileged -i --rm --name buflab-container buflab \
		/bin/bash -c "cat ./raw/exploit1.txt | ./bin/hex2raw | ./bin/bufbomb -u 2015011310"

ex2:
	docker run --privileged -i --rm --name buflab-container buflab \
		/bin/bash -c "cat ./raw/exploit2.txt | ./bin/hex2raw | ./bin/bufbomb -u 2015011310"

ex3:
	docker run --privileged -i --rm --name buflab-container buflab \
		/bin/bash -c "cat ./raw/exploit3.txt | ./bin/hex2raw | ./bin/bufbomb -u 2015011310"

ex4:
	docker run --privileged -i --rm --name buflab-container buflab \
		/bin/bash -c "cat ./raw/exploit4.txt | ./bin/hex2raw -n | ./bin/bufbomb -n -u 2015011310"

# Tools
cookie:
	docker run --privileged -i --rm --name buflab-container buflab ./bin/makecookie $(ID)

dump:
	mkdir -p dump
	docker run --privileged -it --rm \
		--name buflab-container \
		-v $(PWD)/dump:/usr/src/app/dump \
		buflab \
		/usr/bin/objdump -d ./bin/bufbomb > dump/bufbomb.s
