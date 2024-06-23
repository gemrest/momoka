VERSION 0.8

all:
  BUILD +docker

docker:
  ARG tag=latest

  FROM ghcr.io/gleam-lang/gleam:v1.2.1-erlang-alpine

  COPY +build/erlang-shipment/ /momoka/erlang-shipment/

  WORKDIR /momoka/

  ENTRYPOINT ["./erlang-shipment/entrypoint.sh"]

  CMD ["run"]

  SAVE IMAGE --push fuwn/momoka:${tag}

deps:
  FROM ghcr.io/gleam-lang/gleam:v1.2.0-erlang-alpine

  RUN apk add --no-cache build-base

build:
  FROM +deps

  WORKDIR /momoka/

  COPY src/ /momoka/src/
  COPY gleam.toml /momoka/
  COPY manifest.toml /momoka/

  RUN gleam build \
    && cd build/ \
    && gleam export erlang-shipment

  SAVE ARTIFACT /momoka/build/erlang-shipment/
