BASEDIR := $(CURDIR)
DOTBOT := $(BASEDIR)/dotbot/bin/dotbot
LAYERS := $(BASEDIR)/dotbot.d
ROLE_FILE := $(BASEDIR)/.dotfiles_role

# Layers compose instead of conflicting: base -> os -> role -> host -> private.
# OS comes from uname, role defaults to desktop, and the host layer is picked
# up only when dotbot.d/host/<hostname>.yaml actually exists.
ifeq ($(shell uname -s),Darwin)
DETECTED_OS := macos
else
DETECTED_OS := linux
endif

OS ?= $(DETECTED_OS)
ROLE ?= desktop
HOST ?= $(shell hostname -s 2>/dev/null || hostname)

BASE_LAYER := $(LAYERS)/base.yaml
OS_LAYER := $(LAYERS)/os/$(OS).yaml
ROLE_LAYER := $(LAYERS)/role/$(ROLE).yaml
HOST_LAYER := $(wildcard $(LAYERS)/host/$(HOST).yaml)
PRIVATE_LAYER := $(if $(wildcard $(HOME)/dev/dotfiles-private),$(LAYERS)/private.yaml,)

# The server role skips the os layer on purpose: os/linux.yaml is the graphical
# stack (ghostty, pipewire, ignis, containers) and headless boxes want none of
# it. Desktops get the full stack.
ifeq ($(ROLE),server)
LAYER_CONFIGS := $(BASE_LAYER) $(ROLE_LAYER) $(HOST_LAYER) $(PRIVATE_LAYER)
else
LAYER_CONFIGS := $(BASE_LAYER) $(OS_LAYER) $(ROLE_LAYER) $(HOST_LAYER) $(PRIVATE_LAYER)
endif

default:
	@echo "Detected: os=$(OS) role=$(ROLE) host=$(HOST)"
	@echo ""
	@echo "Available installation options:"
	@echo "  make install - Compose the layers for this machine (default)"
	@echo "  make server  - Minimal headless install (alias: make minimal)"
	@echo "  make full    - System tier under sudo, then the composed install"
	@echo "  make macos   - Alias for make install (macOS is auto-detected)"
	@echo "  make system  - System tier only (Linux, sudo)"
	@echo "  make private - Apply private overlay (dotfiles-private)"
	@echo ""
	@echo "Other commands:"
	@echo "  make update  - Update submodules"
	@echo "  make smoke   - Run the CI install smoke matrix on this machine"
	@echo "  make lint    - Lint shell, yaml, lua, json, markdown, PowerShell"
	@echo "  make format  - Reformat everything the linters check"
	@echo "  make test    - Run the Pester suite for the PowerShell profile"
	@echo ""
	@echo "Layers for this machine:"
	@for layer in $(LAYER_CONFIGS); do echo "  $$layer"; done

update:
	git -C $(BASEDIR) submodule update --init --recursive

install: update
	SHELL=/bin/bash $(DOTBOT) -d $(BASEDIR) -c $(LAYER_CONFIGS)
	@printf '%s\n' "$(ROLE)" > $(ROLE_FILE)

# Thin aliases so muscle memory and the docs keep working.
macos: install

server:
	@$(MAKE) ROLE=server install

minimal: server

system:
	@if [ "$(DETECTED_OS)" != "linux" ]; then \
		echo "make system is Linux only; skipping on $(DETECTED_OS)"; \
	else \
		sudo SHELL=/bin/bash $(DOTBOT) -d $(BASEDIR) -c $(LAYERS)/os/linux-system.yaml; \
	fi

full: system
	@$(MAKE) install

private: update
	SHELL=/bin/bash $(DOTBOT) -d $(BASEDIR) -c $(LAYERS)/private.yaml

# The install smoke matrix, run here instead of waiting on CI: the same
# scripts .github/workflows/install-smoke.yml calls, so the two cannot
# drift. Containers need docker or podman; without one it runs the
# link-only dry run and says what it skipped. Nothing touches $(HOME).
smoke:
	@./.github/smoke/local.sh

