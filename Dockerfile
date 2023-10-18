FROM alpine

RUN apk update && apk add --no-cache dumb-init bash xz tar pigz zstd

RUN apk add --no-cache \
  bzip2-dev \
  g++ \
  make

RUN cd /tmp/ && \
  wget -q https://launchpad.net/pbzip2/1.1/1.1.13/+download/pbzip2-1.1.13.tar.gz && \
  tar -xzf pbzip2-1.1.13.tar.gz && \
  cd pbzip2-1.1.13/ && \
  make install && \
  rm -r /tmp/pbzip2-1.1.13/

COPY volume-backup.sh /

ENTRYPOINT [ "/usr/bin/dumb-init", "--", "/volume-backup.sh" ]
