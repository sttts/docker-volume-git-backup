IMAGE_ORG ?=docker.io/fvanderbiest
ARCH ?=amd64

DATE :=$(shell date +%Y%m%d%H%M%S)
REPO :=$(IMAGE_ORG)/volume-git-backup
SHELL :=/bin/bash
ifneq ($(ARCH),amd64)
POSTFIX=-$(ARCH)
endif


docker-build:
	docker build -f <(sed 's/__BASEIMAGE_ARCH__/$(ARCH)/' Dockerfile) -t $(REPO):$(DATE)$(POSTFIX) .
	docker tag $(REPO):$(DATE)$(POSTFIX) $(REPO):latest$(POSTFIX)

docker-push:
	docker push $(REPO):latest$(POSTFIX)

all: docker-build