# Colors for beautiful output
PURPLE := \033[1;35m
PINK := \033[1;95m
CYAN := \033[1;36m
GREEN := \033[1;32m
YELLOW := \033[1;33m
CORAL := \033[1;91m
BLUE := \033[1;94m
GRAY := \033[0;90m
RESET := \033[0m
BOLD := \033[1m

# Unicode symbols
CHECK := ✓
ARROW := →
BULLET := •
WARNING := !
ERROR := ×

# PowerShell 7 installs as `pwsh`; the preview channel installs as
# `pwsh-preview`, so take whichever is on PATH. Empty means no PowerShell
# on this box, and every ps target then skips instead of failing.
PWSH := $(shell command -v pwsh 2> /dev/null || command -v pwsh-preview 2> /dev/null)

# Linting and formatting
#
# lint-ps runs last on purpose: it is the only linter besides lint-shell
# that can fail the chain, and a failing prerequisite stops make, so
# putting it at the end means a PowerShell finding never hides the yaml,
# lua, json or markdown output.
lint: lint-header lint-shell lint-yaml lint-lua lint-json lint-markdown lint-ps lint-footer

lint-header:
	@echo ""
	@echo "$(PURPLE)▶ $(CYAN)Running Linters$(RESET)"
	@echo ""

lint-shell:
	@echo "$(CYAN)$(ARROW)$(RESET) $(BOLD)Shell Scripts$(RESET)"
	@./bin/shellint --check sh/ bin/ .github/smoke/
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

# PSScriptAnalyzer over every tracked .ps1/.psm1/.psd1. Severity policy
# lives in bin/pslint.ps1: Error and Warning are blocking and fail this
# target, Information is printed and ignored. Rule selection comes from
# PSScriptAnalyzerSettings.psd1 when the repo ships one, else PSGallery.
lint-ps:
	@echo "$(BLUE)$(ARROW)$(RESET) $(BOLD)PowerShell Scripts$(RESET)"
	@if [ -n "$(PWSH)" ]; then \
		$(PWSH) -NoProfile -NoLogo -File ./bin/pslint.ps1; \
	else \
		echo "  $(GRAY)$(BULLET) pwsh not installed, skipping$(RESET)"; \
	fi
	@echo ""

lint-footer:
	@echo ""
	@echo "$(GREEN)$(CHECK)$(RESET) $(BOLD)All linting checks completed!$(RESET)"
	@echo ""

format: format-header format-shell format-prettier format-lua format-ps format-footer

format-header:
	@echo ""
	@echo "$(PURPLE)▶ $(PINK)Running Formatters$(RESET)"
	@echo ""

format-shell:
	@echo "$(CYAN)$(ARROW)$(RESET) $(BOLD)Shell Scripts$(RESET)"
	@./bin/shellint --format --fix sh/ bin/ .github/smoke/
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

format-ps:
	@echo "$(BLUE)$(ARROW)$(RESET) $(BOLD)PowerShell Scripts$(RESET)"
	@if [ -n "$(PWSH)" ]; then \
		$(PWSH) -NoProfile -NoLogo -File ./bin/pslint.ps1 -Format; \
	else \
		echo "  $(GRAY)$(BULLET) pwsh not installed, skipping$(RESET)"; \
	fi
	@echo ""

format-footer:
	@echo ""
	@echo "$(GREEN)$(CHECK)$(RESET) $(BOLD)All formatting completed!$(RESET)"
	@echo ""

# Tests
test: test-header test-ps test-footer

test-header:
	@echo ""
	@echo "$(PURPLE)▶ $(CYAN)Running Tests$(RESET)"
	@echo ""

# Pester over hypershell/tests. The directory and the module it exercises
# arrive together, so until then this skips loudly rather than failing.
# Pester 5 or newer is required: -CI is what turns a failed test into a
# nonzero exit code.
test-ps:
	@echo "$(BLUE)$(ARROW)$(RESET) $(BOLD)PowerShell Tests$(RESET)"
	@if [ -z "$(PWSH)" ]; then \
		echo "  $(GRAY)$(BULLET) pwsh not installed, skipping$(RESET)"; \
	elif [ -z "$$(ls hypershell/tests/*.Tests.ps1 2> /dev/null)" ]; then \
		echo "  $(GRAY)$(BULLET) no hypershell/tests/*.Tests.ps1 yet, skipping$(RESET)"; \
	else \
		$(PWSH) -NoProfile -NoLogo -Command \
			"if (Get-Module -ListAvailable -Name Pester) { Invoke-Pester -Path hypershell/tests -CI } else { Write-Host '  Pester not installed but tests exist; install Pester 6'; exit 1 }"; \
	fi
	@echo ""

test-footer:
	@echo ""
	@echo "$(GREEN)$(CHECK)$(RESET) $(BOLD)All tests completed!$(RESET)"
	@echo ""

.PHONY: default update install macos server minimal system full private smoke lint lint-header lint-shell lint-yaml lint-lua lint-json lint-markdown lint-ps lint-footer format format-header format-shell format-prettier format-lua format-ps format-footer test test-header test-ps test-footer
