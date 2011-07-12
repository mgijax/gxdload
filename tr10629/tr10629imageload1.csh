#!/bin/sh

#
# TR 10629
#
# Wrapper script for loading Eurexpress images into GXD for TR 10629
#

cd `dirname $0`

. ./tr10629.config

SCRIPT_NAME=`basename $0`

LOG=${PROJECTDIR}/${SCRIPT_NAME}.log
rm -rf ${LOG}
touch ${LOG}
 
#
# Copy fullsize and thumbnail images to pixel DB.
#
echo "\n`date`" >> ${LOG}
echo "Copy fullsize and thumbnail images to pixel DB" >> ${LOG}
${GXDIMAGELOAD}/tr10629pixload.sh >> ${LOG}
if [ $? -ne 0 ]
then
    echo 'tr10629pixload.sh failed' >> ${LOG}
    exit 1
fi

date >> ${LOG}
exit 0
