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
 
#setenv JPGLOG deletepixeldb.jpg
#rm -rf $JPGLOG
#touch $JPGLOG

#cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $JPGLOG
#select a.numericpart
#from acc_accession a , img_imagepane i, gxd_insituresultimage ig, gxd_insituresult irs, gxd_specimen gs, gxd_assay ga
#where a._logicaldb_key = 19
#and a._object_key = i._image_key
#and i._imagepane_key = ig._imagepane_key
#and ig._result_key = irs._result_key
#and irs._specimen_key = gs._specimen_key
#and gs._assay_key = ga._assay_key
#and ga._refs_key = 229658
#order by a.accID
#;
#EOSQL

foreach i (`cat deletepixeldb.jpg`)
ls -l /data/pixeldb/$i.jpg >> $LOG
#cp /data/pixeldb/$i.jpg pixeldb
rm -rf /data/pixeldb/$i.jpg
end

date | tee -a $LOG

