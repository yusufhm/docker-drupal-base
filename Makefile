default: build

.PHONY: build release push

# Build Docker image
build: docker_build

# Build and push Docker image
release: docker_build docker_push

push: docker_push

DOCKER_IMAGE = yusufhm/drupal-base

# Get the latest commit.
GIT_COMMIT = $(strip $(shell git rev-parse --short HEAD))

docker_build:
	# Build amd64 image
	docker build \
  --build-arg BUILD_DATE=`date -u +"%Y-%m-%dT%H:%M:%SZ"` \
  --build-arg VCS_URL=`git config --get remote.origin.url` \
  --build-arg VCS_REF=$(GIT_COMMIT) \
  --build-arg ARCH=amd64/ \
	-t $(DOCKER_IMAGE):amd64 .

	# Build arm64v8 image
	docker build \
  --build-arg BUILD_DATE=`date -u +"%Y-%m-%dT%H:%M:%SZ"` \
  --build-arg VCS_URL=`git config --get remote.origin.url` \
  --build-arg VCS_REF=$(GIT_COMMIT) \
  --build-arg ARCH=arm64v8/ \
	-t $(DOCKER_IMAGE):arm64v8 .

docker_push:
	# Push to DockerHub
	docker push $(DOCKER_IMAGE):amd64
	docker push $(DOCKER_IMAGE):arm64v8

	docker manifest create $(DOCKER_IMAGE):latest \
  --amend $(DOCKER_IMAGE):amd64 \
  --amend $(DOCKER_IMAGE):arm64v8

	docker manifest push $(DOCKER_IMAGE):latest

	# curl -X POST https://hooks.microbadger.com/images/yusufhm/drupal-base/CZUL-U9XeEcHvZgl3HzwbInlU5E=
