SHELL   = /bin/bash
#
CC      =       gcc
#
CFLAGS =  -c
#
#

.c.o:
	$(CC) $(CFLAGS) $<

SRC =	get_data.c url_decode.c

OBJ =	get_data.o url_decode.o

linux:
	for item in $(SRC); do \
		$(CC) -D__LINUX__ -c $${item}; \
	done; \
	$(CC) -o dus $(OBJ); \
	cp dus $(TEST_ROOT)/utils/bin/dus

sun:
	for item in $(SRC); do \
		$(CC) -D__SUNOS__ -c $${item}; \
	done; \
	$(CC) -o dus $(OBJ); \
	cp dus $(TEST_ROOT)/utils/bin/dus

windows:
	for item in $(SRC); do \
		$(CC) -DPLATFORM_WINDOWS -mno-cygwin -mwindows -I/usr/include/w32api -c $${item}; \
	done; \
	$(CC) -mno-cygwin -mwindows -o dus $(OBJ) -L/usr/lib/w32api -lpsapi

clean:
	rm -f dus dus.exe
	rm *.o


get_data.o:	get_data.c
url_decode.o:	url_decode.c
