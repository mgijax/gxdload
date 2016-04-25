#!/bin/sh

#
# TR 12026
#
# Wrapper script for loading
#

cd `dirname $0`

. ./tr12026.config

LOG=${PROJECTDIR}/$0.log
rm -rf ${LOG}
touch ${LOG}
 
#
# IF DOING WI TESTING, RUN:
#	wi/admin/cleanup
#
# TO REMOVE CACHED DATA
#

cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG
delete from GXD_Assay where _Refs_key = 229658 ;
delete from GXD_Index where _Refs_key = 229658 ;
EOSQL

#
# Create the input files for the in situ load.
#
echo "\n`date`" >> ${LOG}
echo "Create the input files for the in situ load" >> ${LOG}
./tr12026insitu.py >> ${LOG}
if [ $? -ne 0 ]
then
    echo 'tr12026insitu.py failed' >> ${LOG}
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

exit 0

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
echo "\n`date`" >> ${LOG}
echo "Create the literature index for the new assays" >> ${LOG}
${ASSAYLOAD}/indexload.py >> ${LOG}
if [ $? -ne 0 ]
then
    echo 'indexload.py failed' >> ${LOG}
    exit 1
fi

#
# Reload the GXD_Expression table.
#
echo "\n`date`" >> ${LOG}
echo "Reload the GXD_Expression table" >> ${LOG}
${MMGIACHELOAD}/gxdexpression.csh >> ${LOG}
if [ $? -ne 0 ]
then
    echo 'gxdexpression.csh failed' >> ${LOG}
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
