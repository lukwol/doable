ARG ERLANG_VERSION=27.3.4.10
ARG GLEAM_VERSION=v1.16.0

FROM ghcr.io/gleam-lang/gleam:${GLEAM_VERSION}-scratch AS gleam

FROM erlang:${ERLANG_VERSION}-alpine AS build
COPY --from=gleam /bin/gleam /bin/gleam
WORKDIR /doable/server
COPY shared/gleam.toml /doable/shared/gleam.toml
COPY server/gleam.toml server/manifest.toml ./
RUN gleam deps download
COPY shared/ /doable/shared/
COPY server/ ./
RUN gleam export erlang-shipment

FROM erlang:${ERLANG_VERSION}-alpine
COPY --from=build /doable/server/build/erlang-shipment /doable-server
WORKDIR /doable-server
ENTRYPOINT ["/doable-server/entrypoint.sh"]
CMD ["run"]
