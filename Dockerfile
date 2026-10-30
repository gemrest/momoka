# BEAM bytecode runs on any architecture, so build natively instead of under
# emulation, where the Erlang VM can crash.
FROM --platform=$BUILDPLATFORM ghcr.io/gleam-lang/gleam:v1.19.2-erlang-alpine AS build

WORKDIR /momoka/

COPY gleam.toml manifest.toml /momoka/
COPY src/ /momoka/src/

RUN gleam export erlang-shipment

FROM erlang:29-alpine

COPY --from=build /momoka/build/erlang-shipment/ /momoka/erlang-shipment/

WORKDIR /momoka/

ENTRYPOINT ["./erlang-shipment/entrypoint.sh"]

CMD ["run"]
