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

--delete from MGI_Note n
--using todelete d
--where d._Note_key = n._Note_key
--;

EOSQL
exit 0

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
${NOTELOAD}/mginoteload.py -S${MGD_DBSERVER} -D${MGD_DBNAME} -U${MGD_DBUSER} -P${MGD_DBPASSWORDFILE} -I${COPYRIGHTFILE} -M${NOTELOADMODE} -O${IMAGE_OBJECTTYPE} -T\"${COPYRIGHTNOTETYPE}\" >> ${LOG}
if [ $? -ne 0 ]
then
    echo '${NOTELOAD}/mginoteload.py copyright failed' >> ${LOG}
    exit 1
fi
date >> ${LOG}

cd `dirname $0`

date >> ${LOG}
exit 0
