ARG ERLANG_VERSION=27.3.4.10
ARG GLEAM_VERSION=v1.16.0

FROM --platform=${BUILDPLATFORM} ghcr.io/gleam-lang/gleam:${GLEAM_VERSION}-scratch AS gleam
FROM --platform=${BUILDPLATFORM} oven/bun:alpine AS bun

FROM --platform=${BUILDPLATFORM} erlang:${ERLANG_VERSION}-alpine AS build
RUN apk add --no-cache nodejs
COPY --from=gleam /bin/gleam /bin/gleam
COPY --from=bun /usr/local/bin/bun /usr/local/bin/bun

WORKDIR /doable/client

COPY shared/gleam.toml /doable/shared/gleam.toml
COPY client/gleam.toml client/manifest.toml ./
RUN --mount=type=cache,target=/doable/client/build \
    gleam deps download

COPY client/package.json client/bun.lock ./
RUN --mount=type=cache,target=/root/.bun/install/cache \
    bun install --frozen-lockfile

COPY shared/ /doable/shared/
COPY client/ ./
RUN --mount=type=cache,target=/doable/client/build \
    gleam run -m lustre/dev build

FROM caddy:alpine
COPY --from=build /doable/client/dist /srv
COPY Caddyfile /etc/caddy/Caddyfile
