#!/bin/sh

#
# TR 9695
#
# Wrapper script for loading Eurexpress images into GXD for TR 9695
#

cd `dirname $0`

. ./tr9695.config

LOG=${PROJECTDIR}/$0.log
rm -rf ${LOG}
touch ${LOG}
 
#
# Find the image files that need to be added to pixel DB. They are in
# column 4 of the second load file.
#
echo "\n`date`" >> ${LOG}
echo "Find the image files that need to be added to pixel DB" >> ${LOG}
rm -f ${PIXELDB_FILES}
tail +2 ${LOADFILE2} | cut -f4 | sort -u > ${PIXELDB_FILES}

#
# Copy fullsize and thumbnail images to pixel DB.
#
echo "\n`date`" >> ${LOG}
echo "Copy fullsize and thumbnail images to pixel DB" >> ${LOG}
${GXDIMAGELOAD}/tr9695pixload.sh >> ${LOG}
if [ $? -ne 0 ]
then
    echo 'tr9695pixload.sh failed' >> ${LOG}
    exit 1
fi

#
# Create fullsize image input files for the GXD image load.
#
echo "\n`date`" >> ${LOG}
echo "Create fullsize image input files for the GXD image load" >> ${LOG}
${GXDIMAGELOAD}/tr9695prepFullsize.py >> ${LOG}
if [ $? -ne 0 ]
then
    echo 'tr9695prepFullsize.py failed' >> ${LOG}
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
${GXDIMAGELOAD}/tr9695prepThumbnail.py >> ${LOG}
if [ $? -ne 0 ]
then
    echo 'tr9695prepThumbnail.py failed' >> ${LOG}
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
# Create Eurexpress accession IDs that are associated with the fullsize images
# for building links to Eurexpress from the WI.
#
echo "\n`date`" >> ${LOG}
echo "Create Eurexpress accession IDs associated with the fullsize images" >> ${LOG}
${GXDIMAGELOAD}/tr9695imageAssoc.py >> ${LOG}
if [ $? -ne 0 ]
then
    echo 'tr9695imageAssoc.py failed' >> ${LOG}
    exit 1
fi

date >> ${LOG}
exit 0
