BASEDIR=$(shell cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
DOTBOT=$(BASEDIR)/dotbot/bin/dotbot

default: all

update:
	cd $(BASEDIR)
	git submodule update --init --recursive dotbot
	git submodule update --init --recursive fzf

system:
	sudo $(DOTBOT) -d $(BASEDIR) -c system.yaml

local:
	$(DOTBOT) -d $(BASEDIR) -c local.yaml

all: update system local
