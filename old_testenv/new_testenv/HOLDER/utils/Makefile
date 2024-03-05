SHELL   = /bin/bash
#
SUBDIR	=	src bin

all:
	for i in $(SUBDIR); do \
	   $(MAKE) -C $$i; \
	done

src:
	$(MAKE) -C src

clean:
	for i in $(SUBDIR); do \
	   $(MAKE) -C $$i clean; \
	done
