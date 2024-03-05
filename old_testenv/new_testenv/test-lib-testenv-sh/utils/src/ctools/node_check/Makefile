SHELL   = /bin/bash
#
CC      =       gcc
#
CFLAGS =  -c
#
#

.c.o:
	$(CC) $(CFLAGS) $<

SRC =	get_data.c string_proc.c

OBJ =	get_data.o string_proc.o

linux:
	for item in $(SRC); do \
		$(CC) -D__LINUX__ -c $${item}; \
	done; \
	$(CC) -o qry_node_check $(OBJ); \
	cp qry_node_check $(TEST_ROOT)/utils/bin/qry_node_check

sun:
	for item in $(SRC); do \
		$(CC) -D__SUNOS__ -c $${item}; \
	done; \
	$(CC) -o qry_node_check $(OBJ); \
	cp qry_node_check $(TEST_ROOT)/utils/bin/qry_node_check

windows:
	for item in $(SRC); do \
		$(CC) -DPLATFORM_WINDOWS -mno-cygwin -mwindows -I/usr/include/w32api -c $${item}; \
	done; \
	$(CC) -mno-cygwin -mwindows -o qry_node_check $(OBJ) -L/usr/lib/w32api -lpsapi

clean:
	rm -f qry_node_check qry_node_check.exe
	rm *.o


get_data.o:	get_data.c
string_proc.o:	string_proc.c
