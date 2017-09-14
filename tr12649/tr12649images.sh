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
#cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG

#select i._image_key, i.figurelabel, i._refs_key, a.accID, n._note_key
#into temp table todelete
#from IMG_Image i, ACC_Accession a, MGI_Note_Image_View n
#where i._image_key = a._object_key
#and i._refs_key = 172505
#and a.prefixpart = 'PIX:' 
#and i._image_key = n._object_key
#and n._mgitype_key = 9
#and n._notetype_key = 1024
#;
#
#select * from todelete
#;
#
#delete from MGI_Note n
#using todelete d
#where d._Note_key = n._Note_key
#;
#
#EOSQL

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
exit 0

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
