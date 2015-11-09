#!/bin/bash

###############################################################################
## Dropbox Uploader location and configuration
###############################################################################
DROPBOX_UPLOADER="[/path/to/dropbox_uploader.sh]"
CONFIG_FILE="[/path/to/.dropbox_uploader]"

###############################################################################
## File name and directories
###############################################################################
FILE="[NAME]_$(date +"%Y%m%d%H%M")"
LOCALPATH="/[LOCAL_DIRECTORY]/${FILE}"
REMOTEPATH="/[REMOTE_DIRECTORY]/${FILE}"

###############################################################################
## Database information to log backups
###############################################################################
DB_USER="[MYSQL_USER]"
DB_PASSWORD="[MYSQL_PASSWORD]"
DB_NAME="[MYSQL_DATABASE]"
DB_TABLE="[MYSQL_TABLE]"

###############################################################################
## Information to backup
###############################################################################
BU_FILES="[/path/to/dir_1 /path/to/dir_2 /path/to/dir_3]"
BU_DB_USER="[MYSQL_USER]"
BU_DB_PASSWORD="[MYSQL_PASSWORD]"
BU_DB_NAME="[MYSQL_DATABASE]"

###############################################################################
## Functions
###############################################################################
function cleanup
{
    # Perform program exit housekeeping
    echo "Removing temporary files..."
    rm -fr ${LOCALPATH}*
    echo "All done."
    exit ${1}
}

function db
{
    if [[ "${1}" == "insert" ]]; then
       mysql -u ${DB_USER} -p${DB_PASSWORD} -D ${DB_NAME} -e "INSERT INTO ${DB_TABLE} (backup_name, backup_status) VALUES ('${FILE}', 'Initializing')"
    else
        mysql -u ${DB_USER} -p${DB_PASSWORD} -D ${DB_NAME} -e "UPDATE ${DB_TABLE} SET backup_status='${2}' WHERE backup_name = '${FILE}';"
    fi
}

function backupDatabase
{
    echo "Creating database backup..."
    if mysqldump -u ${BU_DB_USER} --password=${BU_DB_PASSWORD} ${BU_DB_NAME} > ${LOCALPATH}.sql; then
        # add sql dump to files to be compressed
        BU_FILES="${BU_FILES} ${LOCALPATH}.sql"

    else
        echo "Failed to create backup. Aborting..."
        db update "Failed"
        cleanup 1
    fi

}

function backupFiles
{
    echo "Creating files backup..."
    tar cf - ${BU_FILES} | gzip -9 > ${LOCALPATH}.tar.gz

    # check if backup was successfull
    if [ ${PIPESTATUS[0]} -ne "0" ] && [ ${PEPESTATUS[1]} -ne "0" ]; then
        echo "Failed to create backup. Aborting..."
        db update "Failed"
        cleanup 1
    fi
}

function uploadBackup
{
    echo "Uploading to Dropbox..."
    if ${DROPBOX_UPLOADER} -f ${CONFIG_FILE} upload ${LOCALPATH}.tar.gz ${REMOTEPATH}.tar.gz; then
        echo "Backup ${FILE} has been successfully uploaded to Dropbox"
        db update "Done"

    else
        echo "Failed to upload backup. Aborting..."
        db update "Failed"
    fi
}

###############################################################################
## Run Script
###############################################################################
db insert
backupDatabase
backupFiles
uploadBackup
cleanup
