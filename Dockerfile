FROM debian:bookworm-slim

# Pin the release. Check https://github.com/storytold/wordcraft/releases for the newest tag.
ARG WC_VERSION=0.8.0

RUN apt-get update && apt-get install -y --no-install-recommends \
      ca-certificates curl poppler-utils fontconfig \
    && rm -rf /var/lib/apt/lists/*

RUN curl -fsSL -o /tmp/wc.tgz \
      "https://github.com/storytold/wordcraft/releases/download/v${WC_VERSION}/wordcraft-${WC_VERSION}-linux-x86_64.tar.gz" \
    && tar -xzf /tmp/wc.tgz -C /opt \
    && ln -s "/opt/wordcraft-${WC_VERSION}-linux-x86_64/bin/wordcraft-cli" /usr/local/bin/wordcraft-cli \
    && rm /tmp/wc.tgz

WORKDIR /work
ENTRYPOINT ["wordcraft-cli"]