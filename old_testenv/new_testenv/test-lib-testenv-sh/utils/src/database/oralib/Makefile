SHELL   = /bin/bash
#
CC      =       gcc
PROC	=	proc
#
INCLUDEDIR0 =	$(ORACLE_HOME)/precomp/public
INCLUDEDIR1 =	$(ORACLE_HOME)/rdbms/public
LIBDIR =	$(ORACLE_HOME)/lib
PROCFLAGS =	MODE=ORACLE INCLUDE=$(INCLUDEDIR1)
CFLAGS =        -c -I $(INCLUDEDIR0) -I $(INCLUDEDIR1)
#
AR      =       ar
RM      =       rm
#
#

.c.o:
	$(CC) $(CFLAGS) $<

OBJ	=	common.o freecddb.o

ifdef ORACLE_HOME
ifdef TEST_ROOT
all:	$(OBJ)
	$(AR) r libtstora.a $(OBJ)
	$(RM) tp*
	cp commonora.h $(TEST_ROOT)/include
	cp libtstora.a $(TEST_ROOT)/lib
else
all:
	   echo "TEST_ROOT not defined"
endif
else
all:
	   echo "ORACLE_HOME not defined"
endif

common.o:	common.pc
		$(PROC) INAME=common $(PROCFLAGS)
		$(CC) $(CFLAGS) common.c
		$(RM) common.c
		$(RM) common.lis

freecddb.o:	freecddb.pc
		$(PROC) INAME=freecddb $(PROCFLAGS)
		$(CC) $(CFLAGS) freecddb.c
		$(RM) freecddb.c
		$(RM) freecddb.lis

