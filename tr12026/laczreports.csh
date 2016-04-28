#!/bin/csh -f

#
# qcnightly_reports.csh
#
# Script to generate nightly QC reports.
#
# Usage: qcnightly_reports.csh
#

source ${QCRPTS}/Configuration

setenv LOG ${QCLOGSDIR}/`basename $0`.log
rm -rf ${LOG}
touch ${LOG}

echo `date`: Start nightly QC reports | tee -a ${LOG}

cd ${QCMGD} 

foreach i (GXD_NotInCache.sql GXD_SpecNoAge.sql GXD_SpecTheiler.sql GXD_ImageJPG.sql GXD_FullCodeGene.sql GXD_FullCodeMissingIndex.sql)
    echo `date`: $i | tee -a ${LOG}
    ${QCRPTS}/reports.csh $i ${QCOUTPUTDIR}/$i.rpt ${MGD_DBSERVER} ${MGD_DBNAME}
end

foreach i (GXD_Stats.py GXD_SpecTheilerAge.py GXD_SameStructure.py GXD_ExpPresNotPres.py GXD_ChildExptNotParent.py GXD_ImagesUnused.py GXD_ImageSpecimen.py GXD_AssayInCacheNotInIndex.py GXD_AssayInIndexNotInCache.py)
    echo `date`: $i | tee -a ${LOG}
    $i >>& ${LOG}
end

cd ../monthly

foreach i (GXD_KnockInGene.sql)
    echo `date`: $i | tee -a ${LOG}
    ${QCRPTS}/reports.csh $i ${QCOUTPUTDIR}/$i.rpt ${MGD_DBSERVER} ${MGD_DBNAME}
end

echo `date`: End nightly QC reports | tee -a ${LOG}
