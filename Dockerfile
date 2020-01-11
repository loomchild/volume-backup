FROM alpine

RUN apk update && apk add --no-cache dumb-init xz tar

COPY volume-backup.sh /

ENTRYPOINT [ "/bin/sh", "/volume-backup.sh" ]
