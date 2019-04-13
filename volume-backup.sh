#!/bin/sh

usage() {
  >&2 echo "Usage: volume-backup <backup|restore> [options] <archive or - for stdin/stdout>"
  >&2 echo ""
  >&2 echo "Options:"
  >&2 echo "  -e <glob> exclude files or directories (only for backup operation)"
}

backup() {
    if [ -z "$(ls -A /volume)" ]; then
       >&2 echo "Volume is empty or missing, check if you specified a correct name"
       exit 1
    fi

    if ! [ "$ARCHIVE" == "-" ]; then
        mkdir -p `dirname /backup/$ARCHIVE`
    fi

    tar -cjf $ARCHIVE_PATH -C /volume $TAROPTS ./
}

restore() {
    if ! [ "$ARCHIVE" == "-" ]; then
        if ! [ -e $ARCHIVE_PATH ]; then
            >&2 echo "Archive file $ARCHIVE does not exist"
            exit 1
        fi
    fi

    rm -rf /volume/* /volume/..?* /volume/.[!.]*
    tar -C /volume/ -xjf $TAROPTS $ARCHIVE_PATH
}

# Needed because sometimes pty is not ready when executing docker-compose run
# See https://github.com/docker/compose/pull/4738 for more details
# TODO: remove after above pull request or equivalent is merged
sleep 1

OPERATION=$1

TAROPTS=""

OPTIND=2

while getopts "h?e:" OPTION; do
    case "$OPTION" in
    h|\?)
        usage
        exit 0
        ;;
    e)  if [ -z "$OPTARG" -o "$OPERATION" != "backup" ]; then
          usage
          exit 1
        fi
        TAROPTS="$TAROPTS --exclude $OPTARG"
        ;;
    esac
done

shift $((OPTIND - 1))

if [ $# -lt 1 ]; then
    usage
    exit 1
fi

if [ "$1" == "-" ]; then
    ARCHIVE=$1
    ARCHIVE_PATH=$ARCHIVE
else
    ARCHIVE=${1%%.tar.bz2}.tar.bz2
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
