#!/bin/sh

#
# Template
#


#if ( ${?MGICONFIG} == 0 ) then
#        setenv MGICONFIG /usr/local/mgi/live/mgiconfig
#endif
#
#source ${MGICONFIG}/master.config.csh
#
cd `dirname $0`

LOG=$0.log
rm -rf $LOG
touch $LOG
 
date | tee -a $LOG
 
cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG

--select distinct m.symbol, s.specimenLabel
select distinct s.specimenLabel
from GXD_Assay a, GXD_Specimen s, GXD_InSituResult ir, MRK_Marker m
where a._Refs_key = 229658
and a._Assay_key = s._Assay_key
and s._Specimen_key = ir._Specimen_key
and not exists (select 1 from GXD_InSituResultImage iri where ir._Result_key = iri._Result_key)
--and not exists (select 1 from IMG_Image ii where s.specimen = ii.figureLabel)
and a._Marker_key = m._Marker_key
order by s.specimenLabel
;

select distinct s.specimenLabel
from GXD_Assay a, GXD_Specimen s, GXD_InSituResult ir, MRK_Marker m
where a._Refs_key = 229658
and a._Assay_key = s._Assay_key
and s._Specimen_key = ir._Specimen_key
and not exists (select 1 from IMG_Image ii where s.specimenLabel = ii.figureLabel)
and a._Marker_key = m._Marker_key
order by s.specimenLabel
;

select count (distinct i.*)
from IMG_ImagePane ii, IMG_Image i
where ii._Image_key = i._Image_key
and i._Refs_key = 229658
and not exists (select 1 from GXD_Assay a, GXD_Specimen s, GXD_InSituResult ir, GXD_InSituResultImage iri
        where a._Assay_key = s._Assay_key
        and s._Specimen_key = ir._Specimen_key
        and ir._Result_key = iri._Result_key
        and iri._ImagePane_key = ii._ImagePane_key)
;

EOSQL

date |tee -a $LOG

