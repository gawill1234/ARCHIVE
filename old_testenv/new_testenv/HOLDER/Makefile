SHELL   = /bin/bash
#
SUBDIR = lib utils

all:
	mkdir -p bin
	for i in $(SUBDIR); do \
	   $(MAKE) -C $$i; \
	done

utils:
	$(MAKE) -C utils

clean:
	for i in $(SUBDIR); do \
	   $(MAKE) -C $$i clean; \
	done

