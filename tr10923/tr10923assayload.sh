#!/bin/sh

#
# TR 10923
#
# Wrapper script for TR10923 assays
#

cd `dirname $0`

. ./tr10923.config

SCRIPT_NAME=`basename $0`

LOG=${PROJECTDIR}/${SCRIPT_NAME}.log
rm -rf ${LOG}
touch ${LOG}
 
#
# Create the probe file
#
cd ${PROJECTDIR}
echo "\n`date`" >> ${LOG}
echo "Load the probe file" >> ${LOG}
${PROBELOAD}/primerload.csh primer.config >> ${LOG}
if [ $? -ne 0 ]
then
    echo 'probe load failed' >> ${LOG}
    exit 1
fi

#
# Create the references file
#
cd ${PROJECTDIR}
echo "\n`date`" >> ${LOG}
echo "Load the references file" >> ${LOG}
${PROBELOAD}/probereference.csh reference.config >> ${LOG}
if [ $? -ne 0 ]
then
    echo 'probereference load failed' >> ${LOG}
    exit 1
fi

exit 0

#
# start 
#

#
# Create the input files for the load.
#
echo "\n`date`" >> ${LOG}
echo "Create the input files for the load" >> ${LOG}
${ASSAYLOAD}/tr10923rtpcr1.py >> ${LOG}
if [ $? -ne 0 ]
then
    echo 'tr10923rtpcr1.py failed' >> ${LOG}
    exit 1
fi

#
# Load the assays and results.
#
echo "\n`date`" >> ${LOG}
echo "Load the assays and results" >> ${LOG}
${ASSAYLOAD}/gelload.py >> ${LOG}
if [ $? -ne 0 ]
then
   echo 'gelload.py failed' >> ${LOG}
   exit 1
fi

mv ${ASSAYLOADDIR}/* ${ASSAYLOADDIR1}

#
# end SuraniTableS7
#

#
# start SuraniTableS6
#

#
# Create the input files for the load.
#
echo "\n`date`" >> ${LOG}
echo "Create the input files for the load" >> ${LOG}
${ASSAYLOAD}/tr10923rtpcr2.py >> ${LOG}
if [ $? -ne 0 ]
then
    echo 'tr10923rtpcr2.py failed' >> ${LOG}
    exit 1
fi

# Load the assays and results.
#
echo "\n`date`" >> ${LOG}
echo "Load the assays and results" >> ${LOG}
${ASSAYLOAD}/gelload.py >> ${LOG}
if [ $? -ne 0 ]
then
    echo 'gelload.py failed' >> ${LOG}
    exit 1
fi

#
# end SuraniTableS6
#

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
