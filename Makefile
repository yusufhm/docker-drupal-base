default: build

.PHONY: build release push

.PHONY: docker_build_amd64 docker_build_arm64v8

# Build Docker image.
build: docker_build_amd64 docker_build_arm64v8

.PHONY: docker_push_amd64 docker_push_arm64v8

push: docker_push_amd64 docker_push_arm64v8

push_manifest: docker_push_manifest_amd64 docker_push_manifest_arm64v8

# Build and push Docker image & push manifest.
release: build push push_manifest

DOCKER_IMAGE = yusufhm/drupal-base

# Get the latest commit.
GIT_COMMIT = $(strip $(shell git rev-parse --short HEAD))

docker_build_amd64:
	# Build amd64 image.
	docker build \
  --build-arg BUILD_DATE=`date -u +"%Y-%m-%dT%H:%M:%SZ"` \
  --build-arg VCS_URL=`git config --get remote.origin.url` \
  --build-arg VCS_REF=$(GIT_COMMIT) \
  --platform linux/amd64 \
	-t $(DOCKER_IMAGE):amd64 .

docker_build_arm64v8:
	# Build arm64v8 image.
	docker build \
  --build-arg BUILD_DATE=`date -u +"%Y-%m-%dT%H:%M:%SZ"` \
  --build-arg VCS_URL=`git config --get remote.origin.url` \
  --build-arg VCS_REF=$(GIT_COMMIT) \
  --platform linux/arm64/v8 \
	-t $(DOCKER_IMAGE):arm64v8 .

docker_push_amd64:
	# Push to DockerHub.
	docker push $(DOCKER_IMAGE):amd64

docker_push_arm64v8:
	docker push $(DOCKER_IMAGE):arm64v8

docker_push_manifest_amd64:
	docker manifest create $(DOCKER_IMAGE):latest \
  --amend $(DOCKER_IMAGE):amd64
  $(DOCKER_IMAGE):arm64v8

	docker manifest push --purge $(DOCKER_IMAGE):latest

docker_push_manifest_arm64v8:
	docker manifest create $(DOCKER_IMAGE):latest \
  $(DOCKER_IMAGE):amd64
  --amend $(DOCKER_IMAGE):arm64v8

	docker manifest push --purge $(DOCKER_IMAGE):latest

	# curl -X POST https://hooks.microbadger.com/images/yusufhm/drupal-base/CZUL-U9XeEcHvZgl3HzwbInlU5E=
