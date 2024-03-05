SHELL   = /bin/bash
#
SUBDIR	= java

all:
	./builder.py
	for i in $(SUBDIR); do \
           $(MAKE) -C $$i; \
        done

clean:
	rm *.class build.xml velocity.jar; \
	rm -rf build soapfault src; \
	for i in $(SUBDIR); do \
           $(MAKE) -C $$i clean; \
        done

