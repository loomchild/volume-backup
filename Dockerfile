FROM alpine

RUN apk update && apk add --no-cache dumb-init xz

COPY volume-backup.sh /

ENTRYPOINT [ "/bin/sh", "/volume-backup.sh" ]
