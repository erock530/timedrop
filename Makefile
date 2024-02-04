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
version: ## Build version info
	@echo "Building version information ..."
	export $$(.circleci/semver/version | xargs) && echo "Version: $${VERSION}$${METADATA}"

build: ## Build the binary file
	@build/make_binaries.sh

docker: ## Build docker image
		@VERSION=$$(./build/version.sh)
		@podman build -t erock530/timedrop:$$VERSION -f Dockerfile .

rpm: ## Build the RPM
	@echo "Building RPM ..."
	    export $$(.circleci/semver/version | xargs) && \
    	    sed "s/{{VERSION}}/$${VERSION}/" build/timedrop.spect > build/timedrop.spec && \
    	    sed -i "s/{{RELEASE}}/$${RELEASE}$${METADATA}/" build/timedrop.spec
	rpmbuild -bb build/timedrop.spec --define "_sourcedir ${PWD}" --define "_rpmdir /tmp/rpmbuild/RPMS" # "_rpmdir ${PWD}/rpmbuild/RPMS"
	rm -f build/timedrop.spec
	cp /tmp/rpmbuild/RPMS/x86_64/timedrop-$${VERSION}-$${RELEASE}$${METADATA}*.rpm .
	@echo "RPM Created"

showrpmname: ## returns just the rpm file name
	@export $$(.circleci/semver/version | xargs)
	@echo timedrop-$${VERSION}-$${RELEASE}$${METADATA}*.rpm

releaseinfo: ## Generate changelog and version.env files in releaseinfo folder
	@mkdir -p releaseinfo
	@./.circleci/semver/changelog -l > releaseinfo/CHANGELOG
	@./.circleci/semver/version > releaseinfo/version.env

release: ## Generate git tag for current source and push new tag to github
	@$(eval REV=$(shell git rev-list main --count))
	@echo "Creating tag v1.0.$(REV)"
	@git tag -d v1.0.$(REV) &> /dev/null && git push --delete origin v1.0.$(REV) &> /dev/null
	@git tag -a v1.0.$(REV) -m "Release v1.0.$(REV)"; git push origin v1.0.$(REV)

prerelease: ## Gerate git tag for pre-release and push new tag to github
	export $$(.circleci/semver/version $(shell git branch --show-current) | xargs) 
	@echo "Creating pre-release tag v$${VERSION}-$${RELEASE}$${METADATA}"
	@git tag -d v$${VERSION}-$${RELEASE}$${METADATA} &> /dev/null && git push --delete origin v$${VERSION}-$${RELEASE}$${METADATA} &> /dev/null
	@git tag -a v$${VERSION}-$${RELEASE}$${METADATA} -m "Pre-Release v$${VERSION}-$${RELEASE}$${METADATA}"; git push origin v$${VERSION}-$${RELEASE}$${METADATA}

prerpm: ## Build the pre-release RPM
	@echo "Building pre-release RPM ..."
	export $$(.circleci/semver/version $$(git branch --show-current) | xargs) && \
				sed "s/{{VERSION}}/$${VERSION}/" build/timedrop.spect > build/timedrop.spec && \
				sed -i "s/{{RELEASE}}/$${RELEASE}$${METADATA}/" build/timedrop.spec
	rpmbuild -bb build/timedrop.spec --define "_sourcedir ${PWD}" --define "_rpmdir /tmp/rpmbuild/RPMS" # "_rpmdir ${PWD}/rpmbuild/RPMS"
	rm -f build/timedrop.spec
	cp /tmp/rpmbuild/RPMS/x86_64/timedrop-$${VERSION}-$${RELEASE}$${METADATA}*.rpm .
	@echo "RPM Created"

clean: ## Remove previous build
	@rm -rf bin
	@rm -rf timedrop-*rpm

help: ## Display this help screen
	@grep -h -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
