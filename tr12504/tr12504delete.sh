#!/bin/sh

#
# TR 12504/lacZ
#
# Wrapper script for loading
#

cd ${GXDLOAD}/tr12504

. ./tr12504.config

cd ${PROJECTDIR}/deleteobjects

LOG=${PROJECTDIR}/tr12504delete.sh.log
rm -rf ${LOG}
touch ${LOG}
 
date >> ${LOG}
echo 'delete images' >> ${LOG}
${GXDLOAD}/tr12504/deleteimages.csh >> $LOG
date >> ${LOG}

date >> ${LOG}
echo 'delete genotypes' >> ${LOG}
${GXDLOAD}/tr12504/deletegenotypes.csh >> $LOG
date >> ${LOG}

exit 0
