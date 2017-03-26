FROM python:onbuild

ENTRYPOINT [ "python", "./volume-backup.py" ]
