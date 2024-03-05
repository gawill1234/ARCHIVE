SHELL   = /bin/bash
#
CC      =       gcc
#
CFLAGS =        -c
#
AR      =       ar
RM      =       rm
#
#

.c.o:
	$(CC) $(CFLAGS) $<

OBJ	=	basename.o filedir.o myreadline.o \
		pathndiralloc.o randomfn.o streq.o

all:	$(OBJ);
	$(AR) r libtst.a $(OBJ);
	cp test.h "$(TEST_ROOT)/include";
	cp libtst.a "$(TEST_ROOT)/lib"

basename.o:	basename.c
filedir.o:	filedir.c
myreadline.o:	myreadline.c
pathndiralloc.o:	pathndiralloc.c
randomfn.o:	randomfn.c
streq.o:	streq.c

clean:
	rm "$(TEST_ROOT)/lib/libtst.a"
	rm libtst.a
	rm *.o
