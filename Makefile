DOCKER = docker

centos7-1: centos7-1.dockerfile
	$(DOCKER) build -t $@ -f $< .
	touch $@

centos7-2: centos7-2.dockerfile
	$(DOCKER) build -t $@ -f $< .
	touch $@