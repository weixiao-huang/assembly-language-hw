
write: write-records.s write-record.s 
	as write-records.s --32 -o write-records.o
	as write-record.s --32 -o write-record.o
	ld write-record.o write-records.o -m elf_i386 -o write-records

read: read-records.s read-record.s
	as read-records.s --32 -o read-records.o
	as read-record.s --32 -o read-record.o
	as write-newline.s --32 -o write-newline.o
	as count-chars.s --32 -o count-chars.o
	as add-age.s --32 -o add-age.o
	ld read-record.o read-records.o add-age.o write-newline.o count-chars.o -m elf_i386 -o read-records

edit: edit-records.s read-record.s write-record.s
	as edit-records.s --32 -o edit-records.o
	as read-record.s --32 -o read-record.o
	as write-record.s --32 -o write-record.o
	as write-newline.s --32 -o write-newline.o
	as count-chars.s --32 -o count-chars.o
	as add-age.s --32 -o add-age.o
	ld read-record.o write-record.o edit-records.o add-age.o write-newline.o count-chars.o -m elf_i386 -o edit-records

clean:
	rm *.o
	rm write-records
	rm read-records
	rm edit-records