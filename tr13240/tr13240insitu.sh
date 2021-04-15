#!/bin/sh

#
# TR 13240/lacZ
#
# Wrapper script for loading
#

cd `dirname $0`
. ../Configuration

cd ${GXDLOAD}/tr13240

. ./tr13240.config

LOG=${PROJECTDIR}/tr13240insitu.sh.log
rm -rf ${LOG}
touch ${LOG}
 
cd ${ASSAYLOADDATADIR}

date | tee -a  ${LOG}

cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG
delete from GXD_Assay where _Refs_key = 229658 ;
delete from GXD_Index where _Refs_key = 229658 ;
EOSQL

#
# Create the input files for the in situ load.
#
date | tee -a  ${LOG}
echo "Create the input files for the in situ load" | tee -a  ${LOG}
${PYTHON} ${GXDLOAD}/tr13240/tr13240insitu.py | tee -a  ${LOG}
if [ $? -ne 0 ]
then
    echo 'tr13240insitu.py failed' | tee -a  ${LOG}
    exit 1
fi

# Load the assays and results.
#
date | tee -a  ${LOG}
echo "Load the assays and results" | tee -a  ${LOG}
${PYTHON} ${ASSAYLOAD}/insituload.py | tee -a  ${LOG}
if [ $? -ne 0 ]
then
    echo 'insituload.py failed' | tee -a  ${LOG}
    exit 1
fi

#
# Create the literature index for the new assays.
#
date | tee -a  ${LOG}
echo "Create the literature index for the new assays" | tee -a  ${LOG}
${PYTHON} ${ASSAYLOAD}/indexload.py | tee -a  ${LOG}
if [ $? -ne 0 ]
then
    echo 'indexload.py failed' | tee -a  ${LOG}
    exit 1
fi

#
# update Copyright
#
date | tee -a  ${LOG}
echo "Update Copyright" | tee -a  ${LOG}
${GXDLOAD}/tr13240/copyright.csh | tee -a ${LOG}
if [ $? -ne 0 ]
then
    echo 'copyright.csh failed' | tee -a  ${LOG}
    exit 1
fi

#
# Reload the GXD_Expression table.
#
date | tee -a  ${LOG}
echo "Reload the GXD_Expression table" | tee -a  ${LOG}
${MGICACHELOAD}/gxdexpression.csh | tee -a  ${LOG}
if [ $? -ne 0 ]
then
    echo 'gxdexpression.csh failed' | tee -a  ${LOG}
    exit 1
fi

#
# Reload the MRK_Reference table.
#
date | tee -a  ${LOG}
echo "Reload the MRK_Reference table" | tee -a  ${LOG}
${MRKCACHELOAD}/mrkref.csh | tee -a  ${LOG}
if [ $? -ne 0 ]
then
    echo 'mrkref.csh failed' | tee -a  ${LOG}
    exit 1
fi

#
# qc_reports.csh
#
${GXDLOAD}/tr13240/qcnightly_reports.csh | tee -a  ${LOG}

date | tee -a  ${LOG}
exit 0
