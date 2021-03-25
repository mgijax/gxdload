#!/bin/sh
#
# TR 12504
#
# Wrapper script for loading
#
echo "cd"
cd `dirname $0`
echo "source config"

. ./tr13240.config
echo ${IMAGELOADDATADIR}
LOG=${IMAGELOADDATADIR}/$0.log
echo ${LOG}
rm -rf ${LOG}
touch ${LOG}
 
#
# Copy fullsize images to Pixel DB.
#
date >> ${LOG}
echo 'Copy fullsize to Pixel DB' >> ${LOG}
./pixload.csh ${FULLSIZE_IMAGE_DIR} ${PIX_MAPPING} >> ${LOG}
if [ $? -ne 0 ]
then
    echo 'pixload.sh failed' >> ${LOG}
    exit 1
fi
date >> ${LOG}
