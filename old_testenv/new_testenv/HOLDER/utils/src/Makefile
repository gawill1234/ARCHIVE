SHELL   = /bin/bash
#
SUBDIR	=	tstlib ctools

all:
	for i in $(SUBDIR); do \
	   $(MAKE) -C $$i; \
	done
	cp normalize_dictionary.sh ../bin/

lib:
	$(MAKE) -C tstlib

ctools:
	$(MAKE) -C ctools

clean:
	for i in $(SUBDIR); do \
	   $(MAKE) -C $$i clean; \
	done
