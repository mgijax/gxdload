#!/bin/sh

#
# TR 10872
#
# Wrapper script for TR10872 assays
#

cd `dirname $0`

. ./tr10872.config

SCRIPT_NAME=`basename $0`

LOG=${PROJECTDIR}/${SCRIPT_NAME}.log
rm -rf ${LOG}
touch ${LOG}
 
#
# Create the input files for the load.
#
echo "\n`date`" >> ${LOG}
echo "Create the input files for the load" >> ${LOG}
${ASSAYLOAD}/tr10872insitu.py
#${ASSAYLOAD}/tr10872insitu.py >> ${LOG}
if [ $? -ne 0 ]
then
    echo 'tr10872insitu.py failed' >> ${LOG}
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
echo "\n`date`" >> ${LOG}
echo "Create the literature index for the new assays" >> ${LOG}
${ASSAYLOAD}/indexload.py >> ${LOG}
if [ $? -ne 0 ]
then
    echo 'indexload.py failed' >> ${LOG}
    exit 1
fi

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

date >> ${LOG}
exit 0
