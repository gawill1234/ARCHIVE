SHELL   = /bin/bash
#
CC      =       gcc
#
CFLAGS =  -c
#
#

.c.o:
	$(CC) $(CFLAGS) $<

SRC =	dir_read.c string_proc.c

OBJ =	dir_read.o string_proc.o

linux:
	for item in $(SRC); do \
		$(CC) -D__LINUX__ -c $${item}; \
	done; \
	$(CC) -o dir_comp $(OBJ); \
	cp dir_comp $(TEST_ROOT)/utils/bin/dir_comp

sun:
	for item in $(SRC); do \
		$(CC) -D__SUNOS__ -c $${item}; \
	done; \
	$(CC) -o dir_comp $(OBJ); \
	cp dir_comp $(TEST_ROOT)/utils/bin/dir_comp

windows:
	for item in $(SRC); do \
		$(CC) -DPLATFORM_WINDOWS -mno-cygwin -mwindows -I/usr/include/w32api -c $${item}; \
	done; \
	$(CC) -mno-cygwin -mwindows -o dir_comp $(OBJ) -L/usr/lib/w32api -lpsapi

clean:
	rm -f dir_comp dir_comp.exe
	rm *.o


dir_read.o:	dir_read.c
string_proc.o:	string_proc.c
