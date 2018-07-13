#!/bin/sh

#
# TR 12649
#
# Wrapper script for loading
#

cd `dirname $0`

LOG=$0.log
rm -rf ${LOG}
touch ${LOG}
 
date >> ${LOG}

#
# unused image jpgs
#

cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG

-- will delete these from pixeldb after this is processed on production
select '/data/pixeldb/' || a.numericPart || '.jpg', i.figureLabel
from IMG_Image i, IMG_ImagePane ii, ACC_Accession a
where i._Refs_key = 172505
and i._Image_key = ii._Image_key
and i._Image_key = a._Object_key 
and a._MGIType_key = 9 
and a._LogicalDB_key = 19
and not exists (select 1
    from GXD_Assay a, GXD_Specimen s, GXD_InSituResult isr, GXD_InSituResultImage p 
    where i._Refs_key = a._Refs_key 
    and a._AssayType_key in (1,6,9,10,11) 
    and a._Assay_key = s._Assay_key 
    and s._Specimen_key = isr._Specimen_key 
    and isr._Result_key = p._Result_key
    and ii._ImagePane_key = p._ImagePane_key
)
order by i.figureLabel
;

EOSQL

