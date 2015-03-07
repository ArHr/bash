#!/bin/bash

DATE=`date`
DIR='/etc/scripts/onapp'
LOG='onapp_df.log'
SEND=0

EMAIL=''
DF_LIMIT=90

echo $DATE > $DIR/$LOG

check_disk_space (){
	echo $NODE
	USAGE=`ssh root@$NODE "df -h" | grep -vE '^Filesystem|tmpfs|cdrom|onapp' | awk '{ print $(NF-1) } | awk -F% '{print$1}'';`
	if [[ "$USAGE" -gt "DF_LIMIT"] ]
	then 
		SEND=1
		printf "\n\t$NODE is over disk limit\n" >> $DIR/$LOG
		printf "\n===========================\n" >> $DIR/$LOG
		ssh root@$NODE "hostname; df -h" >> $DIR/$LOG
	fi
}

for NODE in {1..10}; do check_disk_space; done

if [[ "$SEND" == 1 ]]; then mail -s "Disk usage over limit on Onapp Server" $EMAIL < $DIR/$LOG; fi

test