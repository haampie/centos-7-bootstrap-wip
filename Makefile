DOCKER = docker
export GITHUB_USER ?= haampie
# export GITHUB_TOKEN ?= please-set-me

.PHONY: centos7-1 centos7-2

centos7-1: centos7-1.dockerfile
	$(DOCKER) build -t $@ -f $< .
	touch $@

spack:
	git clone --depth=1 https://github.com/spack/spack $@

stage1_: spack
	$(DOCKER) run --rm \
		-v $(CURDIR):/spack \
		-w /spack \
		-e GITHUB_USER \
		-e GITHUB_TOKEN \
		-e PYTHONUNBUFFERED=1 \
		centos7-1 \
		./spack/bin/spack -e ./stage1 install --no-check-signature
	touch $@

stage2_: spack stage1_
	$(DOCKER) run --rm \
		-v $(CURDIR):/spack \
		-w /spack \
		-e GITHUB_USER \
		-e GITHUB_TOKEN \
		centos7-1 \
		./spack/bin/spack -e ./stage1 install --no-check-signature
	touch $@

centos7-2: centos7-2.dockerfile
	$(DOCKER) build -t $@ -f $< .
	touch $@

clean:
	rm -f centos7-1 centos7-2 stage1_ stage2_
