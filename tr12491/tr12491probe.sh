#!/bin/sh -f

#
# TR 12491
#
# Wrapper script for loading GenePaint dataset into GXD for TR 8270
#

cd `dirname $0`

. ./tr12491.config

echo ${PROJECTDIR}

LOG=${PROJECTDIR}/$0.log
rm -rf ${LOG}
touch ${LOG}
 
date | tee -a $LOG
 
#cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG
#EOSQL

date | tee -a $LOG

# Load the probe notes
#
#
#echo "Load the probe notes" | tee -a ${LOG}
#cd ${PROBELOADDATADIR}
#${PROBELOAD}/probenotes.py | tee -a ${LOG}
#if [ $? -ne 0 ]
#then
#    echo 'probenotes.py failed' | tee -a ${LOG}
#    exit 1
#fi

date | tee -a $LOG

exit 0
