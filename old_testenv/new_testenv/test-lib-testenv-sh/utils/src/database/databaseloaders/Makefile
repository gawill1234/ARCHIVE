SHELL   = /bin/bash
#
CC      =       gcc
PROC	=	proc
#
INCLUDEDIR0 =	$(ORACLE_HOME)/precomp/public
INCLUDEDIR1 =	$(ORACLE_HOME)/rdbms/public
INCLUDEDIR2 =	$(TEST_ROOT)/include
LIBDIR =	$(ORACLE_HOME)/lib
PROCFLAGS =	MODE=ORACLE INCLUDE=$(INCLUDEDIR1)
CFLAGS =        -c -I $(INCLUDEDIR0) -I $(INCLUDEDIR1) -I $(INCLUDEDIR2)
LDFLAGS =	-L $(TEST_ROOT)/lib -L $(LIBDIR) -ltst -ltstora -lsqlplus
#
AR      =       ar
RM      =       rm
#
#

.c.o:
	$(CC) $(CFLAGS) $<

OBJ	=	readit

ifdef ORACLE_HOME
ifdef TEST_ROOT
all:	$(OBJ)
else
all:
	   echo "TEST_ROOT not defined"
endif
else
all:
	   echo "ORACLE_HOME not defined"
endif

readit:		readit.c
		$(CC) $(CFLAGS) $<
		$(CC) -o readit readit.o $(LDFLAGS)


