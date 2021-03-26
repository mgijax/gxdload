#!/bin/sh
#
# TR 12504
#
# Wrapper script for loading
#
echo "cd"
cd `dirname $0`
echo "source config"

. ./tr13240.config
echo ${IMAGELOADDATADIR}
LOG=${IMAGELOADDATADIR}/$0.log
echo ${LOG}
rm -rf ${LOG}
touch ${LOG}
 
#
# Create fullsize image input files for the GXD image load.
#
date >> ${LOG}
echo 'Create fullsize image input files for the GXD image load' >> ${LOG}
${PYTHON} ${GXDLOAD}/tr13240/impclaczPreFullSize.py >> ${LOG}
if [ $? -ne 0 ]
then
    echo 'impclaczPreFullSize.py failed' >> ${LOG}
    exit 1
fi

#
# Load fullsize images
#
date >> ${LOG}
echo 'Load fullsize images' >> ${LOG}
${PYTHON} ${GXDIMAGELOAD}/gxdimageload.py >> ${LOG}
if [ $? -ne 0 ]
then
    echo 'gxdimageload.py failed' >> ${LOG}
    exit 1
fi

#
# process copyright
#
cd ${IMAGELOADDATADIR}
date >> ${LOG}
echo 'process copyright' >> ${LOG}
${PYTHON} ${NOTELOAD}/mginoteload.py -S${MGD_DBSERVER} -D${MGD_DBNAME} -U${MGD_DBUSER} -P${MGD_DBPASSWORDFILE} -I${COPYRIGHTFILE} -M${NOTELOADMODE} -O${IMAGE_OBJECTTYPE} -T\"${COPYRIGHTNOTETYPE}\" >> ${LOG}
if [ $? -ne 0 ]
then
    echo '${NOTELOAD}/mginoteload.py copyright failed' >> ${LOG}
    exit 1
fi
date >> ${LOG}

exit 0
