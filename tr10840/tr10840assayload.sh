#!/bin/sh

#
# TR 10840
#
# Wrapper script for TR10840 assays
#

cd `dirname $0`

. ./tr10840.config

SCRIPT_NAME=`basename $0`

LOG=${PROJECTDIR}/${SCRIPT_NAME}.log
rm -rf ${LOG}
touch ${LOG}
 
cd ${PROJECTDIR}
#
# Create the probe file
#
echo "\n`date`" >> ${LOG}
echo "Load the probe file" >> ${LOG}
${PROBELOAD}/primerload.csh primer.config >> ${LOG}
if [ $? -ne 0 ]
then
    echo 'probe load failed' >> ${LOG}
    exit 1
fi
exit 0

#
# Create the input files for the in situ load.
#
#echo "\n`date`" >> ${LOG}
#echo "Create the input files for the in situ load" >> ${LOG}
#${ASSAYLOAD}/tr10840rtpcr1.py >> ${LOG}
#if [ $? -ne 0 ]
#then
#    echo 'tr10840rtpcr1.py failed' >> ${LOG}
#    exit 1
#fi

#
# Create the input files for the in situ load.
#
echo "\n`date`" >> ${LOG}
echo "Create the input files for the in situ load" >> ${LOG}
${ASSAYLOAD}/tr10840rtpcr2.py
#${ASSAYLOAD}/tr10840rtpcr2.py >> ${LOG}
if [ $? -ne 0 ]
then
    echo 'tr10840rtpcr2.py failed' >> ${LOG}
    exit 1
fi

exit 0

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
