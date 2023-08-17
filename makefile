#!/usr/bin/make -sf

# force use of Bash
SHELL := /bin/bash
INTERACTIVE=true


.PHONY: default
default: usage
usage:
	@printf "usage:"
	@printf "\tmake build-pure-on FISH_VERSION=3.3.1\t# build container\n"
	@printf "\tmake test-pure-on  FISH_VERSION=3.3.1\t# run tests\n"
	@printf "\tmake dev-pure-on   FISH_VERSION=3.3.1\t# dev in container\n"

.PHONY: build-pure-on
build-pure-on: STAGE?=only-fish
build-pure-on:
	docker build \
		--quiet \
		--file ./Dockerfile \
		--target ${STAGE} \
		--build-arg FISH_VERSION=${FISH_VERSION} \
		--tag=pure-${STAGE}-${FISH_VERSION} \
		./

.PHONY: dev-pure-on
dev-pure-on: CMD?=fish
dev-pure-on:
	chmod o=rwx tests/fixtures/ # for migration-to-4.0.0.test.fish only
	docker run \
		--name run-pure-on-${FISH_VERSION} \
		--rm \
		--interactive \
		--tty \
		--volume=$$(pwd):/home/nemo/.config/fish/pure/ \
		--workdir /home/nemo/.config/fish/pure/ \
		pure-${STAGE}-${FISH_VERSION} "${CMD}"
	chmod o=r-x tests/fixtures/ # for migration-to-4.0.0.test.fish only

.PHONY: test-pure-on
test-pure-on: CMD?=fishtape tests/*.test.fish
test-pure-on: STAGE?=with-pure-source
test-pure-on: build-with-pure-source
	docker run \
		--name run-pure-on-${FISH_VERSION} \
		--rm \
		--tty \
		pure-${STAGE}-${FISH_VERSION} "${CMD}"

.PHONY: build-with-pure-source
build-with-pure-source:
	$(MAKE) build-pure-on FISH_VERSION=${FISH_VERSION} STAGE=with-pure-source

.PHONY: build-with-pure-installed
build-with-pure-installed:
	$(MAKE) build-pure-on FISH_VERSION=${FISH_VERSION} STAGE=with-pure-installed


