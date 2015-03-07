#!/bin/bash

SERVICE_1='policyd-weight'
SERVICE_2='postfix'
SERVICE_3='amavisd'

DATE=`date`
SERVER=`hostname`

DIR='/etc/scripts/mxmonitor/'
LOG="$DIRmxmonitor.log"
EMAIL=''

QUEUE=`mailq 2>/dev/null |tail -n1 | awk '{print$5}'`
QUEUE_LIMIT=1000

SEND=0

echo $DATE > $LOG

restart_success () {
    printf "\n\t $SERVICE has been restarted\n\nPlease connect to $SERVER and check service status\n" >> $LOG
}

restart_fail () {
    printf "\n\t $SERVICE has failed to restart\n\nPlease connect to $SERVER and check service status\n" >> $LOG
}

get_status (){
for SERVICE in $SERVICE_1 $SERVICE_2 $SERVICE_3;
do
    printf "\n============================================\n $SERVICE \n============================================\n\t " >> $LOG
    /etc/init.d/$SERVICE status >> $LOG
    #printf "\n\t " >> $LOG
done
}

check_process (){
    #policyd-weight-weight needs to be checked for master process
    #policyd-weight start needs to be used, not service restart
	CHKPROCESS=$SERVICE
    RSTSRV='restart'

    if [ "$SERVICE" == 'policyd-weight' ]; then CHKPROCESS='policyd-weight (master)'; RSTSRV='start'; fi

    if ps ax | grep -v grep | grep "$CHKPROCESS" > /dev/null
        then
            printf "$DATE\n$CHKPROCESS running on $SERVER\n" > /dev/null
        else
            printf "\n\t $CHKPROCESS not running on $SERVER\n\t "
            /etc/init.d/$SERVICE $RSTSRV
            if ps ax | grep -v grep | grep "$CHKPROCESS" > /dev/null; then restart_success; else restart_fail; fi
            SEND=1
            echo $SEND
    fi
}

check_queue (){
    printf "\n============================================\n\t Mail Queue Status \n============================================\n" >> $LOG
    printf "\n\t$SERVER -- there is $QUEUE requests in mail queue. \n" >> $LOG
	
	if [[ "$QUEUE" -gt "QUEUE_LIMIT" ]]; then SEND=1; echo $SEND; printf "\t QUEUE LARGER THEN 1000\n" >> $LOG; fi
	
    printf "\n=============================================\n" >> $LOG
}

check_queue
get_status

printf "\n============================================\n\t Attempting to restart failed services \n===========================================\n" >> $LOG

for SERVICE in $SERVICE_1 $SERVICE_2 $SERVICE_3; do check_process; done

printf "\n\n******************************************************************************************\n\t\t\t  Status after service restart attempt  \n******************************************************************************************\n" >> $LOG
get_status
check_queue

if [[ "$SEND" == 1 ]]; then mail -s "Service issues on $SERVER" $EMAIL < $LOG; fi