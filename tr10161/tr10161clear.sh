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
 
delete from ACC_Accession where _Accession_key >= 280435422
go

delete from IMG_Image where _Image_key >= 89165
go

delete from IMG_ImagePane where _ImagePane_key >= 133682
go

quit
EOSQL

date >> ${LOG}
exit 0
