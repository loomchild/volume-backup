import os
import sys
import tarfile
import shutil


volume_dir = "/volume"
backup_dir = "/backup"
tmp_dir = "/tmp"
data_dir = "data"


def backup(archive_name):
    with tarfile.open(backup_dir + "/" + archive_name, "w:bz2") as tar:
        #TODO maybe instead of tarbomb copy to backup or archive_name
        #     but then make sure permissions work (copy2 doesn't keep them)
        tar.add(volume_dir, ".")


def restore(archive_name):

    for f in os.listdir(volume_dir):
        fp = volume_dir + "/" + f
        if os.path.isfile(fp):
            os.unlink(fp)
        elif os.path.isdir(fp):
            shutil.rmtree(fp)
        else:
            raise Exception("Neither a file nor a directory: " + fp)
    
    with tarfile.open(backup_dir + "/" + archive_name, "r:bz2") as tar:
        #TODO: validate if archive contains only relative paths and no ..
        #TODO: numeric_owner will cause trouble when using uid mapping - make it configurable
        tar.extractall(volume_dir, numeric_owner=True)


def usage():
    print("Usage: volume-backup <backup|restore> <archive>")
    exit(1)

def main():
    if not os.path.isdir(volume_dir):
        print(volume_dir + " directory does not exist")
    if not os.path.isdir(backup_dir):
        print(backup_dir + " directory does not exist")
    
    #TODO: validate that volume is not used, list containers / names

    if not len(sys.argv) == 3:
        usage()
    
    operation = sys.argv[1]

    archive_name = sys.argv[2]
    if not archive_name.endswith(".tar.bz2"):
        archive_name += ".tar.bz2"

    if operation == "backup":
        backup(archive_name)
    elif operation == "restore":
        restore(archive_name)
    else:
        usage()

if __name__ == "__main__":
    main()
