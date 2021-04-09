#!/bin/sh

#
# TR 13240/lacZ
#
# Wrapper script for loading
#

cd ${GXDLOAD}/tr13240

. ./tr13240.config

cd ${PROJECTDIR}/deleteobjects

LOG=${PROJECTDIR}/tr13240delete.sh.log
rm -rf ${LOG}
touch ${LOG}
 
date >> ${LOG}
echo 'delete images' >> ${LOG}
${GXDLOAD}/tr13240/deleteimages.csh >> $LOG
date >> ${LOG}

date >> ${LOG}
echo 'delete genotypes' >> ${LOG}
${GXDLOAD}/tr13240/deletegenotypes.csh >> $LOG
date >> ${LOG}

date >> ${LOG}
echo 'delete pixeldb' >> ${LOG}
${GXDLOAD}/tr13240/deletepixeldb.csh >> $LOG
date >> ${LOG}

exit 0
