#!/bin/sh

#
# TR 10161
#
# Wrapper script for loading GenePaint dataset into GXD for TR 9458
#

cd `dirname $0`

. ./tr10161.config

LOG=${PROJECTDIR}/$0.log
rm -rf ${LOG}
touch ${LOG}
 
#
# Temporary code needed when running repeated tests.
#
cat - <<EOSQL | doisql.csh ${MGD_DBSERVER} ${MGD_DBNAME} $0 >> ${LOG}
 
delete from GXD_Assay where _Assay_key >= 39571
go

delete from GXD_Index where _Index_key >= 100601
go

quit
EOSQL

date >> ${LOG}
exit 0
