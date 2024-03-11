export TOP := $(realpath $(dir $(realpath $(firstword $(MAKEFILE_LIST)))))

.PHONY: lint
lint:
	fd --glob '*.sh' --type f -u -a $(TOP) | xargs shellcheck -x

.PHONY: test
test:
	@echo "TOP is '$(TOP)'"
	$(TOP)/bats/bats-core/bin/bats -r $(TOP)/tests

gh_test:
	act pull_request
