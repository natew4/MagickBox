#!/bin/bash
#
# This script is called by other scripts using the gearman02 worker.
# This guarantees that a single instance sends data to the PACS.
#

# here we can execute something with the data in the input
if [ $# -eq 0 ]
then
   echo "usage: work.sh <DICOM directory>"
   echo "usage: work.sh <DICOM directory>" >> /data/logs/bucket02.log
   exit 1
fi

# get the PARENTIP and PARENTPORT variables
. /data/code/setup.sh
#echo "we can read these from setup.sh: $PARENTIP $PARENTPORT" >> /data/logs/bucket02.log

INP=$1
INP=( $INP )
DATA=${INP[0]}
SERVER=${PARENTIP}
# DCM4CHEE port
PORT=11111

if [ ${#INP[@]} -eq 3 ]
then
  SERVER=${INP[1]}
  PORT=${INP[2]}
fi

echo "`date`: send files to \"$SERVER\" \"$PORT\" ($DATA) start..." >> /data/logs/bucket02.log

/usr/bin/storescu -aet "Processing" -aec "DCM4CHEE" -nh +r +sd $SERVER $PORT $DATA >> /data/logs/bucket02.log
if [ $? -ne 0 ]
then
   echo "`date`: error on send \"$DATA\" to DCM4CHEE received" >> /data/logs/bucket02.log
   logger "Error: could not send \"$DATA\" to DCM4CHEE"
fi

echo "`date`: send files to DCM4CHEE ($DATA) done" >> /data/logs/bucket02.log