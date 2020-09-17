PACKAGE=carlodepieri/docker-archlinux-ansible
VERSION=latest
TAG=$(PACKAGE):$(VERSION)
NAME=cdp-arch-ansible
SHELL := /bin/bash
ACT_GITHUB_WORKSPACE := /github/workspace

all: build

ci: build run test

build: build-image

run: run-container

shell:
	docker exec -it $(NAME) env TERM=xterm bash

build-image:
	docker build -t $(TAG) .

run-container:
	docker run --name=$(NAME) --detach --privileged --volume=/sys/fs/cgroup:/sys/fs/cgroup:ro --volume=`pwd`:/etc/ansible/roles/role_under_test:ro $(TAG)

run-container-act:
	docker run --name=$(NAME) --detach --privileged --volume=/sys/fs/cgroup:/sys/fs/cgroup:ro $(TAG) && \
	sleep 1 && \
	docker exec -i $(NAME) mkdir -p /etc/ansible/roles/role_under_test && \
	docker cp $(ACT_GITHUB_WORKSPACE)/. $(NAME):/etc/ansible/roles/role_under_test/.

test:
	docker exec -i $(NAME) env TERM=xterm ansible-playbook /etc/ansible/roles/role_under_test/test.yml --syntax-check

clean-container: 
	docker kill $(NAME) && docker rm $(NAME)

clean-image: 
	docker rmi $(TAG)

clean: clean-container clean-image

.PHONY: clean clean-image clean-container test run-container build-image shell run build all
