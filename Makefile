BASEDIR=$(shell cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
DOTBOT=$(BASEDIR)/dotbot/bin/dotbot

default: all

update:
	cd $(BASEDIR)
	git submodule update --init --recursive dotbot

install_system:
	sudo $(DOTBOT) -d $(BASEDIR) -c system.yaml

install_local:
	$(DOTBOT) -d $(BASEDIR) -c local.yaml

all: update install_system install_local
