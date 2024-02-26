FROM --platform=linux/amd64 node:lts-bookworm-slim

ARG TAG=master

# Install Rust.
RUN apt update && apt install -y curl bash gcc git tar gzip libc++-dev
RUN curl --proto '=https' --tlsv1.2 https://sh.rustup.rs -sSf > /tmp/rustup.sh \
    && chmod +x /tmp/rustup.sh \
    && sh -c "/tmp/rustup.sh -y" \
    && rm /tmp/rustup.sh
ENV PATH="/root/.cargo/bin:$PATH"

# Install Nargo.
RUN git clone --depth 1 --branch "${TAG}" https://github.com/noir-lang/noir.git \
    && cd noir \
    && cargo build --package nargo_cli --release --no-default-features \
    && ls -lha \
    && ls -lha target/release/ \
    && mkdir -p ~/.nargo/bin/ \
    && cp target/release/nargo ~/.nargo/bin/
ENV PATH="/root/.nargo/bin:$PATH"

# Compile the barretenberg backend.
RUN mkdir /tmp/circuit/ && \
    cd /tmp/circuit/ && \
    nargo init && \
    nargo check && \
    nargo compile && \
    cd / && \
    rm -rf /tmp/circuit/

SHELL ["/bin/sh", "-c"]
WORKDIR /sindri/

ENTRYPOINT ["nargo"]
