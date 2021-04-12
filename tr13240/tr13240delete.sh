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
 
date | tee -a ${LOG}
echo 'delete images' | tee -a ${LOG}
${GXDLOAD}/tr13240/deleteimages.csh | tee -a $LOG
date | tee -a ${LOG}

date | tee -a ${LOG}
echo 'delete genotypes' | tee -a ${LOG}
${GXDLOAD}/tr13240/deletegenotypes.csh | tee -a $LOG
date | tee -a ${LOG}

date | tee -a ${LOG}
echo 'delete pixeldb' | tee -a ${LOG}
${GXDLOAD}/tr13240/deletepixeldb.csh | tee -a $LOG
date | tee -a ${LOG}

exit 0
