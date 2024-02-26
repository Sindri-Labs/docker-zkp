FROM --platform=linux/amd64 node:lts-bookworm-slim

ARG TAG=v0.24.0

SHELL ["/bin/bash", "-c"]
RUN apt update && apt install -y curl bash git tar gzip libc++-dev
RUN curl -L https://raw.githubusercontent.com/noir-lang/noirup/main/install | bash
ENV PATH="/root/.nargo/bin:$PATH"
RUN noirup -v "${TAG}" && \
    mkdir /tmp/circuit/ && \
    cd /tmp/circuit/ && \
    nargo init && \
    nargo check && \
    nargo compile && \
    cd / && \
    rm -rf /tmp/circuit/

SHELL ["/bin/sh", "-c"]
WORKDIR /sindri/

ENTRYPOINT ["nargo"]
