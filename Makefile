TOPTARGETS := all clean build 

SUBDIRS := $(wildcard lambda/*/.)
BASE = $(shell /bin/pwd)

$(TOPTARGETS): $(SUBDIRS)

$(SUBDIRS):
	$(MAKE) -C $@ $(MAKECMDGOALS) $(ARGS) BASE="${BASE}"

.PHONY: $(TOPTARGETS) $(SUBDIRS)

clean:
	rm -f .terraform.lock.hcl
	rm -rf .terraform	
	rm -rf ./lambda/*.zip
	rm -f ./test/go.mod
	rm -f ./test/go.sum
	rm -f tf.json
	rm -f tf.plan
	rm -f *.tfvars
	rm -f ./tests/*.auto.tfvars
	rm -f ./tests/setup/.terraform.lock.hcl
	rm -f ./tests/validate/.terraform.lock.hcl
	rm -rf ./tests/setup/.terraform	
	rm -rf ./tests/validate/.terraform	