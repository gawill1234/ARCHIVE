SHELL   = /bin/bash
#
CC      =       gcc
#
CFLAGS =  -c
#
#

.c.o:
	$(CC) $(CFLAGS) $<

SRC =	data.c gen_name.c gtmxbyt.c main.c node_create.c \
	wordread.c do_updates.c getfssz.c list_track.c \
	namesys.c unique_file.c

OBJ =	data.o gen_name.o gtmxbyt.o main.o node_create.o \
	wordread.o do_updates.o getfssz.o list_track.o \
	namesys.o unique_file.o

linux:
	for item in $(SRC); do \
		$(CC) -D__LINUX__ -c $${item}; \
	done; \
	$(CC) -o lrd_create $(OBJ) -lpthread; \
	cp lrd_create $(TEST_ROOT)/utils/bin/lrd_create

sun:
	for item in $(SRC); do \
		$(CC) -D__SUNOS__ -c $${item}; \
	done; \
	$(CC) -o lrd_create $(OBJ) -lpthread; \
	cp lrd_create $(TEST_ROOT)/utils/bin/lrd_create

windows:
	for item in $(SRC); do \
		$(CC) -DPLATFORM_WINDOWS -mno-cygwin -mwindows -I/usr/include/w32api -c $${item}; \
	done; \
	$(CC) -mno-cygwin -mwindows -o lrd_create $(OBJ) -L/usr/lib/w32api -lpsapi

clean:
	rm -f lrd_create lrd_create.exe
	rm *.o


main.o:		main.c
data.o:		data.c
gen_name.o:	gen_name.c
gtmxbyt.o:	gtmxbyt.c
node_create.o:	node_create.c
wordread.o:	wordread.c
do_updates.o:	do_updates.c
getfssz.o:	getfssz.c
list_track.o:	list_track.c
namesys.o:	namesys.c
unique_file.o:	unique_file.c
