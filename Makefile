#!/usr/bin/make -f
# -*- makefile -*-
#
# Copyright 2015-2016 Kouhei Maeda <mkouhei@palmtb.net>
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#	  http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

REPO := $(shell git config remote.origin.url)

ifneq ($(REPO),)
GOPKG :=$(shell python -c 'print("$(REPO)".replace("git@", "").replace(":", "/").replace(".git", ""))')
BIN := $(shell python -c 'print("$(GOPKG)".rsplit("/", 1)[1])')
endif
GOVET := $(shell go tool vet >/dev/null 2>&1; echo $$?)
GOCOVER := $(shell go tool cover >/dev/null 2>&1; echo $$?)

MSG := [usage] make REPO=\"git remote repository URL\"

SRC := *.go
GOPATH := $(CURDIR)/_build
export GOPATH
PATH := $(CURDIR)/_build/bin:$(PATH)
export PATH
# "FLAGS=" when no update package
FLAGS := $(shell test -d $(GOPATH) && echo "-u")

ifdef FLAGS
VENVFLAG := --clear
PIPFLAG := -U
else
VENVFLAG :=
PIPFLAG :=
endif

# "FUNC=-html" when generate HTML coverage report
FUNC := -func

-include $(wildcard *.in)

all: precheck clean test build build-docs ## make all

precheck: ## precheck
ifeq ($(GOPKG),)
	@echo $(MSG)
	@false
else
ifeq ($(REPO),)
	@echo $(MSG)
	@false
else
	GOPKG=$(shell python -c 'print("$(REPO)".replace("git@", "").replace(":", "/").replace(".git", ""))')
	@if [ ! -d $(CURDIR)/.git ]; then \
		git init; \
	fi
	@if [ -z $$(git config remote.origin.url) ]; then \
		git remote add origin $(REPO);\
	fi
endif
endif
	@if [ ! -d $(CURDIR)/.git/hooks ]; then\
		install -d $(CURDIR)/.git/hooks;\
	fi
	@if [ ! -x $(CURDIR)/.git/hooks/pre-commit ]; then \
		echo "#!/bin/sh -e\n\nmake" > $(CURDIR)/.git/hooks/pre-commit;\
		chmod +x $(CURDIR)/.git/hooks/pre-commit;\
	fi

prebuild: $(SRC) ## pre-build
	go get -d -v ./...
	install -d $(CURDIR)/_build/src/$(GOPKG)
	$(PREBUILD_CMD)
	cp -a $(PREBUILD_COPY_OPTS) $(CURDIR)/*.go $(CURDIR)/_build/src/$(GOPKG)

build: prebuild ## go build
	go build -ldflags "-X main.ver=$(shell git describe --always)" -o _build/$(BIN)

build-only: $(SRC) ## go build only
	go build -ldflags "-X main.ver=$(shell git describe --always)" -o _build/$(BIN)

prebuild-docs: ## pre-build documentation
	@if [ -d $(CURDIR)/docs ] && [ -f $(CURDIR)/docs/requirements.txt ]; then \
		virtualenv $(VENVFLAG) _build/venv;\
		_build/venv/bin/pip install $(PIPFLAG) -r docs/requirements.txt;\
	fi

build-docs: prebuild-docs ## build documentation
	@if [ -d $(CURDIR)/docs ] && [ -f $(CURDIR)/docs/requirements.txt ]; then \
		. _build/venv/bin/activate;\
		cd docs;\
		make html;\
		deactivate;\
	fi

clean: ## clean _build directory
	@rm -rf _build/$(BIN) $(GOPATH)/src/$(GOPKG)

test: prebuild ## go test
	go get $(FLAGS) golang.org/x/tools/cmd/goimports
	go get $(FLAGS) github.com/golang/lint/golint
ifneq ($(GOVET),1)
	go get $(FLAGS) golang.org/x/tools/cmd/vet
endif
ifneq ($(GOCOVER),1)
	go get $(FLAGS) golang.org/x/tools/cmd/cover
endif
	_build/bin/golint
	go vet
	go test -v -covermode=count -coverprofile=c.out $(GOPKG)
	@if [ -f c.out ]; then \
		go tool cover $(FUNC)=c.out; \
		unlink c.out; \
	fi;\
	rm -f $(BIN).test main.test
	for src in $(SRC); do \
		gofmt -w $$src ;\
		goimports -w $$src; \
	done

help:
	@grep -h -P '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.PHONY:	help
#.DEFAULT_GOAL := help
