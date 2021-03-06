#!/bin/sh

#
# TR 12026
#
# Wrapper script for loading
#
#
# COPIED FROM ../tr11471 BUT NOT USED
#

cd `dirname $0`

. ./tr12026.config

LOG=${PROJECTDIR}/$0.log
rm -rf ${LOG}
touch ${LOG}
 
#
# Copy fullsize images to Pixel DB.
#
echo "\n`date`" >> ${LOG}
echo "Copy fullsize to Pixel DB" >> ${LOG}
${GXDIMAGELOAD}/pixload.sh >> ${LOG}
if [ $? -ne 0 ]
then
    echo 'pixload.sh failed' >> ${LOG}
    exit 1
fi

#
# Create fullsize image input files for the GXD image load.
#
echo "\n`date`" >> ${LOG}
echo "Create fullsize image input files for the GXD image load" >> ${LOG}
${GXDIMAGELOAD}/tr12026preFullsize.py >> ${LOG}
if [ $? -ne 0 ]
then
    echo 'tr12026preFullsize.py failed' >> ${LOG}
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
${NOTELOAD}/mginoteload.py -S${MGD_DBSERVER} -D${MGD_DBNAME} -U${MGD_DBUSER} -P${MGD_DBPASSWORDFILE} -I${COPYRIGHTFILE} -M${NOTELOADMODE} -O${IMAGE_OBJECTTYPE} -T${COPYRIGHT_NOTETYPE} >> ${LOG}
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
${NOTELOAD}/mginoteload.py -S${MGD_DBSERVER} -D${MGD_DBNAME} -U${MGD_DBUSER} -P${MGD_DBPASSWORDFILE} -I${CAPTIONFILE} -M${NOTELOADMODE} -O${IMAGE_OBJECTTYPE} -T${CAPTION_NOTETYPE} >> ${LOG}
if [ $? -ne 0 ]
then
    echo 'mginoteload.py failed' >> ${LOG}
    exit 1
fi

#
# Create accession IDs that are associated with the fullsize images
# for building links to GUDMAP from the WI.
#
echo "\n`date`" >> ${LOG}
echo "Create GUDMAP accession IDs associated with the fullsize images" >> ${LOG}
${GXDIMAGELOAD}/tr12026imageAssoc.py >> ${LOG}
if [ $? -ne 0 ]
then
    echo 'tr12026imageAssoc.py failed' >> ${LOG}
    exit 1
fi

cd `dirname $0`

date >> ${LOG}
exit 0
