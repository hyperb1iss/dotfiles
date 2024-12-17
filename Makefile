BASEDIR=$(shell cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
DOTBOT=$(BASEDIR)/dotbot/bin/dotbot
INSTALL_STATE_FILE=$(BASEDIR)/.install_state

default:
	@echo "Available installation options:"
	@echo "  make full   - Full desktop environment installation"
	@echo "  make minimal - Minimal server installation"
	@echo ""
	@echo "Other commands:"
	@echo "  make update - Update submodules"
	@if [ -f $(INSTALL_STATE_FILE) ]; then \
		echo "Current installation type: $$(cat $(INSTALL_STATE_FILE))"; \
	else \
		echo "No previous installation detected"; \
	fi

update:
	cd $(BASEDIR)
	git submodule update --init --recursive

check-state:
	@if [ -f $(INSTALL_STATE_FILE) ]; then \
		if [ "$$(cat $(INSTALL_STATE_FILE))" != "$(TYPE)" ]; then \
			echo "Error: Attempting to install $(TYPE) over existing $$(cat $(INSTALL_STATE_FILE)) installation."; \
			echo "Please backup and remove ~/.* files before changing installation type."; \
			exit 1; \
		fi \
	fi

minimal: TYPE=minimal
minimal: check-state update
	@echo "minimal" > $(INSTALL_STATE_FILE)
	$(DOTBOT) -d $(BASEDIR) -c minimal.yaml

full: TYPE=full
full: check-state update
	@echo "full" > $(INSTALL_STATE_FILE)
	sudo $(DOTBOT) -d $(BASEDIR) -c system.yaml
	$(DOTBOT) -d $(BASEDIR) -c local.yaml

.PHONY: default update check-state minimal full
