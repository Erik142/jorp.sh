export TOP := $(realpath $(dir $(realpath $(firstword $(MAKEFILE_LIST)))))

.PHONY: test
test:
	@echo "TOP is '$(TOP)'"
	$(TOP)/bats/bats-core/bin/bats -r $(TOP)/tests

gh_test:
	act pull_request
