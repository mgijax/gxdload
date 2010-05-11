#!/bin/sh

#
# TR 10161
#
# Wrapper script for loading
#

cd `dirname $0`

. ./tr10161.config

LOG=${PROJECTDIR}/$0.log
rm -rf ${LOG}
touch ${LOG}
 
#
# Create the input files for the in situ load.
#
#echo "\n`date`" >> ${LOG}
#echo "Create the input files for the in situ load" >> ${LOG}
#${ASSAYLOAD}/tr10161insitu.py >> ${LOG}
#if [ $? -ne 0 ]
#then
#    echo 'tr10161insitu.py failed' >> ${LOG}
#    exit 1
#fi

# Load the assays and results.
#
#echo "\n`date`" >> ${LOG}
#echo "Load the assays and results" >> ${LOG}
#${ASSAYLOAD}/insituload.py >> ${LOG}
#if [ $? -ne 0 ]
#then
#    echo 'insituload.py failed' >> ${LOG}
#    exit 1
#fi

#
#
# Associate images with assay results.
#
echo "\n`date`" >> ${LOG}
echo "Associate images with assay results" >> ${LOG}
${GXDIMAGELOAD}/assocResultImage.py >> ${LOG}
if [ $? -ne 0 ]
then
    echo 'assocResultImage.py failed' >> ${LOG}
    exit 1
fi

#
# Create the literature index for the new assays.
#
#echo "\n`date`" >> ${LOG}
#echo "Create the literature index for the new assays" >> ${LOG}
#${ASSAYLOAD}/indexload.py >> ${LOG}
#if [ $? -ne 0 ]
#then
#    echo 'indexload.py failed' >> ${LOG}
#    exit 1
#fi

#
# Reload the MRK_Reference table.
#
#echo "\n`date`" >> ${LOG}
#echo "Reload the MRK_Reference table" >> ${LOG}
#${MRKCACHELOAD}/mrkref.csh >> ${LOG}
#if [ $? -ne 0 ]
#then
#    echo 'mrkref.csh failed' >> ${LOG}
#    exit 1
#fi

#
# Reload the IMG_Cache table.
#
#echo "\n`date`" >> ${LOG}
#echo "Reload the IMG_Cache table" >> ${LOG}
#${MGICACHELOAD}/imgcache.csh >> ${LOG}
#if [ $? -ne 0 ]
#then
#    echo 'imgcache.csh failed' >> ${LOG}
#    exit 1
#fi

date >> ${LOG}
exit 0
