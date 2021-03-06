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
 
#load_db.csh DEV1_MGI mgd_test /lindon/sybase/mgd.backup

#
# remove WI data cache
# _Refs_key = 124081
#
rm -rf ${MGI_LIVE}/wi/data/assays/124081

#
# TR8270: delete current assay and image stubs for J:122989 that were added
#
echo "`date`" >> ${LOG}
echo "Deleting TR8270 data..." >> ${LOG}
${MGD_DBSCHEMADIR}/trigger/GXD_Assay_drop.object | >> ${LOG}
${MGD_DBSCHEMADIR}/trigger/GXD_Assay_create.object | >> ${LOG}
cat - <<EOSQL | doisql.csh ${MGD_DBSERVER} ${MGD_DBNAME} $0 >> ${LOG}

use ${MGD_DBNAME}
go

update ACC_ActualDB set url =
'http://www.genepaint.org/cgi-bin/mgrqcgi94?APPNAME=genepaint&PRGNAME=analysis_viewer&ARGUMENTS=-AQ76649667431800,-A@@@@'
where _LogicalDB_key = 105
go

delete from GXD_Index where _Refs_key = 124081
go

delete from GXD_Expression where _Refs_key = 124081
go

select _Assay_key into #todelete from GXD_Assay where _Refs_key = 124081
go
create index idx1 on #todelete(_Assay_key)
go

delete GXD_Specimen
from #todelete d, GXD_Specimen g
where d._Assay_key = g._Assay_key
go

delete GXD_AssayNote
from #todelete d, GXD_AssayNote g
where d._Assay_key = g._Assay_key
go

delete ACC_Accession
from #todelete d, ACC_Accession g
where d._Assay_key = g._Object_key
and g._MGIType_key = 8
go

delete GXD_Assay
from #todelete d, GXD_Assay g
where d._Assay_key = g._Assay_key
go

drop table #todelete
go

select _Image_key into #todelete from IMG_Image where _Refs_key = 124081
go
create index idx1 on #todelete(_Image_key)
go

delete MGI_Note from MGI_Note, #todelete d
where MGI_Note._MGIType_key = 9
and MGI_Note._Object_key = d._Image_key
go

delete IMG_Cache from IMG_Cache, #todelete d
where IMG_Cache._Image_key = d._Image_key
go
 
delete IMG_Cache from IMG_Cache, #todelete d
where IMG_Cache._ThumbnailImage_key = d._Image_key
go
  
delete IMG_ImagePane from IMG_ImagePane, #todelete d
where IMG_ImagePane._Image_key = d._Image_key
go
   
delete ACC_Accession
from ACC_Accession a, #todelete d
where a._Object_key = d._Image_key
and a._MGIType_key = 9
go

delete from IMG_Image where _Refs_key = 124081
go

quit
EOSQL
echo "`date`" >> ${LOG}
#exit 0

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
#${NOTELOAD}/mginoteload.py -S${MGD_DBSERVER} -D${MGD_DBNAME} -U${MGD_DBUSER} -P${MGD_DBPASSWORDFILE} -I${RAWNOTE_FILE} -M${NOTELOADMODE} -O${RAWNOTE_OBJECTTYPE} -T"${RAWNOTE_NOTETYPE}" >> ${LOG}
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
#echo "\n`date`" >> ${LOG}
#echo "Update the probe notes" >> ${LOG}
#${PROBELOAD}/probenotes.py >> ${LOG}
#if [ $? -ne 0 ]
#then
#    echo 'probenotes.py failed' >> ${LOG}
#    exit 1
#fi

#
# remove probe aliases
#
#cd ${PROJECTDIR}/removealias
#echo "\n`date`" >> ${LOG}
#echo "Remove Probe Aliases" >> ${LOG}
#./tr10976.py >> ${LOG}
#if [ $? -ne 0 ]
#then
#    echo 'remove probe alias failed' >> ${LOG}
#    exit 1
#fi
#

#
# Copy fullsize and thumbnail images to Pixel DB.
#
echo "\n`date`" >> ${LOG}
echo "Copy fullsize and thumbnail images to Pixel DB" >> ${LOG}
${GXDIMAGELOAD}/tr10976pixload.sh >> ${LOG}
if [ $? -ne 0 ]
then
    echo 'tr10976pixload.sh failed' >> ${LOG}
    exit 1
fi
#exit 0

#
# Create fullsize image input files for the GXD image load.
#
echo "\n`date`" >> ${LOG}
echo "Create fullsize image input files for the GXD image load" >> ${LOG}
${GXDIMAGELOAD}/tr10976preFullsize.py >> ${LOG}
if [ $? -ne 0 ]
then
    echo 'tr10976preFullsize.py failed' >> ${LOG}
    exit 1
fi
echo "\n`date`" >> ${LOG}
#exit 0

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
#exit 0

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
#exit 0

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
#exit 0

cd `dirname $0`

#
# Create thumbnail image input files for the GXD image load.
#
echo "\n`date`" >> ${LOG}
echo "Create thumbnail image input files for the GXD image load" >> ${LOG}
${GXDIMAGELOAD}/tr10976preThumbnail.py >> ${LOG}
if [ $? -ne 0 ]
then
    echo 'tr10976prepThumbnail.py failed' >> ${LOG}
    exit 1
fi
#exit 0

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
#exit 0

#
# Create the input files for the in situ load.
#
echo "\n`date`" >> ${LOG}
echo "Create the input files for the in situ load" >> ${LOG}
${ASSAYLOAD}/tr10976insitu.py >> ${LOG}
if [ $? -ne 0 ]
then
    echo 'tr10976insitu.py failed' >> ${LOG}
    exit 1
fi
#exit 0

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
#exit 0

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
#exit 0

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

#
# run reports
#
echo "\n`date`" >> ${LOG}
echo "Running some reports..." >> ${LOG}
${GXDLOAD}/tr10976/qcnightly_reports.csh >> ${LOG}
if [ $? -ne 0 ]
then
    echo 'qcnightly_reports.csh failed' >> ${LOG}
    exit 1
fi

date >> ${LOG}
exit 0
