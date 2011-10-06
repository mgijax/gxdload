#!/bin/sh

#
# TR 10872
#
# Wrapper script for loading Eurexpress images into GXD for TR 10872
#

cd `dirname $0`

. ./tr10872.config

SCRIPT_NAME=`basename $0`

LOG=${PROJECTDIR}/${SCRIPT_NAME}.log
rm -rf ${LOG}
touch ${LOG}
 
#
# Copy fullsize and thumbnail images to pixel DB.
#
echo "\n`date`" >> ${LOG}
echo "Copy fullsize and thumbnail images to pixel DB" >> ${LOG}
${GXDIMAGELOAD}/pixload.sh >> ${LOG}
if [ $? -ne 0 ]
then
    echo 'pixload.sh failed' >> ${LOG}
    exit 1
fi

date >> ${LOG}
exit 0
