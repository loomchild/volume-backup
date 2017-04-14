#!/bin/sh

usage() {
  echo "Usage: volume-backup <backup|restore> <archive>"
  exit
}

backup() {
    mkdir -p `dirname /backup/$ARCHIVE`
    tar -cjf /backup/$ARCHIVE -C /volume ./
}

restore() {
    if ! [ -e /backup/$ARCHIVE ]; then
        echo "Archive file $ARCHIVE does not exist"
        exit 1
    fi

    rm -rf /volume/* /volume/..?* /volume/.[!.]*
    tar -C /volume/ -xjf /backup/$ARCHIVE
}

# Needed because sometimes pty is not ready when executing docker-compose run
# See https://github.com/docker/compose/pull/4738 for more details
# TODO: remove after above pull request or equivalent is merged
sleep 1

if [ $# -ne 2 ]; then
    usage
fi

OPERATION=$1

ARCHIVE=${2%%.tar.bz2}.tar.bz2

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
