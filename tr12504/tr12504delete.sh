#!/bin/sh

#
# TR 12504/lacZ
#
# Wrapper script for loading
#

cd ${GXDLOAD}/tr12504

. ./tr12504.config

LOG=${PROJECTDIR}/tr12504insitu.sh.log
rm -rf ${LOG}
touch ${LOG}
 
date >> ${LOG}
echo 'delete images' >> ${LOG}
./deleteimages.csh >> $LOG
date >> ${LOG}

date >> ${LOG}
echo 'delete genotypes' >> ${LOG}
./deletegenotypes.csh >> $LOG
date >> ${LOG}

exit 0
