# volume-backup

An utility to backup and restore [docker volumes](https://docs.docker.com/engine/reference/commandline/volume/). 

**Note**: Make sure no container is using the volume before backup or restore, otherwise your data might be damaged. See [Miscellaneous](#miscellaneous) for instructions.

## Backup

Syntax:

    docker run -v [volume-name]:/volume -v [output-dir]:/backup --rm loomchild/volume-backup backup [archive-name]

For example:

    docker run -v some_volume:/volume -v /tmp:/backup --rm loomchild/volume-backup backup some_archive

will archive volume named `some_volume` to `/tmp/some_archive.tar.bz2` archive file.

### Backup to standard output

This avoids mounting a second backup volume and allows to redirect it to a file, network, etc.

**WARNING**: This method should not be used with a Docker for Windows installation; no usable backup will be generated.

Syntax:

    docker run -v [volume-name]:/volume --rm loomchild/volume-backup backup - > [archive-name]

For example:

    docker run -v some_volume:/volume --rm loomchild/volume-backup backup - > some_archive.tar.bz2

will archive volume named `some_volume` to `some_archive.tar.bz2` archive file.

## Restore

**Note**: This operation will delete all contents of the volume

Syntax:

    docker run -v [volume-name]:/volume -v [output-dir]:/backup --rm loomchild/volume-backup restore [archive-name]

For example:

    docker run -v some_volume:/volume -v /tmp:/backup --rm loomchild/volume-backup restore some_archive

will clean and restore volume named `some_volume` from `/tmp/some_archive.tar.bz2` archive file.

### Restore from standard input

This avoids mounting a second backup volume.

**Note**: Don't forget the `-i` switch for interactive operation.

**WARNING**: This method should not be used with a Docker for Windows installation; no usable backup will be generated.

Syntax:

    cat [archive-name] | docker run -i -v [volume-name]:/volume --rm loomchild/volume-backup restore -

For example:

    cat some_archive.tar.bz2 | docker run -i -v some_volume:/volume --rm loomchild/volume-backup restore -

will clean and restore volume named `some_volume` from `some_archive.tar.bz2` archive file.

### Miscellaneous

1. Upgrade / update volume-backup

    docker pull loomchild/volume-backup

1. Find all containers using a volume (to stop them before backing-up)

    docker ps -a --filter volume=[volume-name]
