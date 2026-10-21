# Use the installed compiler; never download a replacement toolchain.
export GOTOOLCHAIN = local

BINARY ?= kube-applier-gcp
IMAGE  ?= kube-applier-gcp
TAG    ?= latest

.PHONY: build test vet image clean kind-setup emulator run-local

build:
	go build -o $(BINARY) .

test:
	go test ./... -count=1

vet:
	go vet ./...

image:
	docker build -t $(IMAGE):$(TAG) .

kind-setup:
	./hack/setup-kind.sh

emulator:
	./hack/start-emulator.sh

run-local:
	./hack/run-local.sh

clean:
	rm -f $(BINARY)

# Keep the Go 1.26.10 baseline for CVE-2026-111943 without replacing vendor builds.
.PHONY: check-toolchain
check-toolchain:
	@test "$$(go env GOVERSION | cut -d' ' -f1)" = go1.26.10 || { \
		echo "Install Go 1.26.10 before running this target; automatic toolchain downloads are disabled." >&2; \
		exit 1; \
	}

build test vet run-local: check-toolchain
