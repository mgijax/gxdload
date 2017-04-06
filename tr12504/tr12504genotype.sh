#!/bin/sh

#
# TR 12504
#
# Wrapper script for loading Genotypes using htmpload
#

cd `dirname $0`

. ./tr12504.config

LOG=${PROJECTDIR}/$0.log
rm -rf ${LOG}
touch ${LOG}
 
# done
##${MIRROR_WGET}/download_package www.ebi.ac.uk.impc_lacz_alz.json
##${MIRROR_WGET}/download_package www.ebi.ac.uk.impc_lacz_elz.json

rm -rf ${DATADOWNLOADS}/www.ebi.ac.uk/impc_lacz.json
cp ${DATADOWNLOADS}/www.ebi.ac.uk/impc_lacz_alz.json ${DATADOWNLOADS}/www.ebi.ac.uk/impc_lacz.json
${HTMPLOAD}/bin/htmploadlacz.sh ${HTMPLOAD}/impclaczload.config >> ${LOG}

#
# save alz to another directory
# and recreate directories for elz run
#
cd ${DATALOADSOUTPUT}/mgi/htmpload/ >> ${LOG}
rm -rf impclaczload.alz >> ${LOG}
mv impclaczload impclaczload.alz >> ${LOG}
mkdir impclaczload >> ${LOG}
mkdir impclaczload/archive >> ${LOG}
mkdir impclaczload/input >> ${LOG}
mkdir impclaczload/logs >> ${LOG}
mkdir impclaczload/output >> ${LOG}
mkdir impclaczload/reports >> ${LOG}

cp ${DATADOWNLOADS}/www.ebi.ac.uk/impc_lacz_elz.json ${DATADOWNLOADS}/www.ebi.ac.uk/impc_lacz.json >> ${LOG}
${HTMPLOAD}/bin/htmploadlacz.sh ${HTMPLOAD}/impclaczload.config >> ${LOG}

date >> ${LOG}

exit 0
