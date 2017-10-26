#!/bin/sh

#
# TR????? 
#
# Template to be used for adhoc GXD loads. Find and replace the '?????' as
# appropriate. This template was created primarily to remind us we need to 
# run BIB_updateWFStatusGXD stored procedure after GXD Loads
#

cd `dirname $0`

. ./tr?????.config

LOG=${PROJECTDIR}/$0.log
rm -rf ${LOG}
touch ${LOG}
 
#
# remove existing assay/indexes, if necessary
# by Reference
#
cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a ${LOG}
delete from GXD_Assay where _Refs_key = 172505
;
delete from GXD_Index where _Refs_key = 172505
;
EOSQL

#
# Create the input files for the in situ load.
#
echo "\n`date`" >> ${LOG}
echo "Create the input files for the in situ load" >> ${LOG}
${ASSAYLOAD}/tr?????insitu.py
if [ $? -ne 0 ]
then
    echo 'tr?????insitu.py failed' >> ${LOG}
    exit 1
fi

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

echo 'running BIB_updateWFStatusGXD' | tee -a ${LOG}
cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a ${LOG}
select BIB_updateWFStatusGXD();
EOSQL

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
