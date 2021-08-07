FROM alpine

RUN apk update && apk add --no-cache dumb-init xz tar zstd

COPY volume-backup.sh /

ENTRYPOINT [ "/usr/bin/dumb-init", "--", "/volume-backup.sh" ]
