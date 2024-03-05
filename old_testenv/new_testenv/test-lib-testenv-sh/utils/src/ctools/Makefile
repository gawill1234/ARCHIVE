SHELL   = /bin/bash
#
#
MY_PROGS =	genrand randstring vtd mbinstr genbinfname valid_repo
CC      =       gcc
#
CFLAGS =        -I "$(TEST_ROOT)/include"
LDFLAGS =	-L "$(TEST_ROOT)/lib" -ltst
ORALIB = 	-lora
#
AR      =       ar
RM      =       rm
#
#

%:%.c
	$(CC) $(CFLAGS) $< -o $@ $(LDFLAGS)
%.o:%.c
	$(CC) $(CFLAGS) -c $< -o $@

all:	$(MY_PROGS) $(ORA_PROGS)
ifdef TEST_ROOT
	for FILE in $(MY_PROGS); do \
	   cp $${FILE} "$(TEST_ROOT)/bin/$${FILE}"; \
	done; \
	$(MAKE) -C dus; \
	$(MAKE) -C node_check; \
	$(MAKE) -C lrd_create
else
	echo 'TEST_ROOT not set.'
endif

valid_repo:	valid_repo.c
	$(CC) $(CFLAGS) $< -o $@ $(LDFLAGS)

genbinfname:	genbinfname.c
	$(CC) $(CFLAGS) $< -o $@ $(LDFLAGS)

mbinstr:	mbinstr.c
	$(CC) $(CFLAGS) $< -o $@ $(LDFLAGS)

genrand:	genrand.c
	$(CC) $(CFLAGS) $< -o $@ $(LDFLAGS)

randstring:	randstring.c
	$(CC) $(CFLAGS) $< -o $@ $(LDFLAGS)

vtd:	vtd.c
	$(CC) $(CFLAGS) $< -o $@ $(LDFLAGS)

clean:
ifdef TEST_ROOT
	for FILE in $(MY_PROGS); do \
	   rm $${FILE}; \
	   rm $${FILE}.o; \
	   rm $(TEST_ROOT)/bin/$${FILE}; \
	done; \
	$(MAKE) -C dus clean; \
	$(MAKE) -C node_create clean; \
	$(MAKE) -C lrd_create clean
else
	echo 'TEST_ROOT not set.'
endif

