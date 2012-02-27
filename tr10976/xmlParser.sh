#!/bin/sh

cd `dirname $0`

. ./tr10976.config

if [ $# -eq 0 ]
then
    FILELIST=`cd ${XML_DIR}; ls *.xml`
else
    FILELIST=$*
fi

xmlParser.py ${FILELIST}
