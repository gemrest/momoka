VERSION 0.8

docker:
  ARG tag=latest

  FROM erlang:29-alpine

  COPY +build/erlang-shipment/ /momoka/erlang-shipment/

  WORKDIR /momoka/

  ENTRYPOINT ["./erlang-shipment/entrypoint.sh"]

  CMD ["run"]

  SAVE IMAGE --push fuwn/momoka:${tag}

build:
  FROM ghcr.io/gleam-lang/gleam:v1.19.2-erlang-alpine

  WORKDIR /momoka/

  COPY src/ /momoka/src/
  COPY gleam.toml manifest.toml /momoka/

  RUN gleam export erlang-shipment

  SAVE ARTIFACT /momoka/build/erlang-shipment/
