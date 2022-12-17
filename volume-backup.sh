#!/bin/bash

usage() {
  >&2 echo "Usage: volume-backup <backup|restore> [options]. Reads from stdin and writes to stdout. Can also read/write files (deprecated)."
  >&2 echo ""
  >&2 echo "Options:"
  >&2 echo "  -c <algorithm> chooose compression algorithm: bz2 (default), gz, xz, pigz, zstd and 0 (none)"
  >&2 echo "  -e <glob> exclude files or directories (only for backup operation)"
  >&2 echo "  -f force overwrite even if target volume is not empty during restore"
  >&2 echo "  -x <args> pass additional arguments to the Tar utility"
  >&2 echo "  -v verbose"
}

backup() {
    if [ -z "$(ls -A /volume)" ]; then
       >&2 echo "Volume is empty or missing, check if you specified a correct name"
       exit 1
    fi

    if ! [ "$ARCHIVE" == "-" ]; then
        mkdir -p `dirname /backup/$ARCHIVE`
    fi

    tar -C /volume "${TAROPTS[@]}" -cf $ARCHIVE_PATH ./
}

restore() {
    if ! [ "$ARCHIVE" == "-" ]; then
        if ! [ -e $ARCHIVE_PATH ]; then
            >&2 echo "Archive file $ARCHIVE does not exist"
            exit 1
        fi
    fi


    if ! [ -z "$(ls -A /volume)" -o -n "$FORCE" ]; then
        >&2 echo "Target volume is not empty, aborting; use -f to override"
        exit 1
    fi

    rm -rf /volume/* /volume/..?* /volume/.[!.]*
    tar -C /volume/ "${TAROPTS[@]}" -xf $ARCHIVE_PATH
}

OPERATION=$1

TAROPTS=()
COMPRESSION="bz2"
FORCE=""

OPTIND=2

while getopts "h?vfc:e:x:" OPTION; do
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
        TAROPTS+=(--exclude $OPTARG)
        ;;
    f)
        if [ "$OPERATION" != "restore" ]; then
          usage
          exit 1
        fi
        FORCE=1
        ;;
    v)
        TAROPTS+=(--checkpoint=.1000)
        EOLN=1
        ;;
    x)
        if [ -z "$OPTARG" ]; then
          usage
          exit 1
        fi
        # Note: it doesn't support nested quotes, e.g. -x '-I "zstd -10"'
        OPTARR=($OPTARG)
        TAROPTS=(${TAROPTS[@]} ${OPTARR[@]})
        ;;
    esac
done

shift $((OPTIND - 1))

case "$COMPRESSION" in
xz)
      TAROPTS+=(-J)
      EXTENSION=.tar.xz
      ;;
bz2)
      TAROPTS+=(-j)
      EXTENSION=.tar.bz2
      ;;
gz)
      TAROPTS+=(-z)
      EXTENSION=.tar.gz
      ;;
pigz)
      TAROPTS+=(-I pigz)
      EXTENSION=.tar.gz
      ;;
zstd)
      TAROPTS+=(-I zstd)
      EXTENSION=.tar.zstd
      ;;
none|0)
      EXTENSION=.tar
      ;;
*)
      usage
      exit 1
      ;;
esac

if [ -z "$1" ] || [ "$1" == "-" ]; then
    ARCHIVE="-"
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

if ! [ -z "$EOLN" ]; then
    >&2 echo
fi
