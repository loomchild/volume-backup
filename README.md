# volume-backup

An utility to backup and restore [docker volumes](https://docs.docker.com/engine/reference/commandline/volume/). 

**Note**: Make sure no container is using the volume before backup or restore.

## Backup

Syntax:

    docker run -v [volume-name]:/volume -v [output-dir]:/backup loomchild/volume-backup backup [archive-name]

For example:

    docker run -v some_volume:/volume -v /tmp:/backup loomchild/volume-backup backup archive1

will archive volume named `some_volume` to `/tmp/archive.tar.bz2` archive file.

## Restore

Syntax:

    docker run -v [volume-name]:/volume -v [output-dir]:/backup loomchild/volume-backup restore [archive-name]

**Note**: This operation will delete all contents of the volume

For example:

    docker run -v some_volume:/volume -v /tmp:/backup loomchild/volume-backup restore archive1

will clean and restore volume named `some_volume` from `/tmp/archive.tar.bz2` archive file.
