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

--
-- GXD_OrphanGenotype.sql
--
select g._Genotype_key, a.accID, substring(s.strain, 1, 65) as strain, u.login, g.creation_date
into temporary table toDelete
from GXD_Genotype g, PRB_Strain s, ACC_Accession a, MGI_User u
where not exists (select 1 from GXD_Expression a where g._Genotype_key = a._Genotype_key)
and not exists (select 1 from GXD_GelLane a where g._Genotype_key = a._Genotype_key)
and not exists (select 1 from GXD_Specimen a where g._Genotype_key = a._Genotype_key)
and not exists (select 1 from VOC_Annot a where g._Genotype_key = a._Object_key and a._AnnotType_key in (1002,1020))
and not exists (select 1 from PRB_Strain_Genotype a where g._Genotype_key = a._Genotype_key)
and not exists (select 1 from IMG_ImagePane_Assoc a where g._Genotype_key = a._Object_key and a._MGIType_key = 12)
and not exists (select 1 from GXD_HTSample a where g._Genotype_key = a._Genotype_key)
and g._Strain_key = s._Strain_key 
and g._Genotype_key = a._Object_key
and a._MGIType_key = 12 
and a._LogicalDB_key = 1 
and g._createdby_key = u._user_key
;

create index idx_1 on toDelete(_Genotype_key);

select * from toDelete;

--delete from GXD_Genotype
--using toDelete
--where toDelete._Genotype_key = GXD_Genotype._Genotype_key
--;

EOSQL

date | tee -a $LOG

