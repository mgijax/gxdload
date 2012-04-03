#!/bin/sh

cd `dirname $0`

. ./tr10976.config

if [ $# -eq 0 ]
then
    FILELIST=`cd ${XML_DIR}; ls *.xml`
else
    FILELIST=$*
fi

#FILELIST=MH00002867.xml

xmlParser.py ${FILELIST}
