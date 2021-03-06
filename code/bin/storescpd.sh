#!/bin/bash
# filename: storescpd
#
# purpose: start storescp server at boot time
# This script is started by monit (/etc/monit/conf.d/processing.conf).
#

tos=15
od=/data/scratch/inbox/
port=1234
pidfile=/data/.pids/storescpd.pid
# the following script will get the aetitle of the caller, the called aetitle and the path to the data as arguments
scriptfile=/data/streams/bucket01/process.sh

case $1 in
    'start')
	echo "Starting storescp daemon..."
	if [ ! -d "$od" ]; then
	    mkdir $od
	fi
	/usr/bin/storescp --eostudy-timeout $tos \
	    --write-xfer-little \
	    --exec-on-eostudy "$scriptfile '#a' '#c' '#r' '#p'" \
	    --sort-on-patientname \
	    --log-config /data/code/bin/logger.cfg \
	    --output-directory "$od" \
	    $port & &>/data/logs/storescpd.log
	pid=$!
	echo $pid > $pidfile
	;;
    'stop')
	/usr/bin/pkill -F $pidfile
	RETVAL=$?
	[ $RETVAL -eq 0 ] && rm -f $pidfile
	;;
    *)
	echo "usage: storescpd { start | stop }"
	;;
esac
exit 0
