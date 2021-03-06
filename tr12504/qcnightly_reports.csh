#!/bin/csh -f

#
# qcnightly_reports.csh
#
# Script to generate nightly QC reports.
#
# Usage: qcnightly_reports.csh
#

cd `dirname $0` && source ${QCRPTS}/Configuration

setenv LOG `basename $0`.log
rm -rf ${LOG}
touch ${LOG}

echo `date`: QC reports | tee -a ${LOG}

cd ${QCMGD}

foreach i (GXD_NotInCache.sql)
    echo `date`: $i | tee -a ${LOG}
    ${QCRPTS}/reports.csh $i ${QCOUTPUTDIR}/$i.rpt ${MGD_DBSERVER} ${MGD_DBNAME}
end

foreach i (GXD_SameStructure.py GXD_ImagesUnused.py)
    echo `date`: $i | tee -a ${LOG}
    $i | tee -a ${LOG}
end

cd ${QCMONTHLY}

foreach i (GXD_KnockInGene.sql)
    echo `date`: $i | tee -a ${LOG}
    ${QCRPTS}/reports.csh $i ${QCOUTPUTDIR}/$i.rpt ${MGD_DBSERVER} ${MGD_DBNAME}
end

echo `date`: End QC reports | tee -a ${LOG}
