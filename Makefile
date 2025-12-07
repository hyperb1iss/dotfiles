BASEDIR=$(shell cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
DOTBOT=$(BASEDIR)/dotbot/bin/dotbot
INSTALL_STATE_FILE=$(BASEDIR)/.install_state

default:
	@echo "Available installation options:"
	@echo "  make full   - Full desktop environment installation"
	@echo "  make minimal - Minimal server installation"
	@echo "  make macos  - macOS environment installation"
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

macos: TYPE=macos
macos: check-state update
	@echo "macos" > $(INSTALL_STATE_FILE)
	$(DOTBOT) -d $(BASEDIR) -c macos.yaml

# Colors for beautiful output
PURPLE := \033[1;35m
PINK := \033[1;95m
CYAN := \033[1;36m
GREEN := \033[1;32m
YELLOW := \033[1;33m
CORAL := \033[1;91m
GRAY := \033[0;90m
RESET := \033[0m
BOLD := \033[1m

# Unicode symbols
CHECK := ✓
ARROW := →
BULLET := •
WARNING := !
ERROR := ×

# Linting and formatting
lint: lint-header lint-shell lint-yaml lint-lua lint-json lint-markdown lint-footer

lint-header:
	@echo ""
	@echo "$(PURPLE)▶ $(CYAN)Running Linters$(RESET)"
	@echo ""

lint-shell:
	@echo "$(CYAN)$(ARROW)$(RESET) $(BOLD)Shell Scripts$(RESET)"
	@./bin/shellint --check sh/ bin/
	@echo ""

lint-yaml:
	@echo "$(PINK)$(ARROW)$(RESET) $(BOLD)YAML Files$(RESET)"
	@echo "  $(GRAY)$(BULLET) Validating with prettier...$(RESET)"
	-@git ls-files '*.yml' '*.yaml' | xargs npx prettier --check 2>&1 | sed 's/^/  │ /' || true
	@echo "  $(GREEN)$(CHECK) YAML linting complete$(RESET)"
	@echo ""

lint-lua:
	@echo "$(PURPLE)$(ARROW)$(RESET) $(BOLD)Lua Files$(RESET)"
	@echo "  $(GRAY)$(BULLET) Running selene...$(RESET)"
	-@cd nvim && selene lua 2>&1 | sed 's/^/  │ /' || true
	@echo "  $(GREEN)$(CHECK) Lua linting complete$(RESET)"
	@echo ""

lint-json:
	@echo "$(CORAL)$(ARROW)$(RESET) $(BOLD)JSON Files$(RESET)"
	@echo "  $(GRAY)$(BULLET) Validating JSON...$(RESET)"
	-@git ls-files '*.json' | xargs -I {} sh -c \
		'jq . {} > /dev/null 2>&1 || echo "  │ $(YELLOW)$(WARNING)$(RESET) Invalid JSON: {}"' || true
	@echo "  $(GREEN)$(CHECK) JSON validation complete$(RESET)"
	@echo ""

lint-markdown:
	@echo "$(YELLOW)$(ARROW)$(RESET) $(BOLD)Markdown Files$(RESET)"
	@echo "  $(GRAY)$(BULLET) Running markdownlint...$(RESET)"
	-@git ls-files '*.md' | xargs -n1 markdownlint 2>&1 | \
		sed 's/^/  │ /' || true
	@echo "  $(GREEN)$(CHECK) Markdown linting complete$(RESET)"
	@echo ""

lint-footer:
	@echo ""
	@echo "$(GREEN)$(CHECK)$(RESET) $(BOLD)All linting checks completed!$(RESET)"
	@echo ""

format: format-header format-shell format-prettier format-lua format-footer

format-header:
	@echo ""
	@echo "$(PURPLE)▶ $(PINK)Running Formatters$(RESET)"
	@echo ""

format-shell:
	@echo "$(CYAN)$(ARROW)$(RESET) $(BOLD)Shell Scripts$(RESET)"
	@./bin/shellint --format --fix sh/ bin/
	@echo ""

format-prettier:
	@echo "$(PINK)$(ARROW)$(RESET) $(BOLD)YAML, JSON & Markdown Files$(RESET)"
	@echo "  $(GRAY)$(BULLET) Formatting with prettier...$(RESET)"
	-@git ls-files '*.yml' '*.yaml' '*.json' '*.md' | xargs npx prettier --write 2>&1 | \
		grep -v "unchanged" | sed 's/^/  │ /' || true
	@echo ""

format-lua:
	@echo "$(PURPLE)$(ARROW)$(RESET) $(BOLD)Lua Files$(RESET)"
	@echo "  $(GRAY)$(BULLET) Formatting with stylua...$(RESET)"
	-@cd nvim && stylua lua 2>&1 | sed 's/^/  │ /' || true
	@echo ""

format-footer:
	@echo ""
	@echo "$(GREEN)$(CHECK)$(RESET) $(BOLD)All formatting completed!$(RESET)"
	@echo ""

.PHONY: default update check-state minimal full macos lint lint-header lint-shell lint-yaml lint-lua lint-json lint-markdown lint-footer format format-header format-shell format-yaml format-lua format-json format-markdown format-footer
