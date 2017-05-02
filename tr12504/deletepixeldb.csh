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
 
#
# grep thru log and then delete images from /data/pixeldb
#
foreach i (`cat deleteimages.jpg`)
echo $i
ls -l /data/pixeldb/$i.jpg
end

date | tee -a $LOG

