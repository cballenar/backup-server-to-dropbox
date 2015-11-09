#!/bin/bash

DATE=$(date +"%Y%m%d%H%M")
FILE="[NAME]_$DATE.sql.gz"
LOCALPATH="/[LOCAL_DIRECTORY]/$FILE"
REMOTEPATH="/[REMOTE_DIRECTORY]/$FILE"

DROPBOX_UPLOADER=[/path/to/dropbox_uploader.sh]
CONFIG_FILE=[/path/to/.dropbox_uploader]

echo "Creating backup..."
mysqldump -u [MYSQL_USER] --password=[PASSWORD] [DATABASE] | gzip -9 > $LOCALPATH

echo "Uploading to Dropbox..."
$DROPBOX_UPLOADER -f $CONFIG_FILE upload $LOCALPATH $REMOTEPATH; then

echo "Backup $FILE has been successfully uploaded to Dropbox"
rm -fr $LOCALPATH