TOPTARGETS := all clean build 

SUBDIRS := $(wildcard lambda/*/.)
BASE = $(shell /bin/pwd)

$(TOPTARGETS): $(SUBDIRS)

$(SUBDIRS):
	$(MAKE) -C $@ $(MAKECMDGOALS) $(ARGS) BASE="${BASE}"

.PHONY: $(TOPTARGETS) $(SUBDIRS)