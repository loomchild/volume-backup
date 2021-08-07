FROM alpine

RUN apk update && apk add --no-cache dumb-init xz tar zstd pbzip2

COPY volume-backup.sh /

ENTRYPOINT [ "/usr/bin/dumb-init", "--", "/volume-backup.sh" ]
