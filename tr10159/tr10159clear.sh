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
 
delete from ACC_Accession where _Accession_key >= 280223505
go

delete from IMG_Image where _Image_key >= 87897
go

delete from IMG_ImagePane where _ImagePane_key >= 132414
go

quit
EOSQL

date >> ${LOG}
exit 0
