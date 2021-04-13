#!/bin/csh

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

select a.numericPart, i.*
into temporary table toDelete
from IMG_ImagePane ii, IMG_Image i, ACC_Accession a
where ii._Image_key = i._Image_key
and i._Refs_key = 229658
and not exists (select 1 from GXD_Assay a, GXD_Specimen s, GXD_InSituResult ir, GXD_InSituResultImage iri
        where a._Assay_key = s._Assay_key
        and s._Specimen_key = ir._Specimen_key
        and ir._Result_key = iri._Result_key
        and iri._ImagePane_key = ii._ImagePane_key)
and i._Image_key = a._Object_key
and a._Logicaldb_key = 19
and a.prefixPart = 'PIX:'
;

create index idx_1 on toDelete(_Image_key);

select * from toDelete;

--select numericPart from toDelete order by numericPart;

--delete from IMG_Image
--using toDelete
--where toDelete._Image_key = IMG_Image._Image_key
--;

EOSQL

date | tee -a $LOG

