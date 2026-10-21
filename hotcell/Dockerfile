# syntax=docker/dockerfile:1
ARG RUBY_VERSION=3.4.11
FROM ruby:${RUBY_VERSION}-slim AS build

RUN apt-get update && \
    apt-get install -y --no-install-recommends build-essential pkg-config && \
    rm -rf /var/lib/apt/lists/*

ENV BUNDLE_PATH=/hotcell/bundle BUNDLE_FROZEN=true
WORKDIR /hotcell
COPY Gemfile Gemfile.lock ./
RUN bundle install && rm -rf "$BUNDLE_PATH"/ruby/*/cache

FROM ruby:${RUBY_VERSION}-slim
RUN apt-get update && \
    apt-get upgrade -y --no-install-recommends && \
    apt-get install -y --no-install-recommends libvips42 && \
    rm -rf /var/lib/apt/lists/*

RUN groupadd --gid 10001 hotcell && \
    useradd --uid 10001 --gid 10001 --no-create-home --shell /usr/sbin/nologin hotcell && \
    mkdir -p /run/hotcell/cell /hotcell/operations && \
    chown -R hotcell:hotcell /run/hotcell /hotcell

ENV HOME=/tmp \
    BUNDLE_PATH=/hotcell/bundle \
    BUNDLE_FROZEN=true \
    HOTCELL_CONFIG=/hotcell/config.rb \
    HOTCELL_OPERATIONS=/hotcell/operations \
    HOTCELL_DIR=/run/hotcell/cell \
    OMP_NUM_THREADS=2 \
    OMP_THREAD_LIMIT=8

WORKDIR /hotcell
COPY --from=build --chown=hotcell:hotcell /hotcell/bundle /hotcell/bundle
COPY --chown=hotcell:hotcell Gemfile Gemfile.lock config.rb ./
COPY --chown=hotcell:hotcell operations/ ./operations/
RUN find / -xdev -type f -perm /06000 -exec chmod a-s {} +

USER 10001:10001
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD ["bundle", "exec", "hotcell-health"]
CMD ["bundle", "exec", "hotcell"]
