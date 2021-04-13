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
date | tee -a ${LOG}
echo 'Create fullsize image input files for the GXD image load' | tee -a ${LOG}
${PYTHON} ${GXDLOAD}/tr13240/impclaczPreFullSize.py | tee -a ${LOG}
if [ $? -ne 0 ]
then
    echo 'impclaczPreFullSize.py failed' | tee -a ${LOG}
    exit 1
fi

#
# Load fullsize images
#
date | tee -a ${LOG}
echo 'Load fullsize images' | tee -a ${LOG}
${PYTHON} ${GXDIMAGELOAD}/gxdimageload.py | tee -a ${LOG}
if [ $? -ne 0 ]
then
    echo 'gxdimageload.py failed' | tee -a ${LOG}
    exit 1
fi

#
# process copyright
#
cd ${IMAGELOADDATADIR}
date | tee -a ${LOG}
echo 'process copyright' | tee -a ${LOG}
${PYTHON} ${NOTELOAD}/mginoteload.py -S${MGD_DBSERVER} -D${MGD_DBNAME} -U${MGD_DBUSER} -P${MGD_DBPASSWORDFILE} -I${COPYRIGHTFILE} -M${NOTELOADMODE} -O${IMAGE_OBJECTTYPE} -T\"${COPYRIGHTNOTETYPE}\" | tee -a ${LOG}
if [ $? -ne 0 ]
then
    echo '${NOTELOAD}/mginoteload.py copyright failed' | tee -a ${LOG}
    exit 1
fi
date | tee -a ${LOG}

exit 0
