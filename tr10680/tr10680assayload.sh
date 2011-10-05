#!/bin/sh

#
# TR 10680
#
# Wrapper script for TR10680 assays
#

cd `dirname $0`

. ./tr10680.config

SCRIPT_NAME=`basename $0`

LOG=${PROJECTDIR}/${SCRIPT_NAME}.log
rm -rf ${LOG}
touch ${LOG}
 
#for primer and references
#cd ${PROJECTDIR}

#
# Create the probe file
#
#echo "\n`date`" >> ${LOG}
#echo "Load the probe file" >> ${LOG}
#${PROBELOAD}/primerload.csh primer.config >> ${LOG}
#if [ $? -ne 0 ]
#then
#    echo 'probe load failed' >> ${LOG}
#    exit 1
#fi

#echo "\n`date`" >> ${LOG}
#echo "Load the probe references file" >> ${LOG}
#${PROBELOAD}/probereference.csh primer.config >> ${LOG}
#if [ $? -ne 0 ]
#then
#    echo 'probe reference load failed' >> ${LOG}
#    exit 1
#fi
#exit 0

#
# Create the input files for the in situ load.
#
echo "\n`date`" >> ${LOG}
echo "Create the input files for the in situ load" >> ${LOG}
${ASSAYLOAD}/tr10680insitu.py >> ${LOG}
if [ $? -ne 0 ]
then
    echo 'tr10680insitu.py failed' >> ${LOG}
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
echo "\n`date`" >> ${LOG}
echo "Reload the MRK_Reference table" >> ${LOG}
${MRKCACHELOAD}/mrkref.csh >> ${LOG}
if [ $? -ne 0 ]
then
    echo 'mrkref.csh failed' >> ${LOG}
    exit 1
fi

date >> ${LOG}
exit 0
