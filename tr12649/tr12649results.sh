#!/bin/sh

#
# TR 12649
#
# Wrapper script for loading
#

cd `dirname $0`

. ./tr12649.config

cd ${PROJECTDIR}/resultsload

LOG=${PROJECTDIR}/$0.log
rm -rf ${LOG}
touch ${LOG}
 
#
# delete results only
# delete indexes
#
cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG
delete from GXD_InSituResult insitu
using GXD_Assay a, GXD_Specimen s
where a._Refs_key = 172505
and a._Assay_key = s._Assay_key
and s._Specimen_key = insitu._Specimen_key
;
delete from GXD_Index where _Refs_key = 172505
;
EOSQL

# Load the results only
#
echo "`date`" >> ${LOG}
echo "Load the results" >> ${LOG}
${GXDLOAD}/tr12649/resultsload.py >> ${LOG}
if [ $? -ne 0 ]
then
    echo 'resultsload.py failed' >> ${LOG}
    exit 1
fi

#
# Create the literature index for the new assays.
#
echo "`date`" >> ${LOG}
echo "Create the literature index for the assays" >> ${LOG}
${ASSAYLOAD}/indexload.py >> ${LOG}
if [ $? -ne 0 ]
then
    echo 'indexload.py failed' >> ${LOG}
    exit 1
fi

#
# Reload the MRK_Reference table.
#
echo "`date`" >> ${LOG}
echo "Reload the MRK_Reference table" >> ${LOG}
${MRKCACHELOAD}/mrkref.csh >> ${LOG}
if [ $? -ne 0 ]
then
    echo 'mrkref.csh failed' >> ${LOG}
    exit 1
fi

#
# Reload the GXD_Expression table.
#
echo "`date`" >> ${LOG}
echo "Reload the GXD_Expression table" >> ${LOG}
${MGICACHELOAD}/gxdexpression.csh >> ${LOG}
if [ $? -ne 0 ]
then
    echo 'gxdexpression.csh failed' >> ${LOG}
    exit 1
fi

${GXDLOAD}/tr12649/qcnightly_reports.csh >> ${LOG}

date >> ${LOG}
exit 0
