Bootstraps a build environment targeting linux with glibc 2.17 and gcc 10.

To build it run `make`.

[`stage1/`](stage1/) builds an initial compiler using centos 7 system compiler.
[`stage2/`](stage2/) builds another compiler and other Spack tools using the `stage1` compiler.

The binaries from `stage2` define the build environment.

We store the `spack.lock` files for `stage1/` and `stage2/`. Use `make reconcretize-stage1` or
`make reconcretize-stage2` to make changes to the build environment.
