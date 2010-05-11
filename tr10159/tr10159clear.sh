#!/bin/sh

#
# TR 10159
#
# Wrapper script for loading GenePaint dataset into GXD for TR 9458
#

cd `dirname $0`

. ./tr10159.config

LOG=${PROJECTDIR}/$0.log
rm -rf ${LOG}
touch ${LOG}
 
#
# Temporary code needed when running repeated tests.
#
cat - <<EOSQL | doisql.csh ${MGD_DBSERVER} ${MGD_DBNAME} $0 >> ${LOG}
 
/*delete from GXD_Assay where _Assay_key >= 34624 */
/*go */

delete from GXD_Index where _Index_key >= 85113
go

quit
EOSQL

date >> ${LOG}
exit 0
