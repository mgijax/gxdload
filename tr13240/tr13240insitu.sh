#!/bin/sh

#
# TR 13240/lacZ
#
# Wrapper script for loading
#

cd ${GXDLOAD}/tr13240

. ./tr13240.config

LOG=${PROJECTDIR}/tr13240insitu.sh.log
rm -rf ${LOG}
touch ${LOG}
 
cd ${ASSAYLOADDATADIR}

date >> ${LOG}

cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG
delete from GXD_Assay where _Refs_key = 229658 ;
delete from GXD_Index where _Refs_key = 229658 ;
EOSQL

#
# Create the input files for the in situ load.
#
echo "\n`date`" >> ${LOG}
echo "Create the input files for the in situ load" >> ${LOG}
${PYTHON} ${GXDLOAD}/tr13240/tr13240insitu.py >> ${LOG}
if [ $? -ne 0 ]
then
    echo 'tr13240insitu.py failed' >> ${LOG}
    exit 1
fi

# Load the assays and results.
#
echo "\n`date`" >> ${LOG}
echo "Load the assays and results" >> ${LOG}
${PYTHON} ${ASSAYLOAD}/insituload.py >> ${LOG}
if [ $? -ne 0 ]
then
    echo 'insituload.py failed' >> ${LOG}
    exit 1
fi
exit 0

#
# Create the literature index for the new assays.
#
echo "\n`date`" >> ${LOG}
echo "Create the literature index for the new assays" >> ${LOG}
${PYTHON} ${ASSAYLOAD}/indexload.py >> ${LOG}
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
${MGICACHELOAD}/gxdexpression.csh >> ${LOG}
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

#
# qc_reports.csh
#
${GXDLOAD}/tr13240/qcnightly_reports.csh >> ${LOG}


echo "\n`date`" >> ${LOG}
echo "gxd genotypes that are no longer used" >> ${LOG}
deletegenotypes.csh
echo "gxd images that are no longer used" >> ${LOG}
deleteimages.csh

date >> ${LOG}
exit 0
