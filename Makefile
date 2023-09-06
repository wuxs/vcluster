
# Image URL to use all building/pushing image targets
REPO ?= edgewize
TAG ?= $(shell cat VERSION | tr -d " \t\n\r")
# Get the currently used golang install path (in GOPATH/bin, unless GOBIN is set)
ifeq (,$(shell go env GOBIN))
GOBIN=$(shell go env GOPATH)/bin
else
GOBIN=$(shell go env GOBIN)
endif

# Run go fmt against code
fmt:
	go fmt ./...

# Run go vet against code
vet:
	go vet ./...

# Build the docker image
build-image:
	docker build . -f Dockerfile --pull -t ${REPO}/vcluster:${TAG}
# Push the docker image
build-push:
	docker push ${REPO}/vcluster:${TAG}
# push image with skopeo
build-pushx:
	skopeo copy docker-daemon:${REPO}/vcluster:${TAG} docker://${REPO}/vcluster:${TAG}

container-push: build-image build-push

