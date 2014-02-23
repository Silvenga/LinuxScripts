#!/bin/bash
#######################################################################
#
# Will preform a full backup every 15 days
# Incremental all other days (Including the MySql database)
# Will keep the last 45 days of backups
#
# Install: 
# apt-get install python-software-properties
# add-apt-repository ppa:duplicity-team/ppa
# apt-get update && apt-get install duplicity python-boto mailutils
# mkdir -p /var/log/duplicity/
#
# Install the Cron Job
# su -l root # login to root to edit root's cron jobs
# crontab -e
# 0 1 * * *  /usr/share/cron-scripts/backup.sh # will run at 01:00 every day
#
#######################################################################
#######################################################################
# Settings start
#######################################################################

FOLDER=n0

EMAIL_TO="admin@example.com"

# MySql Database settings
USER="root"
PASSWORD="mysql_password"
# Location of backup SQL scripts
OUTPUTDIR="/var/db-backups"

# Duplicity encryption key for backups
export PASSPHRASE=079ebb47e23b20f3acad9d82fc94731ba3e6495f84a7e9

# Amazon S3 settings
export AWS_ACCESS_KEY_ID=XXXXXXXXXXXXXXXXXXX
export AWS_SECRET_ACCESS_KEY=XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
# S3 location
TARGET=s3+http://bucket/$FOLDER
# Backup root dir
SOURCE=/
# Log location 
# Will only save the last one
LOGLOC=/var/log/duplicity/backup.log

# Add any folders to exclude here
EXCLUDE=/tmp/excludeList.txt
cat > $EXCLUDE <<EOF
- /dev
- /proc
- /home/*/.cache
- /home/*/.ccache
- /lost+found
- /media
- /mnt
- /run
- /tmp
- /boot
- /selinux
- /root/.cache
- /root/.ccache
- /sys
- /var/cache/*/*
- /var/log
- /var/run
- /var/tmp
EOF

#######################################################################
# Settings end
#######################################################################

#######################################################################
# Start Script
#######################################################################

echo "Started At: `date`." >>$LOGLOC
echo "Starting Backup." >>$LOGLOC
echo "" >>$LOGLOC
 
#######################################################################
# Init backup
#######################################################################
echo "Dumping databases..." >>$LOGLOC

mkdir -p $OUTPUTDIR
rm "$OUTPUTDIR/*bak" > /dev/null 2>&1

databases=`mysql --user=$USER --password=$PASSWORD \
 -e "SHOW DATABASES;" | tr -d "| " | grep -v Database`

for db in $databases; do
    echo "Dumping databse: $db">>$LOGLOC
    mysqldump --force --opt --user=$USER --password=$PASSWORD \
    --databases $db 1> "$OUTPUTDIR/$db.bak" 2>NUL
done

echo "Done." >>$LOGLOC
echo "" >>$LOGLOC
####################################################################### 
# Backup
#######################################################################
echo "Backing up files..." >>$LOGLOC
OPTS="--exclude-filelist $EXCLUDE --s3-use-new-style "
duplicity --full-if-older-than 15D $OPTS $SOURCE $TARGET >>$LOGLOC
echo "Done." >>$LOGLOC
echo "" >>$LOGLOC

####################################################################### 
# Clean-up
#######################################################################
echo "Cleaning old backups..." >>$LOGLOC
duplicity remove-all-but-n-full 3 --force $TARGET >>$LOGLOC
echo "Done." >>$LOGLOC
echo "" >>$LOGLOC

####################################################################### 
# Finish up
#######################################################################
unset AWS_ACCESS_KEY_ID
unset AWS_SECRET_ACCESS_KEY
unset PASSPHRASE

# Email log
echo "Backup Finished, Emailing Log..." >>$LOGLOC
mail -s 'Daily Backup Report' $EMAIL_TO <$LOGLOC
 
# Remove old backup log, and backup current log
rm $LOGLOC.bak
mv $LOGLOC $LOGLOC.bak
 
# Done!
exit 0