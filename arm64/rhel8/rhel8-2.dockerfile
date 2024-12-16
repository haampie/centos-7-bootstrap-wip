FROM rhel8-1:latest AS with-spack
ARG SPACK_COMMIT
ENV PYTHONUNBUFFERED=1
COPY stage2/spack.yaml /spack/spack.yaml
COPY stage2/spack.lock /spack/spack.lock
RUN git clone https://github.com/spack/spack.git /root/spack && \
    cd /root/spack && \
    git reset --hard $SPACK_COMMIT
RUN /root/spack/bin/spack -e /spack install --no-check-signature --cache-only
 
FROM redhat/ubi8:8.10-1132.1733300785
ENV PATH=/spack/view/bin:$PATH
COPY --from=with-spack /spack /spack
#RUN rm -rf /usr/lib/aarch64-linux-gnu/libcrypt.so && ldconfig -v # newer glibc does not have libcrypt.so, so avoid linking to it
