#!/bin/csh

#
# Template
#


if ( ${?MGICONFIG} == 0 ) then
        setenv MGICONFIG /usr/local/mgi/live/mgiconfig
endif

source ${MGICONFIG}/master.config.csh

cd `dirname $0`

setenv LOG $0.log
rm -rf $LOG
touch $LOG
 
date | tee -a $LOG
 
foreach i (`cat deletepixeldb.jpg`)
ls -l /data/pixeldb/$i.jpg
#cp /data/pixeldb/$i.jpg pixeldb
rm -rf /data/pixeldb/$i
end

date | tee -a $LOG

