# volume-backup

An utility to backup and restore [docker volumes](https://docs.docker.com/engine/reference/commandline/volume/). For more info, read my article on [Medium](https://medium.com/@jareklipski/backup-restore-docker-named-volumes-350397b8e362)

**Note**: Make sure no container is using the volume before backup or restore, otherwise your data might be damaged. See [Miscellaneous](#miscellaneous) for instructions.

**Note**: When using docker-compose, make sure to backup and restore volume labels. See [Miscellaneous](#miscellaneous) for more information.

## Backup

Syntax:

    docker run -v [volume-name]:/volume --rm --log-driver none loomchild/volume-backup backup > [archive-path]

For example:

    docker run -v some_volume:/volume --rm --log-driver none loomchild/volume-backup backup > some_archive.tar.bz2

will archive volume named `some_volume` to `some_archive.tar.bz2` archive file.

**Note**: `--log-driver none` option is necessary to avoid storing an entire backup in a temporary stdout JSON file. More info in [Docker logging documentation](https://docs.docker.com/config/containers/logging/configure/) and in [this issue](https://github.com/loomchild/volume-backup/issues/39).

**WARNING**: This method should not be used under PowerShell on Windows as no usable backup will be generated.

### Backup to a file (deprecated)

Syntax:

    docker run -v [volume-name]:/volume -v [output-dir]:/backup --rm loomchild/volume-backup backup [archive-name]

For example:

    docker run -v some_volume:/volume -v /tmp:/backup --rm loomchild/volume-backup backup some_archive

will archive volume named `some_volume` to `/tmp/some_archive.tar.bz2` archive file.

## Restore

Syntax:

    docker run -i -v [volume-name]:/volume --rm loomchild/volume-backup restore < [archive-path]

For example:

    docker run -i -v some_volume:/volume --rm loomchild/volume-backup restore < some_archive.tar.bz2

will clean and restore volume named `some_volume` from `some_archive.tar.bz2` archive file.

**Note**: Don't forget the `-i` switch for interactive operation.
**Note** Restore will fail if the target volume is not empty (use `-f` flag to override).

### Restore from a file (deprecated)

Syntax:

    docker run -v [volume-name]:/volume -v [output-dir]:/backup --rm loomchild/volume-backup restore [archive-name]

For example:

    docker run -v some_volume:/volume -v /tmp:/backup --rm loomchild/volume-backup restore some_archive

will clean and restore volume named `some_volume` from `/tmp/some_archive.tar.bz2` archive file.

## Miscellaneous

1. Upgrade / update volume-backup
    ```
    docker pull loomchild/volume-backup
    ```

1. volume-backup is also available from GitHub Container Registry (ghcr.io), to avoid DockerHub usage limits:
    ```
    docker pull ghcr.io/loomchild/volume-backup
    ```
    **Note**: you'll need to write `ghcr.io/loomchild/volume-backup` instead of just `loomchild/volume-backup` when running the utility.

1. Find all containers using a volume (to stop them before backing-up)
    ```
    docker ps -a --filter volume=[volume-name]
    ```

1. Exclude some files from the backup and send the archive to stdout
    ```
    docker run -v [volume-name]:/volume --rm --log-driver none loomchild/volume-backup backup -e [excluded-glob] > [archive-path]
    ```

1. Use different compression algorithm for better performance
    ```
    docker run -v [volume-name]:/volume --rm --log-driver none loomchild/volume-backup backup -c pigz > [archive-path]
    ```

1. Show simple progress indicator using verbose `-v` flag (works both for backup and restore)
    ```
    docker run -v [volume-name]:/volume --rm --log-driver none loomchild/volume-backup backup -v > [archive-path]
    ```

1. Pass additional arguments to the Tar utility using `-x` option
    ```
    docker run -v [volume-name]:/volume --rm --log-driver none loomchild/volume-backup backup -x --verbose > [archive-path]
    ```

1. Directly migrate the volume to a new host
    ```
    docker run -v [volume-name]:/volume --rm --log-driver none loomchild/volume-backup backup | ssh [receiver] docker run -i -v [volume-name]:/volume --rm loomchild/volume-backup restore
    ```
    **Note**: In case there are no traffic limitations between the hosts you can trade CPU time for bandwidth by turning off compression via `-c none` option.

1. Volume labels are not backed-up or restored automatically, but they might be required for your application to work (e.g. when using `docker-compose`). If you need to preserve them, create a label backup file as follows: `docker inspect [volume-name] -f "{{json .Labels}}" > labels.json`. When restoring your data, target volume needs to be created manually with labels before launching the restore script: `docker volume create --label "label1" --label "label2" [volume-name]`.
