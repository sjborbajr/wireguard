FROM ubuntu:24.04
RUN apt-get update && apt-get install -y --no-install-recommends \
    wireguard-tools iproute2 ca-certificates nftables \
    && rm -rf /var/lib/apt/lists/*
COPY entrypoint.sh /entrypoint.sh
COPY setup-nat.sh /usr/local/bin/setup-nat.sh
RUN chmod +x /entrypoint.sh /usr/local/bin/setup-nat.sh
ENTRYPOINT ["/entrypoint.sh"]
