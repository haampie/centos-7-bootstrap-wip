DOCKER = docker
export GITHUB_USER ?= haampie
# export GITHUB_TOKEN ?= please-set-me

.PHONY: clean

all: .image2

spack:
	git clone --depth=1 https://github.com/spack/spack $@

.image1: centos7-1.dockerfile
	$(DOCKER) build -t centos7-1 -f $< .
	touch $@

.stage1: spack .image1
	$(DOCKER) run --rm \
		-v $(CURDIR):/spack \
		-w /spack \
		-e GITHUB_USER \
		-e GITHUB_TOKEN \
		-e PYTHONUNBUFFERED=1 \
		-e SPACK_COLOR=always \
		centos7-1 \
		./spack/bin/spack -e ./stage1 install --no-check-signature
	touch $@

.stage2: spack .stage1
	$(DOCKER) run --rm \
		-v $(CURDIR):/spack \
		-w /spack \
		-e GITHUB_USER \
		-e GITHUB_TOKEN \
		-e PYTHONUNBUFFERED=1 \
		-e SPACK_COLOR=always \
		centos7-1 \
		./spack/bin/spack -e ./stage2 install --no-check-signature
	touch $@

.image2: centos7-2.dockerfile .stage2
	$(DOCKER) build -t centos7-2 -f centos7-2.dockerfile .
	touch $@

clean:
	rm -f .image1 .image2 .stage1 .stage2
