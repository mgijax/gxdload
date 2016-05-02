#!/bin/csh -f

#
# Template
#


if ( ${?MGICONFIG} == 0 ) then
        setenv MGICONFIG /usr/local/mgi/live/mgiconfig
endif

source ${MGICONFIG}/master.config.csh

cd `dirname $0`

setenv LOG $0.log
rm -rf $LOG
touch $LOG
 
date | tee -a $LOG
 
cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG

select m.symbol, s.specimenlabel, r._result_key
from gxd_assay a, gxd_specimen s, gxd_insituresult r, mrk_marker m
where a._refs_key = 229658
and a._assay_key = s._assay_key
and s._specimen_key = r._specimen_key
and a._marker_key = m._marker_key
and not exists (select 1 from gxd_insituresultimage i
where r._result_key = i._result_key)
;

EOSQL

date |tee -a $LOG

