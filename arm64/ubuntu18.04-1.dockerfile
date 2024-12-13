FROM ubuntu:18.04
RUN apt update -y \
 && apt install -y \
    bzip2 \
    file \
    gcc \
    g++ \ 
    git \
    patch \
    python3 \
    vim && \
    apt clean -y
