FROM centos7-1 AS with-spack
COPY stage3/spack.yaml /spack/spack.yaml
COPY stage3/spack.lock /spack/spack.lock
RUN git clone --depth=1 https://github.com/spack/spack.git /root/spack
RUN . /root/spack/share/spack/setup-env.sh && \
    spack -e /spack install --no-check-signature --cache-only
 
FROM centos:7.9.2009
COPY CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo
COPY --from=with-spack /spack /spack
RUN yum install -y glibc-devel && yum clean all
ENV PATH=/spack/view/bin:$PATH