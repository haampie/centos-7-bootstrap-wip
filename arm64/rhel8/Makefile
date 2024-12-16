DOCKER = docker
SPACK_COMMIT = 0ce38ed1092aefeccb31ffed8e23e8d3ef58a4b1
export GITHUB_USER ?= eugeneswalker
# export GITHUB_TOKEN ?= please-set-me

RUN_ARGS = --rm -v $(CURDIR):/spack -w /spack \
	-e PYTHONUNBUFFERED=1 -e SPACK_COLOR=always \
	-e SPACK_USER_CACHE_PATH=/spack/cache -e GITHUB_USER=$(GITHUB_USER) -e GITHUB_TOKEN=$(GITHUB_TOKEN)

.PHONY: clean distclean all

all: .image2

spack:
	git clone https://github.com/spack/spack $@ && git -C $@ reset --hard $(SPACK_COMMIT)

.image1: rhel8-1.dockerfile
	$(DOCKER) build -t rhel8-1 -f rhel8-1.dockerfile .
	touch $@

.stage1: spack .image1
	$(DOCKER) run $(RUN_ARGS) rhel8-1 ./spack/bin/spack -e ./stage1 install --no-check-signature
	touch $@

.compiler: .stage1
	$(DOCKER) run $(RUN_ARGS) rhel8-1 /bin/sh -c '\
		./spack/bin/spack -e ./stage2 compiler find \
			$$(./spack/bin/spack -e ./stage1 location -i gcc)'
	touch $@

.stage2: .compiler
	$(DOCKER) run $(RUN_ARGS) rhel8-1 ./spack/bin/spack --backtrace -e ./stage2 install --no-check-signature
	touch $@

.image2: rhel8-2.dockerfile .stage2
	$(DOCKER) build -t rhel8-2 -f rhel8-2.dockerfile --build-arg SPACK_COMMIT=$(SPACK_COMMIT) --build-arg GITHUB_USER=$(GITHUB_USER) --build-arg GITHUB_TOKEN=$(GITHUB_TOKEN) .
	touch $@

clean:
	rm -f .image1 .image2 .stage1 .stage2

distclean: clean
	rm -rf spack stage1/store stage2/store cache
