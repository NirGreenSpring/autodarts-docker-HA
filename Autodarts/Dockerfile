# Home Assistant add-on builds provide BUILD_VERSION; map it to VERSION
ARG BUILD_VERSION
ARG VERSION=${BUILD_VERSION}

### Build
FROM --platform=${BUILDPLATFORM} alpine:latest AS build

ARG VERSION \
    BUILDPLATFORM \
    TARGETPLATFORM

WORKDIR /

RUN apk update && \
    apk add --no-cache wget tar jq && \
    PLATFORM=$(echo ${TARGETPLATFORM} | cut -d'/' -f1) && \
    ARCH=$(echo ${TARGETPLATFORM} | cut -d'/' -f2) && \
    echo "PLATFORM: $PLATFORM; ARCH: $ARCH; VERSION: $VERSION" && \
    RELEASES_JSON=$(wget -qO- "https://get.autodarts.io/detection/latest/${PLATFORM}/${ARCH}/RELEASES.json") && \
    ASSETURL=$(echo "$RELEASES_JSON" | jq -r --arg VERSION "${VERSION}" '.releases[] | select(.version == $VERSION) | .url' | head -n 1) && \
    if [ -z "$ASSETURL" ] || [ "$ASSETURL" = "null" ]; then \
      echo "No exact match for VERSION=$VERSION, falling back to latest release..."; \
      ASSETURL=$(echo "$RELEASES_JSON" | jq -r '.releases[0].url'); \
    fi && \
    echo "ASSETURL: $ASSETURL" && \
    if [ -z "$ASSETURL" ] || [ "$ASSETURL" = "null" ]; then \
      echo "ERROR: Could not determine an asset URL from RELEASES.json" >&2; \
      exit 1; \
    fi && \
    wget "$ASSETURL" && \
    tar -vxf "$(basename "$ASSETURL")" && \
    rm "$(basename "$ASSETURL")"

### Run
FROM alpine:latest

# Add entrypoint that maps /data -> /root/.config/autodarts
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

WORKDIR /usr/local/bin/autodarts
COPY --from=build /autodarts .
RUN chmod +x ./autodarts

EXPOSE 3180

ENTRYPOINT ["/entrypoint.sh"]
CMD ["./autodarts"]
