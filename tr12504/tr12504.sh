#!/bin/sh

#
# TR 12504
#
# Wrapper script for loading
#

cd `dirname $0`

. ./tr12504.config

LOG=${PROJECTDIR}/$0.log
rm -rf ${LOG}
touch ${LOG}
 
#
# delete all existing Image Captions for J:228563
#
#cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG
#
#select i._image_key, i.figurelabel, i._refs_key, a.accID, n._note_key
#into temp table todelete
#from IMG_Image i, ACC_Accession a, MGI_Note_Image_View n
#where i._image_key = a._object_key
#and i._refs_key = 229658
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
echo "\n`date`" >> ${LOG}
echo "Copy fullsize to Pixel DB" >> ${LOG}
./pixload.csh ${PROJECTDIR}/images ${PROJECTDIR}/imageload/impclacz-pixload.mapping >> ${LOG}
if [ $? -ne 0 ]
then
    echo 'pixload.sh failed' >> ${LOG}
    exit 1
fi
echo "\n`date`" >> ${LOG}
exit 0

#
# Create fullsize image input files for the GXD image load.
#
echo "\n`date`" >> ${LOG}
echo "Create fullsize image input files for the GXD image load" >> ${LOG}
${GXDIMAGELOAD}/impclaczPreFullsize.py >> ${LOG}
if [ $? -ne 0 ]
then
    echo 'impclaczPreFullsize.py failed' >> ${LOG}
    exit 1
fi
exit 0

#
# Create accession IDs that are associated with the fullsize images
# for building links to GUDMAP from the WI.
#
echo "\n`date`" >> ${LOG}
echo "Create GUDMAP accession IDs associated with the fullsize images" >> ${LOG}
${GXDIMAGELOAD}/tr12504imageAssoc.py >> ${LOG}
if [ $? -ne 0 ]
then
    echo 'tr12504imageAssoc.py failed' >> ${LOG}
    exit 1
fi

cd `dirname $0`

date >> ${LOG}
exit 0
