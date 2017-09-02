BINARY := bin

write: write-records.o write-record.o 
	ld $(BINARY)/write-record.o $(BINARY)/write-records.o -m elf_i386 -o $(BINARY)/write-records
	$(BINARY)/write-records

read: read-records.o read-record.o write-newline.o count-chars.o add-age.o
	ld $(BINARY)/read-record.o $(BINARY)/read-records.o $(BINARY)/add-age.o $(BINARY)/write-newline.o $(BINARY)/count-chars.o \
		-m elf_i386 -o $(BINARY)/read-records
	$(BINARY)/read-records

edit: edit-records.o read-record.o write-record.o write-newline.o count-chars.o add-age.o
	ld $(BINARY)/read-record.o $(BINARY)/write-record.o $(BINARY)/edit-records.o \
		$(BINARY)/add-age.o $(BINARY)/write-newline.o $(BINARY)/count-chars.o \
		-m elf_i386 -o $(BINARY)/edit-records
	$(BINARY)/edit-records

bin:
	test -s $(BINARY) || mkdir $(BINARY)

write-record.o: bin write-record.s
	as write-record.s --32 -o $(BINARY)/write-record.o

read-record.o: bin read-record.s
	as read-record.s --32 -o $(BINARY)/read-record.o

write-newline.o: bin write-newline.s
	as write-newline.s --32 -o $(BINARY)/write-newline.o

count-chars.o: bin count-chars.s
	as count-chars.s --32 -o $(BINARY)/count-chars.o

add-age.o: bin add-age.s
	as add-age.s --32 -o $(BINARY)/add-age.o

write-records.o: bin write-records.s
	as write-records.s --32 -o $(BINARY)/write-records.o

read-records.o: bin read-records.s
	as read-records.s --32 -o $(BINARY)/read-records.o

edit-records.o: bin edit-records.s
	as edit-records.s --32 -o $(BINARY)/edit-records.o
clean:
	rm -rf $(BINARY)
	rm -rf *.dat