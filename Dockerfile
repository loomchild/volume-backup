FROM alpine

COPY volume-backup.sh /

ENTRYPOINT [ "/bin/sh", "/volume-backup.sh" ]
