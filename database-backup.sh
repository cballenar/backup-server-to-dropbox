#!/bin/bash

DROPBOX_UPLOADER=[/path/to/dropbox_uploader.sh]
CONFIG_FILE=[/path/to/.dropbox_uploader]

DATE=$(date +"%Y%m%d%H%M")
FILE="[NAME]_$DATE.sql.gz"
LOCALPATH="/[LOCAL_DIRECTORY]/$FILE"
REMOTEPATH="/[REMOTE_DIRECTORY]/$FILE"

function clean_up
{
    # Perform program exit housekeeping
    echo "Removing temporary files..."
    rm -fr $LOCALPATH
    echo "All done."
    exit $1
}

# backup mysql
echo "Creating backup..."
mysqldump -u [MYSQL_USER] --password=[PASSWORD] [DATABASE] | gzip -9 > $LOCALPATH
# check if backup was successfull
if [ ${PIPESTATUS[0]} -ne "0" ]; then
    echo "Failed to create backup. Aborting..."
    clean_up 1
fi

# upload to dropbox
echo "Uploading to Dropbox..."
if $DROPBOX_UPLOADER -f $CONFIG_FILE upload $LOCALPATH $REMOTEPATH; then
    echo "Backup $FILE has been successfully uploaded to Dropbox"
else
    echo "Failed to upload backup. Aborting..."
fi

clean_up