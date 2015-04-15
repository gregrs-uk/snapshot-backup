Snapshot backup script
======================

Description
-----------
A BASH script which uses rsync to backup files to a remote server, using SSH to connect to the server. The script is designed to be run regularly to create backup snapshots and delete old snapshots. Although the backup is incremental in the sense that only changed files are copied, hard links are used so that each snapshot directory appears to contains all files, changed or not.

Installation
------------
* Copy the script `backup.sh` and the file `exclude.txt` to a directory (default location is `/root/snapshot-backup/`)
* Create a destination directory on the remote server
* Set up private key authentication so that the user who will run the script (probably root) can perform an SSH login to the remote server without using a password and modify files in the destination directory
* Create a local directory for log files (default location is `/var/log/snapshot-backup/`)
* Edit the variables at the top of backup.sh to match your configuration
* Edit `exclude.txt` to choose which files to exclude from the backup. You may need to read the rsync documentation regarding exclude patterns
* Test the script from the command line. You may wish to add a `-v` (verbose) option to the rsync command for testing. Without the `-v` option, only errors will be reported
* You may wish to add an entry to the crontab to run the script hourly, for example
