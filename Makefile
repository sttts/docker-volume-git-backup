IMAGE_ORG ?=docker.io/fvanderbiest

docker-build:
	docker pull debian:stretch
	docker build -t $(IMAGE_ORG)/volume-git-backup:`date +%Y%m%d%H%M%S` .
	docker build -t $(IMAGE_ORG)/volume-git-backup:latest .

docker-push:
	docker push fvanderbiest/volume-git-backup

all: docker-build
