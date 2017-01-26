#!/bin/sh -f

#
# TR 12491
#
# Wrapper script for loading
#

cd `dirname $0`

. ./tr12491.config

LOG=${IMAGELOADDATADIR}/$0.log
rm -rf ${LOG}
touch ${LOG}
 
#cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG
#delete from IMG_Image where _Image_key 
#EOSQL

cd ${IMAGELOADDATADIR}

#
# Copy fullsize images to Pixel DB.
#echo "\n`date`" >> ${LOG}
#echo "Copy fullsize to Pixel DB" >> ${LOG}
#${GXDIMAGELOAD}/pixload.csh ${FULLSIZE_IMAGE_DIR} ${PIX_FULLSIZE} >> ${LOG}
#if [ $? -ne 0 ]
#then
#    echo 'pixload.sh failed' >> ${LOG}
#    exit 1
#fi

#
# Create fullsize image input files for the GXD image load.
#
echo "\n`date`" >> ${LOG}
echo "Create fullsize image input files for the GXD image load" >> ${LOG}
${GXDLOAD}/tr12491/tr12491PreFullsize.py >> ${LOG}
if [ $? -ne 0 ]
then
    echo 'tr12491preFullsize.py failed' >> ${LOG}
    exit 1
fi

echo "\n`date`" >> ${LOG}
echo "Create the fullsize image stubs" >> ${LOG}
${GXDIMAGELOAD}/gxdimageload.py >> ${LOG}
if [ $? -ne 0 ]
then
    echo 'gxdimageload.py failed' >> ${LOG}
    exit 1
fi

#
# Load copyright notes.
#
NOTEINPUTFILE=${COPYRIGHTFILE}
NOTELOG=${COPYRIGHTFILE}.log
NOTETYPE="Copyright"
echo "\n`date`" >> ${LOG}
echo "Load copyright notes" >> ${LOG}
${NOTELOAD}/mginoteload.py -S${MGD_DBSERVER} -D${MGD_DBNAME} -U${MGD_DBUSER} -P${MGD_DBPASSWORDFILE} -I${NOTEINPUTFILE} -M${NOTEMODE} -O${NOTEOBJECTTYPE} -T${NOTETYPE} >> ${LOG}
if [ $? -ne 0 ]
then
    echo 'mginoteload.py failed' >> ${LOG}
    exit 1
fi

#
# Load caption notes.
#
NOTEINPUTFILE=${CAPTIONFILE}
NOTELOG=${CAPTIONFILE}.log
NOTETYPE="Caption"
echo "\n`date`" >> ${LOG}
echo "Load caption notes" >> ${LOG}
${NOTELOAD}/mginoteload.py -S${MGD_DBSERVER} -D${MGD_DBNAME} -U${MGD_DBUSER} -P${MGD_DBPASSWORDFILE} -I${NOTEINPUTFILE} -M${NOTEMODE} -O${NOTEOBJECTTYPE} -T${NOTETYPE} >> ${LOG}
if [ $? -ne 0 ]
then
    echo 'mginoteload.py failed' >> ${LOG}
    exit 1
fi

cd `dirname $0`

date >> ${LOG}
exit 0
