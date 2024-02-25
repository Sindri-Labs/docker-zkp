FROM node:lts-bookworm-slim

ARG TAG=main

# Install Rust.
RUN apt update && apt install -y curl bash gcc git tar gzip libc++-dev
RUN curl --proto '=https' --tlsv1.2 https://sh.rustup.rs -sSf > /tmp/rustup.sh \
    && chmod +x /tmp/rustup.sh \
    && sh -c "/tmp/rustup.sh -y" \
    && rm /tmp/rustup.sh
ENV PATH="/root/.cargo/bin:$PATH"

# Install Circomspect.
RUN git clone --depth 1 --branch "${TAG}" https://github.com/trailofbits/circomspect.git \
    && cd circomspect \
    && cargo build --release \
    && cargo install --path cli

WORKDIR /sindri/

ENTRYPOINT ["circomspect"]
