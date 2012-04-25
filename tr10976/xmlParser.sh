#!/bin/sh

cd `dirname $0`

. ./tr10976.config

if [ $# -eq 0 ]
then
    FILELIST=`cd ${XML_DIR}; ls *.xml`
else
    FILELIST=$*
fi

#FILELIST=MY00000075.xml

xmlParser.py ${FILELIST}
