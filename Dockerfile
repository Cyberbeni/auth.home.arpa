FROM --platform=$BUILDPLATFORM codeberg.org/cyberbeni/swift-builder:latest-musl-allocator AS swift-build
ARG BUILDPLATFORM
WORKDIR /workspace
COPY ./Package.swift ./Package.resolved /workspace/
RUN --mount=type=cache,target=/workspace/.build,id=build-$BUILDPLATFORM \
	--mount=type=cache,target=/workspace/.spm-cache,id=spm-cache \
	swift package \
		--cache-path /workspace/.spm-cache \
		--only-use-versions-from-resolved-file \
		resolve

COPY ./scripts /workspace/scripts
COPY ./Sources /workspace/Sources
ARG TARGETPLATFORM
RUN --mount=type=cache,target=/workspace/.build,id=build-$TARGETPLATFORM \
	--mount=type=cache,target=/workspace/.spm-cache,id=spm-cache \
	scripts/build-release.sh && \
	mkdir -p dist && \
	cp .build/release/auth_home_arpa dist

FROM --platform=$BUILDPLATFORM docker.io/node:lts-alpine AS npm-build
WORKDIR /workspace
COPY ./package.json ./package-lock.json /workspace/
RUN npm ci

FROM docker.io/alpine:latest AS release
RUN apk add --no-cache \
	tzdata
COPY ./Resources /data
COPY --from=npm-build /workspace/node_modules/htmx.org/dist/htmx.min.js /data/public/htmx.min.js
RUN date +%s%N | tr -d '\n' > /data/static_files_timestamp
COPY --from=swift-build /workspace/dist/auth_home_arpa /usr/local/bin/auth_home_arpa
ENTRYPOINT ["/usr/local/bin/auth_home_arpa"]
