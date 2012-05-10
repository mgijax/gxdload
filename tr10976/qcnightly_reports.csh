#!/bin/csh -f

#
# qcnightly_reports.csh
#
# Script to generate nightly QC reports.
#
# Usage: qcnightly_reports.csh
#

#cd `dirname $0` && source ./Configuration
source ${QCRPTS}/Configuration

setenv LOG ${QCLOGSDIR}/`basename $0`.log
rm -rf ${LOG}
touch ${LOG}

echo `date`: Start nightly QC reports | tee -a ${LOG}

#foreach qcdir (${QCMGD} ${QCWEEKLY} ${QCMONTHLY})
foreach qcdir (${QCWEEKLY} ${QCMONTHLY})

cd $qcdir

foreach i (GXD*.sql)
    echo `date`: $i | tee -a ${LOG}
    if ( $i == "GXD_Triage.sql" ) then
        mv -f ${QCOUTPUTDIR}/$i.[0-9]*.rpt ${QCGXDARCHIVE}
        rm -rf ${QCOUTPUTDIR}/$i.current.rpt
        reportisql.csh $i ${QCOUTPUTDIR}/$i.${DATE}.rpt ${MGD_DBSERVER} ${MGD_DBNAME}
        ln -s ${QCOUTPUTDIR}/$i.${DATE}.rpt ${QCOUTPUTDIR}/$i.current.rpt
    else
        reportisql.csh $i ${QCOUTPUTDIR}/$i.rpt ${MGD_DBSERVER} ${MGD_DBNAME}
    endif
end

foreach i (GXD*.py)
    echo `date`: $i | tee -a ${LOG}
    if ( $i == "GXD_Stats.py" ) then
        mv -f ${QCOUTPUTDIR}/`basename $i py`[0-9]*.rpt ${QCGXDARCHIVE}
        rm -rf ${QCOUTPUTDIR}/`basename $i py`current.rpt
        $i >>& ${LOG}
        ln -s ${QCOUTPUTDIR}/`basename $i py`${DATE}.rpt ${QCOUTPUTDIR}/`basename $i py`current.rpt
    else if ( $i == "GO_stats.py" ) then
        $i >>& ${LOG}
        cp -p ${QCOUTPUTDIR}/GO_stats.rpt ${QCGOARCHIVE}/GO_stats.`date +%Y%m%d`
    else
        $i >>& ${LOG}
    endif
end

end

echo `date`: End nightly QC reports | tee -a ${LOG}
