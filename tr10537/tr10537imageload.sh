#!/bin/sh

#
# TR 10537
#
# Wrapper script for loading BGEM images into GXD for TR 10537
#

cd `dirname $0`

. ./tr10537.config

SCRIPT_NAME=`basename $0`

LOG=${PROJECTDIR}/${SCRIPT_NAME}.log
rm -rf ${LOG}
touch ${LOG}
 
#
# Find the image files that need to be added to pixel DB. The files names
# can be generated from the figure labels in the input file.
#
echo "\n`date`" >> ${LOG}
echo "Find the image files that need to be added to pixel DB" >> ${LOG}
rm -f ${PIXELDB_FILES}
tail +2 ${IMAGE_DATA} | sed 's/$/.jpg/' | sort -u > ${PIXELDB_FILES}

#
# Copy fullsize and thumbnail images to pixel DB.
#
echo "\n`date`" >> ${LOG}
echo "Copy fullsize and thumbnail images to pixel DB" >> ${LOG}
${GXDIMAGELOAD}/tr10537pixload.sh >> ${LOG}
if [ $? -ne 0 ]
then
    echo 'tr10537pixload.sh failed' >> ${LOG}
    exit 1
fi

#
# Create fullsize image input files for the GXD image load.
#
echo "\n`date`" >> ${LOG}
echo "Create fullsize image input files for the GXD image load" >> ${LOG}
${GXDIMAGELOAD}/tr10537prepFullsize.py >> ${LOG}
if [ $? -ne 0 ]
then
    echo 'tr10537prepFullsize.py failed' >> ${LOG}
    exit 1
fi

#
# Create the fullsize image stubs.
#
IMAGEFILE=${IMAGE_FULLSIZE}; export IMAGEFILE
IMAGEPANEFILE=${IMAGEPANE_FULLSIZE}; export IMAGEPANEFILE
OUTFILE_QUALIFIER=${QUALIFIER_FULLSIZE}; export OUTFILE_QUALIFIER

echo "\n`date`" >> ${LOG}
echo "Create the fullsize image stubs" >> ${LOG}
${GXDIMAGELOAD}/gxdimageload.py >> ${LOG}
if [ $? -ne 0 ]
then
    echo 'gxdimageload.py failed' >> ${LOG}
    exit 1
fi

#
# The note load creates output files in the current directory, so go to
# the directory where the files should be located.
#
cd ${IMAGELOADDATADIR}

#
# Load copyright notes.
#
echo "\n`date`" >> ${LOG}
echo "Load copyright notes" >> ${LOG}
${NOTELOAD}/mginoteload.py -S${MGD_DBSERVER} -D${MGD_DBNAME} -U${MGI_DBUSER} -P${MGI_DBPASSWORDFILE} -I${COPYRIGHTFILE} -M${NOTELOADMODE} -O${IMAGE_OBJECTTYPE} -T${COPYRIGHT_NOTETYPE} >> ${LOG}
if [ $? -ne 0 ]
then
    echo 'mginoteload.py failed' >> ${LOG}
    exit 1
fi

#
# Load caption notes.
#
echo "\n`date`" >> ${LOG}
echo "Load caption notes" >> ${LOG}
${NOTELOAD}/mginoteload.py -S${MGD_DBSERVER} -D${MGD_DBNAME} -U${MGI_DBUSER} -P${MGI_DBPASSWORDFILE} -I${CAPTIONFILE} -M${NOTELOADMODE} -O${IMAGE_OBJECTTYPE} -T${CAPTION_NOTETYPE} >> ${LOG}
if [ $? -ne 0 ]
then
    echo 'mginoteload.py failed' >> ${LOG}
    exit 1
fi

cd `dirname $0`

#
# Create thumbnail image input files for the GXD image load.
#
echo "\n`date`" >> ${LOG}
echo "Create thumbnail image input files for the GXD image load" >> ${LOG}
${GXDIMAGELOAD}/tr10537prepThumbnail.py >> ${LOG}
if [ $? -ne 0 ]
then
    echo 'tr10537prepThumbnail.py failed' >> ${LOG}
    exit 1
fi

#
# Create the thumbnail image stubs.
#
IMAGEFILE=${IMAGE_THUMBNAIL}; export IMAGEFILE
IMAGEPANEFILE=${IMAGEPANE_THUMBNAIL}; export IMAGEPANEFILE
OUTFILE_QUALIFIER=${QUALIFIER_THUMBNAIL}; export OUTFILE_QUALIFIER

echo "\n`date`" >> ${LOG}
echo "Create the thumbnail image stubs" >> ${LOG}
${GXDIMAGELOAD}/gxdimageload.py >> ${LOG}
if [ $? -ne 0 ]
then
    echo 'gxdimageload.py failed' >> ${LOG}
    exit 1
fi

#
# Create BGEM accession IDs that are associated with the fullsize images
# for building links to BGEM from the WI.
#
echo "\n`date`" >> ${LOG}
echo "Create BGEM accession IDs associated with the fullsize images" >> ${LOG}
${GXDIMAGELOAD}/tr10537imageAssoc.py >> ${LOG}
if [ $? -ne 0 ]
then
    echo 'tr10537imageAssoc.py failed' >> ${LOG}
    exit 1
fi

date >> ${LOG}
exit 0
