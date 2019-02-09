#!/bin/sh

usage() {
  echo "Usage: volume-backup <backup|restore> <archive or - for stdin/stdout>"
  exit
}

backup() {
    if ! [ "$ARCHIVE" == "-" ]; then
        mkdir -p `dirname /backup/$ARCHIVE`
    fi

    tar -cjf $ARCHIVE_PATH -C /volume ./
}

restore() {
    if ! [ "$ARCHIVE" == "-" ]; then
        if ! [ -e $ARCHIVE_PATH ]; then
            echo "Archive file $ARCHIVE does not exist"
            exit 1
        fi
    fi

    rm -rf /volume/* /volume/..?* /volume/.[!.]*
    tar -C /volume/ -xjf $ARCHIVE_PATH
}

# Needed because sometimes pty is not ready when executing docker-compose run
# See https://github.com/docker/compose/pull/4738 for more details
# TODO: remove after above pull request or equivalent is merged
sleep 1

if [ $# -ne 2 ]; then
    usage
fi

OPERATION=$1

if [ "$2" == "-" ]; then
    ARCHIVE=$2
    ARCHIVE_PATH=$ARCHIVE
else
    ARCHIVE=${2%%.tar.bz2}.tar.bz2
    ARCHIVE_PATH=/backup/$ARCHIVE
fi

case "$OPERATION" in
"backup" )
backup
;;
"restore" )
restore
;;
* )
usage
;;
esac
