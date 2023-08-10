# Build the manager binary
FROM golang:1.19 as builder

WORKDIR /vcluster-dev
ARG TARGETOS
ARG TARGETARCH

# Install helm binary
RUN curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 && chmod 700 get_helm.sh && ./get_helm.sh

# Copy the Go Modules manifests
COPY go.mod go.mod
COPY go.sum go.sum
COPY vendor/ vendor/

# Copy the go source
COPY cmd/vcluster cmd/vcluster
COPY cmd/vclusterctl cmd/vclusterctl
COPY pkg/ pkg/

# Symlink /manifests folder to the synced location for development purposes
RUN ln -s "$(pwd)/manifests" /manifests

ENV GO111MODULE on
ENV DEBUG true

# create and set GOCACHE now, this should slightly speed up the first build inside of the container
# also create /.config folder for GOENV, as dlv needs to write there when starting debugging
RUN mkdir -p /.cache /.config
ENV GOCACHE=/.cache
ENV GOENV=/.config

# Copy and embed the helm charts
COPY charts/ charts/
COPY hack/ hack/
RUN go generate ./...

# Set home to "/" in order to for kubectl to automatically pick up vcluster kube config 
ENV HOME /

# Build cmd
RUN CGO_ENABLED=0 GOOS=${TARGETOS} GOARCH=${TARGETARCH} GO111MODULE=on go build -mod vendor -o /vcluster cmd/vcluster/main.go

# RUN useradd -u 12345 nonroot
# USER nonroot

ENTRYPOINT ["go", "run", "-mod", "vendor", "cmd/vcluster/main.go"]

# we use alpine for easier debugging
FROM edgewize/base:alpine-3.16.2

# Set root path as working directory
WORKDIR /

COPY --from=builder /vcluster .
COPY manifests/ /manifests/

# RUN useradd -u 12345 nonroot
# USER nonroot

ENTRYPOINT ["/vcluster", "start"]
