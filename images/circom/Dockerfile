FROM node:lts-bookworm-slim

# Install Rust.
RUN apt update && apt install -y curl bash gcc git tar gzip libc++-dev
RUN curl --proto '=https' --tlsv1.2 https://sh.rustup.rs -sSf > /tmp/rustup.sh \
    && chmod +x /tmp/rustup.sh \
    && sh -c "/tmp/rustup.sh -y" \
    && rm /tmp/rustup.sh
ENV PATH="/root/.cargo/bin:$PATH"

# Install Circom.
RUN git clone https://github.com/iden3/circom.git \
    && cd circom \
    && cargo build --release \
    && cargo install --path circom

WORKDIR /sindri-project/

ENTRYPOINT ["circom"]
