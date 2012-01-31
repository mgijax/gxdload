#!/bin/sh

cd `dirname $0`

. ./tr8270.config

if [ $# -eq 0 ]
then
    FILELIST=`cd ${XML_DIR}; ls *.xml`
else
    FILELIST=$*
fi

xmlParser.py ${FILELIST}
