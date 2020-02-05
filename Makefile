.PHONY: build run push

VERSION ?= latest
APP ?= sayes
DOCKER_REGISTRY ?= lowess

# Colors
RED = \033[0;31m
GREEN = \033[0;32m
BLUE = \033[0;36m
NC = \033[0m # No Color

build:
	@echo "Building Docker image (export VERSION=<version> if needed)"
	docker build . -t $(DOCKER_REGISTRY)/$(APP):$(VERSION)

	@echo "\n|- Execute the $(RED)production$(NC) server with:\n"
	@sed -n '/#--prod--/,/$(DOCKER_REGISTRY)\/$(APP)/p' README.md

run:
	@echo "Starting up container"
	@docker run -it --rm \
			-p 8000:80 \
			-v $(shell pwd):/safecast \
			$(DOCKER_REGISTRY)/$(APP)

push:
	@echo "Pushing Docker image to the registry"
	docker push $(DOCKER_REGISTRY)/$(APP):$(VERSION)
