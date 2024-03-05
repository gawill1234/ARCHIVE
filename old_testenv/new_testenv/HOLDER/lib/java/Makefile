SHELL   = /bin/bash
#
SUBDIR	= Packages cleanCollection

all:
	for i in $(SUBDIR); do \
           $(MAKE) -C $$i; \
        done

API:
	$(MAKE) -C API


clean:
	for i in $(SUBDIR); do \
           $(MAKE) -C $$i clean; \
        done
