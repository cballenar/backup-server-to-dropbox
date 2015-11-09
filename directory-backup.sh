#!/bin/bash

DROPBOX_UPLOADER=[/path/to/dropbox_uploader.sh]
CONFIG_FILE=[/path/to/.dropbox_uploader]

DATE=$(date +"%Y%m%d%H%M")
FILE="[NAME]_$DATE.tar.gz"
LOCALPATH="/[LOCAL_DIRECTORY]/$FILE"
REMOTEPATH="/[REMOTE_DIRECTORY]/$FILE"

BKP_DIRS="[/path/to/dir_1 /path/to/dir_2 /path/to/dir_3]"

function clean_up
{
    # Perform program exit housekeeping
    echo "Removing temporary files..."
    rm -fr $LOCALPATH
    echo "All done."
    exit $1
}

# backup directories
echo "Creating backup..."
tar cf - $BKP_DIRS | gzip -9 > $LOCALPATH
# check if backup was successfull
if [ ${PIPESTATUS[0]} -ne "0" ] && [ ${PEPESTATUS[1]} -ne "0" ]; then
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
