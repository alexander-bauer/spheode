CONTAINER := alexanderbauer0/spheode
VERSION := $(shell git describe --tags)

docker := docker

# Make logic borrowed from:
# https://gist.github.com/mpneuried/0594963ad38e68917ef189b4e6a269db

build:
	$(docker) build -t $(CONTAINER) src

build-nc:
	$(docker) build --no-cache -t $(CONTAINER) src

# Tagging
tag: tag-latest tag-version

tag-latest:
	$(docker) tag $(CONTAINER) $(CONTAINER):latest

tag-version:
	$(docker) tag $(CONTAINER) $(CONTAINER):$(VERSION)

# Publish
publish: publish-latest publish-version

publish-latest: tag-latest
	$(docker) push $(CONTAINER):latest

publish-version: tag-version
	$(docker) push $(CONTAINER):$(VERSION)

# Release
release: build-nc publish
