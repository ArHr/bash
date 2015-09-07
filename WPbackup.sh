#!/bin/bash

#Folder where WordPress is installed
WPROOT="public_html"
#Get database used by WordPress
DATABASE=`grep DB_NAME $WPROOT/wp-config.php |awk -F\' '{print$4}'`
#Get WordPress database user
USER=`grep DB_USER $WPROOT/wp-config.php |awk -F\' '{print$4}'`
#Get WordPress database password
PASSWORD=`grep DB_PASSWORD $WPROOT/wp-config.php |awk -F\' '{print$4}'`
#Get WordPress database host
HOST=`grep DB_HOST $WPROOT/wp-config.php |awk -F\' '{print$4}'`
#Date and time in this format 2015-09-07-0913amEDT
DATE=`date +"%F-%H%M%P%Z"`
#Backup file name
BACKUP="WPbackup"_"$DATE".tar.gz

#Remote host for backup storage
RHOST=""
#Remote host username
RUSER=""
#Remote host password
RPASS=""
#Protocol for remote transfer
RPROTO=""
#Remote host SSH port
RPORT=""

#Dump WordPress database to SQL file
mysqldump -h "$HOST" -u "$USER" -p"$PASSWORD" "$DATABASE" > "$DATABASE"_"$DATE".sql
#Compress SQL dump and WPROOT folder to tar.gz file
tar -cvzf $BACKUP $WPROOT "$DATABASE"_"$DATE".sql