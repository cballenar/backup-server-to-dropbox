#!/bin/bash

DROPBOX_UPLOADER=[/path/to/dropbox_uploader.sh]
CONFIG_FILE=[/path/to/.dropbox_uploader]

DATE=$(date +"%Y%m%d%H%M")
FILE="[NAME]_$DATE.tar.gz"
LOCALPATH="/[LOCAL_DIRECTORY]/$FILE"
REMOTEPATH="/[REMOTE_DIRECTORY]/$FILE"

BKP_DIRS="[/path/to/dir_1 /path/to/dir_2 /path/to/dir_3]"

DB_USER="[MYSQL_USER]"
DB_PASSWORD="[MYSQL_PASSWORD]"
DB_NAME="[MYSQL_DATABASE]"
DB_TABLE="[MYSQL_TABLE]"

function clean_up
{
    # Perform program exit housekeeping
    echo "Removing temporary files..."
    rm -fr $LOCALPATH
    echo "All done."
    exit $1
}
function db
{
    if [[ "$1" == "insert" ]]; then
       mysql -u $DB_USER -p$DB_PASSWORD -D $DB_NAME -e "INSERT INTO $DB_TABLE (backup_name, backup_status) VALUES ('$FILE', 'Initializing')"
    else
        mysql -u $DB_USER -p$DB_PASSWORD -D $DB_NAME -e "UPDATE $DB_TABLE SET backup_status='$2' WHERE backup_name = '$FILE';"
    fi
}

# insert into database
db insert

# backup directories
echo "Creating backup..."
tar cf - $BKP_DIRS | gzip -9 > $LOCALPATH
# check if backup was successfull
if [ ${PIPESTATUS[0]} -ne "0" ] && [ ${PEPESTATUS[1]} -ne "0" ]; then
    db update "Failed"
    echo "Failed to create backup. Aborting..."
    clean_up 1
fi

# upload to dropbox
echo "Uploading to Dropbox..."
if $DROPBOX_UPLOADER -f $CONFIG_FILE upload $LOCALPATH $REMOTEPATH; then
    db update "Done"
    echo "Backup $FILE has been successfully uploaded to Dropbox"

else
    mysql -u $DB_USER -p$DB_PASSWORD -D $DB_NAME -e "UPDATE $DB_TABLE SET backup_status='Failed' WHERE backup_name = '$FILE';"
    db update "Failed"
    echo "Failed to upload backup. Aborting..."

fi

clean_up
