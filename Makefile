SHELL := /bin/bash

.PHONY: all dep build clean test lint

all: dep build

.ONESHELL:
dep: ## Get the dependencies
	@git submodule update --init --recursive
	go mod download

.ONESHELL:
lint: ## Go lint the files
	@PKG_LIST=$$(go list ./... | grep -v /vendor/)
	@golint -set_exit_status $$PKG_LIST

fmt: ## Go fmt the files
	@gofmt -d timedrop


vet: ## Go vet the files
	@go vet ./timedrop

.ONESHELL:
build: ## Build the binary file
	@build/make_binaries.sh

clean: ## Remove previous build
	@rm -rf bin
	@rm -rf RPMS BUILD SRPMS SOURCES

rpm: ## Build RPM file
	@build/make_rpm.sh

help: ## Display this help screen
	@grep -h -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
