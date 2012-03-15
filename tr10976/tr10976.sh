#!/bin/sh

#
# TR 10976
#
# Wrapper script for loading GenePaint dataset into GXD for TR 8270
#

cd `dirname $0`

. ./tr10976.config

LOG=${PROJECTDIR}/$0.log
rm -rf ${LOG}
touch ${LOG}
 
#
# Create a new source record with the appropriate attributes to use with
# each new primer/probe record.
#
#echo "`date`" >> ${LOG}
#echo "Create anonymous source record for probes" >> ${LOG}
#cat - <<EOSQL | doisql.csh ${MGD_DBSERVER} ${MGD_DBNAME} $0 >> ${LOG}
#
#declare @sourceKey integer
#
#select @sourceKey = max(_Source_key) + 1 from PRB_Source
#
#insert into PRB_Source
#values (@sourceKey, 63468, 316370, 1, -1, -1, 315167, 316336, null,
#        null, null, "Not Specified", -1.0, -1.0, 0,
#        1080, 1080, getdate(), getdate())
#go
#
#quit
#EOSQL

#
# Load the probe.
#
#echo "\n`date`" >> ${LOG}
#echo "Load the probes" >> ${LOG}
#${PROBELOAD}/probeload.py >> ${LOG}
#if [ $? -ne 0 ]
#then
#    echo 'probeload.py failed' >> ${LOG}
#    exit 1
#fi

#
# Load raw sequence notes.
#
#cd ${PROBELOADDATADIR}
#echo "\n`date`" >> ${LOG}
#echo "Load raw sequence notes" >> ${LOG}
#${NOTELOAD}/mginoteload.py -S${MGD_DBSERVER} -D${MGD_DBNAME} -U${MGI_DBUSER} -P${MGI_DBPASSWORDFILE} -I${RAWNOTE_FILE} -M${NOTELOADMODE} -O${RAWNOTE_OBJECTTYPE} -T"${RAWNOTE_NOTETYPE}" >> ${LOG}
#if [ $? -ne 0 ]
#then
#    echo 'mginoteload.py failed' >> ${LOG}
#    exit 1
#fi

#
# Load the references.
#
#echo "\n`date`" >> ${LOG}
#echo "Load the references" >> ${LOG}
#echo ${PROBELOAD}/probereference.csh ${PROJECTDIR}/referenceload2/reference.config >> ${LOG}
#${PROBELOAD}/probereference.csh ${PROJECTDIR}/referenceload2/reference.config >> ${LOG}
#if [ $? -ne 0 ]
#then
#    echo 'probereference.py failed' >> ${LOG}
#    exit 1
#fi

#
# update probe notes
#
echo "\n`date`" >> ${LOG}
echo "Update the probe notes" >> ${LOG}
${PROBELOAD}/probenotes.py >> ${LOG}
if [ $? -ne 0 ]
then
    echo 'probenotes.py failed' >> ${LOG}
    exit 1
fi

#
# remove probe aliases
#
cd ${PROJECTDIR}/removealias
echo "\n`date`" >> ${LOG}
echo "Remove Probe Aliases" >> ${LOG}
./tr10976.py >> ${LOG}
if [ $? -ne 0 ]
then
    echo 'remove probe alias failed' >> ${LOG}
    exit 1
fi

exit 0

#
# Generate a list of best image files for Pixel DB.
#
echo "\n`date`" >> ${LOG}
echo "Create a list of best image files for Pixel DB" >> ${LOG}
${GXDIMAGELOAD}/tr8270getBestImageFiles.py >> ${LOG}
if [ $? -ne 0 ]
then
    echo 'tr8270getBestImageFiles.py failed' >> ${LOG}
    exit 1
fi

#
# Copy fullsize and thumbnail images to Pixel DB.
#
echo "\n`date`" >> ${LOG}
echo "Copy fullsize and thumbnail images to Pixel DB" >> ${LOG}
${GXDIMAGELOAD}/tr8270pixload.sh >> ${LOG}
if [ $? -ne 0 ]
then
    echo 'tr8270pixload.sh failed' >> ${LOG}
    exit 1
fi

#
# Create fullsize image input files for the GXD image load.
#
echo "\n`date`" >> ${LOG}
echo "Create fullsize image input files for the GXD image load" >> ${LOG}
${GXDIMAGELOAD}/tr8270prepFullsize.py >> ${LOG}
if [ $? -ne 0 ]
then
    echo 'tr8270prepFullsize.py failed' >> ${LOG}
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
${GXDIMAGELOAD}/tr8270prepThumbnail.py >> ${LOG}
if [ $? -ne 0 ]
then
    echo 'tr8270prepThumbnail.py failed' >> ${LOG}
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
# Create GenePaint accession IDs that are associated with the fullsize images
# for building links to GenePaint from the WI.
#
echo "\n`date`" >> ${LOG}
echo "Create GenePaint accession IDs associated with the fullsize images" >> ${LOG}
${GXDIMAGELOAD}/tr8270imageAssoc.py >> ${LOG}
if [ $? -ne 0 ]
then
    echo 'tr8270imageAssoc.py failed' >> ${LOG}
    exit 1
fi

#
# Create the input files for the in situ load.
#
echo "\n`date`" >> ${LOG}
echo "Create the input files for the in situ load" >> ${LOG}
${ASSAYLOAD}/tr8270.py >> ${LOG}
if [ $? -ne 0 ]
then
    echo 'tr8270.py failed' >> ${LOG}
    exit 1
fi

#
# Load the assays and results.
#
echo "\n`date`" >> ${LOG}
echo "Load the assays and results" >> ${LOG}
${ASSAYLOAD}/insituload.py >> ${LOG}
if [ $? -ne 0 ]
then
    echo 'insituload.py failed' >> ${LOG}
    exit 1
fi

#
# Associate images with assay results.
#
echo "\n`date`" >> ${LOG}
echo "Associate images with assay results" >> ${LOG}
${GXDIMAGELOAD}/assocResultImage.py >> ${LOG}
if [ $? -ne 0 ]
then
    echo 'assocResultImage.py failed' >> ${LOG}
    exit 1
fi

#
# Create the literature index for the new assays.
#
echo "\n`date`" >> ${LOG}
echo "Create the literature index for the new assays" >> ${LOG}
${ASSAYLOAD}/indexload.py >> ${LOG}
if [ $? -ne 0 ]
then
    echo 'indexload.py failed' >> ${LOG}
    exit 1
fi

#
# Reload the MRK_Reference table.
#
echo "\n`date`" >> ${LOG}
echo "Reload the MRK_Reference table" >> ${LOG}
${MRKCACHELOAD}/mrkref.csh >> ${LOG}
if [ $? -ne 0 ]
then
    echo 'mrkref.csh failed' >> ${LOG}
    exit 1
fi

#
# Reload the IMG_Cache table.
#
echo "\n`date`" >> ${LOG}
echo "Reload the IMG_Cache table" >> ${LOG}
${MGICACHELOAD}/imgcache.csh >> ${LOG}
if [ $? -ne 0 ]
then
    echo 'imgcache.csh failed' >> ${LOG}
    exit 1
fi

date >> ${LOG}
exit 0
