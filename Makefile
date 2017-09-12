IMAGE      := buflab
CONTAINER  := buflab-container

DFLAGS     := --privileged --rm -it
BASH       := /bin/bash

HEX2RAW    := ./bin/hex2raw
BUFBOMB    := ./bin/bufbomb
MAKECOOKIE := ./bin/makecookie

EXPLOIT0   := ./raw/exploit0.txt
EXPLOIT1   := ./raw/exploit1.txt
EXPLOIT2   := ./raw/exploit2.txt
EXPLOIT3   := ./raw/exploit3.txt
EXPLOIT4   := ./raw/exploit4.txt
DEFAULTID  := 2015011310

WORKDIR	   := /usr/src/app
DUMPDIR    := ./dump

run_ex   = cat $(1) | $(HEX2RAW) | $(BUFBOMB) -u $(if $(2), $(2), $(DEFAULTID))
run_ex_n = cat $(1) | $(HEX2RAW) -n | $(BUFBOMB) -n -u $(if $(2), $(2), $(DEFAULTID))


# Get the Ubuntu environment
all: build run

build:
	docker build -t $(IMAGE) .

run:
	docker run $(DFLAGS) --name $(CONTAINER) $(IMAGE)

# Exploits Executable Codes
# If you change files, PLEASE make build FIRST
ex0:
	docker run $(DFLAGS) --name $(CONTAINER) $(IMAGE) $(BASH) -c "$(call run_ex,$(EXPLOIT0))"

ex1:
	docker run $(DFLAGS) --name $(CONTAINER) $(IMAGE) $(BASH) -c "$(call run_ex,$(EXPLOIT1))"

ex2:
	docker run $(DFLAGS) --name $(CONTAINER) $(IMAGE) $(BASH) -c "$(call run_ex,$(EXPLOIT2))"

ex3:
	docker run $(DFLAGS) --name $(CONTAINER) $(IMAGE) $(BASH) -c "$(call run_ex,$(EXPLOIT3))"

ex4:
	docker run $(DFLAGS) --name $(CONTAINER) $(IMAGE) $(BASH) -c "$(call run_ex_n,$(EXPLOIT4))"

# Tools
cookie:
	docker run $(DFLAGS) --name $(CONTAINER) $(IMAGE) $(MAKECOOKIE) $(if $(ID),$(ID),$(DEFAULTID))

dump:
	mkdir -p dump
	docker run $(DFLAGS) --name $(CONTAINER) \
		-v $(PWD)/dump:$(WORKDIR)/dump \
		$(IMAGE) \
		/usr/bin/objdump -d $(BUFBOMB) > $(DUMPDIR)/bufbomb.s
