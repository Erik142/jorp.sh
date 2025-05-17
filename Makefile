ifneq ($(VERBOSE),$(empty))
	Q := $(empty)
else
	Q := @
endif

export TOP := $(realpath $(dir $(realpath $(firstword $(MAKEFILE_LIST)))))

.PHONY: lint
lint:
	$(Q)fd --ignore-file $(TOP)/.lintignore -e 'sh' -e 'bats' --type f -u -a . $(TOP) | xargs shellcheck -x

.PHONY: test
test:
	$(Q)$(TOP)/bats/bats-core/bin/bats -r $(TOP)/tests

gh_test:
	$(Q)act pull_request
