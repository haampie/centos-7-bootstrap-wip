DOCKER = docker
SPACK_COMMIT = 0ce38ed1092aefeccb31ffed8e23e8d3ef58a4b1
export GITHUB_USER ?= haampie
# export GITHUB_TOKEN ?= please-set-me

RUN_ARGS = --rm -v $(CURDIR):/spack -w /spack \
	-e GITHUB_USER -e GITHUB_TOKEN -e PYTHONUNBUFFERED=1 -e SPACK_COLOR=always \
	-e SPACK_USER_CACHE_PATH=/spack/cache

.PHONY: clean distclean all reconcretize-stage1 reconcretize-stage2

all: .image2

spack:
	git clone https://github.com/spack/spack $@ && git -C $@ reset --hard $(SPACK_COMMIT)

.image1: centos7-1.dockerfile
	$(DOCKER) build -t centos7-1 -f centos7-1.dockerfile .
	touch $@

.stage1: spack .image1
	$(DOCKER) run $(RUN_ARGS) centos7-1 ./spack/bin/spack -e ./stage1 install --no-check-signature
	touch $@

.compiler: .stage1
	$(DOCKER) run $(RUN_ARGS) centos7-1 /bin/sh -c '\
		./spack/bin/spack -e ./stage2 compiler find \
			$$(./spack/bin/spack -e ./stage1 location -i gcc)'
	touch $@

.stage2: .compiler
	$(DOCKER) run $(RUN_ARGS) centos7-1 ./spack/bin/spack -e ./stage2 install --no-check-signature
	touch $@

.image2: centos7-2.dockerfile .stage2
	$(DOCKER) build -t centos7-2 -f centos7-2.dockerfile --build-arg SPACK_COMMIT=$(SPACK_COMMIT) .
	touch $@

reconcretize-stage1: .image1
	$(DOCKER) run $(RUN_ARGS) centos7-1 ./spack/bin/spack -e ./stage1 concretize --force --fresh

reconcretize-stage2: .compiler
	$(DOCKER) run $(RUN_ARGS) centos7-1 ./spack/bin/spack -e ./stage2 concretize --force --fresh

clean:
	rm -f .image1 .image2 .stage1 .stage2

distclean: clean
	rm -rf spack stage1/store stage2/store cache
