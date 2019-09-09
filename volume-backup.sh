#!/bin/sh

usage() {
  >&2 echo "Usage: volume-backup <backup|restore> [options] <archive or - for stdin/stdout>"
  >&2 echo ""
  >&2 echo "Options:"
  >&2 echo "  -c <algorithm> chooose compression algorithm: bz2 (default), gz, xz and 0 (none)"
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

    tar -C /volume $TAROPTS -cf $ARCHIVE_PATH ./
}

restore() {
    if ! [ "$ARCHIVE" == "-" ]; then
        if ! [ -e $ARCHIVE_PATH ]; then
            >&2 echo "Archive file $ARCHIVE does not exist"
            exit 1
        fi
    fi

    rm -rf /volume/* /volume/..?* /volume/.[!.]*
    tar -C /volume/ $TAROPTS -xf $ARCHIVE_PATH
}

# Needed because sometimes pty is not ready when executing docker-compose run
# See https://github.com/docker/compose/pull/4738 for more details
# TODO: remove after above pull request or equivalent is merged
sleep 1

OPERATION=$1

TAROPTS=""
COMPRESSION="bz2"

OPTIND=2

while getopts "h?c:e:" OPTION; do
    case "$OPTION" in
    h|\?)
        usage
        exit 0
        ;;
    c)  
        if [ -z "$OPTARG" ]; then
          usage
          exit 1
        fi
        COMPRESSION=$OPTARG
        ;;
    e)  
        if [ -z "$OPTARG" -o "$OPERATION" != "backup" ]; then
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

case "$COMPRESSION" in
xz)
      TAROPTS="$TAROPTS -J"
      EXTENSION=.tar.xz
      ;;
bz2)
      TAROPTS="$TAROPTS -j"
      EXTENSION=.tar.bz2
      ;;
gz)
      TAROPTS="$TAROPTS -z"
      EXTENSION=.tar.gz
      ;;
none|0)
      EXTENSION=.tar
      ;;
*)
      usage
      exit 1
      ;;
esac

if [ "$1" == "-" ]; then
    ARCHIVE=$1
    ARCHIVE_PATH=$ARCHIVE
else
    ARCHIVE=${1%%$EXTENSION}$EXTENSION
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
