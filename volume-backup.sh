#!/bin/sh

usage() {
  echo "Usage: volume-backup <backup|restore> <archive>"
}

backup() {
    tar -cvjf /backup/$ARCHIVE.tar.bz2 -C /volume ./
}

restore() {
    rm -rf /volume/* /volume/..?* /volume/.[!.]*
    tar -C /volume/ -xvjf /backup/$ARCHIVE.tar.bz2
}

if [ $# -ne 2 ]; then
    usage
fi

OPERATION=$1
ARCHIVE=$2

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
