FROM ubuntu18.04-1 AS with-spack
ARG SPACK_COMMIT
ENV PYTHONUNBUFFERED=1
COPY stage2/spack.yaml /spack/spack.yaml
COPY stage2/spack.lock /spack/spack.lock
RUN git clone https://github.com/spack/spack.git /root/spack && \
    cd /root/spack && \
    git reset --hard $SPACK_COMMIT
RUN /root/spack/bin/spack -e /spack install --no-check-signature --cache-only
 
FROM ubuntu:18.04
ENV PATH=/spack/view/bin:$PATH
COPY --from=with-spack /spack /spack
RUN rm -rf /usr/lib/aarch64-linux-gnu/libcrypt.so && ldconfig -v # newer glibc does not have libcrypt.so, so avoid linking to it
