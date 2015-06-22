#!/bin/bash
################################################################################
# Backs up a file
# Receives one arguement ( the file you want to backup )
backupFile()
{
  (
    CUR_BACKUP_FILE="${1}" ; EPOCH_NS=$( date +%s-%N )
    cp -p "${CUR_BACKUP_FILE}" "${CUR_BACKUP_FILE}-${EPOCH_NS}"
    if      [ -f "${CUR_BACKUP_FILE}-${EPOCH_NS}" ]
    then    echo "# backupFile() SUCCESS: ${CUR_BACKUP_FILE} --> ${CUR_BACKUP_FILE}-${EPOCH_NS}" ; RC=0
    else    echo "# backupFile() FAILED: ${CUR_BACKUP_FILE} --> ${CUR_BACKUP_FILE}-${EPOCH_NS}"  ; RC=1
    fi
  )
}