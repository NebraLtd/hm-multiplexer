ARG BUILD_BOARD

FROM --platform=$BUILDPLATFORM rust:1.65 AS vendor
ENV USER=root
WORKDIR /usr/src/gwmp-mux
RUN cargo init
COPY Cargo.lock Cargo.toml /usr/src/gwmp-mux/
RUN mkdir -p /usr/src/gwmp-mux/.cargo
RUN cargo vendor >> /usr/src/gwmp-mux/.cargo/config.toml

FROM rust:1.65 as builder
WORKDIR /usr/src/gwmp-mux
COPY Cargo.toml ./Cargo.toml
COPY Cargo.lock ./Cargo.lock
COPY src ./src
COPY --from=vendor /usr/src/gwmp-mux/.cargo ./.cargo
COPY --from=vendor /usr/src/gwmp-mux/vendor ./vendor
RUN cargo build --release --offline

FROM balenalib/"$BUILD_BOARD"-debian:buster
COPY --from=builder /usr/src/gwmp-mux/target/release/gwmp-mux /usr/local/bin/gwmp-mux
RUN apt-get update -y
RUN apt-get install python3 -y
COPY start_multiplexer.py /root/start_multiplexer.py
RUN chmod 755 /root/start_multiplexer.py
ENTRYPOINT ["/usr/local/bin/gwmp-mux", "--client", "cs.nebra-staging.com:1700"]
