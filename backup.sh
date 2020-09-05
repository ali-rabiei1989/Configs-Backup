#!/bin/bash

# Author: Ali Rabiei
# Purpose: This script backup files and folders to both local and remote 
# Creation Date: 09/05/2020
# Last Modification Date: 09/05/2020

# Parsing Options
while [[ $# -gt 0 ]]
do
    OPTION=${1}

    case $OPTION in 
    '-c'|'--config')
        shift
        CONFIGFILE=${1}
        shift
    ;;
    '-r'|'--remote')
        REMOTE=true
        shift
        RMTLOC=${1}
        shift
    ;;
    '-d'|'--destination')
        shift
        LOC=${1}backups/
        shift
    ;;
    *)
        echo "Unrecognized Option: $OPTION"
        exit 1
    ;;
    esac
done

# Check mandatory options
if [[ -z "$LOC" ]]
then
    echo "Missing argument: --destination"
    exit 1
fi

# Set default values
: "${CONFIGFILE:=./backup-targets.cfg}"
: "${REMOTE:=false}"

# Set log file location
LOG=/var/log/backup.log

# Formatting log file output
echo -e "\n------------------------- Backup process started on $(date +'%m/%d/%Y %H:%M') -------------------------\n" >> $LOG

# Define local target directory
TGTLOC="$LOC$(date +'%m-%d-%Y_%H-%M')"

echo "Creating target directory: $TGTLOC" >> $LOG
mkdir -p "$TGTLOC"
echo "Target directory created." >> $LOG

# Rsync each entry in backup config file
while  read -r SRC || [[ -n "$SRC" ]]
do
    rsync -avhzt --progress --log-file="$LOG" $SRC "$TGTLOC"
done <$CONFIGFILE

# Create a tar file of backuped files
tar -zcf $TGTLOC.tar.gz $TGTLOC >> $LOG

rm -rf $TGTLOC

# Do the same thing for remote location
if [[ $REMOTE = true ]]
then
    while  read -r SRC || [[ -n "$SRC" ]]
    do
        rsync -avhzt --progress --log-file="$LOG" $SRC "$RMTLOC" 
    done <$CONFIGFILE
fi 
