#!/bin/sh

#
# TR 10629
#
# Wrapper script for loading Eurexpress assays into GXD for TR 10629
#

cd `dirname $0`

. ./tr10629.config

SCRIPT_NAME=`basename $0`

LOG=${PROJECTDIR}/${SCRIPT_NAME}.log
rm -rf ${LOG}
touch ${LOG}
 
#
# Create LoadFile4 (pre-process the LoadFile3.txt file)
#
#echo "\n`date`" >> ${LOG}
#echo "Creted LoadFile4.txt" >> ${LOG}
#${ASSAYLOAD}/tr10629structure.py >> ${LOG}
#if [ $? -ne 0 ]
#then
#    echo 'tr10629structure.py failed' >> ${LOG}
#    exit 1
#fi

#
# Create the input files for the in situ load.
#
echo "\n`date`" >> ${LOG}
echo "Create the input files for the in situ load" >> ${LOG}
${ASSAYLOAD}/tr10629insitu.py >> ${LOG}
if [ $? -ne 0 ]
then
    echo 'tr10629insitu.py failed' >> ${LOG}
    exit 1
fi

#
# Load the assays and results.
#
echo "\n`date`" >> ${LOG}
echo "Load the assays and results" >> ${LOG}
${ASSAYLOAD}/insituload.py >> ${LOG}
if [ $? -ne 0 ]
then
    echo 'insituload.py failed' >> ${LOG}
    exit 1
fi

exit 0

#
# Associate images with assay results.
#
#echo "\n`date`" >> ${LOG}
#echo "Associate images with assay results" >> ${LOG}
#${GXDIMAGELOAD}/assocResultImage.py >> ${LOG}
#if [ $? -ne 0 ]
#then
#    echo 'assocResultImage.py failed' >> ${LOG}
#    exit 1
#fi

#
# Create the literature index for the new assays.
#
echo "\n`date`" >> ${LOG}
echo "Create the literature index for the new assays" >> ${LOG}
${ASSAYLOAD}/indexload.py >> ${LOG}
if [ $? -ne 0 ]
then
    echo 'indexload.py failed' >> ${LOG}
    exit 1
fi

exit 0

#
# Reload the MRK_Reference table.
#
echo "\n`date`" >> ${LOG}
echo "Reload the MRK_Reference table" >> ${LOG}
${MRKCACHELOAD}/mrkref.csh >> ${LOG}
if [ $? -ne 0 ]
then
    echo 'mrkref.csh failed' >> ${LOG}
    exit 1
fi

#
# Reload the IMG_Cache table.
#
echo "\n`date`" >> ${LOG}
echo "Reload the IMG_Cache table" >> ${LOG}
${MGICACHELOAD}/imgcache.csh >> ${LOG}
if [ $? -ne 0 ]
then
    echo 'imgcache.csh failed' >> ${LOG}
    exit 1
fi

date >> ${LOG}
exit 0
