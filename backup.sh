#!/bin/bash

# backup location on remote server
# NB This path should not contain spaces, even if they are escaped
DESTINATION="/mnt/Data/backup"
# ssh login to remote server
LOGIN="user@192.168.1.10"
# exclude file on local machine
EXCLUDE="/root/snapshot-backup/exclude.txt"
# log dir on local machine
LOGROOT="/var/log/snapshot-backup"

# directories to backup
DIRS="/home/ /etc/ /root/ /var/log/"

# ------ END OF CONFIGURATION VARIABLES ------

# the following two variables should not need modification
DATETIME=`date +%Y%m%d-%H%M:%S`
DATE=`date +%Y%m%d`

# check directories exist and are accessible
ssh $LOGIN "test -e $DESTINATION" || { echo "Destination directory does not exist"; exit 1; }

# make directory for this snapshot
ssh $LOGIN "mkdir $DESTINATION/$DATETIME-incomplete" || { echo "Could not create snapshot directory"; exit 1; }

# do the rsync
rsync -azR \
	--link-dest=$DESTINATION/current/ \
	--log-file=$LOGROOT/$DATETIME.log \
	--delete --delete-excluded \
	--exclude-from $EXCLUDE $DIRS \
	$LOGIN:$DESTINATION/$DATETIME-incomplete/

# change name of directory once rsync is complete
ssh $LOGIN "mv $DESTINATION/$DATETIME-incomplete $DESTINATION/$DATETIME" || { echo "Could not rename directory after rsync"; exit 1; }

# link current to this backup
ssh $LOGIN "rm -f $DESTINATION/current" || { echo "Could not remove current backup link"; exit 1; }
ssh $LOGIN "ln -s $DESTINATION/$DATETIME $DESTINATION/current" || { echo "Could not create current backup link"; exit 1; }

# remove backups older than 31 days
ssh $LOGIN "find $DESTINATION/* -maxdepth 0 -type d -mtime +31 -exec rm -r {} \;" || { echo "Could not remove old backups"; exit 1; }

# remove local log files older than 31 days
find $LOGROOT/* -maxdepth 0 -type f -mtime +31 -exec rm {} \; || { echo "Could not remove old log files"; exit 1; }
