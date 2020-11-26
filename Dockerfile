ARG OCAML_VERSION=4.10.0
ARG UNISON_VERSION=2.51.3

FROM ubuntu:latest AS builder

MAINTAINER Igor Goltsov <igor@ecomgems.com>

# Prepare build machine
RUN apt update && apt install --assume-yes build-essential curl git

# Build proper OCAML environment
ARG OCAML_VERSION
RUN curl -L http://caml.inria.fr/pub/distrib/ocaml-$(echo ${OCAML_VERSION} | cut -c1-4)/ocaml-${OCAML_VERSION}.tar.gz | tar xzv -C /tmp \
    && cd /tmp/ocaml-${OCAML_VERSION} \
    && ./configure \
    && make world \
    && make opt \
    && umask 022 \
    && make install \
    && make clean

# Build proper Unison version
ARG UNISON_VERSION
RUN curl -L https://github.com/bcpierce00/unison/archive/v$UNISON_VERSION.tar.gz | tar zxv -C /tmp \
    && cd /tmp/unison-${UNISON_VERSION} \
    && sed -i -e 's/GLIBC_SUPPORT_INOTIFY 0/GLIBC_SUPPORT_INOTIFY 1/' src/fsmonitor/linux/inotify_stubs.c \
    && make UISTYLE=text NATIVE=true STATIC=true \
    && cp src/unison src/unison-fsmonitor /usr/local/bin

FROM alpine:edge AS app

# Install necessary software
RUN apk add --no-cache tzdata bash su-exec tini

# These can be overridden later
ENV TZ="GMT" \
    LANG="C.UTF-8" \
    UNISON_DIR="/data" \
    HOME="/tmp" \
    UNISON_USER="unison" \
    UNISON_GROUP="sync" \
    UNISON_UID="1000" \
    UNISON_GID="1000"

WORKDIR /root

# Install unison server script
COPY --from=builder /usr/local/bin/unison /usr/local/bin
COPY --from=builder /usr/local/bin/unison-fsmonitor /usr/local/bin
COPY entrypoint.sh /entrypoint.sh

VOLUME /unison

EXPOSE 5000
ENTRYPOINT ["/sbin/tini", "--", "/entrypoint.sh"]
