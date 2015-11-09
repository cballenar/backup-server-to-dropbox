#!/bin/bash

DATE=$(date +"%Y%m%d%H%M")
FILE="[NAME]_$DATE.tar.gz"
LOCALPATH="/[LOCAL_DIRECTORY]/$FILE"
REMOTEPATH="/[REMOTE_DIRECTORY]/$FILE"

BKP_DIRS="[/path/to/dir_1 /path/to/dir_2 /path/to/dir_3]"

DROPBOX_UPLOADER=[/path/to/dropbox_uploader.sh]
CONFIG_FILE=[/path/to/.dropbox_uploader]

echo "Creating backup..."
tar cf - $BKP_DIRS | gzip -9 > $LOCALPATH

echo "Uploading to Dropbox..."
$DROPBOX_UPLOADER -f $CONFIG_FILE upload "$BKP_FILE.gz" /

echo "Backup $FILE has been successfully uploaded to Dropbox"
rm -fr $LOCALPATH