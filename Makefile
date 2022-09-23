include .env

USERNAME=$(USER)
APP_NAME=$(shell basename $(CURDIR))
SHELL=/bin/bash
DOCKER_BUILD_CONTEXT=.
DOCKER_FILE_PATH=Dockerfile
IMAGE=$(REGISTRY)/$(NS)/$(APP_NAME)
FULLIMAGE=$(IMAGE):$(TAG)
CONTAINER_NAME ?= $(APP_NAME)


TAG ?= $(TAG)


.PHONY: help

#https://marmelab.com/blog/2016/02/29/auto-documented-makefile.html
help: ## Dispaly usage
	@awk 'BEGIN {FS = ":.*?## ") /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", "make " $$1, $$2)' $(MAKEFILE_LIST)

.DEFAULT_GOAL := help

build: ## Build a Docker image
	podman build -t $(APP_NAME) -f $(DOCKER_FILE_PATH) $(DOCKER_BUILD_CONTEXT)

build-nc: ## Build a Docker image without caching
	podman build --no-cache -t $(APP_NAME) -f $(DOCKER_FILE_PATH) $(DOCKER_BUILD_CONTEXT)

shell: ## Run shell in the Docker container
	podman run --rm --entrypoint=/bin/bash --name $(CONTAINER_NAME)-$(CONTAINER_INSTANCE) -it $(PORTS) $(VOLUMES) $(ENV) $(APP_NAME)

tag: tag-latest tag-version ## Generate Docker tags for the `version` and `latest`

tag-latest: ## Tag the Docker image `latest` tag
	podman tag $(APP_NAME) $(IMAGE):latest

tag-version: ## Tag the Docker image `version` tag
	podman tag $(APP_NAME) $(IMAGE):$(TAG)

delete-all-images: ## Remove all related local Docker images
	podman rmi $(APP_NAME) $(IMAGE):$(TAG) $(IMAGE):latest

push-version: ## Push to the Docker repository `version` tagged Docker image
	podman push $(IMAGE):$(TAG)

push-latest: ## Push to the Docker repository `latest` tagged Docker image
	podman push $(IMAGE):latest

publish: push-version push-latest ## Publish the `version` and `latest` tagged images

do-all: build tag publish ## Do `build` `tag` and `publish` the Docker image%
