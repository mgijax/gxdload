#!/bin/sh

#
# TR 12649
#
# Wrapper script for loading
#

cd `dirname $0`

. ./tr12649.config

LOG=${PROJECTDIR}/$0.log
rm -rf ${LOG}
touch ${LOG}
 
#
# delete all Image Captions for J:171409 not used
#
cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG

-- will delete these from pixeldb after this is processed on production
select a.accID
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
order by a.accID
;

select i._Image_key, i.figureLabel
into temporary table todelete
from IMG_Image i, IMG_ImagePane ii
where i._Refs_key = 172505
and i._Image_key = ii._Image_key
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

select * from todelete
;

delete from IMG_Image i
using todelete d
where d._Image_key = i._Image_key
;

EOSQL

#
# Copy fullsize images to Pixel DB.
#
#date >> ${LOG}
#echo 'Copy fullsize to Pixel DB' >> ${LOG}
#${GXDIMAGELOAD}/pixload.csh ${FULLSIZE_IMAGE_DIR} ${PIX_FULLSIZE} >> ${LOG}
#if [ $? -ne 0 ]
#then
#    echo 'pixload.sh failed' >> ${LOG}
#    exit 1
#fi
#date >> ${LOG}

#
# Create fullsize image input files for the GXD image load.
#
date >> ${LOG}
echo 'Create fullsize image input files for the GXD image load' >> ${LOG}
${GXDLOAD}/tr12649/tr12649preFullsize.py >> ${LOG}
if [ $? -ne 0 ]
then
    echo 'tr12649preFullsize.py failed' >> ${LOG}
    exit 1
fi
date >> ${LOG}

#
# Load fullsize images
#
date >> ${LOG}
echo 'Load fullsize images' >> ${LOG}
${GXDIMAGELOAD}/gxdimageload.py >> ${LOG}
if [ $? -ne 0 ]
then
    echo 'gxdimageload.py failed' >> ${LOG}
    exit 1
fi
date >> ${LOG}

#
# process copyright
#
cd ${IMAGELOADDATADIR}
date >> ${LOG}
echo 'process copyright' >> ${LOG}
${NOTELOAD}/mginoteload.py -S${MGD_DBSERVER} -D${MGD_DBNAME} -U${MGD_DBUSER} -P${MGD_DBPASSWORDFILE} -I${COPYRIGHTFILE} -M${NOTELOADMODE} -O${IMAGE_OBJECTTYPE} -T\"${COPYRIGHT_NOTETYPE}\" >> ${LOG}
if [ $? -ne 0 ]
then
    echo '${NOTELOAD}/mginoteload.py copyright failed' >> ${LOG}
    exit 1
fi
date >> ${LOG}

#
# process caption
#
cd ${IMAGELOADDATADIR}
date >> ${LOG}
echo 'process caption' >> ${LOG}
${NOTELOAD}/mginoteload.py -S${MGD_DBSERVER} -D${MGD_DBNAME} -U${MGD_DBUSER} -P${MGD_DBPASSWORDFILE} -I${CAPTIONFILE} -M${NOTELOADMODE} -O${IMAGE_OBJECTTYPE} -T\"${CAPTION_NOTETYPE}\" >> ${LOG}
if [ $? -ne 0 ]
then
    echo '${NOTELOAD}/mginoteload.py caption failed' >> ${LOG}
    exit 1
fi
date >> ${LOG}
cd `dirname $0`

#
# Create accession IDs that are associated with the fullsize images
# for building links to GUDMAP from the WI. 
#
echo "\n`date`" >> ${LOG}
echo "Create GUDMAP accession IDs associated with the fullsize images" >> ${LOG}
${GXDIMAGELOAD}/gudmapimageAssoc.py >> ${LOG}
if [ $? -ne 0 ] 
then
    echo 'gudmapImageAssoc.py failed' >> ${LOG}
    exit 1
fi

date >> ${LOG}
exit 0
